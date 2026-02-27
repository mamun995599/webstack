#!/bin/bash
# create_scripts.sh - Create all management scripts

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "Creating WebStack Management Scripts"
echo "========================================"
echo ""

mkdir -p "$WEBSTACK_ROOT/scripts"

# ============================================
# Main webstack control script
# ============================================
echo "[1/8] Creating main control script..."

cat > "$WEBSTACK_ROOT/webstack" << 'MAINSCRIPT'
#!/bin/bash
# webstack - Main control script

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
export PATH="$WEBSTACK_ROOT/deps/bin:$WEBSTACK_ROOT/php/bin:$WEBSTACK_ROOT/node/bin:$WEBSTACK_ROOT/mysql/bin:$WEBSTACK_ROOT/nginx/sbin:$PATH"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$WEBSTACK_ROOT/php/lib:$LD_LIBRARY_PATH"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    local name="$1"
    local pid_file="$2"
    local status="${RED}STOPPED${NC}"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            status="${GREEN}RUNNING${NC} (PID: $pid)"
        fi
    fi
    printf "  %-12s %b\n" "$name:" "$status"
}

start_nginx() {
    echo -n "Starting Nginx... "
    if [ -f "$WEBSTACK_ROOT/tmp/nginx.pid" ] && kill -0 $(cat "$WEBSTACK_ROOT/tmp/nginx.pid") 2>/dev/null; then
        echo "already running"
        return 0
    fi
    "$WEBSTACK_ROOT/nginx/sbin/nginx" -p "$WEBSTACK_ROOT/nginx" 2>/dev/null && echo "OK" || echo "FAILED"
}

stop_nginx() {
    echo -n "Stopping Nginx... "
    if [ -f "$WEBSTACK_ROOT/tmp/nginx.pid" ]; then
        "$WEBSTACK_ROOT/nginx/sbin/nginx" -p "$WEBSTACK_ROOT/nginx" -s quit 2>/dev/null
        sleep 1
    fi
    echo "OK"
}

start_php() {
    echo -n "Starting PHP-FPM... "
    if [ -f "$WEBSTACK_ROOT/php/var/run/php-fpm.pid" ] && kill -0 $(cat "$WEBSTACK_ROOT/php/var/run/php-fpm.pid") 2>/dev/null; then
        echo "already running"
        return 0
    fi
    "$WEBSTACK_ROOT/php/sbin/php-fpm" -c "$WEBSTACK_ROOT/php/etc/php.ini" -y "$WEBSTACK_ROOT/php/etc/php-fpm.conf" 2>/dev/null && echo "OK" || echo "FAILED"
}

stop_php() {
    echo -n "Stopping PHP-FPM... "
    if [ -f "$WEBSTACK_ROOT/php/var/run/php-fpm.pid" ]; then
        kill $(cat "$WEBSTACK_ROOT/php/var/run/php-fpm.pid") 2>/dev/null
        rm -f "$WEBSTACK_ROOT/php/var/run/php-fpm.pid"
    fi
    rm -f "$WEBSTACK_ROOT/tmp/php-fpm.sock"
    echo "OK"
}

start_node() {
    echo -n "Starting Node.js... "
    if [ -f "$WEBSTACK_ROOT/tmp/node.pid" ] && kill -0 $(cat "$WEBSTACK_ROOT/tmp/node.pid") 2>/dev/null; then
        echo "already running"
        return 0
    fi
    cd "$WEBSTACK_ROOT/www"
    nohup "$WEBSTACK_ROOT/node/bin/node" app.js > "$WEBSTACK_ROOT/logs/node.log" 2>&1 &
    echo $! > "$WEBSTACK_ROOT/tmp/node.pid"
    echo "OK"
}

stop_node() {
    echo -n "Stopping Node.js... "
    [ -f "$WEBSTACK_ROOT/tmp/node.pid" ] && kill $(cat "$WEBSTACK_ROOT/tmp/node.pid") 2>/dev/null
    rm -f "$WEBSTACK_ROOT/tmp/node.pid"
    echo "OK"
}

