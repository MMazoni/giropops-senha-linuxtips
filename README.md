# Giropops Senha

### Summary

- [~~Requirements~~](#requirements)
- [~~Lightweight image~~](#docker)
- [~~Push images to DockerHub~~](#dockerhub)
- [~~Report of image vulnerabilities on readme~~](#trivy-report)
- [~~Signed images~~](#verify-image-signature)
- [~~K8s cluster with 3 worker~~](#kubernetes)
- [Resources Optimization](#)
- [Automation with GitHub Actions](#)
- [Performance Test - Min 1000 requests by minutes](#)
- [Monitoring with Prometheus](#)
- [Cert Manager](#)
- [~~Ingress~~](#)
- [Documentation on readme file](#)

## Requirements

- docker
- trivy
- kind
- kubectl

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

## Local Hosts configuration

Edit the hosts to the application work with ingress.

    sudo vim /etc/hosts

Then, add the wildcard for the host:

    127.0.0.1 *.kubernetes.local

## Kubernetes locally

1. Install [kind](https://kind.sigs.k8s.io/) to use Kubernetes in Docker locally and kubectl to work with kubernetes API through your terminal.

2. Use this command to create the cluster:

    kind create cluster --config=k8s/0.kind-cluster.yml

3. Commands to setup NGINX Ingress Controller:

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
    kubectl wait --namespace ingress-nginx \
          --for=condition=ready pod \
          --selector=app.kubernetes.io/component=controller \
          --timeout=90s

4. Apply the manifests

    kubectl apply -f k8s/

5. Access the application

    http://giropops-senhas.kubernetes.local/



