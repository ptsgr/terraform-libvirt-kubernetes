resource "libvirt_volume" "base" {
  name = "base"
  pool = "k8s-pool"
  source = "/kvm/images/base.qcow2"
  format = "qcow2"
}