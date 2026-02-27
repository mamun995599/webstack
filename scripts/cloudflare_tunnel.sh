#!/bin/bash
# cloudflare_tunnel.sh - Manage Try Cloudflare random tunnels with auto-reconnect

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"

CLOUDFLARED="$WEBSTACK_ROOT/deps/bin/cloudflared"
PID_FILE="$WEBSTACK_ROOT/tmp/cloudflare_tunnel.pid"
MONITOR_PID_FILE="$WEBSTACK_ROOT/tmp/cloudflare_monitor.pid"
URL_FILE="$WEBSTACK_ROOT/tmp/cloudflare_url.txt"
LOG_FILE="$WEBSTACK_ROOT/logs/cloudflare/tunnel.log"
URL_HISTORY="$WEBSTACK_ROOT/logs/cloudflare/url_history.log"
TUNNEL_LOG="$WEBSTACK_ROOT/logs/cloudflare/cloudflared.log"
DEFAULT_PORT=80
MAX_RETRIES=5
RETRY_DELAY=10
HEALTH_CHECK_INTERVAL=30

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

mkdir -p "$WEBSTACK_ROOT/logs/cloudflare" "$WEBSTACK_ROOT/tmp"

log() {
    local level="$1"; shift
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $*" >> "$LOG_FILE"
    case "$level" in
        INFO)  echo -e "${GREEN}[$timestamp]${NC} $*" ;;
        WARN)  echo -e "${YELLOW}[$timestamp]${NC} $*" ;;
        ERROR) echo -e "${RED}[$timestamp]${NC} $*" ;;
        *)     echo "[$timestamp] $*" ;;
    esac
}

save_url_to_history() {
    local url="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local entry="$timestamp | $url"
    
    if [ -f "$URL_HISTORY" ]; then
        echo "$entry" | cat - "$URL_HISTORY" > "$URL_HISTORY.tmp"
        mv "$URL_HISTORY.tmp" "$URL_HISTORY"
    else
        echo "$entry" > "$URL_HISTORY"
    fi
    
    head -100 "$URL_HISTORY" > "$URL_HISTORY.tmp" 2>/dev/null && mv "$URL_HISTORY.tmp" "$URL_HISTORY"
    echo "$url" > "$URL_FILE"
    log "INFO" "New tunnel URL: $url"
}

extract_url() {
    local log_file="$1"
    for i in {1..30}; do
        if [ -f "$log_file" ]; then
            local url=$(grep -oE 'https://[a-zA-Z0-9-]+\.trycloudflare\.com' "$log_file" 2>/dev/null | tail -1)
            [ -n "$url" ] && echo "$url" && return 0
        fi
        sleep 1
    done
    return 1
}

is_tunnel_healthy() {
    local pid="${1:-}"
    [ -z "$pid" ] && [ -f "$PID_FILE" ] && pid=$(cat "$PID_FILE")
    [ -z "$pid" ] && return 1
    kill -0 "$pid" 2>/dev/null
}

start_tunnel() {
    local port="${1:-$DEFAULT_PORT}"
    
    if [ ! -x "$CLOUDFLARED" ]; then
        log "ERROR" "Cloudflared not found. Run: ./install_cloudflared.sh"
        return 1
    fi
    
    if [ -f "$PID_FILE" ] && is_tunnel_healthy; then
        log "WARN" "Tunnel already running"
        [ -f "$URL_FILE" ] && echo -e "\n${GREEN}Current URL:${NC} $(cat "$URL_FILE")"
        return 0
    fi
    
    rm -f "$PID_FILE"
    log "INFO" "Starting Cloudflare tunnel on port $port..."
    
    > "$TUNNEL_LOG"
    nohup "$CLOUDFLARED" tunnel --url "http://localhost:$port" --no-autoupdate >> "$TUNNEL_LOG" 2>&1 &
    local tunnel_pid=$!
    echo "$tunnel_pid" > "$PID_FILE"
    
    echo -n "Waiting for tunnel URL"
    local url=""
    for i in {1..30}; do
        echo -n "."
        url=$(extract_url "$TUNNEL_LOG")
        [ -n "$url" ] && break
        is_tunnel_healthy "$tunnel_pid" || { echo ""; log "ERROR" "Process died"; rm -f "$PID_FILE"; return 1; }
        sleep 1
    done
    echo ""
    
    [ -z "$url" ] && { log "ERROR" "Failed to get URL"; stop_tunnel; return 1; }
    
    save_url_to_history "$url"
    
    echo ""
    echo "========================================"
    echo -e "${GREEN}Tunnel Started!${NC}"
    echo "========================================"
    echo -e "URL:  ${BLUE}$url${NC}"
    echo -e "Port: $port"
    echo -e "PID:  $tunnel_pid"
    echo ""
}

