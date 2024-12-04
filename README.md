# K8S Homelab

## Secrets

The following secrets are required in the provisioning secrets manager:

| Name                                         | Description                                       |
|----------------------------------------------|---------------------------------------------------|
| `CERTMANAGER_LETSENCRYPT_EMAIL`              | Email address used for LetsEncrypt registration   |
| `CLOUDFLARE_API_TOKEN`                       | For DNS management and LetsEncrypt DNS validation |
| `EXTERNALSECRETS_INFISICAL_CLIENT_ID`        | Infisical Client ID for External-Secrets          |
| `EXTERNALSECRETS_INFISICAL_CLIENT_SECRET`    | Infisical Client Secret for External-Secrets      |
| `EXTERNALSECRETS_INFISICAL_ENVIRONMENT_SLUG` | Infisical Environment Slug for External-Secrets   |
| `EXTERNALSECRETS_INFISICAL_PROJECT_SLUG`     | Infisical Project Slug for External-Secrets       |
| `METALLB_IPADDRESSPOOL_DEFAULT`              | MetalLB IP Address Pool Range                     |

## Quickstart

### Clean (Optional)

    find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

### Setup

Provision Talos Cluster:

    cd envs/prod/local/k8s/talos
    terragrunt apply

After Talos cluster has bootstrapped, pull `kubeconfig` from Terraform State:

    terragrunt output -raw kubeconfig_raw > ~/.kube/config
    kubectl get nodes

Provision Secrets Manager:

    # Install 'external-secrets'
    cd envs/prod/local/k8s/services/external-secrets
    terragrunt apply

    # Install Infisicial secrets provider
    cd envs/prod/local/k8s/providers/secrets/infisical
    terragrunt apply

Provision Certificate Management:

    # Install 'cert-manager'
    cd envs/prod/local/k8s/services/cert-manager
    terragrunt apply

    # Install LetsEncrypt certificate issuers
    cd envs/prod/local/k8s/providers/tls/letsencrypt
    terragrunt apply

Provision External DNS:

    # Install `external-dns`
    cd envs/prod/local/k8s/services/external-dns
    terragrunt apply

Provision MetalLB:

    # Install 'metallb'
    cd envs/prod/local/k8s/services/metallb
    terragrunt apply

    # Install IP Address Pool and L2 Advertisements
    cd envs/prods/local/k8s/providers/metallb/home
    terragrunt apply

### Testing

To test `external-secrets`:

    # Create ExternalSecret resource
    kubectl apply -f tests/k8s/external-secrets/external-secret.yaml

    # Check ExternalSecret resource
    kubectl get externalsecrets

    # Check target secret
    kubectl get secret infisicial-test-secret -o jsonpath="{.data.secret}" | base64 -d

To test TLS certificate generation using `cert-manager`:

    # Create Certificate resource
    kubectl apply -f tests/k8s/cert-manager/certificate.yaml

    # Check CertificateRequest progress
    kubectl get certificaterequests

    # Check Certificate status
    kubectl get certificates

