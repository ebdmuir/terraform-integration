version: 0.2

phases:
  pre_build:
    commands:
      - apt install -y zip unzip wget git >/dev/null
      - wget -q https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
      - unzip terraform_0.13.5_linux_amd64.zip > /dev/null
      - chmod +x terraform
      - mv terraform /bin/
      - rm terraform_0.13.5_linux_amd64.zip
      - git config --global credential.helper '!aws codecommit credential-helper $@'
      - git config --global credential.UseHttpPath true
  build:
    commands:
      - git clone $REPO repo
      - mv tfplan repo/
      - cd repo
      - terraform init
      - aws ec2 authorize-security-group-ingress --protocol tcp --port 14866 --cidr `curl -s ifconfig.co`/32 --group-id ${secgroup} >/dev/null
      - terraform apply "tfplan"
      - aws ec2 revoke-security-group-ingress --protocol tcp --port 14866 --cidr `curl -s ifconfig.co`/32 --group-id ${secgroup} >/dev/null