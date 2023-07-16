resource "yandex_compute_instance" "docker" {
  count = 6
  name  = "docker${count.index + 1}"
  
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
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=\\\"$(dpkg --print-architecture)\\\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \\\"$(. /etc/os-release && echo \\\"$VERSION_CODENAME\\\")\\\" stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get -y update",
      "sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
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
