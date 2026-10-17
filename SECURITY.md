# Security

## Reporting

Use GitHub's private "Report a vulnerability" button on this repository. I aim to reply within 72 hours.

## Threat model

- **Assets:** the cluster workloads and whatever Argo CD is allowed to create.
- **Actors:** anyone who can push to the tracked branch, compromised images, and pods inside the cluster.
- **Entry points:** Git commits, chart values, container images, in-cluster network traffic.
- **Defaults that matter:** non-root, read-only root filesystem, all capabilities dropped, `RuntimeDefault` seccomp, no service-account token unless requested, deny-by-default ingress NetworkPolicy, digest pinning supported. The values schema rejects root containers, privilege escalation and pods without resource requests. The Argo CD AppProject restricts source repo, destination namespaces and resource kinds. Prod never auto-prunes.
- **Verification:** helm-unittest and kubeconform on every commit, plus a real install and a self-heal drill on kind.

## Not provided

- Branch protection and required reviews on the tracked branch. Git is the control plane here, so protect it.
- Image signing and admission policy (cosign, Kyverno or Gatekeeper).
- Secrets management.
