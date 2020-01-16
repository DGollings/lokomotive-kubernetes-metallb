
# Get some public IPs to use for our load balancer

variable "project_id" {
  description = "packet project id (e.g. 405efe9c-cce9-4c71-87c1-949c290b27dc)"
}

variable "facility" {
  type        = string
  description = "Packet facility to deploy the cluster in"
}

variable "kubeconfig_path" {
  default     = "~/.kube/config"
  description = "which kubeconfig(-admin) file to use"
}

variable "calicoctl" {
  # default = intentionally left blank as a form of local state validation.
  # https://docs.projectcalico.org/v3.9/getting-started/calicoctl/install#installing-calicoctl-as-a-binary-on-a-single-host
  description = "path to locally installed calicoctl"
}

variable "kubectl" {
  # default = intentionally left blank as a form of local state validation.
  # make sure to install kubectl
  # https://kubernetes.io/docs/tasks/tools/install-kubectl/
  description = "path to locally installed kubectl"
}

variable "worker_nodes_hostname" {
  # example: module.worker-pool-helium.worker_nodes_hostname
  description = "which worker nodes to add to calico BGPPeer configuration"
}

# Simple script 
resource "null_resource" "wait_for_kubernetes" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/wait-for-kubernetes.sh"
    environment = {
      KUBECTL    = var.kubectl
      KUBECONFIG = var.kubeconfig_path
    }
  }
}
