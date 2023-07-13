terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone      = "ru-central1-a"
  cloud_id  = "***"
  folder_id = "***"
  token     = "***"
}
 
resource "yandex_compute_instance" "zabbix" {
  name  = "zabbix"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd843htdp8usqsiji0bb"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  provisioner "remote-exec" {
    inline = [
      "wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb",
      "sudo dpkg -i zabbix-release_6.4-1+debian11_all.deb",
      "sudo apt -y update",
      "sudo apt -y install postgresql zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent",
      "sudo -u postgres psql -c \"CREATE USER zabbix WITH PASSWORD 'zabbix'\"",
      "sudo -u postgres createdb -O zabbix zabbix",
      "sudo zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix",
      "sudo sed -i 's/^# DBPassword=.*/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf",
      "sudo sed -i \"s/#\\s*server_name\\s*example.com;/server_name 0.0.0.0;/\" /etc/zabbix/nginx.conf",
      "sudo sed -i \"s/#\\s*listen\\s*8080;/listen 8080;/\" /etc/zabbix/nginx.conf",
      "sudo systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm",
      "sudo systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm"
    ]

    connection {
      host        = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
      type        = "ssh"
      user        = "debian"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  metadata = {
    ssh-keys  = "debian:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "vm" {
  count = 3
  name  = "vm${count.index + 1}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd843htdp8usqsiji0bb"
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb",
      "sudo dpkg -i zabbix-release_6.4-1+debian11_all.deb",
      "sudo apt -y update",
      "sudo apt -y install zabbix-agent",
      "sudo systemctl restart zabbix-agent",
      "sudo systemctl enable zabbix-agent"
    ]

  connection {
     host        = self.network_interface[0].nat_ip_address
     type        = "ssh"
     user        = "debian"
     private_key = file("~/.ssh/id_rsa")
     }
  }

  metadata = {
    ssh-keys  = "debian:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

output "internal_ip_address_vm" {
  value = yandex_compute_instance.vm[*].network_interface.0.ip_address
}
output "external_ip_address_vm" {
  value = yandex_compute_instance.vm[*].network_interface.0.nat_ip_address
}
output "internal_ip_address_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.ip_address
}
output "external_ip_address_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

