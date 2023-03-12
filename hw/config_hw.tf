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


resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "aje2il7vqsine6kr7di0"
  description = "static access key for object storage"
}

resource "yandex_storage_bucket" "bckt-1" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "demo-bucket.doedu.yandex.ru" 
  max_size = 1073741824
  force_destroy = true
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
          "sudo apt update && sudo apt install git s3cmd -y",
          "sudo DEBIAN_FRONTEND=noninteractive apt-get install maven -y",
          "sudo git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git",
          "cd boxfuse-sample-java-war-hello/",
          "sudo mvn package",
          "s3cmd --access_key=${yandex_storage_bucket.bckt-1.access_key} --secret_key=${yandex_storage_bucket.bckt-1.secret_key} --bucket-location=ru-central1 --host=storage.yandexcloud.net --host-bucket='%(bucket)s.storage.yandexcloud.net' put target/hello-1.0.war s3://${yandex_storage_bucket.bckt-1.bucket}"
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
