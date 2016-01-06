# gitlab-ci-provision

This provisions a machine on AWS and starts a gitlab runner on it.


## Dependencies

```bash
# install ansible https://github.com/ansible/ansible
pip install ansible
```

## Provisioning



```
mkdir -p ssh
ssh-keygen -t rsa -b 4096 -G ssh/id_rsa

cd terraform

# if you dont save your credentials, it will prompt for them
echo 'access_key = "..."
secret_key = "..."' > terraform.tfvars

terraform apply
cd ..

cd ansible
ansible-playbook --inventory-file=inventory.sh -e "registration_token=..." playbook.yml

# or if you want to use the playbook on an existing host
ansible-playbook -i <ip>, -e "registration_token=..." playbook.yml
```
