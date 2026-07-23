use std::{
    collections::HashMap,
    net::{Ipv4Addr, SocketAddrV4},
    str::FromStr,
    sync::Arc,
    time::Duration,
};

use async_trait::async_trait;
use clap::Parser;
use hickory_server::{
    Server,
    net::runtime::Time,
    proto::{
        op::{Header, HeaderCounts, Metadata, ResponseCode},
        rr::{DNSClass, LowerName, Name, RData, Record, RecordType, rdata::A},
    },
    server::{Request, RequestHandler, ResponseHandler, ResponseInfo},
    zone_handler::MessageResponseBuilder,
};
use tokio::{net::UdpSocket, sync::RwLock, time::interval};

mod ceph;

#[derive(Debug, Clone, Copy)]
struct CephIpState {
    ip: Ipv4Addr,
    #[allow(unused)]
    updated: std::time::Instant,
}

impl CephIpState {
    fn same_ip(&self, other: &CephIpState) -> bool {
        self.ip == other.ip
    }
}

struct Handler {
    ceph_ip: Arc<RwLock<Option<CephIpState>>>,
}

#[async_trait]
impl RequestHandler for Handler {
    async fn handle_request<R: ResponseHandler, T: Time>(
        &self,
        request: &Request,
        mut response_handle: R,
    ) -> ResponseInfo {
        let mut answers = Vec::new();

        if let Some(ceph_ip) = (*self.ceph_ip.read().await).as_ref() {
            for query in request.queries.queries() {
                if query.query_class() == DNSClass::IN {
                    if query.name() == &LowerName::new(&Name::from_str("ceph-mgr.local.").unwrap())
                    {
                        if query.query_type() == RecordType::A {
                            answers.push(Record::from_rdata(
                                query.name().to_lowercase(),
                                40,
                                RData::A(A(ceph_ip.ip)),
                            ));
                        }
                    }
                }
            }
        }

        let response = MessageResponseBuilder::from_message_request(&request).build(
            Metadata::response_from_request(&request.metadata),
            &answers,
            [],
            [],
            [],
        );

        response_handle
            .send_response(response)
            .await
            .unwrap_or_else(|e| {
                eprintln!("failed to send DNS response: {e}");
                let mut metadata = Metadata::response_from_request(&request.metadata);
                metadata.response_code = ResponseCode::ServFail;
                ResponseInfo::from(Header {
                    metadata,
                    counts: HeaderCounts::default(),
                })
            })
    }
}

async fn ceph_ip_updater(
    ceph_ip: Arc<RwLock<Option<CephIpState>>>,
    mapping: HashMap<String, Ipv4Addr>,
) {
    let mut interval = interval(Duration::from_secs(30));
    loop {
        interval.tick().await;
        match ceph::get_active_mgr_host().await {
            Ok(host) => {
                if let Some(ip) = mapping.get(&host) {
                    let new_state = CephIpState {
                        ip: *ip,
                        updated: std::time::Instant::now(),
                    };
                    let mut guard = ceph_ip.write().await;
                    let log = guard
                        .as_ref()
                        .map_or(true, |prev| !prev.same_ip(&new_state));
                    *guard = Some(new_state);
                    if log {
                        println!("ceph-mgr IP changed to: {ip}");
                    }
                } else {
                    eprintln!(
                        "ceph-mgr IP seems to come from \"{host}\", not present in the mapping"
                    );
                }
            }
            Err(e) => {
                eprintln!("ceph-mgr IP fetch failed: {e}");
            }
        }
    }
}

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// UDP Port number to listen on (always listen on 127.0.0.1)
    #[arg(short, long)]
    port: u16,
    #[arg(long, num_args = 2)]
    mapping: Vec<String>,
}

#[tokio::main]
async fn main() {
    let args = Args::parse();
    let mut mapping = HashMap::new();
    for m in args.mapping.as_chunks::<2>().0 {
        mapping.insert(
            m[0].clone(),
            Ipv4Addr::from_str(&m[1]).expect("Couldn’t parse IP from mapping argument"),
        );
    }

    let ceph_ip_state = Arc::new(RwLock::new(None));
    let ceph_ip_state_for_task = ceph_ip_state.clone();
    tokio::spawn(async move {
        ceph_ip_updater(ceph_ip_state_for_task, mapping).await;
    });

    let mut server = Server::new(Handler {
        ceph_ip: ceph_ip_state.clone(),
    });

    let udp_socket = UdpSocket::bind(SocketAddrV4::new(Ipv4Addr::new(127, 0, 0, 1), args.port))
        .await
        .unwrap();
    server.register_socket(udp_socket);

    println!("starting server...");

    server.block_until_done().await.unwrap();
}
