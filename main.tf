provider "aws" {}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "${var.az}"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "default" {
  name        = "coreos_sg"
  description = "CoreOS Cluster Security Group"
  vpc_id      = "${aws_vpc.default.id}"
}

resource "aws_security_group_rule" "allow_out_all" {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.default.id}"
}

# SSH access from anywhere
resource "aws_security_group_rule" "allow_ssh" {
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_4001" {
    type            = "ingress"
    from_port       = 4001
    to_port         = 4001
    protocol        = "tcp"

    security_group_id = "${aws_security_group.default.id}"
    source_security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_5000" {
    type            = "ingress"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"

    security_group_id = "${aws_security_group.default.id}"
    source_security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_2379" {
    type            = "ingress"
    from_port       = 2379
    to_port         = 2379
    protocol        = "tcp"

    security_group_id = "${aws_security_group.default.id}"
    source_security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_2380" {
    type            = "ingress"
    from_port       = 2380
    to_port         = 2380
    protocol        = "tcp"

    security_group_id = "${aws_security_group.default.id}"
    source_security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_ping" {
    type            = "ingress"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"

    security_group_id = "${aws_security_group.default.id}"
    source_security_group_id = "${aws_security_group.default.id}"
}


resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "etcd" {
  connection {
    user = "core"
  }

  tags {
    Name = "Cluster Coordinator"
    "Cluster::Name" = "${var.name}"
    "Cluster::Role" = "etcd"
  }

  instance_type = "${var.etcd_instance_type}"
  availability_zone = "${var.az}"

  ami = "${lookup(var.aws_amis, var.region)}"

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  subnet_id = "${aws_subnet.default.id}"
  private_ip = "10.0.0.128"

  user_data = "${file("etcd.yaml")}"
}

resource "aws_instance" "worker" {
  connection {
    user = "core"
  }

  tags {
    Name = "Worker"
    "Cluster::Name" = "${var.name}"
    "Cluster::Role" = "worker"
  }

  count = "${var.workers}"
  instance_type = "${var.worker_instance_type}"

  ami = "${lookup(var.aws_amis, var.region)}"
  availability_zone = "${var.az}"

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  subnet_id = "${aws_subnet.default.id}"

  ephemeral_block_device {
    device_name = "/dev/xvdd"
    virtual_name = "ephemeral0"
  }

  user_data = "${file("worker.yaml")}"
}
