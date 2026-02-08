provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {}
variable "region" { default = "us-central1" }
variable "machine_type" { default = "e2-medium" }

resource "google_compute_network" "veex_network" {
  name = "veex-network"
}

resource "google_compute_firewall" "veex_firewall" {
  name    = "veex-firewall"
  network = google_compute_network.veex_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "veex_server" {
  name         = "veex-server"
  machine_type = var.machine_type
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.veex_network.name
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "public_ip" {
  value = google_compute_instance.veex_server.network_interface.0.access_config.0.nat_ip
}
