#!/bin/bash
#plase makesure using uniq hostname between infrastructures

wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update && sudo apt-get install telegraf
sudo mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf-default

sudo cat <<EOF | sudo tee /etc/telegraf/telegraf.conf
[global_tags]
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
   logfile = "/var/log/telegraf/telegraf.log"
  omit_hostname = false
[[outputs.influxdb]]
   urls = ["http://influxdb.ms-biznetgio.net:8086"]
   database = "dipay_perf_report"
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
[[inputs.diskio]]
[[inputs.kernel]]
[[inputs.mem]]
[[inputs.processes]]
[[inputs.swap]]
[[inputs.system]]
[[inputs.net]]
[[inputs.net_response]]
   protocol = "tcp"
   address = "localhost:80"
[[inputs.netstat]]
EOF

sudo systemctl restart telegraf; sudo systemctl enable telegraf
