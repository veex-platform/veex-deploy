# OpenSearch Observability Stack - Deployment Guide

## Overview
Centralized logging solution for all VEEX Platform services using OpenSearch, OpenSearch Dashboards, and Fluent Bit.

## Architecture
```
VEEX Services (platform, studio, admin, gateway)
    ↓ (fluentd logging driver, port 24224)
Fluent Bit (log aggregator & forwarder)
    ↓ (opensearch output plugin, port 9200)
OpenSearch (log storage & search engine)
    ↓ (HTTP API, port 9200)
OpenSearch Dashboards (visualization)
    ↓ (web UI, port 5601)
Users/Admins
```

## ⚠️ Critical Pre-requisites

### **REQUIRED: Configure vm.max_map_count on Droplet**
OpenSearch **will NOT start** without this system configuration. Run on the **droplet host**:

```bash
# Temporary (until reboot)
sudo sysctl -w vm.max_map_count=262144

# Permanent (persists after reboot) - RECOMMENDED
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Verify
cat /proc/sys/vm/max_map_count
# Should output: 262144
```

## Services Added

### 1. **OpenSearch**
- **Image**: `opensearchproject/opensearch:2.11.0`
- **Ports**: 
  - `9200`: REST API
  - `9600`: Performance Analyzer
- **Memory**: 512MB heap (configured via OPENSEARCH_JAVA_OPTS)
- **Security**: Disabled for simplicity (set `DISABLE_SECURITY_PLUGIN=true`)

### 2. **OpenSearch Dashboards**
- **Image**: `opensearchproject/opensearch-dashboards:2.11.0`
- **Port**: `5601`
- **Access**: `http://logs.veexplatform.com` or `http://<DROPLET-IP>:5601`

### 3. **Fluent Bit**
- **Image**: `fluent/fluent-bit:2.2`
- **Port**: `24224` (fluentd forward protocol)
- **Config**: `fluent-bit.conf` - routes all logs to OpenSearch

## Fixed Issues

### ✅ **NEXT_PUBLIC_REGISTRY_URL Configuration**
The previous hardcoded value caused 502 errors. Now uses environment variable:
```bash
NEXT_PUBLIC_REGISTRY_URL=http://<YOUR-IP>/api/v1
```

## Deployment Instructions

### Step 1: Configure Environment
```bash
cd /path/to/veex-deploy/docker/all-in-one
cp env.example .env
nano .env
```

Update `.env` with your droplet's public IP:
```bash
NEXT_PUBLIC_REGISTRY_URL=http://<YOUR-PUBLIC-IP>/api/v1
```

### Step 2: Deploy Stack
```bash
docker-compose down
docker-compose pull
docker-compose up -d
```

### Step 3: Verify Services
```bash
# Check all containers are running
docker-compose ps

# Expected output: all services should be "Up"
# - veex-platform
# - veex-studio
# - veex-admin
# - veex-gateway
# - opensearch
# - opensearch-dashboards
# - fluent-bit
```

### Step 4: Verify Logging
```bash
# Check Fluent Bit is receiving logs
docker logs fluent-bit --tail 20

# Check OpenSearch has indices
curl http://localhost:9200/_cat/indices?v

# Should see: veex-* indices
```

### Step 5: Access OpenSearch Dashboards
1. Open browser: `http://<DROPLET-IP>:5601`
2. **Create Index Pattern**:
   - Go to "Stack Management" → "Index Patterns"
   - Create pattern: `veex-*`
   - Time field: `@timestamp`
3. **View Logs**:
   - Go to "Discover"
   - Select `veex-*` index pattern
   - See real-time logs from all services

## Log Tags
Each service has a unique tag for filtering:
- `veex.platform` - Backend registry/API
- `veex.studio` - Visual studio frontend
- `veex.admin` - Admin dashboard
- `veex.gateway` - Nginx gateway

## Troubleshooting

### Services show as "Restarting"
```bash
# Check individual service logs
docker logs veex-admin --tail 50
docker logs veex-studio --tail 50
```

### OpenSearch fails to start
Increase memory limits or disable memory locking:
```bash
# On the droplet host
sudo sysctl -w vm.max_map_count=262144
```

### Logs not appearing in OpenSearch Dashboards
```bash
# Check Fluent Bit is forwarding
docker logs fluent-bit --tail 50

# Check OpenSearch is accepting data
curl http://localhost:9200/veex-*/_search?size=10
```

## Access URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Registry API | `http://registry.veexplatform.com` | Backend API |
| Studio | `http://studio.veexplatform.com` | Visual editor |
| Admin | `http://admin.veexplatform.com` | Admin portal |
| **Logs** | `http://logs.veexplatform.com` | **OpenSearch Dashboards** |

## Resource Usage
- **OpenSearch**: ~600MB RAM
- **OpenSearch Dashboards**: ~200MB RAM
- **Fluent Bit**: ~50MB RAM
- **Total Additional**: ~850MB RAM

Recommended droplet: **2GB RAM minimum** for all services.
