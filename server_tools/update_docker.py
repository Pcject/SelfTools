import os
import json
import subprocess

def run(cmd):
    subprocess.call(cmd, shell=True)
    

old_dir = '/var/lib/docker/'
target_dir = '/opt/docker/'
run('mkdir -p {}'.format(target_dir))
run('service docker stop')
run('rsync -a {} {}'.format(old_dir, target_dir))
run('mv {} /var/lib/docker.bak/'.format(old_dir))
run('ln -s {} {}'.format(target_dir, old_dir))
run('service docker start')
run("docker info | grep 'Root Dir'")

daemon_json_path='/etc/docker/daemon.json'
try:
    with open(daemon_json_path, 'r') as f:
        content = json.load(f)
except Exception:
    content = {}

content['data-root'] = target_dir
with open(daemon_json_path, 'w') as f:
    json.dump(content, f, indent=4)
    