# Quick Start Guide

Get VEEX up and running in minutes.

## Prerequisites

- Docker 20.10 or later
- Docker Compose 2.0 or later
- 2GB available RAM
- 10GB available disk space

## Installation

### 1. Download

```bash
git clone https://github.com/veex-platform/veex-deploy.git
cd veex-deploy/docker/all-in-one
```

### 2. Start Services

```bash
docker-compose up -d
```

### 3. Verify Installation

```bash
../../scripts/health-check.sh
```

## Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| Studio | http://localhost:3000 | Visual VDL Editor |
| Platform API | http://localhost:8080 | REST API for CLI/devices |
| Dashboard | http://localhost:8080/dashboard | Real-time telemetry |

## First Steps

### Create Your First Device Logic

1. Open **Studio** at http://localhost:3000
2. Create a new VDL project
3. Use the visual editor to design your logic
4. Click "Build" to compile to `.vex`

### Register a Device

```bash
# Install VEEX CLI
curl -sSL https://get.veex.dev | bash

# Flash a device
veex flash firmware.vex --port COM3
```

### View Telemetry

Open the **Dashboard** at http://localhost:8080/dashboard to see real-time signals from your devices.

## Next Steps

- [Production Deployment Guide](production-deployment.md)
- [Security Best Practices](security.md)
- [CLI Documentation](https://github.com/veex-platform/veex-docs)

## Troubleshooting

### Services won't start
```bash
# Check logs
docker-compose logs

# Restart services
docker-compose restart
```

### Can't access Studio
- Verify port 3000 is not in use: `netstat -an | grep 3000`
- Check firewall rules

### Database errors
```bash
# Reset database (WARNING: deletes all data)
docker-compose down -v
docker-compose up -d
```

## Getting Help

- [Documentation](https://github.com/veex-platform/veex-docs)
- [Community Forum](https://github.com/veex-platform/veex-deploy/discussions)
- [Report Issues](https://github.com/veex-platform/veex-deploy/issues)