start_ws() {
    echo -n "Starting WebSocket... "
    if [ -f "$WEBSTACK_ROOT/tmp/ws.pid" ] && kill -0 $(cat "$WEBSTACK_ROOT/tmp/ws.pid") 2>/dev/null; then
        echo "already running"
        return 0
    fi
    cd "$WEBSTACK_ROOT/ws"
    [ ! -d "node_modules" ] && npm install --silent 2>/dev/null
    nohup "$WEBSTACK_ROOT/node/bin/node" server.js > "$WEBSTACK_ROOT/logs/ws.log" 2>&1 &
    echo $! > "$WEBSTACK_ROOT/tmp/ws.pid"
    echo "OK"
}

stop_ws() {
    echo -n "Stopping WebSocket... "
    [ -f "$WEBSTACK_ROOT/tmp/ws.pid" ] && kill $(cat "$WEBSTACK_ROOT/tmp/ws.pid") 2>/dev/null
    rm -f "$WEBSTACK_ROOT/tmp/ws.pid"
    echo "OK"
}

start_mysql() {
    if [ ! -d "$WEBSTACK_ROOT/mysql" ]; then return; fi
    echo -n "Starting MySQL... "
    if [ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ]; then
        echo "already running"
        return 0
    fi
    "$WEBSTACK_ROOT/mysql/bin/mysqld_safe" --defaults-file="$WEBSTACK_ROOT/mysql/my.cnf" &
    sleep 3
    [ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ] && echo "OK" || echo "FAILED"
}

stop_mysql() {
    if [ ! -d "$WEBSTACK_ROOT/mysql" ]; then return; fi
    echo -n "Stopping MySQL... "
    if [ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ]; then
        "$WEBSTACK_ROOT/mysql/bin/mysqladmin" --socket="$WEBSTACK_ROOT/tmp/mysql.sock" -u root shutdown 2>/dev/null
    fi
    [ -f "$WEBSTACK_ROOT/tmp/mysql.pid" ] && kill $(cat "$WEBSTACK_ROOT/tmp/mysql.pid") 2>/dev/null
    rm -f "$WEBSTACK_ROOT/tmp/mysql.pid" "$WEBSTACK_ROOT/tmp/mysql.sock"
    echo "OK"
}

start_cloudflare() {
    if [ -x "$WEBSTACK_ROOT/scripts/cloudflare_tunnel.sh" ]; then
        "$WEBSTACK_ROOT/scripts/cloudflare_tunnel.sh" daemon 80
    fi
}

stop_cloudflare() {
    if [ -x "$WEBSTACK_ROOT/scripts/cloudflare_tunnel.sh" ]; then
        "$WEBSTACK_ROOT/scripts/cloudflare_tunnel.sh" stop-daemon
    fi
}

status() {
    echo ""
    echo "========================================"
    echo "WebStack Status"
    echo "========================================"
    echo ""
    print_status "Nginx" "$WEBSTACK_ROOT/tmp/nginx.pid"
    print_status "PHP-FPM" "$WEBSTACK_ROOT/php/var/run/php-fpm.pid"
    print_status "Node.js" "$WEBSTACK_ROOT/tmp/node.pid"
    print_status "WebSocket" "$WEBSTACK_ROOT/tmp/ws.pid"
    [ -d "$WEBSTACK_ROOT/mysql" ] && print_status "MySQL" "$WEBSTACK_ROOT/tmp/mysql.pid"
    
    # Cloudflare tunnel
    if [ -f "$WEBSTACK_ROOT/tmp/cloudflare_tunnel.pid" ]; then
        local cf_pid=$(cat "$WEBSTACK_ROOT/tmp/cloudflare_tunnel.pid")
        if kill -0 "$cf_pid" 2>/dev/null; then
            local cf_url=""
            [ -f "$WEBSTACK_ROOT/tmp/cloudflare_url.txt" ] && cf_url=$(cat "$WEBSTACK_ROOT/tmp/cloudflare_url.txt")
            printf "  %-12s ${GREEN}RUNNING${NC}\n" "Cloudflare:"
            [ -n "$cf_url" ] && printf "  %-12s ${BLUE}%s${NC}\n" "Tunnel URL:" "$cf_url"
        else
            printf "  %-12s ${YELLOW}DEAD${NC}\n" "Cloudflare:"
        fi
    else
        printf "  %-12s ${YELLOW}STOPPED${NC}\n" "Cloudflare:"
    fi
    
    echo ""
    echo "URLs:"
    echo "  HTTP:       http://localhost"
    echo "  HTTPS:      https://localhost"
    echo "  RTMP:       rtmp://localhost:1935/live/streamkey"
    echo "  RTMPS:      rtmps://localhost:1936/live/streamkey"
    [ -f "$WEBSTACK_ROOT/tmp/cloudflare_url.txt" ] && echo "  Cloudflare: $(cat "$WEBSTACK_ROOT/tmp/cloudflare_url.txt")"
    echo ""
}

