# Giropops Senha

## Assessment

- [x] ~~Lightweight image~~
- [x] ~~The app and Redis images created by me~~
- [x] ~~Push images to DockerHub~~
- [x] ~~Report of image vulnerabilities on readme~~
- [x] ~~Signed images~~
- [ ] K8s cluster - 3 workers
- [ ] Manage resources
- [ ] Min 1000 requests by minutes
- [ ] Monitoring with Prometheus
- [ ] Cert Manager
- [ ] Ingress
- [ ] Documentation on readme file

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
