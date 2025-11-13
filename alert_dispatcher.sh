#!/bin/bash

###############################################################################
# Alert Dispatcher Script
# 
# This script fetches active alerts from Prometheus API and logs them locally
# Simulates an alert dispatch system for observability monitoring
#
# Usage: ./alert_dispatcher.sh [prometheus_url] [log_file]
###############################################################################

set -e

# Configuration
PROMETHEUS_URL="${1:-http://localhost:9090}"
LOG_FILE="${2:-alert_logs.txt}"
ALERT_API="${PROMETHEUS_URL}/api/v1/alerts"
CHECK_INTERVAL=30  # seconds

# Colors for terminal output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Function to format alert details
format_alert() {
    local alert_json=$1
    local alert_name=$(echo "$alert_json" | jq -r '.labels.alertname // "Unknown"')
    local severity=$(echo "$alert_json" | jq -r '.labels.severity // "unknown"')
    local state=$(echo "$alert_json" | jq -r '.state // "unknown"')
    local description=$(echo "$alert_json" | jq -r '.annotations.description // "No description"')
    local value=$(echo "$alert_json" | jq -r '.annotations.value // "N/A"')
    
    echo "Alert: $alert_name | Severity: $severity | State: $state | Value: $value"
    echo "Description: $description"
}

# Function to send alert notification (simulated)
dispatch_alert() {
    local alert_json=$1
    local alert_name=$(echo "$alert_json" | jq -r '.labels.alertname')
    local severity=$(echo "$alert_json" | jq -r '.labels.severity')
    local state=$(echo "$alert_json" | jq -r '.state')
    
    # Format alert details
    local alert_details=$(format_alert "$alert_json")
    
    # Determine log level based on severity
    case "$severity" in
        critical)
            log_message "CRITICAL" "$alert_details"
            echo -e "${RED}🚨 CRITICAL ALERT: $alert_name${NC}"
            ;;
        warning)
            log_message "WARNING" "$alert_details"
            echo -e "${YELLOW}⚠️  WARNING ALERT: $alert_name${NC}"
            ;;
        *)
            log_message "INFO" "$alert_details"
            echo -e "${BLUE}ℹ️  INFO ALERT: $alert_name${NC}"
            ;;
    esac
    
    # Add separator to log file
    echo "----------------------------------------" >> "$LOG_FILE"
}

# Function to check Prometheus connectivity
check_prometheus() {
    if curl -s -f "${PROMETHEUS_URL}/-/healthy" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to fetch and process alerts
fetch_alerts() {
    local response=$(curl -s "$ALERT_API" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to fetch alerts from Prometheus"
        return 1
    fi
    
    # Check if response is valid JSON
    if ! echo "$response" | jq empty 2>/dev/null; then
        log_message "ERROR" "Invalid JSON response from Prometheus"
        return 1
    fi
    
    # Extract alerts
    local alerts=$(echo "$response" | jq -c '.data.alerts[]?' 2>/dev/null)
    
    if [ -z "$alerts" ]; then
        echo -e "${GREEN}✅ No active alerts at $(date '+%H:%M:%S')${NC}"
        log_message "INFO" "No active alerts detected"
        return 0
    fi
    
    # Process each alert
    local alert_count=0
    while IFS= read -r alert; do
        if [ ! -z "$alert" ]; then
            dispatch_alert "$alert"
            ((alert_count++))
        fi
    done <<< "$alerts"
    
    log_message "INFO" "Processed $alert_count alert(s)"
    echo -e "${BLUE}Processed $alert_count alert(s)${NC}"
}

# Function to display alert summary
display_summary() {
    echo ""
    echo "==================================="
    echo "  Alert Dispatcher Summary"
    echo "==================================="
    echo "Prometheus URL: $PROMETHEUS_URL"
    echo "Log File: $LOG_FILE"
    echo "Last Check: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    if [ -f "$LOG_FILE" ]; then
        local total_alerts=$(grep -c "Alert:" "$LOG_FILE" 2>/dev/null || echo "0")
        local critical_alerts=$(grep -c "\[CRITICAL\]" "$LOG_FILE" 2>/dev/null || echo "0")
        local warning_alerts=$(grep -c "\[WARNING\]" "$LOG_FILE" 2>/dev/null || echo "0")
        
        echo "Total Alerts Logged: $total_alerts"
        echo -e "${RED}Critical Alerts: $critical_alerts${NC}"
        echo -e "${YELLOW}Warning Alerts: $warning_alerts${NC}"
    fi
    echo "==================================="
    echo ""
}

# Main function
main() {
    echo "╔══════════════════════════════════════╗"
    echo "║   Prometheus Alert Dispatcher       ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    
    # Check dependencies
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is not installed. Please install it first.${NC}"
        echo "On macOS: brew install jq"
        echo "On Ubuntu: sudo apt-get install jq"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is not installed.${NC}"
        exit 1
    fi
    
    # Initialize log file
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
        log_message "INFO" "Alert dispatcher started"
    fi
    
    echo "Connecting to Prometheus at $PROMETHEUS_URL..."
    
    # Check Prometheus connectivity
    if ! check_prometheus; then
        echo -e "${RED}Error: Cannot connect to Prometheus at $PROMETHEUS_URL${NC}"
        echo "Make sure Prometheus is running and accessible."
        exit 1
    fi
    
    echo -e "${GREEN}✅ Connected to Prometheus successfully${NC}"
    echo ""
    echo "Monitoring for alerts... (Press Ctrl+C to stop)"
    echo "Check interval: ${CHECK_INTERVAL}s"
    echo ""
    
    # Trap Ctrl+C to display summary before exit
    trap 'echo ""; display_summary; exit 0' INT TERM
    
    # Main monitoring loop
    while true; do
        fetch_alerts
        echo ""
        sleep "$CHECK_INTERVAL"
    done
}

# Run main function
main "$@"

