#!/usr/bin/env bash
set -e

command_exists() {
	command -v "$@" >/dev/null 2>&1
}
data_disk="/dev/vdb"
user="$(id -un 2>/dev/null || true)"
sh_c='bash -c'
if [ "$user" != 'root' ]; then
	if command_exists sudo; then
		sh_c='sudo -E bash -c'
	elif command_exists su; then
		sh_c='su -c'
	fi
fi

install_docker() {
	sh_c "curl -sSL https://mirror.azure.cn/repo/install-docker-engine.sh | sh -s -- --mirror Aliyun"
	sh_c "systemctl enable docker"
}
install_docker_compose() {
	sh_c "curl -L http://mirrors.aliyun.com/docker-toolbox/linux/compose/1.21.2/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose"
	sh_c "chmod +x /usr/local/bin/docker-compose"
}

doker_login() {
	sh_c "'docker login --username=docker_gllue_release@gllue --password=gllue123!@# registry.cn-hangzhou.aliyuncs.com'"
}

update_ssh_port() {
	sh_c "sed -i 's/#Port 22/Port 9998/g' /etc/ssh/sshd_config"
	sh_c "service sshd restart"
}

update_docker_comfig() {
sh_c "mkdir -p /etc/docker"
sh_c "touch /etc/docker/daemon.json"
sh_c "cat > /etc/docker/daemon.json <<EOF
>{
> "data-root": "/opt/docker",
> "registry-mirrors": [
>    "https://registry.docker-cn.com",
>    "https://docker.mirrors.ustc.edu.cn"
	>]
>}
> EOF"
}

install_zsh() {
	sh_c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}
inti_data_disk() {
	sh_c "ssm create -n lv_opt -p data_vg --fstype xfs /opt  /dev/vdb"
	sh_c "echo '/dev/mapper/data_vg-lv_opt  /opt               xfs     defaults        1 2' >> /etc/fatab"
	sh_c "mount -a"
}
init_monitor() {
	sh_c "mount --make-rshared /"
	sh_c "docker rm -f node-exporter"
	sh_c 'docker run -d --restart=unless-stopped  \
  --net="host" \
  --pid="host" \
  --name node-exporter \
  --log-opt max-size=100m  \
  --log-opt max-file=10 \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter:v0.17.0 \
  --collector.filesystem.ignored-mount-points="^/(dev|proc|sys|etc|dev|var/lib/docker|opt/docker)($|/)" \
  --collector.filesystem.ignored-fs-types="^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$" \
  --path.rootfs /host'
	sh_c 'docker rm -f cadvisor'
	sh_c 'docker run -d --restart=unless-stopped \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --name=cadvisor \
  --detach=true \
  --log-opt max-size=100m  \
  --log-opt max-file=10 \
  --publish=9101:8080 \
  google/cadvisor:v0.32.0'
}

install_saltstack() {
	sh_c "wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -"
	sh_c "echo 'deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main' > /etc/apt/sources.list.d/saltstack.list"
	sh_c "apt install -y salt-minion"
	sh_c "sed -i '/^#master:/a master: 42.121.31.17' /etc/salt/minion"
	sh_c "sed -i '/^#hash_type:/a hash_type: sha256' /etc/salt/minion"
	sh_c "sed -i '/^#id:/a id: $hostname' /etc/salt/minion"
	sh_c "service salt-minion restart"
}

do_install() {
	apt install curl system-storage-manager -y
	[ -e $data_disk ] && inti_data_disk
	install_docker
	install_docker_compose
	init_monitor
	install_saltstack
	install_zsh
	doker_login
}

do_install
