# 🔍 Observability & Monitoring Stack

A comprehensive local observability setup using Prometheus, Node Exporter, and Grafana to monitor a containerized web application.

## 📋 Overview

This project demonstrates a production-ready observability stack that:

- ✅ Monitors a local web service running in Docker
- ✅ Collects metrics like CPU, memory, and response time
- ✅ Visualizes metrics in a Grafana dashboard
- ✅ Triggers alerts when the app becomes unhealthy or CPU > 70%
- ✅ Dispatches alerts via a custom Bash script

## 🏗️ Architecture

```
┌─────────────────┐
│   Demo App      │  Exposes /metrics endpoint
│   (Flask)       │  Port: 8080
└────────┬────────┘
         │
         ├─────────────────────────────────┐
         │                                 │
         ▼                                 ▼
┌─────────────────┐              ┌──────────────────┐
│  Prometheus     │◄─────────────│  Node Exporter   │
│  Port: 9090     │              │  Port: 9100      │
└────────┬────────┘              └──────────────────┘
         │
         ▼
┌─────────────────┐              ┌──────────────────┐
│    Grafana      │              │ Alert Dispatcher │
│    Port: 3000   │              │  (Bash Script)   │
└─────────────────┘              └──────────────────┘
```

## 📦 Components

### 1. **Demo Application** (`app/`)
- Flask-based web application
- Exposes Prometheus metrics at `/metrics`
- Provides endpoints to simulate load and health issues
- Tracks CPU usage, memory usage, and response times

### 2. **Prometheus**
- Scrapes metrics from the demo app and Node Exporter
- Evaluates alert rules
- Stores time-series data
- Provides API for querying metrics

### 3. **Node Exporter**
- Collects system-level metrics (CPU, memory, disk, network)
- Exposes hardware and OS metrics

### 4. **Grafana**
- Visualizes metrics in real-time dashboards
- Pre-configured with Prometheus as data source
- Displays application and system metrics

### 5. **Alert Dispatcher** (Bonus)
- Bash script that polls Prometheus alerts API
- Logs alerts to a local file
- Color-coded terminal output for different severity levels

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- 4GB RAM available
- Ports 3000, 8080, 9090, 9100 available
- jq (for alert dispatcher script)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd cuet-observability

# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

### Accessing Services

| Service | URL | Credentials |
|---------|-----|-------------|
| Demo App | http://localhost:8080 | N/A |
| Prometheus | http://localhost:9090 | N/A |
| Node Exporter | http://localhost:9100 | N/A |
| Grafana | http://localhost:3000 | admin/admin |

## 📊 Grafana Dashboard

### Accessing the Dashboard

1. Open http://localhost:3000
2. Login with username: `admin`, password: `admin`
3. Navigate to **Dashboards** → **Observability Demo Dashboard**

### Dashboard Panels

The dashboard includes:

- **Application Health Status** - Real-time health indicator
- **CPU Usage Gauge** - Current system CPU usage
- **Memory Usage Gauge** - Current memory usage
- **CPU Usage Over Time** - Historical CPU trends
- **Memory Usage Over Time** - Historical memory trends
- **Application Response Time** - Request latency tracking
- **Request Rate by Endpoint** - Traffic analysis
- **Total Request Rate** - Aggregate traffic metrics
- **Service Availability** - Uptime monitoring
- **Active Alerts** - Current firing alerts

## 🚨 Alert Rules

### Configured Alerts

| Alert Name | Condition | Duration | Severity |
|------------|-----------|----------|----------|
| **ApplicationUnhealthy** | `app_health_status == 0` | 30s | Critical |
| **ApplicationDown** | `up{job="demo-app"} == 0` | 1m | Critical |
| **HighResponseTime** | `app_response_time_seconds > 1` | 2m | Warning |
| **HighCPUUsage** | System CPU > 70% | 1m | Warning |
| **HighApplicationCPU** | App CPU > 70% | 1m | Warning |
| **HighMemoryUsage** | Memory usage > 80% | 2m | Warning |
| **LowDiskSpace** | Disk free < 10% | 5m | Critical |
| **PrometheusTargetDown** | Target unavailable | 2m | Warning |

### Viewing Alerts

- **Prometheus**: http://localhost:9090/alerts
- **Grafana Dashboard**: Active Alerts panel
- **Alert Dispatcher**: `tail -f alert_logs.txt`

## 🧪 Testing Alerts

### Trigger High CPU Alert

```bash
# Generate load on the application
for i in {1..10}; do
  curl http://localhost:8080/load &
done
wait
```

### Trigger Unhealthy App Alert

```bash
# Make the app report unhealthy status
curl http://localhost:8080/unhealthy
```

### Check Alert Status

```bash
# Via Prometheus API
curl http://localhost:9090/api/v1/alerts | jq

# Via Alert Dispatcher
./alert_dispatcher.sh
```

