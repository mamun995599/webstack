#!/bin/bash
# setup.sh - Generate all configuration files

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
echo "[1/8] Creating directories..."
mkdir -p "$WEBSTACK_ROOT"/{www/{hls,videos,recordings},data/mysql,tmp/{sessions,uploads,client_body,proxy,fastcgi},logs/{cloudflare},backups,nginx/{logs,conf/{conf.d,ssl}},php/var/{run,log},php/etc/conf.d,deps/{ssl/certs,bin},ws,scripts}
echo "  Done"

# 2. SSL Certificate
echo "[2/8] Setting up SSL certificate..."
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
echo "[3/8] Setting up CA certificates..."
if [ ! -f "$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem" ]; then
    wget -q --no-check-certificate https://curl.se/ca/cacert.pem -O "$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem" 2>/dev/null || \
    cp /etc/ssl/certs/ca-certificates.crt "$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem" 2>/dev/null || true
fi
echo "  Done"

# 4. PHP-FPM Config
echo "[4/8] Generating PHP-FPM config..."
if [ -d "$WEBSTACK_ROOT/php" ]; then
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
php_admin_value[error_log] = $WEBSTACK_ROOT/php/var/log/php-error.log
php_admin_flag[log_errors] = on
EOF
    echo "  Done"
else
    echo "  Skipped (PHP not installed)"
fi

# 5. MySQL Config
echo "[5/8] Generating MySQL config..."
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

[client]
socket = $WEBSTACK_ROOT/tmp/mysql.sock
default-character-set = utf8mb4
EOF
    echo "  Done"
else
    echo "  Skipped (MySQL not installed)"
fi

