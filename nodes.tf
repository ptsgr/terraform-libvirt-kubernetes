data "template_file" "node_setting" {
  template = "${file("${path.module}/network_config.tpl")}"
  count    = "${var.node_count}"
  vars {
    addr = "${var.master_count+count.index}"
  }
}

resource "libvirt_volume" "node" {
  count = "${var.node_count}"
  name  = "node-${count.index}"
  pool = "k8s-pool"
  base_volume_id = "${libvirt_volume.base.id}"
  format         = "qcow2"
  size           = "${var.node_disk_size}"
}

resource "libvirt_cloudinit_disk" "nodeinit" {
  count = "${var.node_count}"
  name = "nodeinit-${count.index}"
  pool = "k8s-pool"
  user_data = "${data.template_file.user_data.rendered}"
  network_config = "${element(data.template_file.node_setting.*.rendered, count.index)}"
}

resource "libvirt_domain" "k8s-node" {
  count = "${var.node_count}"
  name = "k8s-node-${count.index}"
  memory = "${var.node_memory}"
  vcpu  = "${var.node_cpus}"
  autostart = "true"

  network_interface {
      bridge = "${var.bridge}"
      addresses = ["192.168.3.${var.master_count+count.index}"]
  }

  disk {
      volume_id = "${element(libvirt_volume.node.*.id, count.index)}"
  }

  cloudinit = "${element(libvirt_cloudinit_disk.nodeinit.*.id, count.index)}"

  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = true
  }
}