case "$1" in
    start)
        echo ""
        start_php
        start_nginx
        start_node
        start_ws
        start_mysql
        echo ""
        echo "WebStack started!"
        echo ""
        ;;
    stop)
        echo ""
        stop_cloudflare
        stop_ws
        stop_node
        stop_nginx
        stop_php
        stop_mysql
        echo ""
        echo "WebStack stopped!"
        echo ""
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    status)
        status
        ;;
    tunnel)
        shift
        if [ -x "$WEBSTACK_ROOT/scripts/cloudflare_tunnel.sh" ]; then
            "$WEBSTACK_ROOT/scripts/cloudflare_tunnel.sh" "$@"
        else
            echo "Cloudflare tunnel not installed. Run: ./install_cloudflared.sh"
        fi
        ;;
    logs)
        echo "=== Nginx Error Log ==="
        tail -20 "$WEBSTACK_ROOT/nginx/logs/error.log" 2>/dev/null
        echo ""
        echo "=== PHP-FPM Log ==="
        tail -20 "$WEBSTACK_ROOT/php/var/log/php-fpm.log" 2>/dev/null
        echo ""
        echo "=== Node.js Log ==="
        tail -20 "$WEBSTACK_ROOT/logs/node.log" 2>/dev/null
        ;;
    *)
        echo "WebStack Control"
        echo ""
        echo "Usage: $0 {start|stop|restart|status|tunnel|logs}"
        echo ""
        echo "Commands:"
        echo "  start         Start all services"
        echo "  stop          Stop all services"
        echo "  restart       Restart all services"
        echo "  status        Show status of all services"
        echo "  tunnel <cmd>  Manage Cloudflare tunnel"
        echo "  logs          Show recent logs"
        echo ""
        echo "Tunnel commands:"
        echo "  tunnel start       Start tunnel"
        echo "  tunnel stop        Stop tunnel"
        echo "  tunnel daemon      Start with auto-reconnect"
        echo "  tunnel status      Show tunnel status"
        echo "  tunnel url         Show current URL"
        echo "  tunnel logs        Show URL history"
        echo ""
        exit 1
        ;;
esac
MAINSCRIPT

chmod +x "$WEBSTACK_ROOT/webstack"
echo "  Done"

# ============================================
# Cloudflare tunnel script
# ============================================
echo "[2/8] Creating Cloudflare tunnel script..."

cat > "$WEBSTACK_ROOT/scripts/cloudflare_tunnel.sh" << 'CFSCRIPT'
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
CFSCRIPT

chmod +x "$WEBSTACK_ROOT/scripts/cloudflare_tunnel.sh"
echo "  Done"

# ============================================
# MySQL scripts
# ============================================
echo "[3/8] Creating MySQL scripts..."

cat > "$WEBSTACK_ROOT/scripts/start_mysql.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/mysql/lib:$LD_LIBRARY_PATH"

[ ! -d "$WEBSTACK_ROOT/mysql" ] && { echo "MySQL not installed"; exit 1; }
[ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ] && { echo "Already running"; exit 0; }

