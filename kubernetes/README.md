# Provision Contrail in Kubernetes for CNI plugin:

The following short sequence is a working guideline to build and run Contrail in Kubernetes with CNI.
It is by no means production-ready or finished. Use it as a collection of approximate HOWTOs.
It will be updated in the future.
Now it's checked with CentOS containers only, however host system can be Ubuntu 16.04, for example.

* Use this guide to deploy and configure Kubernetes core:
  
  https://github.com/Juniper/contrail-docker/wiki/Provision-Contrail-CNI-for-Kubernetes
  
  Stop before deploying Contrail (kubectl apply -f contrail-host-ubuntu.yaml)
  
* Clone this repo:
  
  git clone https://github.com/cloudscaling/docker-contrail-4

* Bring up your local docker repo on localhost:5000 (or change the files later for other location)

* Bring up http server and make Contrail rpm packages accessible by http (http://10.0.2.15/contrail-4.0.1.0-32 in current code)

* Use change_contrail_version.sh to update version before build (e.g., ```change_contrail_version.sh 4.0.1.0-32 4.0.1.0-33```

* Change IP 10.0.2.15 everywhere to IP of your repo URLs and to (another) IP of your controller nodes, 
  you can employ something like the following script to make changes across all code:
  
  ```for fn in `grep -r -l 10.0.2.15 *`; do sed 's/10.0.2.15/192.168.0.1/g' < "$fn" > result; rm "$fn"; mv result "$fn"; done```

* Use containers/build.sh to build. Update repo location and version in it if needed.

* Build the containers: ```cd containers; sudo ./build.sh```

* Build the containers again (only base ones will be built during first iteration)

* You can check your built containers in http://localhost:5000/v2/_catalog (or where your repo is)

* Do not forget to adjust your configuration in kubernetes/manifests/contrail-micro.yaml

* Deploy Contrail:
  ```kubectl apply -f kubernetes/manifests/contrail-micro.yaml```

* Check the deployment by:
  ```kubectl -n=kube-system get pods```
  
  Check WebUI in https://localhost:8143 (login:admin password:contrail123)

# Debug containers

You can debug particular containers in the following manner

* ```docker run --net=host -itd --entrypoint sleep --env-file pathto_common.env --name mycontainer container_name 10000``

  this starts your container in the background without executing the entrypoint
  
* ```docker exec -it mycontainer /bin/bash```

  then you are inside the container
  
* ```/entrypoint.sh```

  executes the entrypoint script and populates configuration
  
* then execute the cmd line as defined in the dockerfile
