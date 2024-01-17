# Giropops Senha

### Summary

- [~~Requirements~~](#requirements)
- [~~Lightweight image~~](#docker)
- [~~Push images to DockerHub~~](#dockerhub)
- [~~Report of image vulnerabilities on readme~~](#trivy-report)
- [~~Signed images~~](#verify-image-signature)
- [~~Kube-linter~~](#kube-linter)
- [~~KinD Cluster~~](#create-kind-cluster)
- [~~Monitoring with Prometheus~~](#monitoring-with-prometheus-and-grafana)
- [~~Apply the manifests~~](#apply-the-manifests)
- [Configure with OCI](#)
- [Performance Test - Min 1000 requests by minutes](#)
- [Resources Optimization](#)
- [Automation with GitHub Actions](#)
- [Cert Manager](#)
- [Documentation on readme file](#)

## Requirements

- [docker](https://docs.docker.com/engine/install/)
- [trivy](https://aquasecurity.github.io/trivy/v0.18.3/installation/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [kube-linter](https://github.com/stackrox/kube-linter#installing-kubelinter) (optional)
- [ingress](#)
- [kube-prometheus](#)

## Docker

I've used the [wolfi images from Chainguard](https://www.chainguard.dev/chainguard-images), to build the application with python and use its redis image.

We can test them locally with docker compose:

    docker compose up

## DockerHub

Log into docker in the terminal (use your username):

    docker login -u mmazoni

Push the image you created:

    docker push mmazoni/linuxtips-giropops-senhas:3.0

## Trivy Report

The wolfi image for python has no vulnerabilities, only the python libs have vulnerabilities, updating the libraries into the fixed versions make the image with 0 vulnerability.

### Before

![image](https://github.com/MMazoni/giropops-senha-linuxtips/assets/37179593/90c50569-9510-4c00-a444-75af6139c788)


### After

![image](https://github.com/MMazoni/giropops-senha-linuxtips/assets/37179593/0f84918b-56f2-4dfa-8f06-07d0cd45c947)


## Verify Image Signature

Install [cosign](https://docs.sigstore.dev/system_config/installation). Then, we can give the command to verify the signature:

    cosign verify --key=dockerfile/cosign.pub mmazoni/linuxtips-giropops-senhas:3.0

## Kube-linter

Kube-linter is configured (GitHub Actions) to run when merging/pushing to `main` branch. You can run locally too, if you want:

    kube-linter lint manifests/ --config .kube-linter.yml

## Local Hosts configuration

Edit the hosts to the application work with ingress.

    sudo vim /etc/hosts

Then, add the hosts necessary for the project:

    127.0.0.1    giropops-senhas.kubernetes.local
    127.0.0.1    grafana.kubernetes.local
    127.0.0.1    prometheus.kubernetes.local
    127.0.0.1    alertmanager.kubernetes.local

## Create KinD cluster

1. Install [kind](https://kind.sigs.k8s.io/) to use Kubernetes in Docker locally and kubectl to work with kubernetes API through your terminal.

2. Use this command to create the cluster:

    kind create cluster --config=config/kind/cluster.yml


## Monitoring with Prometheus and Grafana

1. We will use the [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) to start monitoring `giropops-senhas`. Now, install the CRDs(Custom Resource Definitions) of kube-prometheus:

    git clone https://github.com/prometheus-operator/kube-prometheus ~/kube-prometheus
    cd ~/kube-prometheus
    kubectl create -f manifests/setup

2. Then, install the services (Prometheus, Grafana, Alertmanager, Blackbox, etc)

    kubectl apply -f manifests/

3. Check if everything installed properly:

    kubectl get servicemonitors -n monitoring
    kubectl get pods -n monitoring


## Apply the manifests

1. Apply the manifests

    kubectl apply -k manifests/overlays/kind
    kubectl apply -f manifests/overlays/kind/specific

2. See if all pods is running, then access the application

    kubectl get pods -n giropops

* http://giropops-senhas.kubernetes.local/
* http://grafana.kubernetes.local
* http://prometheus.kubernetes.local

Access here: http://prometheus.kubernetes.local/targets?search=

#### Service Monitor

![ServiceMonitor in Prometheus](static/servicemonitor-prometheus.png)

#### Pod Monitor

![PodMonitor in Prometheus](static/podmonitor-prometheus.png)


## Run cluster in OKE

1. Authenticate in OCI:

    export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)
    cd infra/
    chmod +x refresh-token.sh
    ./refresh-token

2. Then create the infrastructure with Terraform:

    terraform init
    terraform apply

3. After that, you cluster will be created and you already connected to it. Do the [monitoring steps](#monitoring-with-prometheus-and-grafana) to your cluster.

4. Apply the manifests:

    k apply -k ../manifests/overlays/oke
