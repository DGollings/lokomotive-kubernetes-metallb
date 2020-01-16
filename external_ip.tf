# IP range to use for external ingress
resource "packet_reserved_ip_block" "load_balancer_ips" {
  project_id = var.project_id
  facility   = var.facility
  quantity   = 2
}
