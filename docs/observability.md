# Prometheus & Grafana Observability Stack - Deployment Guide

## Overview
Centralized monitoring solution for all VEEX Platform services using Prometheus for metrics collection and Grafana for visualization.

## Architecture
```
VEEX Platform (Golang API)
    ↓ (HTTP metrics endpoint /api/v1/metrics)
Prometheus (Metrics Scraper & Time-Series DB)
    ↓ (PromQL & HTTP API)
Grafana (Visualization & Dashboards)
    ↓ (Web UI, port 3000)
Users / Admins
```

## Services Added

### 1. **Prometheus**
- **Image**: `prom/prometheus:latest`
- **Port**: `9090`
- **Config**: `prometheus.yml` - scrapes `veex-platform` every 15 seconds.
- **Storage**: Persistent volume `prometheus-data`.

### 2. **Grafana**
- **Image**: `grafana/grafana:latest`
- **Port**: `3000`
- **Access**: `http://logs.veexplatform.com` or `http://<DROPLET-IP>:3000`
- **Authentication**: 
  - Anonymous access enabled as **Admin**.
  - Default login: `admin` / `admin`.

## Deployment Instructions

### Step 1: Deploy Stack
```bash
cd /path/to/veex-deploy/docker/all-in-one
docker-compose up -d
```

### Step 2: Verify Services
```bash
# Check all containers are running
docker-compose ps

# Expected services:
# - veex-platform
# - veex-studio
# - veex-admin
# - veex-gateway
# - prometheus
# - grafana
```

### Step 3: Verify Metrics Scraping
1. Access Prometheus: `http://<DROPLET-IP>:9090`
2. Go to **Status** → **Targets**
3. Verify that `veex-platform` is **UP**.

### Step 4: Access Grafana & Create Dashboard
1. Open browser: `http://logs.veexplatform.com` (or `http://<DROPLET-IP>:3000`)
2. **Add Data Source**:
   - URL: `http://prometheus:9090`
   - Type: `Prometheus`
3. **Check Metrics**: Try querying `veex_devices_total` or `veex_uptime_seconds`.

## Platform Metrics
The `veex-platform` exposes the following custom metrics:
- `veex_devices_total`: Total registered devices.
- `veex_devices_active`: Devices active in the last hour.
- `veex_fleets_total`: Total device fleets.
- `veex_campaigns_active`: Active OTA campaigns.
- `veex_signals_last_hour`: Telemetry signals received in the last hour.
- `veex_uptime_seconds`: Platform uptime.

## Access URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Registry API | `http://registry.veexplatform.com` | Backend API |
| Studio | `http://studio.veexplatform.com` | Visual editor |
| Admin | `http://admin.veexplatform.com` | Admin portal |
| **Metrics/Dashboards** | `http://logs.veexplatform.com` | **Grafana** |

## Resource Usage
- **Prometheus**: ~150MB RAM
- **Grafana**: ~150MB RAM
- **Total Additional**: ~300MB RAM

Recommended droplet: **1GB RAM** is now sufficient
