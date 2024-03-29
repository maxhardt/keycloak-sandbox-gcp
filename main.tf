resource "google_compute_instance" "keycloak_instance" {

  name         = var.instance_name
  project      = var.gcp_project
  zone         = var.gcp_zone
  machine_type = "e2-small"
  tags         = ["http-server", "https-server"]

  boot_disk {
    auto_delete = true
    device_name = "keycloak-sandbox-device"
    initialize_params {
      image = "projects/cos-cloud/global/images/cos-stable-109-17800-147-38"
    }
  }

  metadata = {
    gce-container-declaration = file("${path.module}/container-spec.yaml")
    startup-script            = file("${path.module}/startup.sh")
  }

  network_interface {
    network = var.network
    access_config {
      // ephemeral public ip
    }
  }
}

resource "google_compute_firewall" "firewall" {

  name          = var.firewall.name
  project       = var.gcp_project
  network       = var.network
  source_ranges = var.firewall.cidrs
  target_tags   = ["http-server"]

  allow {
    ports    = var.firewall.ports
    protocol = "tcp"
  }
}

output "external_ip_address" {
    value = google_compute_instance.keycloak_instance.network_interface[0].access_config[0].nat_ip
}
