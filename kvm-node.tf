provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "kvmdisk" {
  name = "kvmdisk"
  pool = "k8s-pool"
  source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1901.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
}

resource "libvirt_cloudinit_disk" "centos" {
  name = "centos"
  pool = "k8s-pool"
  user_data = "${data.template_file.user_data.rendered}"
}

resource "libvirt_domain" "kvm-node" {
  name = "kvm-node"
  memory = "4096"
  vcpu  = 2
  autostart = "true"

  network_interface {
      network_name = "default"
  }

    disk {
      volume_id = "${libvirt_volume.kvmdisk.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.centos.id}"

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}
