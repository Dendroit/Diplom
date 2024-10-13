resource "yandex_compute_disk" "disk-nginx1" {
  name     = "disk-n-nginx1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8a4icddonrspdp6839"
  size     = 10

}

resource "yandex_compute_disk" "disk-nginx2" {
  name     = "disk-n-nginx2"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8hsei0au7hvctohsh9"
  size     = 10

}

resource "yandex_compute_disk" "disk-bastion" {
  name     = "disk-n-bastion"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 8

}

resource "yandex_compute_disk" "disk-zabbix" {
  name     = "disk-n-zabbix"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 10

}

resource "yandex_compute_disk" "disk-elastic" {
  name     = "disk-n-elastic"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 10

}

resource "yandex_compute_disk" "disk-kibana" {
  name     = "disk-n-kibana"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 10

}
