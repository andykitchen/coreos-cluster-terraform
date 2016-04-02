CoreOS Cluster
==============

Terraform scripts for spinning up a cluster of Amazon AWS EC2 instances running [CoreOS](https://coreos.com/) on amazon with an [etcd](https://coreos.com/etcd/) controller and [fleet](https://coreos.com/fleet/) cluster membership.

#### Setup

1. You'll neet to install the latest vesion of [terraform](https://www.terraform.io/).

2. You will also need to have your amazon credientials stored in environment variables:

	```shell
	$ export AWS_ACCESS_KEY_ID=<key_id>
	$ export AWS_SECRET_ACCESS_KEY=<key_secret>
	```

3. You'll need to generate a ssh keypair to connect to the cluster with:

	```shell
	$ cd coreos-cluster
	$ ssh-keygen -f id_rsa.terraform
	```

4. Create a `terraform.tfvars` with configuration for the cluster name, region, etc.

	```shell
	$ cp terraform.tfvars.example terraform.tfvars
	$ vim terraform.tfvars
	```

	If you want GPU instances set the `worker_instance_type` variable to something like `g2.2xlarge`.

### Usage

To start the cluster run:

```shell
$ cd coreos-cluster
$ terraform apply --var "workers=3"
```

If you want to scale the cluster up or down while it is running, simply call terraform apply again with a different numeric value for the variable `workers`. (You can also put the number of workers in `terraform.tfvars`)

To connect to machines in the cluster, use the provided script to generate an `ssh-config`:

```shell
$ ruby make-ssh-config.rb
$ ssh -F ssh-config worker0
```

N.B. `terraform` will need to be on you path

The machines should be linked in a fleet cluster and when it is scaled up or down new nodes should automatically leave and join the cluster. To view a list of active machines in the cluster:

```shell
$ ssh -F ssh-config worker0
$ fleetctl list-machines
```

The output should be a list with an entry for each worker machine in the cluster.
