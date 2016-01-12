# gitlab-ci-provision

This provisions a machine on AWS and starts a gitlab runner on it.


## Dependencies

```bash
# install ansible https://github.com/ansible/ansible
pip install ansible
```

## Provisioning


```bash
# Add the IP addresses/host names for your server 
echo '
[master]
some-server.www/ip address
[slave]
some-server2.www/ip address
' > hosts

# Generate and save a runner token
echo "
---
gitlab_ci_runner_token: $(http POST https://gitlab.com/ci/api/v1/runners/register.json token=d48eca9acbbf3b54cdf4c77be52fef -b | jq .token)
" > group_vars/master

# generate a key pair for the master to talk to the slave
ssh-keygen -t rsa -b 4096 -N "" -f ssh/gitlab-ci

ansible-playbook playbook.yml
```


## Debugging

Gitlab CI runner logs:

```bash
ansible master -m command -a 'docker logs gitlab-ci-multi-runner'
```

Gitlab CI config:

```bash
ansible master -m command -a 'docker exec -it gitlab-ci-multi-runner cat /etc/gitlab-runner/config.toml'
```



Docker registry logs:

```bash
ansible slave -m command -a 'docker logs registry-proxy'
```


## Background
This is an attempt for a reliable, fast, and flexible Gitlab CI setup. It is
designed for applications running `docker-compose` commands for their tests.

It run's the `gitlab-ci-multi-runner` on one machine (`master`). That uses
ssh to run docker commands on `slave`. These docker machines themselves run
docker, so that each test run get's it's own isolated docker daemon and
doesn't have to worry about cleanup.

We use a docker registyr on `slave` as a cache for docker images, that each
test run will use by default.
