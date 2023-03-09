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
  connection {
    type = "ssh"
    user = "edu"
    private_key = file("~/.ssh/id_rsa")
    host = ""
  }

  provisioner "remote-exec" {
        inline = [
          "sudo apt update && sudo apt install git maven"
        ]
    }
}