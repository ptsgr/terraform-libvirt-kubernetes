data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
}

variable "bridge" {
  description = "Name of the libvirt netowkr interface to use"
  type        = "string"
  default     = "br0"
}

variable "master_count" {
  description = "Number of masters"
  type        = "string"
  default     = "3"
}

variable "master_cpus" {
  description = "Number of CPUs to assign to the masters"
  type        = "string"
  default     = "2"
}

variable "master_memory" {
  description = "Amount of memory in MiB to assign to the masters"
  type        = "string"
  default     = "4096"
}

variable "master_disk_size" {
  description = "Size of the master disk in bytes"
  type        = "string"
  default     = "10000000000"
}

variable "node_count" {
  description = "Number of nodes"
  type        = "string"
  default     = "3"
}

variable "node_cpus" {
  description = "Number of CPUs to assign to the nodes"
  type        = "string"
  default     = "2"
}

variable "node_memory" {
  description = "Amount of memory in MiB to assign to the nodes"
  type        = "string"
  default     = "2048"
}

variable "node_disk_size" {
  description = "Size of the node disk in bytes"
  type        = "string"
  default     = "30000000000"
}