echo "Starting MySQL..."
"$WEBSTACK_ROOT/mysql/bin/mysqld_safe" --defaults-file="$WEBSTACK_ROOT/mysql/my.cnf" &
sleep 3
[ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ] && echo "Started" || echo "Failed"
EOF

cat > "$WEBSTACK_ROOT/scripts/stop_mysql.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/mysql/lib:$LD_LIBRARY_PATH"

echo "Stopping MySQL..."
[ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ] && "$WEBSTACK_ROOT/mysql/bin/mysqladmin" --socket="$WEBSTACK_ROOT/tmp/mysql.sock" -u root shutdown 2>/dev/null
[ -f "$WEBSTACK_ROOT/tmp/mysql.pid" ] && kill $(cat "$WEBSTACK_ROOT/tmp/mysql.pid") 2>/dev/null
rm -f "$WEBSTACK_ROOT/tmp/mysql.pid" "$WEBSTACK_ROOT/tmp/mysql.sock"
echo "Stopped"
EOF

chmod +x "$WEBSTACK_ROOT/scripts/start_mysql.sh" "$WEBSTACK_ROOT/scripts/stop_mysql.sh"
echo "  Done"

# ============================================
# Backup script
# ============================================
echo "[4/8] Creating backup script..."

cat > "$WEBSTACK_ROOT/scripts/backup.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$WEBSTACK_ROOT/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "Creating backup..."

# Backup www
tar -czf "$BACKUP_DIR/www_$TIMESTAMP.tar.gz" -C "$WEBSTACK_ROOT" www 2>/dev/null

# Backup MySQL
if [ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ]; then
    "$WEBSTACK_ROOT/mysql/bin/mysqldump" --socket="$WEBSTACK_ROOT/tmp/mysql.sock" -u root --all-databases > "$BACKUP_DIR/mysql_$TIMESTAMP.sql" 2>/dev/null
    gzip "$BACKUP_DIR/mysql_$TIMESTAMP.sql"
fi

# Backup configs
tar -czf "$BACKUP_DIR/config_$TIMESTAMP.tar.gz" \
    -C "$WEBSTACK_ROOT" \
    nginx/conf php/etc mysql/my.cnf 2>/dev/null

# Keep only last 10 backups of each type
for prefix in www mysql config; do
    ls -t "$BACKUP_DIR/${prefix}_"* 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
done

