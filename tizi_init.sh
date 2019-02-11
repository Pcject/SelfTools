sudo curl -fsSL get.docker.com -o /opt/get-docker.sh
sudo sh /opt/get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER
sudo service docker restart
sudo apt-get install -y docker-compose
filename="/opt/shadowsocks.yaml"
sudo touch $filename
sudo chown -R $USER $filename
cat>"${filename}"<<EOF
version: '2'
services:
  shadowsocks:
    image: mritd/shadowsocks
    container_name: shadowsocks
    restart: always
    ports:
      - 6443:6443
      - 6500:6500/udp
    environment:
      SS_CONFIG: "-s 0.0.0.0 -p 6443 -m chacha20 -k password --fast-open"
      KCP_MODULE: "kcpserver"
      KCP_CONFIG: "-t 127.0.0.1:6443 -l :6500 -mode fast2"
      KCP_FLAG: "true"
EOF
sudo docker-compose -f $filename up -d