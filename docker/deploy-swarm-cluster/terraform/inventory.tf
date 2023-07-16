resource "null_resource" "update_inventory" {
  triggers = {
    existing_file = filesha256("/etc/ansible/hosts")
  }

  provisioner "local-exec" {
    command = <<EOT
      echo '
[nodes:children]
managers
workers

[managers:children]
active
standby

[active]
docker1 ansible_host=${yandex_compute_instance.docker[0].network_interface.0.nat_ip_address} ansible_user=debian ansible_ssh_private_key_file=/root/.ssh/id_rsa

[standby]
docker2 ansible_host=${yandex_compute_instance.docker[1].network_interface.0.nat_ip_address} ansible_user=debian ansible_ssh_private_key_file=/root/.ssh/id_rsa
docker3 ansible_host=${yandex_compute_instance.docker[2].network_interface.0.nat_ip_address} ansible_user=debian ansible_ssh_private_key_file=/root/.ssh/id_rsa

[workers]
docker4 ansible_host=${yandex_compute_instance.docker[3].network_interface.0.nat_ip_address} ansible_user=debian ansible_ssh_private_key_file=/root/.ssh/id_rsa
docker5 ansible_host=${yandex_compute_instance.docker[4].network_interface.0.nat_ip_address} ansible_user=debian ansible_ssh_private_key_file=/root/.ssh/id_rsa
docker6 ansible_host=${yandex_compute_instance.docker[5].network_interface.0.nat_ip_address} ansible_user=debian ansible_ssh_private_key_file=/root/.ssh/id_rsa
      ' >> /etc/ansible/hosts
    EOT
  }

depends_on = [yandex_compute_instance.docker]
}
