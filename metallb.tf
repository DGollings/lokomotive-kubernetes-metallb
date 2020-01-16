
resource "null_resource" "install_metallb" {
  triggers = {
    manifest_sha1 = "${sha1(file("${path.module}/assets/metallb.yaml"))}"
  }

  provisioner "local-exec" {
    command = "${var.kubectl} apply -f ${path.module}/assets/metallb.yaml"
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
  }
  depends_on = [null_resource.wait_for_kubernetes]
}

data "template_file" "metallb_config" {
  template = file("${path.module}/templates/metallb-config.yaml.tpl")

  vars = {
    cidr = packet_reserved_ip_block.load_balancer_ips.cidr_notation
  }
}

resource "null_resource" "apply_metallb_config" {
  triggers = {
    manifest_sha1 = "${sha1("${data.template_file.metallb_config.rendered}")}"
  }

  provisioner "local-exec" {
    command = "${var.kubectl} apply -f -<<EOF\n${data.template_file.metallb_config.rendered}\nEOF"
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
  }
  depends_on = [null_resource.install_metallb, null_resource.wait_for_kubernetes]
}
