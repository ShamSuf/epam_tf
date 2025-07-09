# Terraform AWS Web Server Deployment
This project uses terraform to deploy a simple web server on AWS. 
It provisions a VPC, NAT Gateway, Internet Gateway, Subnets, SecurityGroups, an EC2 (installs a basic web server using userdata), ApplicatoinLoadBalancer.

## 📁 Project Structure
├── provider.tf         # account info  \
├── main.tf             # lb and ec2    \
├── vpc.tf              # vpc, nat, sg  \
├── terraform.tfstate                   \
├── terraform.tfstate.backup            \
├── terraform.lock.hcl                  \
└── README.md          # Project documentation \
