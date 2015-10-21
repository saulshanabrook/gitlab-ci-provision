# gitlab-ci-provision

This provisions a machine on AWS and starts a gitlab runner on it.


## Dependencies

```
# install terraform inventory script, so that we can access machines created
# in terraform easily in ansible https://github.com/adammck/terraform-inventory
brew install https://raw.github.com/adammck/terraform-inventory/master/homebrew/terraform-inventory.rb

# install terraform https://www.terraform.io/downloads.html
brew install terraform

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

```
