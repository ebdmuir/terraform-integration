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
      - npm install -g @terraform-visual/cli
  build:
    commands:
      - terraform init >/dev/null
      - terraform plan -out tfplan
      - terraform plan -destroy -out tfplan.destroy >/dev/null
artifacts:
  files:
    - '**/*'
  name: plan
  discard-paths: no