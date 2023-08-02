
# This repo contains a sample code which creates 3 Azure VMs in same networks with [Terraform](https://www.terraform.io/)

## Prerequisites 
- Install [Terraform](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
- Install the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
- Generate SSH keys 
```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
 
## The usage is pretty simple

- clone the repo 
```
git clone https://github.com/chavo1/terraform-azure-test-vms.git
cd terraform-azure-test-vms
```
- rename the example.terraform.tfvars
```
rm example.terraform.tfvars terraform.tfvars
```
- change it on your needs - "terraform.tfvars" will overwrite the default variables 
- initialize terraform 
```
terraform init
terraform plan
terraform apply
```

#### Once created you will find the public IPs and you can login to the machines
```
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

public_ip_addresses = [
  "52.188.108.0",
  "52.255.148.186",
  "52.188.127.204",
]

```
#### Connect to the VMs
```
ssh azureuser@52.188.108.0
```
## If you need to change the OS just change the following:
- First image is Ubuntu 20 the rest are RedHat
```
    content {
      publisher = each.value == "vm1" ? "Canonical" : "RedHat"
      offer     = each.value == "vm1" ? "0001-com-ubuntu-server-focal" : "RHEL"
      sku       = each.value == "vm1" ? "20_04-lts-gen2" : "83-gen2"
      version   = each.value == "vm1" ? "20.04.202209200" : "latest"
    }
```

### Check the OS releases

```
azureuser@chavoVM-vm1:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 20.04.5 LTS
Release:        20.04
Codename:       focal

[azureuser@chavoVM-vm2 ~]$ cat /etc/redhat-release
Red Hat Enterprise Linux release 8.3 (Ootpa)

[azureuser@chavoVM-vm3 ~]$ cat /etc/redhat-release
Red Hat Enterprise Linux release 8.3 (Ootpa)

```
### Don't forget to destroy the infra

```
terraform destroy
```
