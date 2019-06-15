variable "do_token" {}
variable "do_region" {}
variable "do_image" {}
variable "do_size" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

# Create a new SSH key
resource "digitalocean_ssh_key" "ins_default" {
  name       = "InSales testcase"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

# create two demo droplets
resource "digitalocean_droplet" "mongo-test1" {
  name     = "mongo-test1"
  image    = "${var.do_image}"
  region   = "${var.do_region}"
  size     = "${var.do_size}"
  ssh_keys = ["${digitalocean_ssh_key.ins_default.fingerprint}"]
}

resource "digitalocean_droplet" "mongo-test2" {
  name     = "mongo-test2"
  image    = "${var.do_image}"
  region   = "${var.do_region}"
  size     = "${var.do_size}"
  ssh_keys = ["${digitalocean_ssh_key.ins_default.fingerprint}"]
}

resource "digitalocean_droplet" "mongo-test3" {
  name     = "mongo-test3"
  image    = "${var.do_image}"
  region   = "${var.do_region}"
  size     = "${var.do_size}"
  ssh_keys = ["${digitalocean_ssh_key.ins_default.fingerprint}"]
}

# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = ["digitalocean_droplet.mongo-test1", "digitalocean_droplet.mongo-test2", "digitalocean_droplet.mongo-test3"]

  provisioner "local-exec" {
    command = "echo [mongo] > hosts"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.mongo-test1.name} ansible_host=${digitalocean_droplet.mongo-test1.ipv4_address} ansible_ssh_user=root' >> hosts"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.mongo-test2.name} ansible_host=${digitalocean_droplet.mongo-test2.ipv4_address} ansible_ssh_user=root' >> hosts"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.mongo-test3.name} ansible_host=${digitalocean_droplet.mongo-test3.ipv4_address} ansible_ssh_user=root' >> hosts"
  }

  provisioner "local-exec" {
    command = "cat hosts.example >> hosts"
  }
}
