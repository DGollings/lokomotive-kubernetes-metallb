# lokomotive-kubernetes-metallb

First of all, thanks packet for the [tutorial](https://github.com/packet-labs/kubernetes-bgp)  

Configures the default [Lokomotive Kubernetes Packet](https://github.com/kinvolk/lokomotive-kubernetes) installation (with default Calico networking) to use [Metallb](https://metallb.universe.tf/) for ingress on Packet.net bare metal hosts

Basically, follow this [tutorial](https://github.com/kinvolk/lokomotive-kubernetes/blob/master/docs/flatcar-linux/packet.md)

and add the following at the bottom of your personal main.tf:  
```
locals {
  asset_dir    = "/path/to/lokomotive/asset_dir"
}

module "metallb" {
  source = "git::https://github.com/DGollings/lokomotive-kubernetes-metallb.git?ref=master"

  project_id            = local.project_id
  facility              = local.facility
  kubectl               = "/usr/bin/kubectl"
  kubeconfig_path       = "${local.asset_dir}/auth/kubeconfig"
  calicoctl             = "/usr/local/bin/calicoctl"
  worker_nodes_hostname = module.worker-pool-helium.worker_nodes_hostname
}
```

For testing, you can apply the echo server in the `test` directory:  
`kubectl apply -f test/echo-server.yaml`  
followed by:  
`kubectl get service -n echoserver`  
```
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
echoserver   LoadBalancer   10.3.220.254   147.75.84.66   80:32490/TCP   8s
```

take the value under EXTERNAL-IP and sending an HTTP request should result (once the pods have started) in:  
`curl 147.75.84.66`  
```
CLIENT VALUES:
client_address=('10.2.232.0', 44684) (10.2.232.0)
command=GET
path=/
real path=/
query=
request_version=HTTP/1.1

SERVER VALUES:
server_version=BaseHTTP/0.6
sys_version=Python/3.5.0
protocol_version=HTTP/1.0

HEADERS RECEIVED:
Accept=*/*
Host=147.75.84.66
User-Agent=curl/7.67.0
```

clean up:  
`kubectl delete -f test/echo-server.yaml`

Although I'd suggest using an nginx instance instead of a single hardcoded microservice instead :)