# 6. Nginx Config
echo "[6/8] Generating Nginx config..."
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
    
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_types application/javascript application/json text/css text/plain image/svg+xml;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:50m;
    
    push_stream_shared_memory_size 64M;
    
    upstream php-fpm {
        server unix:$WEBSTACK_ROOT/tmp/php-fpm.sock;
    }
    
    upstream nodejs {
        server 127.0.0.1:3000;
    }
    
    upstream websocket {
        server 127.0.0.1:8081;
    }
    
    # HTTP
    server {
        listen 80;
        server_name localhost _;
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
            include fastcgi_params;
        }
        
        location /api/ {
            proxy_pass http://nodejs;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        
        location /ws {
            proxy_pass http://websocket;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
        
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
        
        location /hls {
            alias $WEBSTACK_ROOT/www/hls;
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
            types { application/vnd.apple.mpegurl m3u8; video/mp2t ts; }
        }
        
        location /nginx_status { stub_status on; }
        location ~ /\. { deny all; }
    }
    
    # HTTPS
    server {
        listen 443 ssl;
        listen 443 quic reuseport;
        http2 on;
        server_name localhost _;
        
        ssl_certificate $WEBSTACK_ROOT/nginx/conf/ssl/cert.pem;
        ssl_certificate_key $WEBSTACK_ROOT/nginx/conf/ssl/key.pem;
        
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
        }
        
        location /hls {
            alias $WEBSTACK_ROOT/www/hls;
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
            types { application/vnd.apple.mpegurl m3u8; video/mp2t ts; }
        }
        
        location /nginx_status { stub_status on; }
        location ~ /\. { deny all; }
    }
    
    include conf.d/*.conf;
}

# RTMP
rtmp {
    server {
        listen 1935;
        chunk_size 4096;
        
        application live {
            live on;
            record off;
            hls on;
            hls_path $WEBSTACK_ROOT/www/hls;
            hls_fragment 3;
            hls_playlist_length 60;
        }
        
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

# 7. Cloudflare setup
echo "[7/8] Setting up Cloudflare tunnel..."
mkdir -p "$WEBSTACK_ROOT/logs/cloudflare"

# Check if cloudflared exists
if [ -x "$WEBSTACK_ROOT/deps/bin/cloudflared" ]; then
    echo "  Cloudflared found"
else
    echo "  Cloudflared not found - run ./install_cloudflared.sh to install"
fi
echo "  Done"

# 8. Sample files
echo "[8/8] Creating sample files..."

cat > "$WEBSTACK_ROOT/www/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>WebStack</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        .status { padding: 10px; border-radius: 5px; margin: 10px 0; }
        .ok { background: #d4edda; color: #155724; }
        .links a { display: inline-block; margin: 5px 10px 5px 0; padding: 8px 16px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; }
        .links a:hover { background: #0056b3; }
    </style>
</head>
<body>
    <h1>🚀 WebStack Working!</h1>
    <div class="status ok">Server is running successfully</div>
    <div class="links">
        <a href="index.php">PHP Test</a>
        <a href="phpinfo.php">PHP Info</a>
        <a href="phpmyadmin/">phpMyAdmin</a>
        <a href="/api/status">API Status</a>
    </div>
    <h3>Features</h3>
    <ul>
        <li>HTTP/2 & HTTP/3 (QUIC)</li>
        <li>PHP 8.3 with Redis & Memcached</li>
        <li>Node.js with WebSocket</li>
        <li>RTMP/RTMPS Streaming</li>
        <li>Cloudflare Tunnel Support</li>
    </ul>
</body>
</html>
EOF

cat > "$WEBSTACK_ROOT/www/index.php" << 'EOF'
<?php
echo "<h1>🚀 PHP " . phpversion() . " Working!</h1>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<p>Extensions: " . count(get_loaded_extensions()) . " loaded</p>";

$extensions = ['redis', 'memcached', 'curl', 'openssl', 'mbstring', 'gd', 'zip'];
echo "<h3>Key Extensions:</h3><ul>";
foreach ($extensions as $ext) {
    $status = extension_loaded($ext) ? '✓' : '✗';
    echo "<li>$status $ext</li>";
}
echo "</ul>";

echo "<p><a href='phpinfo.php'>Full PHP Info</a> | <a href='phpmyadmin/'>phpMyAdmin</a></p>";
EOF

cat > "$WEBSTACK_ROOT/www/phpinfo.php" << 'EOF'
<?php phpinfo();
EOF

# Node.js app
cat > "$WEBSTACK_ROOT/www/app.js" << 'EOF'
const http = require('http');
const PORT = 3000;

http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    
    if (req.url.startsWith('/api/status')) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
            status: 'ok', 
            time: new Date().toISOString(),
            node: process.version 
        }));
    } else if (req.url.startsWith('/api/')) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
            endpoint: req.url, 
            method: req.method,
            time: new Date().toISOString() 
        }));
    } else if (req.url === '/events') {
        res.writeHead(200, { 
            'Content-Type': 'text/event-stream', 
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive'
        });
        const interval = setInterval(() => {
            res.write(`data: ${JSON.stringify({ time: new Date().toISOString() })}\n\n`);
        }, 2000);
        req.on('close', () => clearInterval(interval));
    } else {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Not Found' }));
    }
}).listen(PORT, '127.0.0.1', () => console.log('Node.js API on port ' + PORT));
EOF

# WebSocket server
cat > "$WEBSTACK_ROOT/ws/server.js" << 'EOF'
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8081 });
let clientId = 0;

wss.on('connection', (ws, req) => {
    const id = ++clientId;
    console.log(`Client ${id} connected`);
    
    ws.send(JSON.stringify({ type: 'welcome', id: id, time: new Date().toISOString() }));
    
    ws.on('message', data => {
        const message = data.toString();
        console.log(`Client ${id}: ${message}`);
        
        // Echo back
        ws.send(JSON.stringify({ type: 'echo', data: message, time: new Date().toISOString() }));
        
        // Broadcast to all clients
        wss.clients.forEach(client => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ type: 'broadcast', from: id, data: message }));
            }
        });
    });
    
    ws.on('close', () => console.log(`Client ${id} disconnected`));
});

console.log('WebSocket server running on port 8081');
EOF

cat > "$WEBSTACK_ROOT/ws/package.json" << 'EOF'
{
    "name": "webstack-websocket",
    "version": "1.0.0",
    "main": "server.js",
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

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. ./create_scripts.sh   - Create management scripts"
echo "  2. ./webstack start      - Start all services"
echo ""
echo "Optional:"
echo "  ./install_cloudflared.sh - Install Cloudflare tunnel"
echo ""