echo "Backup complete: $BACKUP_DIR"
ls -lh "$BACKUP_DIR"/*_$TIMESTAMP* 2>/dev/null
EOF

chmod +x "$WEBSTACK_ROOT/scripts/backup.sh"
echo "  Done"

# ============================================
# SSL renewal script
# ============================================
echo "[5/8] Creating SSL script..."

cat > "$WEBSTACK_ROOT/scripts/renew_ssl.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
SSL_DIR="$WEBSTACK_ROOT/nginx/conf/ssl"

echo "Generating new SSL certificate..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/key.pem" \
    -out "$SSL_DIR/cert.pem" \
    -subj "/C=US/ST=State/L=City/O=WebStack/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" 2>/dev/null

chmod 600 "$SSL_DIR/key.pem"

# Reload nginx
[ -f "$WEBSTACK_ROOT/tmp/nginx.pid" ] && "$WEBSTACK_ROOT/nginx/sbin/nginx" -p "$WEBSTACK_ROOT/nginx" -s reload

echo "SSL certificate renewed"
openssl x509 -in "$SSL_DIR/cert.pem" -noout -dates
EOF

chmod +x "$WEBSTACK_ROOT/scripts/renew_ssl.sh"
echo "  Done"

# ============================================
# Environment script
# ============================================
echo "[6/8] Creating environment script..."

cat > "$WEBSTACK_ROOT/scripts/env.sh" << 'EOF'
#!/bin/bash
# Source this file: source ./scripts/env.sh

WEBSTACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export PATH="$WEBSTACK_ROOT/deps/bin:$WEBSTACK_ROOT/php/bin:$WEBSTACK_ROOT/node/bin:$WEBSTACK_ROOT/mysql/bin:$WEBSTACK_ROOT/nginx/sbin:$PATH"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$WEBSTACK_ROOT/php/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$WEBSTACK_ROOT/deps/lib/pkgconfig:$PKG_CONFIG_PATH"
export SSL_CERT_FILE="$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem"

echo "WebStack environment loaded"
echo "  PHP:   $(php -v 2>/dev/null | head -1 || echo 'not found')"
echo "  Node:  $(node -v 2>/dev/null || echo 'not found')"
echo "  Nginx: $($WEBSTACK_ROOT/nginx/sbin/nginx -v 2>&1 | head -1)"
EOF

chmod +x "$WEBSTACK_ROOT/scripts/env.sh"
echo "  Done"

# ============================================
# Health check script
# ============================================
echo "[7/8] Creating health check script..."

cat > "$WEBSTACK_ROOT/scripts/health.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"

echo "WebStack Health Check"
echo "====================="

check() {
    local name="$1"
    local cmd="$2"
    echo -n "$name: "
    if eval "$cmd" >/dev/null 2>&1; then
        echo "OK"
        return 0
    else
        echo "FAIL"
        return 1
    fi
}

check "Nginx" "curl -s http://localhost >/dev/null"
check "PHP-FPM" "curl -s http://localhost/index.php >/dev/null"
check "Node.js" "curl -s http://localhost/api/status >/dev/null"
check "WebSocket" "[ -f '$WEBSTACK_ROOT/tmp/ws.pid' ] && kill -0 \$(cat '$WEBSTACK_ROOT/tmp/ws.pid')"

if [ -d "$WEBSTACK_ROOT/mysql" ]; then
    check "MySQL" "[ -S '$WEBSTACK_ROOT/tmp/mysql.sock' ]"
fi

if [ -f "$WEBSTACK_ROOT/tmp/cloudflare_tunnel.pid" ]; then
    check "Cloudflare" "kill -0 \$(cat '$WEBSTACK_ROOT/tmp/cloudflare_tunnel.pid')"
fi

echo ""
echo "Disk usage: $(du -sh "$WEBSTACK_ROOT" | cut -f1)"
EOF

chmod +x "$WEBSTACK_ROOT/scripts/health.sh"
echo "  Done"

# ============================================
# Log viewer
# ============================================
echo "[8/8] Creating log viewer..."

cat > "$WEBSTACK_ROOT/scripts/logs.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"

case "${1:-all}" in
    nginx)
        tail -f "$WEBSTACK_ROOT/nginx/logs/error.log" "$WEBSTACK_ROOT/nginx/logs/access.log"
        ;;
    php)
        tail -f "$WEBSTACK_ROOT/php/var/log/php-fpm.log" "$WEBSTACK_ROOT/php/var/log/php-error.log"
        ;;
    node)
        tail -f "$WEBSTACK_ROOT/logs/node.log"
        ;;
    mysql)
        tail -f "$WEBSTACK_ROOT/logs/mysql-error.log"
        ;;
    cloudflare|cf)
        tail -f "$WEBSTACK_ROOT/logs/cloudflare/tunnel.log"
        ;;
    all|*)
        tail -f "$WEBSTACK_ROOT/nginx/logs/error.log" \
               "$WEBSTACK_ROOT/php/var/log/php-fpm.log" \
               "$WEBSTACK_ROOT/logs/node.log" \
               "$WEBSTACK_ROOT/logs/cloudflare/tunnel.log" 2>/dev/null
        ;;
esac
EOF

chmod +x "$WEBSTACK_ROOT/scripts/logs.sh"
echo "  Done"

echo ""
echo "========================================"
echo "Scripts Created!"
echo "========================================"
echo ""
echo "Main command: ./webstack {start|stop|restart|status|tunnel|logs}"
echo ""
echo "Tunnel commands:"
echo "  ./webstack tunnel start    - Start Cloudflare tunnel"
echo "  ./webstack tunnel daemon   - Start with auto-reconnect"
echo "  ./webstack tunnel status   - Show tunnel status"
echo "  ./webstack tunnel url      - Show current URL"
echo ""