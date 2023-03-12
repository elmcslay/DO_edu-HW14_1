terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "${file("~/key.json")}"
  zone = "ru-central1-b"
  cloud_id = "b1g8au9em58afkdtkahm"
  folder_id = "b1go28jbjr6v23i268qj"
}

resource "yandex_compute_instance" "vm-1" {
  name = "demo-build"
  hostname = "demo-build"
  platform_id = "standard-v3"

  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
        image_id = "fd8snjpoq85qqv0mk9gi"
        type = "network-ssd"
        size = 10
    }
  }

  network_interface {
    subnet_id = "e2l0aklkamuvt9s69baf"
    nat = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  scheduling_policy {
    preemptible = true
  }

  

  connection {
    type = "ssh"
    user = "edu"
    private_key = file("~/.ssh/id_rsa")
    host = self.network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
        inline = [
          "sudo apt update && sudo apt install git -y",
          "sudo DEBIAN_FRONTEND=noninteractive apt-get install maven -y",
          "sudo git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git",
          //"sudo cd boxfuse-sample-java-war-hello/",
          "sudo mvn package"
        ]
  }
}

/*resource "yandex_compute_instance" "vm-2" {
  name = "demo-prod"
  hostname = "demo-prod"
  platform_id = "standard-v3"

  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
        image_id = "fd8snjpoq85qqv0mk9gi"
        type = "network-ssd"
        size = 10
    }
  }

  network_interface {
    subnet_id = "e2l0aklkamuvt9s69baf"
    nat = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
    ssh-key = "edu:${file("~/.ssh/id_rsa_2")}"
  }

  scheduling_policy {
    preemptible = true
  }

  /*connection {
    type = "ssh"
    user = "edu"
    private_key = file("~/.ssh/id_rsa")
    host = self.network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
        inline = [
          "sudo apt update && sudo apt install tomcat9 -y"
        ]
  }
}

*/
