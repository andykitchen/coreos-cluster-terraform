variable "name" {
  description = "name of cluster tagged on compute instances"
}

variable "public_key_path" {
  default = "id_rsa.terraform.pub"
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "region" {
  description = "AWS region to launch servers."
  default = "ap-southeast-2"
}

variable "az" {
  description = "AWS Availability-Zone to launch servers."
  default = "ap-southeast-2b"
}

variable "workers" {
  description = "number of workers"
}

variable "etcd_instance_type" {
  description = "etcd coordinator instance type"
  default = "t2.small"  
}

variable "worker_instance_type" {
  description = "worker instance type"
  default = "m3.medium"
}

# CoreOS stable (899.13.0)
variable "aws_amis" {
  default = {
    eu-central-1 = "ami-cb8d6ba4"
    ap-northeast-1 = "ami-962c39f8"
    us-gov-west-1 = "ami-0f3c806e"
    ap-northeast-2 = "ami-03a76e6d"
    sa-east-1 = "ami-a49915c8"
    ap-southeast-2 = "ami-74dcfc17"
    ap-southeast-1 = "ami-3b8f4558"
    us-east-1 = "ami-2c393546"
    us-west-2 = "ami-4f4ba32f"
    us-west-1 = "ami-52e69432"
    eu-west-1 = "ami-c346c2b0"
  }
}
