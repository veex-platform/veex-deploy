#!/bin/bash
# VEEX Health Check Script
# Usage: ./health-check.sh [platform-url]

PLATFORM_URL="${1:-http://localhost:8080}"
STUDIO_URL="${2:-http://localhost:3000}"

echo "🔍 VEEX Health Check"
echo "===================="

# Check Platform API
echo -n "Platform API ($PLATFORM_URL)... "
if curl -s -f "$PLATFORM_URL/api/v1/registry/check-update?device_id=health&current_version=0.0.0" > /dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    exit 1
fi

# Check Dashboard
echo -n "Dashboard ($PLATFORM_URL/dashboard)... "
if curl -s -f "$PLATFORM_URL/dashboard" > /dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    exit 1
fi

# Check Studio
echo -n "Studio ($STUDIO_URL)... "
if curl -s -f "$STUDIO_URL" > /dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    exit 1
fi

echo ""
echo "✅ All services are healthy!"
exit 0
