# Kong Gateway on Kubernetes

Target: the KVM/libvirt Kubernetes cluster.

PostgreSQL initially remains in Docker on the Linux Mint host, with
persistent data under /data/postgres.

## Deployment sequence

1. Verify Kubernetes nodes and networking.
2. Establish secure, stable PostgreSQL connectivity from all worker nodes.
3. Create the namespace and configuration.
4. Create credentials without committing real secrets.
5. Run and validate the database migration Job.
6. Deploy Kong Gateway.
7. Expose the Proxy Service using a deliberate access method.
8. Keep the Admin API internal-only.
9. Validate health, logs, connectivity and metrics.

The YAML files are placeholders, not deployable manifests yet.
Implement and validate one resource at a time.
