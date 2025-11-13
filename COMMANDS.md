# 🚀 Quick Command Reference

## Essential Commands to Run the Observability Stack

### 1. Start the Stack

```bash
cd /Users/asif/Documents/git/cuet-observability

# Build and start all services
docker-compose up -d --build

# Wait for services to be ready (about 30 seconds)
sleep 30

# Check if all services are running
docker-compose ps
```

### 2. Access the Services

Open in your browser:
- **Demo App**: http://localhost:8080
- **Prometheus**: http://localhost:9090
- **Node Exporter**: http://localhost:9100/metrics
- **Grafana**: http://localhost:3000 (login: admin/admin)

### 3. View the Dashboard

```bash
# Navigate to Grafana
open http://localhost:3000

# Login: admin/admin
# Go to: Dashboards → Observability Demo Dashboard
```

### 4. Trigger Alerts

```bash
# Trigger high CPU alert (generate load)
for i in {1..20}; do curl http://localhost:8080/load & done; wait

# Trigger unhealthy app alert
curl http://localhost:8080/unhealthy

# Check alerts in Prometheus
open http://localhost:9090/alerts

# Wait 30-60 seconds for alerts to fire
```

### 5. Run Alert Dispatcher (Bonus)

```bash
# Install jq if needed (macOS)
brew install jq

# Run the alert dispatcher
./alert_dispatcher.sh

# In another terminal, view the logs
tail -f alert_logs.txt
```

### 6. Take Screenshot

```bash
# Take screenshot of Grafana dashboard showing:
# - All metrics panels
# - Active alerts (after triggering alerts)
# - CPU/Memory gauges
# - Time series graphs

# Save as: grafana-dashboard-screenshot.png
```

### 7. Stop the Stack

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

## Testing Commands

```bash
# Test app health
curl http://localhost:8080/health

# View app metrics
curl http://localhost:8080/metrics

# Generate continuous load (in background)
while true; do curl -s http://localhost:8080/load > /dev/null; sleep 2; done &

# Stop background load
pkill -f "curl.*localhost:8080/load"

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'

# Query specific metrics
curl -G http://localhost:9090/api/v1/query --data-urlencode 'query=app_cpu_usage_percent'
```

## Troubleshooting Commands

```bash
# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f app
docker-compose logs -f prometheus
docker-compose logs -f grafana

# Restart a specific service
docker-compose restart app

# Check resource usage
docker stats

# Validate Prometheus config
docker exec prometheus promtool check config /etc/prometheus/prometheus.yml

# Validate alert rules
docker exec prometheus promtool check rules /etc/prometheus/alert.rules.yml
```

## Git Commands

```bash
# Initialize git repository
git init

# Add all files
git add .

# Commit
git commit -m "Add observability stack with Prometheus, Grafana, and Node Exporter"

# Add remote (replace with your repo URL)
git remote add origin <your-github-repo-url>

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## Complete Setup Flow (Copy & Paste)

```bash
# Navigate to project
cd /Users/asif/Documents/git/cuet-observability

# Start services
docker-compose up -d --build

# Wait for initialization
echo "Waiting for services to start..."
sleep 30

# Check status
docker-compose ps

# Open Grafana
open http://localhost:3000

# Run alert dispatcher in background (optional)
./alert_dispatcher.sh > /dev/null 2>&1 &

# Trigger some alerts for testing
echo "Triggering test alerts..."
for i in {1..15}; do curl -s http://localhost:8080/load > /dev/null & done
sleep 5
curl http://localhost:8080/unhealthy

echo ""
echo "✅ Setup complete!"
echo ""
echo "Access points:"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - Prometheus: http://localhost:9090"
echo "  - Demo App: http://localhost:8080"
echo ""
echo "Wait 1-2 minutes for alerts to fire, then check:"
echo "  - Prometheus Alerts: http://localhost:9090/alerts"
echo "  - Grafana Dashboard → Active Alerts panel"
echo ""
```

