# terraform-libvirt-kubernetes

A small project describing how to use [terraform](https://www.terraform.io/) to deploy infrastructure for [Kubernetes](https://kubernetes.io/) on [KVM](https://wikipedia.org/wiki/KVM).

## Install the necessary components and dependencies

I am writing this guide 08.2019, versions of some components could not coincide with the current ones. All commands run as root.

### Operating system

For this project, I used CentOS operating system on hardware and virtual machines.

* [CentOS-7-x86_64-Minimal-1810](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso) for bare metal
* [CentOS-7-x86_64-GenericCloud-1901](https://cloud.centos.org/centos/7/images/) for virtual machines

### Check CPU virtualization

First check if your CPU supports hardware virtualization

```bash
cat /proc/cpuinfo | egrep "(vmx|svm)"
```

If the command does not return anything, virtualization is not supported on the server or it is disabled in the BIOS settings. KVM itself can be put on such a server, but when we try to enter the hypervisor management command, we will get the error "WARNING KVM acceleration not available, using 'qemu'".

### Install libvirt and virsh

```bash
yum install -y qemu-kvm libvirt virt-install
```

* qemu-kvm - hypervisor;
* libvirt - virtualization management library;
* virt-install - utility for managing virtual machines.

Allow autorun:

```bash
systemctl enable libvirtd
```

Launch KVM:

```bash
systemctl start libvirtd
```

### Network configuration

Install the package to work with bridge:

```bash
yum install -y bridge-utils
```

Сheck the real network interface with the configured IP address

```bash
ip a
```

Edit the settings of the real adapter:

```bash
vi /etc/sysconfig/network-scripts/ifcfg-eth0
```

Need to get something like this:

```text
TYPE=Ethernet
DEVICE=eth0
#IPADDR=192.168.1.100
#PREFIX=24
#GATEWAY=192.168.1.1
#DNS1=8.8.8.8
#DNS2=8.8.4.4
ONBOOT=yes
BOOTPROTO=none
BRIDGE=br0
```

Create an interface for the network bridge:

```bash
vi /etc/sysconfig/network-scripts/ifcfg-br0
```

Need to get something like this:

```text
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
```

Restart the network:

```bash
systemctl restart network
```

Restart libvirtd:

```bash
systemctl restart libvirtd
```

### Install terraform

Ensure wget and unzip are installed

```bash
yum install -y wget unzip
```

Then download the terraform archive

```bash
wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
unzip terraform_0.11.10_linux_amd64.zip
```

This will create a terraform binary file on your working directory. Move this file to the directory/usr/local/bin

```bash
mv terraform /usr/local/bin/
```

Confirm the version installed

```bash
terraform -v
```

### Install Terraform KVM provider

Terraform has a number of officially [supported providers](https://www.terraform.io/docs/providers/) available for use. Unfortunately, KVM is not in the list. I will use the [Terraform KVM provider](https://github.com/dmacvicar/terraform-provider-libvirt)

```bash
wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.5.1/terraform-provider-libvirt-0.5.1.CentOS_7.x86_64.tar.gz
tar xvf terraform-provider-libvirt-0.5.1.CentOS_7.x86_64.tar.gz
mv terraform-provider-libvirt ~/.terraform.d/plugins/
```

Check that libvirt daemon 1.2.14 or newer is running on the hypervisor

```bash
yum info libvirt
```

## Component versions

* OS - CentOS Linux release 7.6.1810 (Core)
* Libvirt - Version : 4.5.0
* Terraform - v0.11.10
* terraform-provider-libvirt - 0.5.1.CentOS_7.x86_64

### If all the necessary components and dependencies are installed, you can start writing the infrastructure as code

## Terraform

Initialize a Terraform working directory

```bash
terraform init
```

Generate and show Terraform execution plan

```bash
terraform plan
```

Then build your Terraform infrastructure

```bash
terraform apply
```

Check your infrastructure use virsh

```bash
virsh list --all
```

You can destroy your Terraform infrastructure

```bash
terraform destroy
```

## Creating virsh pool

Terraform v0.11.10 cannot create a storage pool from code.  In this example I will use the virsh for create k8s-pool.
"/kvm/images" is the path to a file system directory for storing image files. If this directory does not exist, virsh will create it.

```bash
virsh pool-define-as k8s-pool dir - - - - "/kvm/images"
```

Check storage pool

```bash
virsh pool-list --all
```

Build and start k8s-pool

```bash
virsh pool-build k8s-pool
virsh pool-start k8s-pool
```

Enable autostart to start the pool after restarting the machine.

```bash
virsh pool-autostart k8s-pool
```
