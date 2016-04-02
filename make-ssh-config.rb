#!/usr/bin/env ruby

require 'erb'

template   = 'ssh-config.erb'
etcd_ip    = `terraform output etcd.ip`.chomp
worker_ips = `terraform output worker.ips`.chomp.split(',')

base_path = File.expand_path File.dirname(__FILE__)
erb = ERB.new(File.read(template))
erb.filename = template

names_with_ips = [["etcd0", etcd_ip]] +
	worker_ips.each_with_index.map{|ip, idx| ["worker#{idx}", ip]}

File.open('ssh-config', 'w') do |f|
	f.write erb.result
end
