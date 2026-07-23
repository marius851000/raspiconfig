use anyhow::{Context, bail};
use serde::Deserialize;
use tokio::process::Command;

#[derive(Deserialize)]
struct CephMgrStat {
    active_name: String,
    #[serde(rename = "available")]
    available: bool,
    #[serde(default)]
    #[allow(unused)]
    num_standby: Option<usize>,
    #[serde(default)]
    #[allow(unused)]
    epoch: Option<usize>,
}

/// Query the active Ceph mgr, returning its name
pub async fn get_active_mgr_host() -> anyhow::Result<String> {
    // Run ceph mgr stat
    let output = Command::new("ceph")
        .args(["mgr", "stat", "-f", "json-pretty"])
        .output()
        .await
        .context("failed to execute 'ceph mgr stat'")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        bail!("ceph mgr stat failed: {}", stderr.trim());
    }

    let stat: CephMgrStat =
        serde_json::from_slice(&output.stdout).context("failed to parse ceph mgr stat JSON")?;

    if !stat.available {
        bail!("Ceph mgr is not available");
    }

    return Ok(stat.active_name.clone());
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn parse_ceph_stat() {
        let json = r#"{
            "epoch": 65,
            "available": true,
            "active_name": "zana",
            "num_standby": 1
        }"#;
        let stat: CephMgrStat = serde_json::from_str(json).unwrap();
        assert_eq!(stat.active_name, "zana");
        assert!(stat.available);
        assert_eq!(stat.epoch, Some(65));
    }

    #[test]
    fn parse_inactive_stat() {
        let json = r#"{
            "epoch": 64,
            "available": false,
            "active_name": "old-mgr",
            "num_standby": 2
        }"#;
        let stat: CephMgrStat = serde_json::from_str(json).unwrap();
        assert!(!stat.available);
    }
}
