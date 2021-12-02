# SplitMe!™

Ensure you have docker installed. To run the application locally, do:

```
$ make build
$ make run-local
````

# Mission:
```
Package the SplitMe!TM application into a Helm chart, 
and use Terraform to deploy that Helm chart into a 
Kubernetes cluster running in minikube or a cloud environment.
```

## Observations:
1. Renamed the IMAGE_TAG with in the `Makefile` to `rbalusup/split-me` and pushed the image to `dockerhub`.
2. Created the helm chart `split-me-chart`
3. Created a github page `https://rbalusup.github.io/Helm3` which can be used as **Helm Repository**
4. The git repository for Github page is `https://github.com/rbalusup/rbalusup.github.io`
5. Packaged the helm chart `split-me-chart` and uploaded to helm repository.
6. Created the `terraform` folder and added `main.tf` file with `helm provider`
7. Run the `docker-desktop` with `Kubernetes`. Set the `KUBE_CONFIG` and set the `Kubernetes Context`.
8. Run the `terraform init`, `terraform plan` and `terraform apply` commands to deploy the app in K8S cluster.

## 1. Packaging the application into Helm Chart
Here are the steps to package the helm chart...

1. Create the helm chart `split-me-chart`. This will generate set of files & folders within split-me-chart directory.
```
1. cd split-me
2. helm create split-me-chart
```
2. Update the `values.yaml` like this...
```
image:
  repository: rbalusup/split-me
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: LoadBalancer
  port: 5000
```
3. Update the `templates/deployment.yaml` like this (modify containerPort and comment-out livenessprobe and redinessprobe)
```
ports:
   - name: http
     containerPort: 5000
     protocol: TCP
#          livenessProbe:
#            httpGet:
#              path: /
#              port: http
#          readinessProbe:
#            httpGet:
#              path: /
#              port: http
```
4. Package helm chart (This will create .tgz file)
```
cd ..
helm package .
helm repo index .
```
5. Create the helm repository index (This will generate `index.yaml`)
```
helm repo index .
```
6. Create Github page ([https://rbalusup.github.io]()) - This will be used as the helm repository[Git repo: [https://github.com/rbalusup/rbalusup.github.io](https://github.com/rbalusup/rbalusup.github.io)].
7. Copy the `Chart.yaml`, `index.yaml` and the `.tgz` file to this new repo and do the commit and push.
```
helm repo index --url https://rbalusup.github.io/Helm3 .
helm repo ls
helm repo add rbalusup-repo https://rbalusup.github.io/Helm3/
helm update

helm repo list
NAME            URL                              
rbalusup-repo   https://rbalusup.github.io/Helm3/
```
8. Create directory `terraform` under the `split-me` project root directory.
9. Add `main.tf` file with helm provider...
```
resource "helm_release" "split-me-release" {
  name       = "split-me-release"
  repository = "https://rbalusup.github.io/Helm3"
  chart      = "split-me-chart"
  namespace = "default"
}
```
10. Make sure the `docker-desktop` or `minikube` or any cloud env is up and running...Set the KubeConfig path
```
export KUBE_CONFIG_PATH=/path/to/.kube/config
cd terraform
terraform init
terraform plan
terraform apply
```
11. Once above all commands are executed successfully, we can ensure that the app is deployed in the K8S cluster!!
```
kubectl get all
kubectl get po
kubectl port-forward <POD_NAME> 5000:<CONTAINER_PORT> 
ex: kubectl port-forward split-me-release-split-me-chart-6ddc588b5c-jtq6t 5000:5000
```
12. Access the app @ `http://localhost:5000`!!

"We dream of a world in which no more squids will be needlessly slaughtered for their ink. - Arthur Troy Astorino III"_