## 📝 Alert Dispatcher Usage

The bonus alert dispatcher script monitors Prometheus and logs alerts:

```bash
# Run with default settings (localhost:9090)
./alert_dispatcher.sh

# Run with custom Prometheus URL
./alert_dispatcher.sh http://prometheus-host:9090

# Run with custom log file
./alert_dispatcher.sh http://localhost:9090 custom-alerts.log

# View alert logs
tail -f alert_logs.txt

# Stop the dispatcher
Press Ctrl+C
```

### Alert Dispatcher Features

- ✅ Real-time alert monitoring
- ✅ Color-coded severity levels (Critical/Warning/Info)
- ✅ Detailed alert information logging
- ✅ Alert summary statistics
- ✅ Automatic connectivity checks

## 📁 Project Structure

```
cuet-observability/
├── docker-compose.yml           # Docker services configuration
├── prometheus.yml               # Prometheus scrape configuration
├── alert.rules.yml              # Alert rules definitions
├── grafana-dashboard.json       # Grafana dashboard export
├── alert_dispatcher.sh          # Alert dispatcher script (Bonus)
├── README.md                    # This file
├── app/                         # Demo application
│   ├── app.py                   # Flask application
│   ├── requirements.txt         # Python dependencies
│   └── Dockerfile               # App container image
└── grafana-provisioning/        # Grafana auto-provisioning
    ├── datasources/
    │   └── prometheus.yml       # Prometheus data source
    └── dashboards/
        └── dashboard-provider.yml
```

## 🛠️ Useful Commands

### Docker Management

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# View logs for specific service
docker-compose logs -f prometheus
docker-compose logs -f app
docker-compose logs -f grafana

# Restart a service
docker-compose restart app

# Rebuild and restart
docker-compose up -d --build
```

### Metrics & Monitoring

```bash
# Check app metrics
curl http://localhost:8080/metrics

# Check app health
curl http://localhost:8080/health

# Query Prometheus API
curl 'http://localhost:9090/api/v1/query?query=up'

# Get active alerts
curl http://localhost:9090/api/v1/alerts | jq '.data.alerts'

# Check Node Exporter metrics
curl http://localhost:9100/metrics
```

### Troubleshooting

```bash
# Check if all containers are running
docker-compose ps

# Check container resource usage
docker stats

# Access container shell
docker exec -it demo-app /bin/sh
docker exec -it prometheus /bin/sh

# Validate Prometheus configuration
docker exec prometheus promtool check config /etc/prometheus/prometheus.yml

# Validate alert rules
docker exec prometheus promtool check rules /etc/prometheus/alert.rules.yml

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | jq
```

## 🎯 Metrics Collected

### Application Metrics
- `app_health_status` - Application health (1=healthy, 0=unhealthy)
- `app_cpu_usage_percent` - Application CPU usage
- `app_memory_usage_bytes` - Application memory usage
- `app_response_time_seconds` - Last response time
- `app_requests_total` - Total request count by endpoint
- `app_request_duration_seconds` - Request duration histogram

### System Metrics (Node Exporter)
- `node_cpu_seconds_total` - CPU time by mode
- `node_memory_*` - Memory statistics
- `node_filesystem_*` - Filesystem metrics
- `node_network_*` - Network interface metrics

## 🔧 Configuration Details

### Prometheus Scrape Intervals

- **Prometheus self-monitoring**: 15s
- **Demo App**: 10s
- **Node Exporter**: 10s

### Alert Evaluation

- **Evaluation Interval**: 15s
- **Scrape Interval**: 15s (global)

### Grafana Auto-refresh

- **Dashboard refresh**: 10s
- **Time range**: Last 15 minutes

## 📸 Screenshots

Screenshots should show:

1. ✅ Grafana dashboard with all panels displaying metrics
2. ✅ CPU usage gauge showing values
3. ✅ Memory usage trends
4. ✅ Application health status
5. ✅ Active alerts panel (when triggered)
6. ✅ Response time graphs
7. ✅ Request rate metrics

## 🎓 Learning Outcomes

This project demonstrates:

- ✅ Container orchestration with Docker Compose
- ✅ Metrics collection and exposition (Prometheus format)
- ✅ Time-series data storage and querying
- ✅ Alert rule configuration and evaluation
- ✅ Dashboard creation and visualization
- ✅ System monitoring best practices
- ✅ Alert dispatch automation

## 🤝 Contributing

Feel free to submit issues or pull requests to improve this observability stack!

## 📄 License

This project is open source and available for educational purposes.

## 🔗 References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [Prometheus Client Python](https://github.com/prometheus/client_python)

---

**Author**: Observability Demo Project  
**Purpose**: Educational demonstration of monitoring stack  
**Date**: 2025
