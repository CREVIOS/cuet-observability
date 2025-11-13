#!/usr/bin/env python3
"""
Demo web application with Prometheus metrics endpoint
Simulates a web service with health checks and custom metrics
"""

from flask import Flask, Response, jsonify
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY
import time
import random
import psutil

app = Flask(__name__)

# Define Prometheus metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total number of requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'Request duration in seconds')
APP_HEALTH = Gauge('app_health_status', 'Application health status (1=healthy, 0=unhealthy)')
CPU_USAGE = Gauge('app_cpu_usage_percent', 'Current CPU usage percentage')
MEMORY_USAGE = Gauge('app_memory_usage_bytes', 'Current memory usage in bytes')
RESPONSE_TIME = Gauge('app_response_time_seconds', 'Last response time in seconds')

# Simulate initial healthy state
APP_HEALTH.set(1)

@app.route('/')
def home():
    """Home endpoint"""
    REQUEST_COUNT.labels(method='GET', endpoint='/').inc()
    return jsonify({
        'message': 'Demo Observability Application',
        'status': 'running',
        'endpoints': {
            '/': 'Home',
            '/health': 'Health check',
            '/metrics': 'Prometheus metrics',
            '/load': 'Simulate load',
            '/unhealthy': 'Make app unhealthy'
        }
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    REQUEST_COUNT.labels(method='GET', endpoint='/health').inc()
    start_time = time.time()
    
    # Randomly simulate health issues (10% chance)
    is_healthy = random.random() > 0.1
    APP_HEALTH.set(1 if is_healthy else 0)
    
    duration = time.time() - start_time
    RESPONSE_TIME.set(duration)
    
    if is_healthy:
        return jsonify({'status': 'healthy'}), 200
    else:
        return jsonify({'status': 'unhealthy'}), 503

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    # Update system metrics
    try:
        cpu_percent = psutil.cpu_percent(interval=0.1)
        memory_info = psutil.Process().memory_info()
        
        CPU_USAGE.set(cpu_percent)
        MEMORY_USAGE.set(memory_info.rss)
    except Exception as e:
        print(f"Error collecting metrics: {e}")
    
    return Response(generate_latest(REGISTRY), mimetype='text/plain')

@app.route('/load')
def simulate_load():
    """Simulate high load to trigger CPU alerts"""
    REQUEST_COUNT.labels(method='GET', endpoint='/load').inc()
    start_time = time.time()
    
    # Simulate some CPU-intensive work
    result = 0
    for i in range(1000000):
        result += i ** 2
    
    duration = time.time() - start_time
    REQUEST_DURATION.observe(duration)
    RESPONSE_TIME.set(duration)
    
    return jsonify({
        'message': 'Load simulation completed',
        'duration_seconds': duration
    })

@app.route('/unhealthy')
def make_unhealthy():
    """Force app to become unhealthy"""
    REQUEST_COUNT.labels(method='GET', endpoint='/unhealthy').inc()
    APP_HEALTH.set(0)
    return jsonify({
        'message': 'App set to unhealthy state',
        'status': 'unhealthy'
    }), 503

@app.before_request
def before_request():
    """Track request start time"""
    app.request_start_time = time.time()

@app.after_request
def after_request(response):
    """Track request duration"""
    if hasattr(app, 'request_start_time'):
        duration = time.time() - app.request_start_time
        REQUEST_DURATION.observe(duration)
    return response

if __name__ == '__main__':
    print("Starting Demo Observability Application...")
    print("Endpoints:")
    print("  - http://localhost:8080/")
    print("  - http://localhost:8080/health")
    print("  - http://localhost:8080/metrics")
    print("  - http://localhost:8080/load")
    print("  - http://localhost:8080/unhealthy")
    app.run(host='0.0.0.0', port=8080, debug=False)

