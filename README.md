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

**mmazoni/linuxtips-giropops-senhas:2.0 (wolfi 20230201)**

Total: 0 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0)

2023-11-14T10:27:55.565Z        INFO    Table result includes only package filenames. Use '--format json' option to get the full path to the package file.

**Python (python-pkg)**

Total: 4 (UNKNOWN: 0, LOW: 1, MEDIUM: 2, HIGH: 1, CRITICAL: 0)

┌─────────────────────┬────────────────┬──────────┬────────┬───────────────────┬─────────────────────┬──────────────────────────────────────────────────────────────┐
│       Library       │ Vulnerability  │ Severity │ Status │ Installed Version │    Fixed Version    │                            Title                             │
├─────────────────────┼────────────────┼──────────┼────────┼───────────────────┼─────────────────────┼──────────────────────────────────────────────────────────────┤
│ Flask (METADATA)    │ CVE-2023-30861 │ HIGH     │ fixed  │ 2.1.1             │ 2.3.2, 2.2.5        │ Cookie header                                                │
│                     │                │          │        │                   │                     │ https://avd.aquasec.com/nvd/cve-2023-30861                   │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼─────────────────────┼──────────────────────────────────────────────────────────────┤
│ Werkzeug (METADATA) │ CVE-2023-46136 │ MEDIUM   │        │ 2.3.0             │ 3.0.1, 2.3.8        │ python-werkzeug: high resource consumption leading to denial │
│                     │                │          │        │                   │                     │ of service                                                   │
│                     │                │          │        │                   │                     │ https://avd.aquasec.com/nvd/cve-2023-46136                   │
├─────────────────────┼────────────────┤          │        ├───────────────────┼─────────────────────┼──────────────────────────────────────────────────────────────┤
│ redis (METADATA)    │ CVE-2023-28859 │          │        │ 4.5.2             │ 4.5.4, 4.4.4        │ Async command information disclosure                         │
│                     │                │          │        │                   │                     │ https://avd.aquasec.com/nvd/cve-2023-28859                   │
│                     ├────────────────┼──────────┤        │                   ├─────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2023-28858 │ LOW      │        │                   │ 4.4.3, 4.5.3, 4.3.6 │ Async command information disclosure                         │
│                     │                │          │        │                   │                     │ https://avd.aquasec.com/nvd/cve-2023-28858                   │
└─────────────────────┴────────────────┴──────────┴────────┴───────────────────┴─────────────────────┴──────────────────────────────────────────────────────────────┘


### After

**mmazoni/linuxtips-giropops-senhas:3.0 (wolfi 20230201)**

Total: 0 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0)

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