stop_tunnel() {
    log "INFO" "Stopping tunnel..."
    [ -f "$PID_FILE" ] && { kill $(cat "$PID_FILE") 2>/dev/null; rm -f "$PID_FILE"; }
    pkill -f "cloudflared tunnel --url" 2>/dev/null || true
    echo "Tunnel stopped"
}

monitor_tunnel() {
    local port="${1:-$DEFAULT_PORT}"
    local failures=0
    
    trap 'log "INFO" "Shutdown"; stop_tunnel; exit 0' SIGINT SIGTERM
    
    # Initial start
    start_tunnel "$port" || failures=$((failures + 1))
    
    while true; do
        sleep $HEALTH_CHECK_INTERVAL
        
        if ! is_tunnel_healthy; then
            failures=$((failures + 1))
            log "WARN" "Tunnel unhealthy (failure #$failures)"
            
            if [ $failures -ge $MAX_RETRIES ]; then
                log "ERROR" "Max retries reached, creating new tunnel..."
                failures=0
            fi
            
            stop_tunnel
            sleep $RETRY_DELAY
            start_tunnel "$port" && failures=0 || log "ERROR" "Restart failed"
        else
            failures=0
        fi
    done
}

start_daemon() {
    local port="${1:-$DEFAULT_PORT}"
    
    if [ -f "$MONITOR_PID_FILE" ] && kill -0 $(cat "$MONITOR_PID_FILE") 2>/dev/null; then
        log "WARN" "Daemon already running"
        return 0
    fi
    
    nohup "$0" monitor "$port" >> "$LOG_FILE" 2>&1 &
    echo $! > "$MONITOR_PID_FILE"
    
    sleep 5
    [ -f "$URL_FILE" ] && echo -e "${GREEN}Daemon started!${NC}\nURL: ${BLUE}$(cat "$URL_FILE")${NC}"
}

stop_daemon() {
    stop_tunnel
    [ -f "$MONITOR_PID_FILE" ] && { kill $(cat "$MONITOR_PID_FILE") 2>/dev/null; kill -9 $(cat "$MONITOR_PID_FILE") 2>/dev/null; rm -f "$MONITOR_PID_FILE"; }
    echo "Daemon stopped"
}

show_status() {
    echo ""
    echo "========================================"
    echo "Cloudflare Tunnel Status"
    echo "========================================"
    echo ""
    
    if [ -f "$PID_FILE" ] && is_tunnel_healthy; then
        echo -e "Status: ${GREEN}RUNNING${NC}"
        echo -e "PID:    $(cat "$PID_FILE")"
        [ -f "$URL_FILE" ] && echo -e "URL:    ${BLUE}$(cat "$URL_FILE")${NC}"
    else
        echo -e "Status: ${YELLOW}STOPPED${NC}"
    fi
    
    if [ -f "$MONITOR_PID_FILE" ] && kill -0 $(cat "$MONITOR_PID_FILE") 2>/dev/null; then
        echo -e "Daemon: ${GREEN}RUNNING${NC} (PID: $(cat "$MONITOR_PID_FILE"))"
    fi
    
    echo ""
    echo "Recent URLs:"
    [ -f "$URL_HISTORY" ] && head -5 "$URL_HISTORY" | while read line; do echo "  $line"; done
    echo ""
}

show_url() {
    [ -f "$URL_FILE" ] && cat "$URL_FILE" || { echo "No active tunnel"; return 1; }
}

show_logs() {
    echo "========================================"
    echo "URL History (newest first)"
    echo "========================================"
    [ -f "$URL_HISTORY" ] && cat "$URL_HISTORY" || echo "No history"
}

case "${1:-}" in
    start)    start_tunnel "${2:-$DEFAULT_PORT}" ;;
    stop)     stop_tunnel ;;
    restart)  stop_tunnel; sleep 2; start_tunnel "${2:-$DEFAULT_PORT}" ;;
    status)   show_status ;;
    url)      show_url ;;
    logs|history) show_logs ;;
    monitor)  monitor_tunnel "${2:-$DEFAULT_PORT}" ;;
    daemon)   start_daemon "${2:-$DEFAULT_PORT}" ;;
    stop-daemon) stop_daemon ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|url|logs|daemon|stop-daemon|monitor} [port]"
        echo ""
        echo "Commands:"
        echo "  start [port]    Start tunnel (default: 80)"
        echo "  stop            Stop tunnel"
        echo "  restart         Get new random URL"
        echo "  status          Show status"
        echo "  url             Show current URL"
        echo "  logs            Show URL history"
        echo "  daemon [port]   Start with auto-reconnect"
        echo "  stop-daemon     Stop daemon"
        exit 1
        ;;
esac
