#!/bin/bash
# setup.sh - Generate all configuration files (with Redis & Memcached)

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
CURRENT_USER="$(whoami)"
CURRENT_GROUP="$(id -gn)"

echo "========================================"
echo "WebStack Setup"
echo "========================================"
echo ""
echo "Location: $WEBSTACK_ROOT"
echo "User: $CURRENT_USER"
echo ""

# 1. Create directories
echo "[1/10] Creating directories..."
mkdir -p "$WEBSTACK_ROOT"/{www/{hls,videos,recordings},data/{mysql,redis},tmp/{sessions,uploads,client_body,proxy,fastcgi},logs/cloudflare,backups,nginx/{logs,conf/{conf.d,ssl}},php/var/{run,log},php/etc/conf.d,deps/{ssl/certs,bin},ws,scripts,redis,memcached}
echo "  Done"

# 2. SSL Certificate
echo "[2/10] Setting up SSL certificate..."
if [ ! -f "$WEBSTACK_ROOT/nginx/conf/ssl/cert.pem" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$WEBSTACK_ROOT/nginx/conf/ssl/key.pem" \
        -out "$WEBSTACK_ROOT/nginx/conf/ssl/cert.pem" \
        -subj "/C=US/ST=State/L=City/O=WebStack/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" 2>/dev/null
    chmod 600 "$WEBSTACK_ROOT/nginx/conf/ssl/key.pem"
    echo "  Created"
else
    echo "  Exists"
fi

# 3. CA Certificates
echo "[3/10] Setting up CA certificates..."
if [ ! -f "$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem" ]; then
    wget -q --no-check-certificate https://curl.se/ca/cacert.pem -O "$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem" 2>/dev/null || \
    cp /etc/ssl/certs/ca-certificates.crt "$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem" 2>/dev/null || true
fi
echo "  Done"

# 4. PHP-FPM Config
echo "[4/10] Generating PHP-FPM config..."
if [ -d "$WEBSTACK_ROOT/php" ]; then
    mkdir -p "$WEBSTACK_ROOT/php/etc/conf.d"
    
    cat > "$WEBSTACK_ROOT/php/etc/php-fpm.conf" << EOF
[global]
pid = $WEBSTACK_ROOT/php/var/run/php-fpm.pid
error_log = $WEBSTACK_ROOT/php/var/log/php-fpm.log
daemonize = yes

[www]
listen = $WEBSTACK_ROOT/tmp/php-fpm.sock
listen.owner = $CURRENT_USER
listen.group = $CURRENT_GROUP
listen.mode = 0666

user = $CURRENT_USER
group = $CURRENT_GROUP

pm = dynamic
pm.max_children = 25
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
pm.max_requests = 500

catch_workers_output = yes
decorate_workers_output = no
php_admin_value[error_log] = $WEBSTACK_ROOT/php/var/log/php-error.log
php_admin_flag[log_errors] = on
EOF
    echo "  Done"
else
    echo "  Skipped (PHP not installed)"
fi

# 5. MySQL Config
echo "[5/10] Generating MySQL config..."
if [ -d "$WEBSTACK_ROOT/mysql" ]; then
    cat > "$WEBSTACK_ROOT/mysql/my.cnf" << EOF
[mysqld]
basedir = $WEBSTACK_ROOT/mysql
datadir = $WEBSTACK_ROOT/data/mysql
socket = $WEBSTACK_ROOT/tmp/mysql.sock
pid-file = $WEBSTACK_ROOT/tmp/mysql.pid
log-error = $WEBSTACK_ROOT/logs/mysql-error.log
port = 3306
bind-address = 127.0.0.1
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
skip-name-resolve
max_connections = 100
innodb_buffer_pool_size = 128M

[client]
socket = $WEBSTACK_ROOT/tmp/mysql.sock
default-character-set = utf8mb4

[mysql]
socket = $WEBSTACK_ROOT/tmp/mysql.sock
default-character-set = utf8mb4
EOF
    echo "  Done"
else
    echo "  Skipped (MySQL not installed)"
fi

# 6. Redis Config
echo "[6/10] Generating Redis config..."
# Check if Redis is installed (either location)
if [ -x "$WEBSTACK_ROOT/deps/bin/redis-server" ] || [ -x "$WEBSTACK_ROOT/redis/bin/redis-server" ]; then
    mkdir -p "$WEBSTACK_ROOT/redis"
    mkdir -p "$WEBSTACK_ROOT/data/redis"
    
    cat > "$WEBSTACK_ROOT/redis/redis.conf" << EOF
# Redis Configuration for WebStack
# Generated: $(date)

# Network
bind 127.0.0.1
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300

# General
daemonize yes
pidfile $WEBSTACK_ROOT/tmp/redis.pid
loglevel notice
logfile $WEBSTACK_ROOT/logs/redis.log

# Snapshotting
dir $WEBSTACK_ROOT/data/redis
dbfilename dump.rdb
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes

# Memory Management
maxmemory 128mb
maxmemory-policy allkeys-lru

# Append Only Mode (optional, more durable)
appendonly no
appendfilename "appendonly.aof"

# Security (uncomment and set password for production)
# requirepass your_secure_password_here

# Clients
maxclients 100

# Slow Log
slowlog-log-slower-than 10000
slowlog-max-len 128
EOF
    echo "  Done"
else
    echo "  Skipped (Redis not installed)"
fi

# 7. Memcached Config (Memcached uses command-line args, but we create a reference file)
echo "[7/10] Setting up Memcached..."
# Check if Memcached is installed (either location)
if [ -x "$WEBSTACK_ROOT/deps/bin/memcached" ] || [ -x "$WEBSTACK_ROOT/memcached/bin/memcached" ]; then
    mkdir -p "$WEBSTACK_ROOT/memcached"
    
    cat > "$WEBSTACK_ROOT/memcached/memcached.conf" << EOF
# Memcached Configuration Reference for WebStack
# Note: Memcached uses command-line arguments, this is for reference
# Generated: $(date)

# These are the default settings used by WebStack:
# -d                    Run as daemon
# -m 64                 Memory limit (64 MB)
# -p 11211              Port
# -l 127.0.0.1          Listen address
# -c 1024               Max connections
# -u $CURRENT_USER      Run as user
# -P $WEBSTACK_ROOT/tmp/memcached.pid

# The start command is:
# memcached -d -m 64 -p 11211 -l 127.0.0.1 -c 1024 -u $CURRENT_USER -P $WEBSTACK_ROOT/tmp/memcached.pid
EOF
    echo "  Done"
else
    echo "  Skipped (Memcached not installed)"
fi

# 8. Nginx Config
echo "[8/10] Generating Nginx config..."
if [ -d "$WEBSTACK_ROOT/nginx" ]; then
    cat > "$WEBSTACK_ROOT/nginx/conf/nginx.conf" << EOF
user $CURRENT_USER $CURRENT_GROUP;
worker_processes auto;
error_log $WEBSTACK_ROOT/nginx/logs/error.log warn;
pid $WEBSTACK_ROOT/tmp/nginx.pid;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    include mime.types;
    default_type application/octet-stream;
    
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" "\$http_user_agent"';
    
    access_log $WEBSTACK_ROOT/nginx/logs/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    server_tokens off;
    client_max_body_size 100M;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_types application/javascript application/json text/css text/plain text/xml image/svg+xml application/xml;
    
    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    
    # Push stream (SSE)
    push_stream_shared_memory_size 64M;
    
    # Upstreams
    upstream php-fpm {
        server unix:$WEBSTACK_ROOT/tmp/php-fpm.sock;
    }
    
    upstream nodejs {
        server 127.0.0.1:3000;
    }
    
    upstream websocket {
        server 127.0.0.1:8081;
    }
    
    # HTTP Server
    server {
        listen 80;
        server_name localhost _;
        root $WEBSTACK_ROOT/www;
        index index.php index.html;
        
        # Main location
        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }
        
        # PHP handling
        location ~ \.php\$ {
            try_files \$uri =404;
            fastcgi_pass php-fpm;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
            fastcgi_read_timeout 300;
        }
        
        # Node.js API proxy
        location /api/ {
            proxy_pass http://nodejs;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_cache_bypass \$http_upgrade;
        }
        
        # WebSocket proxy
        location /ws {
            proxy_pass http://websocket;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_read_timeout 86400;
        }
        
        # Server-Sent Events (Push Stream)
        location /sse/sub {
            push_stream_subscriber;
            push_stream_channels_path \$arg_channel;
            push_stream_message_template ~text~;
            default_type text/event-stream;
        }
        
        location /sse/pub {
            push_stream_publisher admin;
            push_stream_channels_path \$arg_channel;
        }
        
        # HLS streaming
        location /hls {
            alias $WEBSTACK_ROOT/www/hls;
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
        }
        
        # Status pages
        location /nginx_status {
            stub_status on;
            allow 127.0.0.1;
            deny all;
        }
        
        # Security - deny hidden files
        location ~ /\. {
            deny all;
        }
    }
    
    # HTTPS Server
    server {
        listen 443 ssl;
        listen 443 quic reuseport;
        http2 on;
        server_name localhost _;
        
        ssl_certificate $WEBSTACK_ROOT/nginx/conf/ssl/cert.pem;
        ssl_certificate_key $WEBSTACK_ROOT/nginx/conf/ssl/key.pem;
        
        # HTTP/3 advertisement
        add_header Alt-Svc 'h3=":443"; ma=86400';
        
        root $WEBSTACK_ROOT/www;
        index index.php index.html;
        
        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }
        
        location ~ \.php\$ {
            try_files \$uri =404;
            fastcgi_pass php-fpm;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param HTTPS on;
            include fastcgi_params;
        }
        
        location /api/ {
            proxy_pass http://nodejs;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Proto https;
        }
        
        location /ws {
            proxy_pass http://websocket;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_read_timeout 86400;
        }
        
        location /hls {
            alias $WEBSTACK_ROOT/www/hls;
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
        }
        
        location /nginx_status {
            stub_status on;
            allow 127.0.0.1;
            deny all;
        }
        
        location ~ /\. {
            deny all;
        }
    }
    
    include conf.d/*.conf;
}

# RTMP Configuration
rtmp {
    server {
        listen 1935;
        chunk_size 4096;
        
        # Live streaming application
        application live {
            live on;
            record off;
            
            # HLS output
            hls on;
            hls_path $WEBSTACK_ROOT/www/hls;
            hls_fragment 3;
            hls_playlist_length 60;
            hls_cleanup on;
            
            # Optional: recording
            # record all;
            # record_path $WEBSTACK_ROOT/www/recordings;
            # record_suffix _%Y%m%d_%H%M%S.flv;
        }
        
        # Video on Demand
        application vod {
            play $WEBSTACK_ROOT/www/videos;
        }
    }
}

# RTMPS (SSL proxy to RTMP)
stream {
    server {
        listen 1936 ssl;
        ssl_certificate $WEBSTACK_ROOT/nginx/conf/ssl/cert.pem;
        ssl_certificate_key $WEBSTACK_ROOT/nginx/conf/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        proxy_pass 127.0.0.1:1935;
    }
}
EOF
    echo "  Done"
else
    echo "  Skipped (Nginx not installed)"
fi

# 9. Cloudflare setup
echo "[9/10] Setting up Cloudflare tunnel..."
mkdir -p "$WEBSTACK_ROOT/logs/cloudflare"

if [ -x "$WEBSTACK_ROOT/deps/bin/cloudflared" ]; then
    echo "  Cloudflared found"
else
    echo "  Cloudflared not found - run ./install_cloudflared.sh to install"
fi
echo "  Done"

# 10. Sample files
echo "[10/10] Creating sample files..."

# Main index.html
cat > "$WEBSTACK_ROOT/www/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebStack</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
            max-width: 900px; 
            margin: 0 auto; 
            padding: 20px;
            background: #f5f5f5;
        }
        .header { text-align: center; padding: 30px 0; }
        .header h1 { color: #333; font-size: 2.5em; }
        .status { padding: 15px; border-radius: 8px; margin: 20px 0; text-align: center; }
        .ok { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .card { background: white; border-radius: 8px; padding: 20px; margin: 15px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .card h3 { margin-bottom: 15px; color: #333; }
        .links { display: flex; flex-wrap: wrap; gap: 10px; }
        .links a { 
            display: inline-block; 
            padding: 10px 20px; 
            background: #007bff; 
            color: white; 
            text-decoration: none; 
            border-radius: 5px;
            transition: background 0.2s;
        }
        .links a:hover { background: #0056b3; }
        .links a.green { background: #28a745; }
        .links a.green:hover { background: #1e7e34; }
        .links a.orange { background: #fd7e14; }
        .links a.orange:hover { background: #e56b00; }
        ul { list-style: none; }
        ul li { padding: 8px 0; border-bottom: 1px solid #eee; }
        ul li:last-child { border-bottom: none; }
        code { background: #e9ecef; padding: 2px 6px; border-radius: 3px; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="header">
        <h1>? WebStack</h1>
        <p>Portable Web Development Environment</p>
    </div>
    
    <div class="status ok">? Server is running successfully</div>
    
    <div class="card">
        <h3>Quick Links</h3>
        <div class="links">
            <a href="index.php">PHP Test</a>
            <a href="phpinfo.php">PHP Info</a>
            <a href="test_cache.php" class="green">Cache Test</a>
            <a href="phpmyadmin/">phpMyAdmin</a>
            <a href="/api/status" class="orange">API Status</a>
        </div>
    </div>
    
    <div class="card">
        <h3>Features</h3>
        <ul>
            <li>? <strong>Nginx</strong> - HTTP/2, HTTP/3 (QUIC), RTMP/RTMPS Streaming</li>
            <li>? <strong>PHP 8.3</strong> - FPM with OPcache, JIT, 50+ extensions</li>
            <li>? <strong>Node.js</strong> - API server with WebSocket support</li>
            <li>? <strong>MySQL/MariaDB</strong> - Database server with phpMyAdmin</li>
            <li>? <strong>Redis</strong> - In-memory cache and data store</li>
            <li>? <strong>Memcached</strong> - High-performance caching</li>
            <li>? <strong>Cloudflare Tunnel</strong> - Instant public HTTPS access</li>
        </ul>
    </div>
    
    <div class="card">
        <h3>URLs</h3>
        <ul>
            <li><strong>HTTP:</strong> <code>http://localhost</code></li>
            <li><strong>HTTPS:</strong> <code>https://localhost</code></li>
            <li><strong>RTMP:</strong> <code>rtmp://localhost:1935/live/streamkey</code></li>
            <li><strong>RTMPS:</strong> <code>rtmps://localhost:1936/live/streamkey</code></li>
            <li><strong>WebSocket:</strong> <code>ws://localhost/ws</code></li>
        </ul>
    </div>
    
    <div class="card">
        <h3>Cache Connections</h3>
        <ul>
            <li><strong>Redis:</strong> <code>127.0.0.1:6379</code></li>
            <li><strong>Memcached:</strong> <code>127.0.0.1:11211</code></li>
        </ul>
    </div>
</body>
</html>
HTMLEOF

# PHP index
cat > "$WEBSTACK_ROOT/www/index.php" << 'PHPEOF'
<?php
$phpVersion = phpversion();
$extensionCount = count(get_loaded_extensions());
$serverTime = date('Y-m-d H:i:s');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PHP Test - WebStack</title>
    <style>
        body { font-family: -apple-system, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        .info { background: #e7f3ff; padding: 15px; border-radius: 8px; margin: 15px 0; }
        .extensions { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 10px; }
        .ext { padding: 8px; background: #f5f5f5; border-radius: 4px; text-align: center; }
        .ext.loaded { background: #d4edda; color: #155724; }
        .ext.missing { background: #f8d7da; color: #721c24; }
        .links a { display: inline-block; margin: 5px 10px 5px 0; padding: 8px 16px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; }
    </style>
</head>
<body>
    <h1>? PHP <?php echo $phpVersion; ?> Working!</h1>
    
    <div class="info">
        <p><strong>Server Time:</strong> <?php echo $serverTime; ?></p>
        <p><strong>Extensions Loaded:</strong> <?php echo $extensionCount; ?></p>
        <p><strong>Memory Limit:</strong> <?php echo ini_get('memory_limit'); ?></p>
        <p><strong>Max Execution Time:</strong> <?php echo ini_get('max_execution_time'); ?>s</p>
    </div>
    
    <h3>Key Extensions</h3>
    <div class="extensions">
        <?php
        $keyExtensions = ['redis', 'memcached', 'curl', 'openssl', 'mbstring', 'gd', 'zip', 'pdo_mysql', 'mysqli', 'json', 'xml', 'opcache', 'intl', 'sodium'];
        foreach ($keyExtensions as $ext):
            $loaded = extension_loaded($ext);
            $class = $loaded ? 'loaded' : 'missing';
            $status = $loaded ? '?' : '?';
        ?>
        <div class="ext <?php echo $class; ?>"><?php echo $status; ?> <?php echo $ext; ?></div>
        <?php endforeach; ?>
    </div>
    
    <h3>Links</h3>
    <div class="links">
        <a href="phpinfo.php">Full PHP Info</a>
        <a href="test_cache.php">Cache Test</a>
        <a href="phpmyadmin/">phpMyAdmin</a>
        <a href="/">Home</a>
    </div>
</body>
</html>
PHPEOF

# PHP info
cat > "$WEBSTACK_ROOT/www/phpinfo.php" << 'EOF'
<?php phpinfo();
EOF

# Cache test page
cat > "$WEBSTACK_ROOT/www/test_cache.php" << 'CACHEEOF'
<?php
$webstackRoot = getenv('WEBSTACK_ROOT') ?: dirname(__DIR__);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cache Test - WebStack</title>
    <style>
        body { font-family: -apple-system, sans-serif; max-width: 900px; margin: 50px auto; padding: 20px; background: #f5f5f5; }
        h1 { color: #333; text-align: center; }
        .card { background: white; border-radius: 8px; padding: 20px; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .card h2 { margin-top: 0; padding-bottom: 10px; border-bottom: 2px solid #eee; }
        .success { color: #155724; }
        .error { color: #721c24; }
        .warning { color: #856404; }
        .status-box { padding: 10px 15px; border-radius: 5px; margin: 10px 0; }
        .status-box.ok { background: #d4edda; }
        .status-box.fail { background: #f8d7da; }
        .status-box.warn { background: #fff3cd; }
        pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; font-size: 13px; }
        .links { text-align: center; margin-top: 30px; }
        .links a { display: inline-block; margin: 5px; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; }
        .links a:hover { background: #0056b3; }
    </style>
</head>
<body>
    <h1>? WebStack Cache Test</h1>
    
    <!-- Redis Test -->
    <div class="card">
        <h2>Redis</h2>
        <?php
        if (!extension_loaded('redis')) {
            echo '<div class="status-box fail"><strong class="error">? Redis extension not loaded</strong></div>';
            echo '<p>Install with: <code>./install_redis_memcached.sh</code></p>';
        } else {
            echo '<div class="status-box ok"><strong class="success">? Redis extension loaded</strong></div>';
            
            try {
                $redis = new Redis();
                $connected = @$redis->connect('127.0.0.1', 6379, 2);
                
                if ($connected && $redis->ping()) {
                    echo '<div class="status-box ok"><strong class="success">? Connected to Redis server</strong></div>';
                    
                    // Test operations
                    $testKey = 'webstack_test_' . time();
                    $testValue = 'Hello from WebStack at ' . date('Y-m-d H:i:s');
                    
                    $redis->set($testKey, $testValue);
                    $retrieved = $redis->get($testKey);
                    $redis->del($testKey);
                    
                    if ($retrieved === $testValue) {
                        echo '<div class="status-box ok"><strong class="success">? Read/Write operations working</strong></div>';
                    }
                    
                    // Server info
                    $info = $redis->info('server');
                    $memory = $redis->info('memory');
                    $stats = $redis->info('stats');
                    
                    echo '<h4>Server Info:</h4>';
                    echo '<pre>';
                    echo "Version:     " . ($info['redis_version'] ?? 'N/A') . "\n";
                    echo "Memory Used: " . ($memory['used_memory_human'] ?? 'N/A') . "\n";
                    echo "Clients:     " . ($redis->info('clients')['connected_clients'] ?? 'N/A') . "\n";
                    echo "Total Cmds:  " . ($stats['total_commands_processed'] ?? 'N/A') . "\n";
                    echo "Uptime:      " . ($info['uptime_in_seconds'] ?? 'N/A') . " seconds\n";
                    echo '</pre>';
                    
                } else {
                    echo '<div class="status-box fail"><strong class="error">? Cannot connect to Redis server</strong></div>';
                    echo '<p>Start Redis: <code>./webstack redis start</code></p>';
                }
            } catch (Exception $e) {
                echo '<div class="status-box fail"><strong class="error">? Error: ' . htmlspecialchars($e->getMessage()) . '</strong></div>';
            }
        }
        ?>
    </div>
    
    <!-- Memcached Test -->
    <div class="card">
        <h2>Memcached</h2>
        <?php
        if (!extension_loaded('memcached')) {
            echo '<div class="status-box fail"><strong class="error">? Memcached extension not loaded</strong></div>';
            echo '<p>Install with: <code>./install_redis_memcached.sh</code></p>';
        } else {
            echo '<div class="status-box ok"><strong class="success">? Memcached extension loaded</strong></div>';
            
            try {
                $memcached = new Memcached();
                $memcached->addServer('127.0.0.1', 11211);
                
                $stats = $memcached->getStats();
                $serverKey = '127.0.0.1:11211';
                
                if (!empty($stats) && isset($stats[$serverKey]) && $stats[$serverKey]['pid'] > 0) {
                    echo '<div class="status-box ok"><strong class="success">? Connected to Memcached server</strong></div>';
                    
                    // Test operations
                    $testKey = 'webstack_test_' . time();
                    $testValue = 'Hello from WebStack at ' . date('Y-m-d H:i:s');
                    
                    $memcached->set($testKey, $testValue, 60);
                    $retrieved = $memcached->get($testKey);
                    $memcached->delete($testKey);
                    
                    if ($retrieved === $testValue) {
                        echo '<div class="status-box ok"><strong class="success">? Read/Write operations working</strong></div>';
                    }
                    
                    // Server info
                    $serverStats = $stats[$serverKey];
                    echo '<h4>Server Info:</h4>';
                    echo '<pre>';
                    echo "Version:      " . ($serverStats['version'] ?? 'N/A') . "\n";
                    echo "Memory Used:  " . round(($serverStats['bytes'] ?? 0) / 1024 / 1024, 2) . " MB\n";
                    echo "Memory Limit: " . round(($serverStats['limit_maxbytes'] ?? 0) / 1024 / 1024, 2) . " MB\n";
                    echo "Curr Items:   " . ($serverStats['curr_items'] ?? 'N/A') . "\n";
                    echo "Connections:  " . ($serverStats['curr_connections'] ?? 'N/A') . "\n";
                    echo "Get Hits:     " . ($serverStats['get_hits'] ?? 'N/A') . "\n";
                    echo "Get Misses:   " . ($serverStats['get_misses'] ?? 'N/A') . "\n";
                    echo "Uptime:       " . ($serverStats['uptime'] ?? 'N/A') . " seconds\n";
                    echo '</pre>';
                    
                } else {
                    echo '<div class="status-box fail"><strong class="error">? Cannot connect to Memcached server</strong></div>';
                    echo '<p>Start Memcached: <code>./webstack memcached start</code></p>';
                }
            } catch (Exception $e) {
                echo '<div class="status-box fail"><strong class="error">? Error: ' . htmlspecialchars($e->getMessage()) . '</strong></div>';
            }
        }
        ?>
    </div>
    
    <!-- PHP OPcache -->
    <div class="card">
        <h2>OPcache</h2>
        <?php
        if (!extension_loaded('Zend OPcache')) {
            echo '<div class="status-box warn"><strong class="warning">? OPcache not loaded</strong></div>';
        } else {
            $status = opcache_get_status(false);
            if ($status && $status['opcache_enabled']) {
                echo '<div class="status-box ok"><strong class="success">? OPcache enabled and running</strong></div>';
                
                echo '<h4>OPcache Info:</h4>';
                echo '<pre>';
                echo "Memory Used:  " . round($status['memory_usage']['used_memory'] / 1024 / 1024, 2) . " MB\n";
                echo "Memory Free:  " . round($status['memory_usage']['free_memory'] / 1024 / 1024, 2) . " MB\n";
                echo "Cached Files: " . $status['opcache_statistics']['num_cached_scripts'] . "\n";
                echo "Hit Rate:     " . round($status['opcache_statistics']['opcache_hit_rate'], 2) . "%\n";
                echo "JIT Enabled:  " . (isset($status['jit']['enabled']) && $status['jit']['enabled'] ? 'Yes' : 'No') . "\n";
                echo '</pre>';
            } else {
                echo '<div class="status-box warn"><strong class="warning">? OPcache installed but not enabled</strong></div>';
            }
        }
        ?>
    </div>
    
    <div class="links">
        <a href="/">Home</a>
        <a href="index.php">PHP Test</a>
        <a href="phpinfo.php">PHP Info</a>
    </div>
</body>
</html>
CACHEEOF

# Node.js API app
cat > "$WEBSTACK_ROOT/www/app.js" << 'NODEEOF'
const http = require('http');
const PORT = 3000;

const server = http.createServer((req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    // Handle preflight
    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }
    
    const url = req.url;
    
    // Status endpoint
    if (url === '/api/status' || url === '/api/status/') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            status: 'ok',
            service: 'WebStack Node.js API',
            node: process.version,
            platform: process.platform,
            uptime: Math.floor(process.uptime()),
            memory: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + ' MB',
            time: new Date().toISOString()
        }, null, 2));
        return;
    }
    
    // Health check
    if (url === '/api/health' || url === '/api/health/') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ healthy: true }));
        return;
    }
    
    // Echo endpoint
    if (url.startsWith('/api/echo')) {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                method: req.method,
                url: req.url,
                headers: req.headers,
                body: body || null,
                time: new Date().toISOString()
            }, null, 2));
        });
        return;
    }
    
    // Server-Sent Events
    if (url === '/api/events' || url === '/events') {
        res.writeHead(200, {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive'
        });
        
        const sendEvent = () => {
            res.write(`data: ${JSON.stringify({ time: new Date().toISOString(), random: Math.random() })}\n\n`);
        };
        
        sendEvent();
        const interval = setInterval(sendEvent, 2000);
        
        req.on('close', () => {
            clearInterval(interval);
        });
        return;
    }
    
    // Generic API endpoint
    if (url.startsWith('/api/')) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            endpoint: url,
            method: req.method,
            message: 'API endpoint ready',
            time: new Date().toISOString()
        }));
        return;
    }
    
    // 404 for everything else
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not Found', path: url }));
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`[${new Date().toISOString()}] Node.js API server running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('Received SIGTERM, shutting down...');
    server.close(() => process.exit(0));
});
NODEEOF

# WebSocket server
cat > "$WEBSTACK_ROOT/ws/server.js" << 'WSEOF'
const WebSocket = require('ws');
const PORT = 8081;

const wss = new WebSocket.Server({ port: PORT });
let clientId = 0;
const clients = new Map();

wss.on('connection', (ws, req) => {
    const id = ++clientId;
    const clientIp = req.socket.remoteAddress;
    
    clients.set(id, { ws, ip: clientIp, joinedAt: new Date() });
    
    console.log(`[${new Date().toISOString()}] Client ${id} connected from ${clientIp}`);
    
    // Send welcome message
    ws.send(JSON.stringify({
        type: 'welcome',
        id: id,
        message: 'Connected to WebStack WebSocket server',
        clients: clients.size,
        time: new Date().toISOString()
    }));
    
    // Broadcast new client to others
    broadcast({
        type: 'client_joined',
        id: id,
        clients: clients.size
    }, ws);
    
    // Handle messages
    ws.on('message', (data) => {
        const message = data.toString();
        console.log(`[${new Date().toISOString()}] Client ${id}: ${message}`);
        
        try {
            const parsed = JSON.parse(message);
            
            // Handle different message types
            if (parsed.type === 'ping') {
                ws.send(JSON.stringify({ type: 'pong', time: new Date().toISOString() }));
            } else if (parsed.type === 'broadcast') {
                broadcast({
                    type: 'broadcast',
                    from: id,
                    data: parsed.data,
                    time: new Date().toISOString()
                });
            } else {
                // Echo back
                ws.send(JSON.stringify({
                    type: 'echo',
                    data: parsed,
                    time: new Date().toISOString()
                }));
            }
        } catch (e) {
            // Plain text message - echo back
            ws.send(JSON.stringify({
                type: 'echo',
                data: message,
                time: new Date().toISOString()
            }));
            
            // Broadcast to others
            broadcast({
                type: 'message',
                from: id,
                data: message,
                time: new Date().toISOString()
            }, ws);
        }
    });
    
    // Handle disconnect
    ws.on('close', () => {
        clients.delete(id);
        console.log(`[${new Date().toISOString()}] Client ${id} disconnected`);
        
        broadcast({
            type: 'client_left',
            id: id,
            clients: clients.size
        });
    });
    
    // Handle errors
    ws.on('error', (error) => {
        console.error(`[${new Date().toISOString()}] Client ${id} error:`, error.message);
    });
});

function broadcast(message, exclude = null) {
    const data = JSON.stringify(message);
    clients.forEach((client) => {
        if (client.ws !== exclude && client.ws.readyState === WebSocket.OPEN) {
            client.ws.send(data);
        }
    });
}

console.log(`[${new Date().toISOString()}] WebSocket server running on port ${PORT}`);
WSEOF

# WebSocket package.json
cat > "$WEBSTACK_ROOT/ws/package.json" << 'EOF'
{
    "name": "webstack-websocket",
    "version": "1.0.0",
    "description": "WebStack WebSocket Server",
    "main": "server.js",
    "scripts": {
        "start": "node server.js"
    },
    "dependencies": {
        "ws": "^8.14.2"
    }
}
EOF

echo "  Done"

# Test nginx config
echo ""
echo "Testing configurations..."
if [ -x "$WEBSTACK_ROOT/nginx/sbin/nginx" ]; then
    "$WEBSTACK_ROOT/nginx/sbin/nginx" -t -p "$WEBSTACK_ROOT/nginx" 2>&1 | head -3
fi

# Summary
echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Configuration files generated:"
echo "  - Nginx:     nginx/conf/nginx.conf"
echo "  - PHP-FPM:   php/etc/php-fpm.conf"
echo "  - MySQL:     mysql/my.cnf"
[ -f "$WEBSTACK_ROOT/redis/redis.conf" ] && echo "  - Redis:     redis/redis.conf"
[ -f "$WEBSTACK_ROOT/memcached/memcached.conf" ] && echo "  - Memcached: memcached/memcached.conf (reference)"
echo ""
echo "Sample files created:"
echo "  - www/index.html"
echo "  - www/index.php"
echo "  - www/phpinfo.php"
echo "  - www/test_cache.php"
echo "  - www/app.js"
echo "  - ws/server.js"
echo ""
echo "Next steps:"
echo "  ./webstack start      - Start all services"
echo "  ./webstack status     - Check status"
echo ""
echo "Optional:"
echo "  ./install_cloudflared.sh - Install Cloudflare tunnel"
echo ""