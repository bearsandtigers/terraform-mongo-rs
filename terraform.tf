variable "ycc_token" {}
variable "ycc_cloud_id" {}
variable "ycc_folder_id" {}
variable "ycc_zone" {}
variable "ycc_image_id" {}

provider "yandex" {
  token = "${var.ycc_token}"
  cloud_id  = "${var.ycc_cloud_id}"
  folder_id = "${var.ycc_folder_id}"
  zone      = "${var.ycc_zone}"
}

# instances 
resource "yandex_compute_instance" "tf-test1" {
  name = "tf-test1"
  resources {
    cores  = 1
    memory = 1
  }
  boot_disk {
    initialize_params {
      image_id = "${var.ycc_image_id}"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }
  metadata = {
    ssh-keys = "user:${file("~/.ssh/ycc_tf.pub")}"
  }
}

resource "yandex_compute_instance" "tf-test2" {
  name = "tf-test2"
  resources {
    cores  = 1
    memory = 1
  }
  boot_disk {
    initialize_params {
      image_id = "${var.ycc_image_id}"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }
  metadata = {
    ssh-keys = "user:${file("~/.ssh/ycc_tf.pub")}"
  }
}

resource "yandex_compute_instance" "tf-test3" {
  name = "tf-test3"
  resources {
    cores  = 1
    memory = 1
  }
  boot_disk {
    initialize_params {
      image_id = "${var.ycc_image_id}"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }
  metadata = {
    ssh-keys = "user:${file("~/.ssh/ycc_tf.pub")}"
  }
}

# network, Yandex wants it declared this way
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = ["10.68.68.0/24"]
}


# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = ["yandex_compute_instance.tf-test1", "yandex_compute_instance.tf-test2", "yandex_compute_instance.tf-test3"]

  provisioner "local-exec" {
    command = "echo [mongo] > hosts"
  }

  provisioner "local-exec" {
    command = "echo '${yandex_compute_instance.tf-test1.name} ansible_host=${yandex_compute_instance.tf-test1.network_interface.0.nat_ip_address} ansible_ssh_user=ubuntu' >> hosts"
  }

  provisioner "local-exec" {
    command = "echo '${yandex_compute_instance.tf-test2.name} ansible_host=${yandex_compute_instance.tf-test2.network_interface.0.nat_ip_address} ansible_ssh_user=ubuntu' >> hosts"
  }

  provisioner "local-exec" {
    command = "echo '${yandex_compute_instance.tf-test3.name} ansible_host=${yandex_compute_instance.tf-test3.network_interface.0.nat_ip_address} ansible_ssh_user=ubuntu' >> hosts"
  }

  provisioner "local-exec" {
    command = "cat hosts.example >> hosts"
  }
}
