# Kubernetes manifests for Netflix Clone

This folder contains baseline Kubernetes resources covering:

- Namespaces (`frontend`, `backend`)
- ConfigMaps and Secrets
- Deployments with resource requests/limits
- ClusterIP Services
- Ingress resources configured for the AWS Load Balancer Controller (ALB)

## Apply order

```bash
kubectl apply -f k8s/00-namespaces.yaml
kubectl apply -f k8s/01-configmaps-secrets.yaml
kubectl apply -f k8s/02-backend-deployment-service.yaml
kubectl apply -f k8s/03-frontend-deployment-service.yaml
kubectl apply -f k8s/04-ingress-alb.yaml
kubectl apply -f k8s/05-aws-load-balancer-controller.yaml
```

## Notes

1. Replace container images (`netflix-frontend:latest`, `netflix-backend:latest`) with your ECR image URIs.
2. If you use an external database, update `backend-secrets` (`DB_URL`) before apply.
3. These Ingress resources assume AWS Load Balancer Controller is installed in the cluster and has IAM permissions configured.
