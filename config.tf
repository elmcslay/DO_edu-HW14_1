terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = ""  
  zone = "ru-central1-b"
  cloud_id = "b1g8au9em58afkdtkahm"
  folder_id = "b1go28jbjr6v23i268qj"
}

resource "yandex_compute_instance" "vm-1" {
  name = "test-vm-1"
  platform_id = "standard-v3"

  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
        image_id = "fd8snjpoq85qqv0mk9gi"
        type = "network-ssd"
        size = 15
    }
  }

  network_interface {
    subnet_id = "e2l0aklkamuvt9s69baf"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
