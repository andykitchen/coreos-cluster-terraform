output "etcd.ip" {
  value = "${aws_instance.etcd.public_ip}"
}

output "worker.ips" {
  value = "${join(",", aws_instance.worker.*.public_ip)}"
}
