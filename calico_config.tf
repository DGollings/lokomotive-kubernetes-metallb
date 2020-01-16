
# prepare calico for metallb
data "template_file" "calico_metallb" {
  template = file("${path.module}/templates/calico-metallb.yaml.tpl")

  vars = {
    cidr = packet_reserved_ip_block.load_balancer_ips.cidr_notation
  }
}

resource "null_resource" "apply_calico_metallb" {
  triggers = {
    manifest_sha1 = "${sha1("${data.template_file.calico_metallb.rendered}")}"
  }

  provisioner "local-exec" {
    command = "${var.calicoctl} apply -f -<<EOF\n${data.template_file.calico_metallb.rendered}\nEOF"
    environment = {
      KUBECONFIG     = var.kubeconfig_path
      DATASTORE_TYPE = "kubernetes"
    }
  }
  depends_on = [null_resource.wait_for_kubernetes]
}

# Add a metallb configmap to calico
resource "null_resource" "apply_calico-metallb_configmap" {
  triggers = {
    manifest_sha1 = "${sha1(file("${path.module}/assets/bird.cfg.template.yaml"))}"
  }

  provisioner "local-exec" {
    command = "${var.kubectl} apply -f ${path.module}/assets/bird.cfg.template.yaml"
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
  }
  depends_on = [null_resource.wait_for_kubernetes]
}

# patch preinstalled calico to use configmap
resource "null_resource" "patch_calico_for_configmap" {
  triggers = {
    manifest_sha1 = "${sha1(file("${path.module}/patches/calico-k8s-backend-metallb.json"))}"
  }

  provisioner "local-exec" {
    command = "${var.kubectl} patch -n kube-system daemonsets.apps calico-node --patch \"$(cat ${path.module}/patches/calico-k8s-backend-metallb.json)\""
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
  }
  depends_on = [null_resource.wait_for_kubernetes]
}

data "packet_device" "worker" {
  count      = length(var.worker_nodes_hostname)
  project_id = var.project_id
  hostname   = var.worker_nodes_hostname[count.index]
}

data "template_file" "worker_bgppeer" {
  count    = length(var.worker_nodes_hostname)
  template = file("${path.module}/templates/calico-bgppeer.yaml.tpl")
  vars = {
    HOSTNAME = var.worker_nodes_hostname[count.index]
    PEER_IP  = "${element(data.packet_device.worker.*.network.2.gateway, count.index)}"
  }
}


# Add each node's peer/gateway to as a Calico bgppeer
resource "null_resource" "calico_node_peers" {
  count = length(var.worker_nodes_hostname)

  provisioner "local-exec" {
    command = "${var.calicoctl} apply -f - <<EOF\n${data.template_file.worker_bgppeer[count.index].rendered}\nEOF"
    environment = {
      KUBECONFIG     = var.kubeconfig_path
      DATASTORE_TYPE = "kubernetes"
    }
  }
  depends_on = [null_resource.wait_for_kubernetes]
}
