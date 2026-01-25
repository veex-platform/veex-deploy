# Production Deployment Guide

Deploy VEEX at scale for industrial production environments.

## Architecture Overview

```
                    ┌─────────────┐
                    │   Ingress   │
                    │  (nginx/LB) │
                    └──────┬──────┘
                           │
            ┌──────────────┴──────────────┐
            │                             │
     ┌──────▼──────┐              ┌──────▼──────┐
     │ veex-studio │              │veex-platform│
     │  (3 pods)   │              │  (5 pods)   │
     └─────────────┘              └──────┬──────┘
                                         │
                                  ┌──────▼──────┐
                                  │  PostgreSQL │
                                  │ (replicated)│
                                  └─────────────┘
```

## Prerequisites

- Kubernetes cluster (1.24+)
- kubectl configured
- Helm 3.x
- Persistent storage provisioner
- Load balancer support

## Deployment Options

### Option 1: Helm Chart (Recommended)

```bash
# Add repository
helm repo add veex https://charts.veex.dev
helm repo update

# Install with custom values
helm install veex veex/veex-platform \
  --set platform.replicas=5 \
  --set studio.replicas=3 \
  --set ingress.enabled=true \
  --set ingress.domain=veex.yourdomain.com \
  --set database.type=postgres \
  --set database.host=postgres.default.svc
```

### Option 2: Raw Manifests

```bash
kubectl apply -f kubernetes/manifests/
```

## Configuration

### High Availability

```yaml
# values.yaml
platform:
  replicas: 5
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 2000m
      memory: 4Gi

studio:
  replicas: 3
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
```

### Persistent Storage

```yaml
persistence:
  enabled: true
  storageClass: "fast-ssd"
  size: 100Gi
```

### Database

For production, migrate from SQLite to PostgreSQL:

```yaml
database:
  type: postgres
  host: postgres.database.svc
  port: 5432
  username: veex
  passwordSecret: veex-db-secret
```

## Security

### TLS/HTTPS

```yaml
ingress:
  enabled: true
  tls:
    - secretName: veex-tls
      hosts:
        - veex.yourdomain.com
```

### Network Policies

```bash
kubectl apply -f kubernetes/network-policies/
```

### RBAC

```bash
kubectl apply -f kubernetes/rbac/
```

## Monitoring

### Prometheus Metrics

Platform exposes metrics at `/metrics`:

```yaml
serviceMonitor:
  enabled: true
  interval: 30s
```

### Grafana Dashboards

```bash
kubectl apply -f kubernetes/monitoring/grafana-dashboard.yaml
```

## Backup & Recovery

### Automated Backups

```bash
# Daily backup cron
kubectl apply -f kubernetes/cronjobs/backup.yaml
```

### Manual Backup

```bash
kubectl exec -it veex-platform-0 -- \
  sqlite3 /data/veex.db ".backup /backup/veex-$(date +%Y%m%d).db"
```

### Restore

```bash
kubectl cp backup/veex-20260124.db veex-platform-0:/data/veex.db
kubectl rollout restart deployment/veex-platform
```

## Scaling

### Horizontal Pod Autoscaler

```yaml
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70
```

### Manual Scaling

```bash
kubectl scale deployment veex-platform --replicas=10
```

## Troubleshooting

### View Logs

```bash
# Platform logs
kubectl logs -l app=veex-platform --tail=100 -f

# Studio logs
kubectl logs -l app=veex-studio --tail=100 -f
```

### Database Connection Issues

```bash
# Test database connectivity
kubectl exec -it veex-platform-0 -- nc -zv postgres 5432
```

### Performance Issues

```bash
# Check resource usage
kubectl top pods -l app=veex-platform

# Describe pod for events
kubectl describe pod veex-platform-0
```

## Updates

### Rolling Update

```bash
helm upgrade veex veex/veex-platform \
  --set image.tag=v2.0.0 \
  --reuse-values
```

### Rollback

```bash
helm rollback veex
```

## Best Practices

1. **Use specific image tags** instead of `latest`
2. **Enable resource limits** to prevent resource starvation
3. **Configure liveness/readiness probes** properly
4. **Use secrets** for sensitive data
5. **Enable TLS** for all external traffic
6. **Regular backups** (automated daily)
7. **Monitor metrics** and set up alerts
8. **Test disaster recovery** procedures quarterly

## Support

- [Architecture Docs](https://docs.veex.dev/architecture)
- [Troubleshooting Guide](troubleshooting.md)
- [Security Guidelines](security.md)
