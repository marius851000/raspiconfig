pushd private/
rm scrogne.key scrogne.crt
nebula-cert sign -ca-crt latest_ca.crt -ca-key latest_ca.key -name "scrogne" -ip "10.100.0.1/24"
echo scrogne key made
rm zana.key zana.crt
nebula-cert sign -ca-crt latest_ca.crt -ca-key latest_ca.key  -name "zana" -ip "10.100.0.2/24"
echo zana key made
rm marella.key marella.crt
nebula-cert sign -ca-crt latest_ca.crt -ca-key latest_ca.key  -name "marella" -ip "10.100.0.3/24"
echo marella key made
popd
