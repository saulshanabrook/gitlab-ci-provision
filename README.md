# gitlab-ci-provision

This provisions a machine on AWS and starts a gitlab runner on it.


## Dependencies

```bash
# install ansible https://github.com/ansible/ansible
pip install ansible
```

## Provisioning

This requires two machines, a `master` and a `slave`. I have it set up now
so that `master` is running ubuntu and `slave` is running coreos. The slave
needs to be running a system that has overlayfs available, so that docker
in docker can use it to save disk space.

```bash
# Add the IP addresses/host names for your server 
echo '
[master]
some-server.www/ip address
[slave]
some-server2.www/ip address ansible_ssh_user=core ansible_python_interpreter="PATH=/home/core/bin:$PATH python"
' > hosts

# Generate and save a runner token
echo "
---
gitlab_ci_runner_token: $(http POST https://gitlab.com/ci/api/v1/runners/register.json token=d48eca9acbbf3b54cdf4c77be52fef -b | jq .token)
" > group_vars/master

# generate certs so that the master can talk to the slave's docker daemon
docker run --rm -v $PWD/certs:/app -e IPS="<slave ip>" saulshanabrook/openssl-docker-daemon

ansible-playbook playbook.yml
```

To update the docker image, change the `docker_image` variable in `./group_vars/all`
and run `ansible-playbook playbook.yml -l master`

## Debugging

### Master
Gitlab CI runner logs:

```bash
ansible master -m command -a 'docker logs --tail 50 gitlab-ci-multi-runner'
```

Gitlab CI config:

```bash
ansible master -m command -a 'cat /etc/gitlab-ci-ansible/config.toml'
# or
ansible master -m command -a 'docker exec -it gitlab-ci-multi-runner cat /etc/gitlab-runner/config.toml'
```

### Slave
Docker daemon logs

```bash
ansible slave -m command -a 'journalctl -u docker'
```

Specific Run logs

```bash
# find the name or id of the run container
ansible slave -m command -a 'docker ps'

# then get it's logs
ansible slave -m command -a 'docker logs runner-27bbf33a-project-532380-concurrent-0-build'
```

Force cleanup of docker containers and volume (runs every hour):

```bash
ansible slave -m shell -a 'sudo systemctl start docker-cleanup.service; journalctl -u docker-cleanup.service'
```

#### Docker in Docker
logs:

```bash
ansible slave -m command -a 'docker logs --tail 50 dind'
```

To see proccesses running in:

```bash
ansible slave -m command -a 'docker exec dind docker ps'
```

restart:

```bash
ansible slave -m command -a 'docker restart dind'
```

Force cleanup of docker containers and volumes (runs every hours):

```bash
ansible slave -m shell -a 'sudo systemctl start docker-cleanup-dind.service; journalctl -u docker-cleanup-dind.service'
```

## Background
This is an attempt for a reliable, fast, and flexible Gitlab CI setup. It is
designed for applications running `docker-compose` commands for their tests.

It run's the `gitlab-ci-multi-runner` on one machine (`master`). Then it starts
a secure docker daemon on `slave`. It tells the runs on `master` to use the
`slave` as the docker host. These docker machines themselves run
docker, so that each test run get's it's own isolated docker daemon and
doesn't have to worry about cleanup.

We use a docker registyr on `slave` as a cache for docker images, that each
test run will use by default.


## Troubleshooting

If you get `ERROR: Build failed with: API error (500): Could not find container for entity id ece5da9419c9c23b5d0cdacf3e065066bd1b672c861a305b1c1eeb4844fcb024`
on a build run ([will be fixed in Docker 1.10](https://github.com/docker/docker/issues/17691)) 

```
ansible slave -m command -a 'sudo rm -f /var/lib/docker/linkgraph.db'
ansible slave -m command -a 'sudo rm -rf /var/lib/docker/containers/'
ansible slave -m command -a 'sudo systemctl restart docker'
```
