## Kubernetes deployment
The repository includes a comprehensive Kubernetes manifest (`kubernetes.yaml`) that mirrors the Docker Compose configuration with additional Kubernetes-specific features. This manifest is production-ready and suitable for deploying webPDF to any Kubernetes cluster, including Docker Desktop, Minikube, EKS, GKE, and AKS.

### Quick start
```console
$ kubectl apply -f kubernetes.yaml
```

### What's included
The Kubernetes manifest includes:
- **PersistentVolumeClaims**: For `conf`, `keystore`, `logs`, and `temp` storage
- **ConfigMap**: Reserved for future font configuration
- **Service**: NodePort service exposing port 8080 (default NodePort: 30080)
- **Deployment**: Single replica with comprehensive configuration:
    - **Init Container**: Automatically populates configuration on first deployment
    - **Resource limits**: CPU and memory requests/limits
    - **Health checks**: Liveness and readiness probes using webPDF health endpoints
    - **Security**: Non-root execution (UID/GID 10000), read-only root filesystem where possible
    - **Volumes**: Shared memory (2GB) for Chromium rendering
    - **Production comments**: Extensive inline documentation for customization

### Access the service
After deployment, access webPDF based on the service type:

**NodePort** (default configuration):
```console
# Docker Desktop / Local Kubernetes
http://localhost:30080/webPDF/

# Remote cluster
http://<node-ip>:30080/webPDF/
```

**LoadBalancer** (cloud environments):
```console
$ kubectl get svc webpdf
# Use the EXTERNAL-IP shown
http://<external-ip>:8080/webPDF/
```

### Production configuration notes
The `kubernetes.yaml` file includes extensive inline comments (prefixed with `# PRODUCTION:`) marking values that should be adjusted for production. Key configuration areas:

#### Storage and persistence
- **PVC sizes**: Adjust based on your requirements (conf: 1-5Gi, keystore: 1Gi, logs: 5-50Gi, temp: 10-100Gi)
- **StorageClass**: Uncomment and specify appropriate storage class (e.g., fast-ssd for temp/conf, standard for logs)
- **Temp storage**: Size based on concurrent document processing volume

#### Networking
- **Service type**:
    - `NodePort`: For test/dev environments (default, port 30080)
    - `LoadBalancer`: For cloud environments (AWS ELB, GCP LB, Azure LB)
    - `ClusterIP + Ingress`: For production with external ingress controller
- **Port configuration**: Adjust nodePort (30000-32767) or remove for automatic assignment

#### Scalability and availability
- **Replicas**: Increase to 2+ for high availability
- **Update strategy**: Enable RollingUpdate with maxSurge/maxUnavailable for zero-downtime deployments
- **Pod anti-affinity**: Distribute replicas across nodes
- **Node selection**: Use nodeSelector and tolerations for dedicated node pools

#### Resources
- **Memory**: Adjust requests/limits based on workload (default: 4Gi request, 6Gi limit)
- **CPU**: Scale based on concurrent processing needs (default: 1000m request, 2000m limit)
- **Java heap**: Set JAVA_PARAMETERS to ~50-70% of memory limit (default: -Xmx4g)

#### Security
- **Security context**: Non-root execution enforced (UID/GID 10000)
- **Capabilities**: Consider dropping all capabilities for enhanced security
- **seccomp profile**: Enable RuntimeDefault seccomp profile for production

#### Monitoring and observability
- **Prometheus annotations**: Uncomment to enable Prometheus scraping
- **Health checks**: Pre-configured liveness and readiness probes
- **Logging**: Stdout/stderr logs accessible via `kubectl logs`

#### Environment configuration
- **Locale**: Customize LANG, LC_ALL, LANGUAGE (default: de_DE.UTF-8)
- **Timezone**: Set TZ environment variable (default: Europe/Berlin)
- **Custom fonts**: Mount via hostPath, PVC, or ConfigMap

### Check deployment status
```console
# View pods
$ kubectl get pods

# View service
$ kubectl get svc webpdf

# View logs
$ kubectl logs -f deployment/webpdf

# Check health
$ kubectl get pods -w
```

Wait for the pod to reach `Running` status and the readiness probe to succeed (typically 20-30 seconds after container start).

### Init container behavior
The manifest includes an init container that automatically initializes the configuration volume on first deployment:
- Copies default configuration files from `/opt/webpdf/conf` to the PVC
- Sets proper file ownership (UID/GID 10000)
- Skips initialization if configuration already exists (safe for redeployments)
- Check init container logs: `kubectl logs <pod-name> -c init-data`

### Troubleshooting

**Pod not starting:**
```console
# Check pod status and events
$ kubectl describe pod <pod-name>

# Check init container logs
$ kubectl logs <pod-name> -c init-data

# Check main container logs
$ kubectl logs <pod-name> -c webpdf
```

**PVC issues:**
```console
# Check PVC status
$ kubectl get pvc

# If PVC pending, check StorageClass
$ kubectl get storageclass
```

**Permission issues:**
Ensure your StorageClass supports fsGroup (most do). If you see permission errors, verify the securityContext settings match the webpdf user (UID/GID 10000).

### Example: Production deployment with customization
For production environments, consider these common adjustments:

```yaml
# 1. Change to LoadBalancer service
spec:
  type: LoadBalancer

# 2. Increase replicas for high availability
spec:
  replicas: 3

# 3. Add rolling update strategy
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0

# 4. Adjust resource limits for heavier workloads
resources:
  requests:
    memory: "8Gi"
    cpu: "2000m"
  limits:
    memory: "12Gi"
    cpu: "4000m"
env:
  - name: JAVA_PARAMETERS
    value: "-Xmx8g"  # Adjust heap to ~70% of memory limit

# 5. Add pod anti-affinity (uncomment in manifest)
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - webpdf
          topologyKey: kubernetes.io/hostname
```

### Uninstall
```console
$ kubectl delete -f kubernetes.yaml
```

**Note:** PersistentVolumeClaims are not automatically deleted to prevent data loss. Delete them manually if needed:
```console
$ kubectl delete pvc webpdf10-conf webpdf10-keystore webpdf10-logs webpdf10-temp
```

