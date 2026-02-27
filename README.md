[webstack_usermanual.md](https://github.com/user-attachments/files/25596940/webstack_usermanual.md)


# WebStack Portable Web Server

## Complete Documentation & User Manual

---

# Table of Contents

1. [Introduction](#1-introduction)
2. [System Requirements](#2-system-requirements)
3. [Installation](#3-installation)
4. [Directory Structure](#4-directory-structure)
5. [Quick Start](#5-quick-start)
6. [Command Reference](#6-command-reference)
7. [Components](#7-components)
   - [Nginx](#71-nginx)
   - [PHP](#72-php)
   - [Node.js](#73-nodejs)
   - [MySQL/MariaDB](#74-mysqlmariadb)
   - [WebSocket](#75-websocket)
   - [RTMP Streaming](#76-rtmp-streaming)
   - [Cloudflare Tunnel](#77-cloudflare-tunnel)
   - [FFmpeg](#78-ffmpeg)
8. [Configuration](#8-configuration)
9. [Development Guide](#9-development-guide)
10. [Production Deployment](#10-production-deployment)
11. [Backup & Recovery](#11-backup--recovery)
12. [Troubleshooting](#12-troubleshooting)
13. [Security](#13-security)
14. [Performance Tuning](#14-performance-tuning)
15. [API Reference](#15-api-reference)
16. [Examples](#16-examples)
17. [FAQ](#17-faq)
18. [Appendix](#18-appendix)

---

# 1. Introduction

## 1.1 What is WebStack?

WebStack is a **fully portable, self-contained web server environment** that runs entirely from a single directory without requiring root privileges or system-wide installation. It includes everything needed to develop and deploy modern web applications:

- **Nginx** with HTTP/2, HTTP/3 (QUIC), and RTMP/RTMPS streaming
- **PHP 8.3** with FPM, Redis, Memcached, and 50+ extensions
- **Node.js** with npm and WebSocket support
- **MySQL/MariaDB** database server
- **Cloudflare Tunnel** for instant public HTTPS access
- **FFmpeg** for media processing
- **Composer** for PHP dependency management

## 1.2 Key Features

| Feature | Description |
|---------|-------------|
| **Portable** | Entire stack runs from `~/webstack` - copy anywhere |
| **No Root Required** | Runs as regular user (except ports 80/443) |
| **Self-Contained** | All dependencies built-in, no system libraries needed |
| **HTTP/3 Ready** | QUIC protocol support for faster connections |
| **Live Streaming** | RTMP/RTMPS ingest with HLS output |
| **Instant Public URL** | Cloudflare tunnel with auto-reconnect |
| **Modern PHP** | PHP 8.3 with JIT, OPcache, Redis, Memcached |
| **Real-time** | WebSocket and Server-Sent Events support |

## 1.3 Architecture Overview

<details>
<summary><strong>💻 Code Block — 31 lines</strong></summary>

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              │   Cloudflare Tunnel       │
              │   (Optional Public URL)   │
              └─────────────┬─────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────────┐
│                         NGINX                                    │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐            │
│  │ HTTP/80 │  │HTTPS/443│  │RTMP/1935│  │RTMPS/1936│           │
│  │ HTTP/2  │  │ HTTP/3  │  │   Live  │  │  Secure │           │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘           │
└───────┼────────────┼────────────┼────────────┼──────────────────┘
        │            │            │            │
   ┌────┴────┐  ┌────┴────┐  ┌────┴────┐      │
   │         │  │         │  │         │      │
   ▼         ▼  ▼         ▼  ▼         │      │
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │      │
│PHP   │ │Node  │ │ WS   │ │ HLS  │◄──┘      │
│FPM   │ │.js   │ │Server│ │Output│          │
└──┬───┘ └──┬───┘ └──────┘ └──────┘          │
   │        │                                 │
   └────┬───┘                                 │
        │                                     │
   ┌────┴────┐                               │
   │  MySQL  │◄──────────────────────────────┘
   │ MariaDB │
   └─────────┘
```

</details>

---

# 2. System Requirements

## 2.1 Minimum Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **OS** | Linux (64-bit) | Ubuntu 20.04+, Debian 11+ |
| **CPU** | 2 cores | 4+ cores |
| **RAM** | 2 GB | 4+ GB |
| **Disk** | 5 GB | 10+ GB |
| **Architecture** | x86_64, ARM64 | x86_64 |

## 2.2 Supported Operating Systems

- ✅ Ubuntu 18.04, 20.04, 22.04, 24.04
- ✅ Debian 10, 11, 12
- ✅ CentOS 7, 8, Stream
- ✅ Rocky Linux 8, 9
- ✅ AlmaLinux 8, 9
- ✅ Fedora 36+
- ✅ Arch Linux
- ✅ WSL2 (Windows Subsystem for Linux)

## 2.3 Build Dependencies

Required only for building from source:

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y build-essential autoconf libtool pkg-config \
    git wget curl cmake ninja-build libsqlite3-dev libreadline-dev \
    libbz2-dev libgmp-dev

# CentOS/RHEL/Rocky
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y autoconf libtool pkgconfig git wget curl cmake \
    sqlite-devel readline-devel bzip2-devel gmp-devel

# Arch Linux
sudo pacman -S base-devel git wget curl cmake ninja sqlite readline bzip2 gmp
```

</details>

---

# 3. Installation

## 3.1 Quick Install (Pre-built Package)

If you have a pre-built package:

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# Extract package
tar -xzf webstack_portable_YYYYMMDD_HHMMSS.tar.gz

# Navigate to directory
cd webstack

# Run installer
./INSTALL.sh

# Start services
./webstack start
```

</details>

## 3.2 Build from Source

### Step 1: Create Directory Structure

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
# Download and run setup script
mkdir -p ~/webstack
cd ~/webstack

# Create directory structure
./setup_directories.sh
```

</details>

### Step 2: Build Nginx Dependencies

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_nginx_deps.sh
```

</details>

This builds:
- PCRE2 (regex)
- zlib (compression)
- OpenSSL with QUIC support
- libatomic_ops
- libmaxminddb (GeoIP2)
- libxml2
- libxslt

**Duration:** ~10-15 minutes

### Step 3: Build Nginx

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_nginx.sh
```

</details>

This builds Nginx with:
- HTTP/2 and HTTP/3 (QUIC)
- RTMP module
- Push Stream module
- Various optimization modules

**Duration:** ~10-15 minutes

### Step 4: Build PHP Dependencies

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_php_deps.sh
```

</details>

This builds:
- All image libraries (PNG, JPEG, WebP, FreeType)
- Encryption libraries (OpenSSL, libsodium, argon2)
- Compression libraries (zlib, libzip)
- ICU (internationalization)
- curl, hiredis, libmemcached

**Duration:** ~20-30 minutes

### Step 5: Build PHP

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_php.sh
```

</details>

This builds PHP 8.3 with:
- PHP-FPM
- 50+ extensions including Redis and Memcached
- JIT compilation
- OPcache

**Duration:** ~15-25 minutes

### Step 6: Install Node.js

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./install_node.sh
```

</details>

**Duration:** ~1 minute

### Step 7: Optional Components

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# MySQL/MariaDB
./setup_mysql.sh

# Composer
./setup_composer.sh

# FFmpeg
./install_ffmpeg.sh

# Cloudflare Tunnel
./install_cloudflared.sh
```

</details>

### Step 8: Generate Configuration

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
./setup.sh
./create_scripts.sh
```

</details>

### Step 9: Start Services

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack start
```

</details>

## 3.3 Verify Installation

<details>
<summary><strong>💻 Code Block (bash) — 20 lines</strong></summary>

```bash
# Check status
./webstack status

# Test HTTP
curl http://localhost

# Test PHP
curl http://localhost/index.php

# Test HTTPS
curl -k https://localhost

# Check PHP version
./php/bin/php -v

# Check Node version
./node/bin/node -v

# Check Nginx version
./nginx/sbin/nginx -v
```

</details>

---

# 4. Directory Structure

<details>
<summary><strong>💻 Code Block — 153 lines</strong></summary>

```
~/webstack/
│
├── webstack                 # Main control script
├── composer                 # Composer wrapper script
├── setup.sh                 # Configuration generator
├── create_scripts.sh        # Script generator
├── INSTALL.sh              # Quick installer
├── cleanup.sh              # Cleanup script
├── package.sh              # Packaging script
│
├── nginx/                   # Nginx web server
│   ├── sbin/
│   │   └── nginx           # Nginx binary
│   ├── conf/
│   │   ├── nginx.conf      # Main configuration
│   │   ├── mime.types      # MIME type mappings
│   │   ├── fastcgi_params  # FastCGI parameters
│   │   ├── conf.d/         # Additional configs
│   │   ├── sites-available/# Available sites
│   │   ├── sites-enabled/  # Enabled sites
│   │   └── ssl/
│   │       ├── cert.pem    # SSL certificate
│   │       └── key.pem     # SSL private key
│   ├── logs/
│   │   ├── access.log      # Access log
│   │   └── error.log       # Error log
│   ├── html/               # Default web root
│   └── modules/            # Dynamic modules
│
├── php/                     # PHP installation
│   ├── bin/
│   │   ├── php             # PHP CLI
│   │   ├── phpize          # Extension builder
│   │   ├── php-config      # PHP configuration
│   │   └── composer        # Composer binary
│   ├── sbin/
│   │   └── php-fpm         # PHP-FPM binary
│   ├── lib/
│   │   └── php/
│   │       └── extensions/ # PHP extensions (.so files)
│   ├── etc/
│   │   ├── php.ini         # PHP configuration
│   │   ├── php-fpm.conf    # FPM configuration
│   │   ├── php-fpm.d/
│   │   │   └── www.conf    # Pool configuration
│   │   └── conf.d/         # Additional PHP configs
│   │       ├── custom.ini
│   │       ├── ssl.ini
│   │       ├── redis.ini
│   │       └── memcached.ini
│   └── var/
│       ├── run/
│       │   └── php-fpm.pid
│       └── log/
│           ├── php-fpm.log
│           └── php-error.log
│
├── node/                    # Node.js installation
│   ├── bin/
│   │   ├── node            # Node.js binary
│   │   ├── npm             # npm package manager
│   │   └── npx             # npm executor
│   └── lib/
│       └── node_modules/   # Global modules
│
├── mysql/                   # MariaDB installation
│   ├── bin/
│   │   ├── mysql           # MySQL client
│   │   ├── mysqld          # MySQL server
│   │   ├── mysqldump       # Backup tool
│   │   └── mysqladmin      # Admin tool
│   ├── lib/                # MySQL libraries
│   ├── share/              # SQL scripts
│   └── my.cnf              # MySQL configuration
│
├── deps/                    # Shared dependencies
│   ├── bin/
│   │   ├── openssl         # OpenSSL binary
│   │   ├── ffmpeg          # FFmpeg binary
│   │   ├── ffprobe         # FFprobe binary
│   │   └── cloudflared     # Cloudflare tunnel
│   ├── lib/                # Shared libraries
│   │   ├── libssl.so*
│   │   ├── libcrypto.so*
│   │   ├── libz.so*
│   │   ├── libcurl.so*
│   │   └── ...
│   ├── include/            # Header files (removed after cleanup)
│   └── ssl/
│       └── certs/
│           └── cacert.pem  # CA certificates
│
├── www/                     # Web root directory
│   ├── index.html          # Default HTML page
│   ├── index.php           # Default PHP page
│   ├── phpinfo.php         # PHP info page
│   ├── app.js              # Node.js API server
│   ├── phpmyadmin/         # phpMyAdmin (if installed)
│   ├── hls/                # HLS stream output
│   ├── videos/             # VOD videos
│   └── recordings/         # RTMP recordings
│
├── ws/                      # WebSocket server
│   ├── server.js           # WebSocket server script
│   ├── package.json        # npm dependencies
│   └── node_modules/       # Installed modules
│
├── data/                    # Persistent data
│   └── mysql/              # MySQL data files
│
├── tmp/                     # Runtime files
│   ├── nginx.pid
│   ├── php-fpm.sock
│   ├── mysql.sock
│   ├── node.pid
│   ├── ws.pid
│   ├── cloudflare_tunnel.pid
│   ├── cloudflare_url.txt
│   ├── sessions/           # PHP sessions
│   ├── uploads/            # Temporary uploads
│   ├── client_body/        # Nginx client body
│   ├── proxy/              # Nginx proxy cache
│   └── fastcgi/            # Nginx FastCGI cache
│
├── logs/                    # Log files
│   ├── node.log
│   ├── ws.log
│   ├── mysql-error.log
│   └── cloudflare/
│       ├── tunnel.log
│       ├── cloudflared.log
│       └── url_history.log
│
├── backups/                 # Backup files
│   ├── www_TIMESTAMP.tar.gz
│   ├── mysql_TIMESTAMP.sql.gz
│   └── config_TIMESTAMP.tar.gz
│
├── scripts/                 # Management scripts
│   ├── cloudflare_tunnel.sh
│   ├── start_mysql.sh
│   ├── stop_mysql.sh
│   ├── backup.sh
│   ├── renew_ssl.sh
│   ├── env.sh
│   ├── health.sh
│   └── logs.sh
│
└── src/                     # Source files (removed after cleanup)
    ├── nginx-1.25.4/
    ├── php-8.3.2/
    ├── pcre2-10.42/
    └── ...
```

</details>

---

# 5. Quick Start

## 5.1 Start Everything

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~/webstack
./webstack start
```

</details>

Output:
<details>
<summary><strong>💻 Code Block — 6 lines</strong></summary>

```
Starting PHP-FPM... OK
Starting Nginx... OK
Starting Node.js... OK
Starting WebSocket... OK

WebStack started!
```

</details>

## 5.2 Check Status

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack status
```

</details>

Output:
<details>
<summary><strong>💻 Code Block — 16 lines</strong></summary>

```
========================================
WebStack Status
========================================

  Nginx:       RUNNING (PID: 12345)
  PHP-FPM:     RUNNING (PID: 12346)
  Node.js:     RUNNING (PID: 12347)
  WebSocket:   RUNNING (PID: 12348)
  MySQL:       RUNNING (PID: 12349)
  Cloudflare:  STOPPED

URLs:
  HTTP:       http://localhost
  HTTPS:      https://localhost
  RTMP:       rtmp://localhost:1935/live/streamkey
  RTMPS:      rtmps://localhost:1936/live/streamkey
```

</details>

## 5.3 Access Your Site

| URL | Description |
|-----|-------------|
| http://localhost | Main website |
| https://localhost | HTTPS website |
| http://localhost/phpinfo.php | PHP information |
| http://localhost/phpmyadmin | Database management |
| http://localhost/api/status | Node.js API |
| ws://localhost/ws | WebSocket |

## 5.4 Stop Everything

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack stop
```

</details>

## 5.5 Enable Public Access (Cloudflare Tunnel)

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# Start tunnel with auto-reconnect
./webstack tunnel daemon

# Get your public URL
./webstack tunnel url
```

</details>

Your site is now accessible at: `https://random-words.trycloudflare.com`

---

# 6. Command Reference

## 6.1 Main Control Script (`./webstack`)

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack <command> [options]
```

</details>

### Commands

| Command | Description |
|---------|-------------|
| `start` | Start all services (Nginx, PHP-FPM, Node.js, WebSocket, MySQL) |
| `stop` | Stop all services |
| `restart` | Restart all services |
| `status` | Show status of all services |
| `logs` | Show recent log entries |
| `tunnel <cmd>` | Manage Cloudflare tunnel |

### Tunnel Subcommands

| Command | Description |
|---------|-------------|
| `tunnel start [port]` | Start tunnel (default port 80) |
| `tunnel stop` | Stop tunnel |
| `tunnel restart` | Restart tunnel (get new URL) |
| `tunnel daemon [port]` | Start with auto-reconnect |
| `tunnel stop-daemon` | Stop daemon |
| `tunnel status` | Show tunnel status |
| `tunnel url` | Show current URL |
| `tunnel logs` | Show URL history |

### Examples

<details>
<summary><strong>💻 Code Block (bash) — 23 lines</strong></summary>

```bash
# Start all services
./webstack start

# Check status
./webstack status

# Start tunnel on port 80
./webstack tunnel daemon

# Start tunnel on custom port
./webstack tunnel daemon 8080

# Get current tunnel URL
./webstack tunnel url

# View all tunnel URLs (history)
./webstack tunnel logs

# Restart tunnel (new URL)
./webstack tunnel restart

# View logs
./webstack logs
```

</details>

## 6.2 Individual Scripts

### PHP

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# PHP CLI
./php/bin/php -v
./php/bin/php script.php
./php/bin/php -m                    # List modules
./php/bin/php -i                    # PHP info

# PHP-FPM
./php/sbin/php-fpm -t               # Test config
./php/sbin/php-fpm -y /path/to/fpm.conf
```

</details>

### Node.js

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# Run node
./node/bin/node -v
./node/bin/node script.js

# Use npm (from project directory)
cd ~/webstack/ws
../node/bin/node ../node/bin/npm install package-name
../node/bin/node ../node/bin/npm update

# Or with full paths
~/webstack/node/bin/node ~/webstack/node/bin/npm install ws
```

</details>

### Nginx

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# Test configuration
./nginx/sbin/nginx -t -p ~/webstack/nginx

# Reload configuration
./nginx/sbin/nginx -p ~/webstack/nginx -s reload

# Stop gracefully
./nginx/sbin/nginx -p ~/webstack/nginx -s quit

# Stop immediately
./nginx/sbin/nginx -p ~/webstack/nginx -s stop

# Show version and modules
./nginx/sbin/nginx -V
```

</details>

### MySQL

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# Start MySQL
./scripts/start_mysql.sh

# Stop MySQL
./scripts/stop_mysql.sh

# MySQL client
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# Dump database
./mysql/bin/mysqldump --socket=./tmp/mysql.sock -u root dbname > backup.sql

# Restore database
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root dbname < backup.sql
```

</details>

### Composer

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Use wrapper script
./composer --version
./composer install
./composer require vendor/package
./composer update

# Or directly
./php/bin/php ./php/bin/composer install
```

</details>

### FFmpeg

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Check version
./deps/bin/ffmpeg -version

# Convert video
./deps/bin/ffmpeg -i input.mp4 -c:v libx264 output.mp4

# Stream to RTMP
./deps/bin/ffmpeg -re -i video.mp4 -c copy -f flv rtmp://localhost:1935/live/streamkey
```

</details>

## 6.3 Utility Scripts

### Environment Setup

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Load environment (adds paths to current shell)
source ./scripts/env.sh

# Now you can use commands directly
php -v
node -v
nginx -t
mysql -u root
```

</details>

### Backup

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# Create backup
./scripts/backup.sh

# Backups are stored in ./backups/
ls -la backups/
```

</details>

### SSL Certificate

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
# Renew self-signed certificate
./scripts/renew_ssl.sh
```

</details>

### Health Check

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./scripts/health.sh
```

</details>

### Log Viewer

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# View all logs
./scripts/logs.sh

# View specific logs
./scripts/logs.sh nginx
./scripts/logs.sh php
./scripts/logs.sh node
./scripts/logs.sh mysql
./scripts/logs.sh cloudflare
```

</details>

---

# 7. Components

## 7.1 Nginx

### Version & Features

- **Version:** 1.25.4
- **HTTP/2:** ✅ Enabled
- **HTTP/3 (QUIC):** ✅ Enabled
- **TLS 1.3:** ✅ Enabled
- **Brotli Compression:** ✅ Enabled
- **GeoIP2:** ✅ Enabled

### Installed Modules

| Module | Description |
|--------|-------------|
| `http_ssl_module` | SSL/TLS support |
| `http_v2_module` | HTTP/2 support |
| `http_v3_module` | HTTP/3 (QUIC) support |
| `http_realip_module` | Real IP from proxy headers |
| `http_gzip_static_module` | Pre-compressed files |
| `http_mp4_module` | MP4 streaming |
| `http_flv_module` | FLV streaming |
| `http_secure_link_module` | Secure links |
| `http_stub_status_module` | Basic status |
| `http_auth_request_module` | Auth subrequests |
| `stream_module` | TCP/UDP proxy |
| `nginx-rtmp-module` | RTMP streaming |
| `push_stream_module` | Server-Sent Events |
| `headers-more-module` | Header manipulation |
| `ngx_brotli` | Brotli compression |
| `ngx_cache_purge` | Cache purging |
| `nginx-module-vts` | Virtual host traffic status |
| `njs` | JavaScript scripting |

### Configuration Files

| File | Purpose |
|------|---------|
| `nginx/conf/nginx.conf` | Main configuration |
| `nginx/conf/mime.types` | MIME type mappings |
| `nginx/conf/fastcgi_params` | FastCGI parameters |
| `nginx/conf/conf.d/*.conf` | Additional configurations |
| `nginx/conf/ssl/cert.pem` | SSL certificate |
| `nginx/conf/ssl/key.pem` | SSL private key |

### Example: Add Virtual Host

Create `nginx/conf/conf.d/mysite.conf`:

<details>
<summary><strong>💻 Code Block (nginx) — 16 lines</strong></summary>

```nginx
server {
    listen 80;
    server_name mysite.local;
    root /home/user/webstack/www/mysite;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/home/user/webstack/tmp/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

</details>

Reload Nginx:
<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./nginx/sbin/nginx -p ~/webstack/nginx -s reload
```

</details>

## 7.2 PHP

### Version & Configuration

- **Version:** 8.3.2
- **SAPI:** FPM (FastCGI Process Manager)
- **JIT:** ✅ Enabled
- **OPcache:** ✅ Enabled

### Installed Extensions

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
# List all extensions
./php/bin/php -m
```

</details>

| Category | Extensions |
|----------|------------|
| **Core** | Core, date, filter, hash, json, pcre, Reflection, SPL, standard |
| **Database** | mysqli, mysqlnd, PDO, pdo_mysql, pdo_sqlite, sqlite3 |
| **Caching** | redis, memcached, opcache |
| **Encryption** | openssl, sodium, password (argon2) |
| **Compression** | zlib, zip, bz2 |
| **Image** | gd (freetype, jpeg, webp, png) |
| **XML** | dom, libxml, simplexml, xml, xmlreader, xmlwriter |
| **String** | mbstring, iconv, intl, ctype, tokenizer |
| **Network** | curl, sockets, ftp |
| **Other** | bcmath, calendar, exif, fileinfo, gettext, pcntl, posix, readline, session, shmop |

### Configuration Files

| File | Purpose |
|------|---------|
| `php/etc/php.ini` | Main PHP configuration |
| `php/etc/php-fpm.conf` | FPM global configuration |
| `php/etc/php-fpm.d/www.conf` | FPM pool configuration |
| `php/etc/conf.d/custom.ini` | Custom settings |
| `php/etc/conf.d/ssl.ini` | SSL certificate paths |
| `php/etc/conf.d/redis.ini` | Redis extension |
| `php/etc/conf.d/memcached.ini` | Memcached extension |

### Key Settings (php.ini)

<details>
<summary><strong>💻 Code Block (ini) — 28 lines</strong></summary>

```ini
; Memory and execution
memory_limit = 256M
max_execution_time = 300
max_input_time = 300

; Upload
post_max_size = 100M
upload_max_filesize = 100M
max_file_uploads = 20

; OPcache
opcache.enable = 1
opcache.enable_cli = 1
opcache.memory_consumption = 128
opcache.max_accelerated_files = 10000
opcache.jit = 1255
opcache.jit_buffer_size = 64M

; Error handling
display_errors = Off
log_errors = On
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; Timezone
date.timezone = UTC

; Security
expose_php = Off
```

</details>

### FPM Pool Settings (www.conf)

<details>
<summary><strong>💻 Code Block (ini) — 10 lines</strong></summary>

```ini
[www]
listen = /home/user/webstack/tmp/php-fpm.sock
listen.mode = 0666

pm = dynamic
pm.max_children = 25
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
pm.max_requests = 500
```

</details>

## 7.3 Node.js

### Version

- **Version:** 20.10.0 (LTS)
- **npm:** 10.x

### Using npm

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# Navigate to your project directory
cd ~/webstack/ws

# Install packages
../node/bin/node ../node/bin/npm install ws
../node/bin/node ../node/bin/npm install express
../node/bin/node ../node/bin/npm install socket.io

# Or create an alias
alias npm="~/webstack/node/bin/node ~/webstack/node/bin/npm"
npm install ws
```

</details>

### Global Packages (Pre-installed)

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
# pm2 - Process manager
./node/bin/pm2 start app.js
./node/bin/pm2 list
./node/bin/pm2 stop all

# nodemon - Development auto-restart
./node/bin/nodemon app.js
```

</details>

### Default Node.js API Server

Location: `www/app.js`

<details>
<summary><strong>💻 Code Block (javascript) — 27 lines</strong></summary>

```javascript
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
    } else {
        res.writeHead(404);
        res.end('Not Found');
    }
}).listen(PORT, '127.0.0.1', () => {
    console.log('Node.js API on port ' + PORT);
});
```

</details>

Access: `http://localhost/api/status`

## 7.4 MySQL/MariaDB

### Version

- **MariaDB:** 11.2.2

### Configuration

Location: `mysql/my.cnf`

<details>
<summary><strong>💻 Code Block (ini) — 16 lines</strong></summary>

```ini
[mysqld]
basedir = /home/user/webstack/mysql
datadir = /home/user/webstack/data/mysql
socket = /home/user/webstack/tmp/mysql.sock
port = 3306
bind-address = 127.0.0.1

max_connections = 100
max_allowed_packet = 64M
innodb_buffer_pool_size = 128M
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[client]
socket = /home/user/webstack/tmp/mysql.sock
default-character-set = utf8mb4
```

</details>

### Common Commands

<details>
<summary><strong>💻 Code Block (bash) — 24 lines</strong></summary>

```bash
# Start MySQL
./scripts/start_mysql.sh

# Stop MySQL
./scripts/stop_mysql.sh

# Connect to MySQL
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# Set root password
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'newpassword';"

# Create database
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -e "CREATE DATABASE myapp;"

# Create user
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -e "CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'password';"
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -e "GRANT ALL PRIVILEGES ON myapp.* TO 'myuser'@'localhost';"

# Backup
./mysql/bin/mysqldump --socket=./tmp/mysql.sock -u root --all-databases > backup.sql

# Restore
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root < backup.sql
```

</details>

### PHP Connection

<details>
<summary><strong>💻 Code Block (php) — 7 lines</strong></summary>

```php
<?php
// Using PDO
$dsn = 'mysql:unix_socket=/home/user/webstack/tmp/mysql.sock;dbname=myapp';
$pdo = new PDO($dsn, 'root', '');

// Using mysqli
$mysqli = new mysqli('localhost', 'root', '', 'myapp', 0, '/home/user/webstack/tmp/mysql.sock');
```

</details>

### phpMyAdmin

Access: `http://localhost/phpmyadmin`

Default login:
- Username: `root`
- Password: (empty)

## 7.5 WebSocket

### Server

Location: `ws/server.js`

<details>
<summary><strong>💻 Code Block (javascript) — 43 lines</strong></summary>

```javascript
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8081 });
let clientId = 0;

wss.on('connection', (ws, req) => {
    const id = ++clientId;
    console.log(`Client ${id} connected`);
    
    // Send welcome message
    ws.send(JSON.stringify({ 
        type: 'welcome', 
        id: id, 
        time: new Date().toISOString() 
    }));
    
    // Handle incoming messages
    ws.on('message', data => {
        const message = data.toString();
        console.log(`Client ${id}: ${message}`);
        
        // Echo back
        ws.send(JSON.stringify({ 
            type: 'echo', 
            data: message, 
            time: new Date().toISOString() 
        }));
        
        // Broadcast to all other clients
        wss.clients.forEach(client => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ 
                    type: 'broadcast', 
                    from: id, 
                    data: message 
                }));
            }
        });
    });
    
    ws.on('close', () => console.log(`Client ${id} disconnected`));
});

console.log('WebSocket server running on port 8081');
```

</details>

### Install Dependencies

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~/webstack/ws
../node/bin/node ../node/bin/npm install ws
```

</details>

### Client Example (JavaScript)

<details>
<summary><strong>💻 Code Block (html) — 39 lines</strong></summary>

```html
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket Test</title>
</head>
<body>
    <h1>WebSocket Test</h1>
    <input type="text" id="message" placeholder="Enter message">
    <button onclick="send()">Send</button>
    <div id="output"></div>

    <script>
        const ws = new WebSocket('ws://localhost/ws');
        
        ws.onopen = () => {
            log('Connected!');
        };
        
        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            log('Received: ' + JSON.stringify(data));
        };
        
        ws.onclose = () => {
            log('Disconnected');
        };
        
        function send() {
            const msg = document.getElementById('message').value;
            ws.send(msg);
            log('Sent: ' + msg);
        }
        
        function log(msg) {
            document.getElementById('output').innerHTML += '<p>' + msg + '</p>';
        }
    </script>
</body>
</html>
```

</details>

### Nginx WebSocket Proxy Configuration

<details>
<summary><strong>💻 Code Block (nginx) — 9 lines</strong></summary>

```nginx
location /ws {
    proxy_pass http://127.0.0.1:8081;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_read_timeout 86400;
}
```

</details>

## 7.6 RTMP Streaming

### Overview

WebStack includes full RTMP (Real-Time Messaging Protocol) support for:
- Live streaming (ingest)
- RTMPS (secure RTMP over TLS)
- HLS output (HTTP Live Streaming)
- Video on Demand (VOD)

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 1935 | RTMP | Standard RTMP |
| 1936 | RTMPS | Secure RTMP (TLS) |

### Stream URLs

<details>
<summary><strong>💻 Code Block — 8 lines</strong></summary>

```
# RTMP (standard)
rtmp://localhost:1935/live/streamkey

# RTMPS (secure)
rtmps://localhost:1936/live/streamkey

# HLS Playback
http://localhost/hls/streamkey.m3u8
```

</details>

### OBS Studio Settings

| Setting | Value |
|---------|-------|
| **Service** | Custom |
| **Server** | `rtmp://localhost:1935/live` or `rtmps://localhost:1936/live` |
| **Stream Key** | `mystreamkey` (your choice) |

### FFmpeg Streaming

<details>
<summary><strong>💻 Code Block (bash) — 12 lines</strong></summary>

```bash
# Stream a video file
./deps/bin/ffmpeg -re -i video.mp4 -c copy -f flv rtmp://localhost:1935/live/test

# Stream webcam (Linux)
./deps/bin/ffmpeg -f v4l2 -i /dev/video0 -f alsa -i default \
    -c:v libx264 -preset veryfast -c:a aac \
    -f flv rtmp://localhost:1935/live/webcam

# Stream desktop (Linux)
./deps/bin/ffmpeg -f x11grab -s 1920x1080 -i :0.0 \
    -c:v libx264 -preset veryfast \
    -f flv rtmp://localhost:1935/live/desktop
```

</details>

### HLS Playback (HTML)

<details>
<summary><strong>💻 Code Block (html) — 28 lines</strong></summary>

```html
<!DOCTYPE html>
<html>
<head>
    <title>Live Stream</title>
    <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
</head>
<body>
    <video id="video" controls width="720"></video>
    
    <script>
        const video = document.getElementById('video');
        const streamUrl = '/hls/mystreamkey.m3u8';
        
        if (Hls.isSupported()) {
            const hls = new Hls();
            hls.loadSource(streamUrl);
            hls.attachMedia(video);
            hls.on(Hls.Events.MANIFEST_PARSED, () => {
                video.play();
            });
        } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
            // Safari native HLS
            video.src = streamUrl;
            video.play();
        }
    </script>
</body>
</html>
```

</details>

### RTMP Configuration

From `nginx/conf/nginx.conf`:

<details>
<summary><strong>💻 Code Block (nginx) — 39 lines</strong></summary>

```nginx
rtmp {
    server {
        listen 1935;
        chunk_size 4096;
        
        # Live streaming
        application live {
            live on;
            record off;
            
            # HLS output
            hls on;
            hls_path /home/user/webstack/www/hls;
            hls_fragment 3;
            hls_playlist_length 60;
            
            # Optional: Recording
            # record all;
            # record_path /home/user/webstack/www/recordings;
            # record_suffix _%Y%m%d_%H%M%S.flv;
        }
        
        # Video on Demand
        application vod {
            play /home/user/webstack/www/videos;
        }
    }
}

# RTMPS (TLS proxy)
stream {
    server {
        listen 1936 ssl;
        ssl_certificate /home/user/webstack/nginx/conf/ssl/cert.pem;
        ssl_certificate_key /home/user/webstack/nginx/conf/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        proxy_pass 127.0.0.1:1935;
    }
}
```

</details>

### Enable Recording

Edit `nginx/conf/nginx.conf`:

<details>
<summary><strong>💻 Code Block (nginx) — 13 lines</strong></summary>

```nginx
application live {
    live on;
    
    # Enable recording
    record all;
    record_path /home/user/webstack/www/recordings;
    record_suffix _%Y%m%d_%H%M%S.flv;
    record_unique on;
    
    # HLS
    hls on;
    hls_path /home/user/webstack/www/hls;
}
```

</details>

Reload Nginx:
<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./nginx/sbin/nginx -p ~/webstack/nginx -s reload
```

</details>

## 7.7 Cloudflare Tunnel

### Overview

Cloudflare Tunnel (formerly Argo Tunnel) provides instant, secure public access to your local WebStack without:
- Opening firewall ports
- Configuring port forwarding
- Setting up dynamic DNS
- Purchasing SSL certificates

### Installation

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./install_cloudflared.sh
```

</details>

### Commands

<details>
<summary><strong>💻 Code Block (bash) — 26 lines</strong></summary>

```bash
# Start tunnel (simple)
./webstack tunnel start

# Start with auto-reconnect (recommended)
./webstack tunnel daemon

# Stop tunnel
./webstack tunnel stop

# Stop daemon
./webstack tunnel stop-daemon

# Show status
./webstack tunnel status

# Get current URL
./webstack tunnel url

# View URL history
./webstack tunnel logs

# Restart (get new URL)
./webstack tunnel restart

# Start on different port
./webstack tunnel daemon 8080
```

</details>

### Direct Script Usage

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# Start
./scripts/cloudflare_tunnel.sh start

# Start daemon
./scripts/cloudflare_tunnel.sh daemon

# Status
./scripts/cloudflare_tunnel.sh status

# URL history
./scripts/cloudflare_tunnel.sh logs
```

</details>

### URL History

URL history is stored in `logs/cloudflare/url_history.log` with newest entries first:

<details>
<summary><strong>💻 Code Block — 3 lines</strong></summary>

```
2024-01-15 14:30:22 | https://random-words-here.trycloudflare.com
2024-01-15 12:15:10 | https://other-random-words.trycloudflare.com
2024-01-14 09:45:33 | https://previous-tunnel-url.trycloudflare.com
```

</details>

### How Auto-Reconnect Works

The daemon mode:
1. Starts the tunnel
2. Monitors health every 30 seconds
3. If tunnel dies, attempts to reconnect
4. After 5 failures, creates new tunnel with new URL
5. Logs all URLs to history file

### Example Status Output

<details>
<summary><strong>💻 Code Block — 12 lines</strong></summary>

```
========================================
Cloudflare Tunnel Status
========================================

Status: RUNNING
PID:    12345
URL:    https://random-words-here.trycloudflare.com
Daemon: RUNNING (PID: 12346)

Recent URLs:
  2024-01-15 14:30:22 | https://random-words-here.trycloudflare.com
  2024-01-15 12:15:10 | https://other-random-words.trycloudflare.com
```

</details>

## 7.8 FFmpeg

### Version

Pre-built static binary from John Van Sickle's builds.

### Capabilities

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# Check version and build info
./deps/bin/ffmpeg -version

# List encoders
./deps/bin/ffmpeg -encoders

# List decoders
./deps/bin/ffmpeg -decoders

# List formats
./deps/bin/ffmpeg -formats
```

</details>

### Common Operations

<details>
<summary><strong>💻 Code Block (bash) — 23 lines</strong></summary>

```bash
# Convert video
./deps/bin/ffmpeg -i input.mp4 -c:v libx264 -c:a aac output.mp4

# Extract audio
./deps/bin/ffmpeg -i video.mp4 -vn -c:a mp3 audio.mp3

# Create thumbnail
./deps/bin/ffmpeg -i video.mp4 -ss 00:00:05 -vframes 1 thumbnail.jpg

# Convert to HLS
./deps/bin/ffmpeg -i input.mp4 -c:v libx264 -c:a aac \
    -hls_time 10 -hls_list_size 0 \
    -f hls output.m3u8

# Scale video
./deps/bin/ffmpeg -i input.mp4 -vf scale=1280:720 output_720p.mp4

# Add watermark
./deps/bin/ffmpeg -i input.mp4 -i watermark.png \
    -filter_complex "overlay=10:10" output.mp4

# Compress video
./deps/bin/ffmpeg -i input.mp4 -c:v libx264 -crf 23 -c:a aac -b:a 128k output.mp4
```

</details>

### Stream to RTMP

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# Stream file in loop
./deps/bin/ffmpeg -stream_loop -1 -re -i video.mp4 \
    -c copy -f flv rtmp://localhost:1935/live/test

# Stream with transcoding
./deps/bin/ffmpeg -re -i video.mp4 \
    -c:v libx264 -preset veryfast -b:v 2500k \
    -c:a aac -b:a 128k \
    -f flv rtmp://localhost:1935/live/test
```

</details>

---

# 8. Configuration

## 8.1 Nginx Configuration

### Main Configuration (`nginx/conf/nginx.conf`)

<details>
<summary><strong>💻 Code Block (nginx) — 162 lines</strong></summary>

```nginx
# User and worker settings
user username groupname;
worker_processes auto;
error_log /home/user/webstack/nginx/logs/error.log warn;
pid /home/user/webstack/tmp/nginx.pid;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    include mime.types;
    default_type application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" "$http_user_agent"';
    access_log /home/user/webstack/nginx/logs/access.log main;
    
    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    
    # Security
    server_tokens off;
    
    # Limits
    client_max_body_size 100M;
    
    # Compression
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_types application/javascript application/json text/css text/plain image/svg+xml;
    
    # SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:50m;
    
    # Push stream (SSE)
    push_stream_shared_memory_size 64M;
    
    # Upstreams
    upstream php-fpm {
        server unix:/home/user/webstack/tmp/php-fpm.sock;
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
        root /home/user/webstack/www;
        index index.php index.html;
        
        # PHP
        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_pass php-fpm;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
        
        # API proxy to Node.js
        location /api/ {
            proxy_pass http://nodejs;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        # WebSocket
        location /ws {
            proxy_pass http://websocket;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_read_timeout 86400;
        }
        
        # HLS streaming
        location /hls {
            alias /home/user/webstack/www/hls;
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
        }
        
        # Status
        location /nginx_status {
            stub_status on;
        }
        
        # Security
        location ~ /\. { deny all; }
    }
    
    # HTTPS Server
    server {
        listen 443 ssl;
        listen 443 quic reuseport;
        http2 on;
        server_name localhost _;
        
        ssl_certificate /home/user/webstack/nginx/conf/ssl/cert.pem;
        ssl_certificate_key /home/user/webstack/nginx/conf/ssl/key.pem;
        
        # HTTP/3 advertisement
        add_header Alt-Svc 'h3=":443"; ma=86400';
        
        root /home/user/webstack/www;
        index index.php index.html;
        
        # ... same locations as HTTP ...
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
            hls on;
            hls_path /home/user/webstack/www/hls;
            hls_fragment 3;
        }
    }
}

# RTMPS
stream {
    server {
        listen 1936 ssl;
        ssl_certificate /home/user/webstack/nginx/conf/ssl/cert.pem;
        ssl_certificate_key /home/user/webstack/nginx/conf/ssl/key.pem;
        proxy_pass 127.0.0.1:1935;
    }
}
```

</details>

### Add Custom Site

Create `nginx/conf/conf.d/mysite.conf`:

<details>
<summary><strong>💻 Code Block (nginx) — 23 lines</strong></summary>

```nginx
server {
    listen 80;
    server_name mysite.local;
    root /home/user/projects/mysite/public;
    index index.php index.html;
    
    # Laravel/Symfony style routing
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass php-fpm;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

</details>

Add to `/etc/hosts`:
<details>
<summary><strong>💻 Code Block — 1 lines</strong></summary>

```
127.0.0.1 mysite.local
```

</details>

Reload:
<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./nginx/sbin/nginx -p ~/webstack/nginx -s reload
```

</details>

## 8.2 PHP Configuration

### php.ini Settings

Location: `php/etc/php.ini`

Common customizations:

<details>
<summary><strong>💻 Code Block (ini) — 74 lines</strong></summary>

```ini
; ========================
; Resource Limits
; ========================
memory_limit = 512M
max_execution_time = 300
max_input_time = 300
max_input_vars = 5000

; ========================
; Upload Settings
; ========================
file_uploads = On
upload_max_filesize = 100M
post_max_size = 100M
max_file_uploads = 50

; ========================
; Error Handling
; ========================
; Development
display_errors = On
display_startup_errors = On
error_reporting = E_ALL
log_errors = On

; Production
; display_errors = Off
; display_startup_errors = Off
; error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; ========================
; OPcache (Performance)
; ========================
opcache.enable = 1
opcache.enable_cli = 1
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 20000
opcache.validate_timestamps = 0  ; Set to 1 for development
opcache.revalidate_freq = 0
opcache.jit = 1255
opcache.jit_buffer_size = 128M

; ========================
; Session
; ========================
session.save_handler = files
session.save_path = "/home/user/webstack/tmp/sessions"
session.gc_maxlifetime = 86400
session.cookie_httponly = 1
session.cookie_secure = 1  ; Enable for HTTPS
session.cookie_samesite = "Lax"

; ========================
; Security
; ========================
expose_php = Off
allow_url_fopen = On
allow_url_include = Off
disable_functions = exec,passthru,shell_exec,system,proc_open,popen

; ========================
; Date/Time
; ========================
date.timezone = UTC

; ========================
; Extensions Config
; ========================
[curl]
curl.cainfo = "/home/user/webstack/deps/ssl/certs/cacert.pem"

[openssl]
openssl.cafile = "/home/user/webstack/deps/ssl/certs/cacert.pem"
```

</details>

### PHP-FPM Pool Configuration

Location: `php/etc/php-fpm.d/www.conf`

<details>
<summary><strong>💻 Code Block (ini) — 38 lines</strong></summary>

```ini
[www]
; Listen socket
listen = /home/user/webstack/tmp/php-fpm.sock
listen.owner = username
listen.group = groupname
listen.mode = 0666

; Process user
user = username
group = groupname

; Process Manager
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 1000
pm.process_idle_timeout = 10s

; Logging
catch_workers_output = yes
decorate_workers_output = no
php_admin_value[error_log] = /home/user/webstack/php/var/log/php-error.log
php_admin_flag[log_errors] = on

; Slow log (for debugging)
slowlog = /home/user/webstack/php/var/log/php-slow.log
request_slowlog_timeout = 5s

; Security limits
php_admin_value[open_basedir] = /home/user/webstack/www:/tmp
php_admin_value[upload_tmp_dir] = /home/user/webstack/tmp/uploads
php_admin_value[session.save_path] = /home/user/webstack/tmp/sessions

; Environment
env[WEBSTACK_ROOT] = /home/user/webstack
env[DB_SOCKET] = /home/user/webstack/tmp/mysql.sock
```

</details>

### Create Additional PHP Pool

For running a separate application with different settings:

Create `php/etc/php-fpm.d/myapp.conf`:

<details>
<summary><strong>💻 Code Block (ini) — 15 lines</strong></summary>

```ini
[myapp]
listen = /home/user/webstack/tmp/php-fpm-myapp.sock
listen.mode = 0666

user = username
group = groupname

pm = dynamic
pm.max_children = 20
pm.start_servers = 5
pm.min_spare_servers = 2
pm.max_spare_servers = 10

php_admin_value[memory_limit] = 512M
php_admin_value[error_log] = /home/user/projects/myapp/logs/php-error.log
```

</details>

Use in Nginx:
<details>
<summary><strong>💻 Code Block (nginx) — 10 lines</strong></summary>

```nginx
upstream myapp-fpm {
    server unix:/home/user/webstack/tmp/php-fpm-myapp.sock;
}

server {
    location ~ \.php$ {
        fastcgi_pass myapp-fpm;
        # ...
    }
}
```

</details>

## 8.3 MySQL Configuration

Location: `mysql/my.cnf`

<details>
<summary><strong>💻 Code Block (ini) — 57 lines</strong></summary>

```ini
[mysqld]
# Directories
basedir = /home/user/webstack/mysql
datadir = /home/user/webstack/data/mysql
tmpdir = /home/user/webstack/tmp
socket = /home/user/webstack/tmp/mysql.sock
pid-file = /home/user/webstack/tmp/mysql.pid
log-error = /home/user/webstack/logs/mysql-error.log

# Network
port = 3306
bind-address = 127.0.0.1

# Connections
max_connections = 200
max_connect_errors = 100
wait_timeout = 600
interactive_timeout = 600

# Memory (adjust based on available RAM)
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_log_buffer_size = 16M
key_buffer_size = 32M
sort_buffer_size = 4M
read_buffer_size = 2M

# InnoDB
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT

# Query cache (MariaDB)
query_cache_type = 1
query_cache_size = 32M

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Security
skip-name-resolve
skip-external-locking

# Slow query log
slow_query_log = 1
slow_query_log_file = /home/user/webstack/logs/mysql-slow.log
long_query_time = 2

[client]
socket = /home/user/webstack/tmp/mysql.sock
default-character-set = utf8mb4

[mysql]
socket = /home/user/webstack/tmp/mysql.sock
default-character-set = utf8mb4
prompt = "mysql [\d]> "
```

</details>

## 8.4 Environment Variables

Create `.env` file in your project or use `scripts/env.sh`:

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# Source in your shell
source ~/webstack/scripts/env.sh

# Or add to ~/.bashrc
echo 'source ~/webstack/scripts/env.sh' >> ~/.bashrc
```

</details>

The `env.sh` script sets:

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
export WEBSTACK_ROOT="$HOME/webstack"
export PATH="$WEBSTACK_ROOT/deps/bin:$WEBSTACK_ROOT/php/bin:$WEBSTACK_ROOT/node/bin:$WEBSTACK_ROOT/mysql/bin:$WEBSTACK_ROOT/nginx/sbin:$PATH"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$WEBSTACK_ROOT/php/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$WEBSTACK_ROOT/deps/lib/pkgconfig:$PKG_CONFIG_PATH"
export SSL_CERT_FILE="$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem"
```

</details>

---

# 9. Development Guide

## 9.1 PHP Development

### Laravel Project

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
# Create project
cd ~/webstack/www
../composer create-project laravel/laravel myapp

# Configure database
cd myapp
nano .env
```

</details>

<details>
<summary><strong>💻 Code Block (env) — 7 lines</strong></summary>

```env
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_SOCKET=/home/user/webstack/tmp/mysql.sock
DB_DATABASE=myapp
DB_USERNAME=root
DB_PASSWORD=
```

</details>

Create database:
<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root -e "CREATE DATABASE myapp"
```

</details>

Nginx configuration (`nginx/conf/conf.d/laravel.conf`):
<details>
<summary><strong>💻 Code Block (nginx) — 20 lines</strong></summary>

```nginx
server {
    listen 80;
    server_name myapp.local;
    root /home/user/webstack/www/myapp/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/home/user/webstack/tmp/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known) {
        deny all;
    }
}
```

</details>

### WordPress

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
cd ~/webstack/www
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
rm latest.tar.gz

# Create database
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root -e "CREATE DATABASE wordpress"
```

</details>

Configure `wp-config.php`:
<details>
<summary><strong>💻 Code Block (php) — 4 lines</strong></summary>

```php
define('DB_NAME', 'wordpress');
define('DB_USER', 'root');
define('DB_PASSWORD', '');
define('DB_HOST', 'localhost:/home/user/webstack/tmp/mysql.sock');
```

</details>

### Using Redis in PHP

<details>
<summary><strong>💻 Code Block (php) — 28 lines</strong></summary>

```php
<?php
// Connect to Redis
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

// Set value
$redis->set('key', 'value');
$redis->setex('temp_key', 3600, 'expires in 1 hour');

// Get value
$value = $redis->get('key');

// Use as cache
function getCached($key, $callback, $ttl = 3600) {
    global $redis;
    $value = $redis->get($key);
    if ($value === false) {
        $value = $callback();
        $redis->setex($key, $ttl, serialize($value));
        return $value;
    }
    return unserialize($value);
}

$users = getCached('all_users', function() {
    // Expensive database query
    return $pdo->query('SELECT * FROM users')->fetchAll();
});
```

</details>

### Using Memcached in PHP

<details>
<summary><strong>💻 Code Block (php) — 17 lines</strong></summary>

```php
<?php
$memcached = new Memcached();
$memcached->addServer('127.0.0.1', 11211);

// Set value
$memcached->set('key', 'value', 3600);

// Get value
$value = $memcached->get('key');

// Multiple keys
$memcached->setMulti([
    'key1' => 'value1',
    'key2' => 'value2'
], 3600);

$values = $memcached->getMulti(['key1', 'key2']);
```

</details>

## 9.2 Node.js Development

### Express API

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
cd ~/webstack/www
mkdir api && cd api

# Initialize and install
~/webstack/node/bin/node ~/webstack/node/bin/npm init -y
~/webstack/node/bin/node ~/webstack/node/bin/npm install express cors helmet
```

</details>

Create `app.js`:
<details>
<summary><strong>💻 Code Block (javascript) — 42 lines</strong></summary>

```javascript
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Routes
app.get('/api/status', (req, res) => {
    res.json({
        status: 'ok',
        time: new Date().toISOString(),
        version: process.version
    });
});

app.get('/api/users', (req, res) => {
    res.json([
        { id: 1, name: 'John' },
        { id: 2, name: 'Jane' }
    ]);
});

app.post('/api/users', (req, res) => {
    const { name } = req.body;
    res.status(201).json({ id: 3, name });
});

// Error handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Internal Server Error' });
});

app.listen(PORT, '127.0.0.1', () => {
    console.log(`API server running on port ${PORT}`);
});
```

</details>

### Socket.IO Real-time App

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~/webstack/ws
~/webstack/node/bin/node ~/webstack/node/bin/npm install socket.io
```

</details>

Create `socketio-server.js`:
<details>
<summary><strong>💻 Code Block (javascript) — 43 lines</strong></summary>

```javascript
const { Server } = require('socket.io');
const http = require('http');

const server = http.createServer();
const io = new Server(server, {
    cors: { origin: '*' }
});

const rooms = new Map();

io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);
    
    // Join room
    socket.on('join', (room) => {
        socket.join(room);
        if (!rooms.has(room)) rooms.set(room, new Set());
        rooms.get(room).add(socket.id);
        io.to(room).emit('userCount', rooms.get(room).size);
    });
    
    // Chat message
    socket.on('message', ({ room, message }) => {
        io.to(room).emit('message', {
            from: socket.id,
            message,
            time: new Date().toISOString()
        });
    });
    
    // Disconnect
    socket.on('disconnect', () => {
        rooms.forEach((users, room) => {
            if (users.delete(socket.id)) {
                io.to(room).emit('userCount', users.size);
            }
        });
    });
});

server.listen(8081, () => {
    console.log('Socket.IO server on port 8081');
});
```

</details>

## 9.3 Database Development

### Create Development Database

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Connect to MySQL
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root

# In MySQL
CREATE DATABASE devdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'devuser'@'localhost' IDENTIFIED BY 'devpass';
GRANT ALL PRIVILEGES ON devdb.* TO 'devuser'@'localhost';
FLUSH PRIVILEGES;
```

</details>

### Database Migrations (Raw SQL)

Create `migrations/001_create_users.sql`:
<details>
<summary><strong>💻 Code Block (sql) — 10 lines</strong></summary>

```sql
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
```

</details>

Run migration:
<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root devdb < migrations/001_create_users.sql
```

</details>

## 9.4 Using Composer

<details>
<summary><strong>💻 Code Block (bash) — 17 lines</strong></summary>

```bash
# From webstack root
./composer --version

# In project directory
cd ~/webstack/www/myproject

# Install dependencies
~/webstack/composer install

# Add package
~/webstack/composer require monolog/monolog

# Update packages
~/webstack/composer update

# Autoload dump
~/webstack/composer dump-autoload -o
```

</details>

---

# 10. Production Deployment

## 10.1 Pre-deployment Checklist

- [ ] Run `./cleanup.sh` to reduce size
- [ ] Disable PHP display_errors
- [ ] Enable OPcache with validate_timestamps=0
- [ ] Configure proper SSL certificates
- [ ] Set strong MySQL root password
- [ ] Remove phpMyAdmin or restrict access
- [ ] Configure firewall rules
- [ ] Set up regular backups
- [ ] Configure log rotation

## 10.2 Production PHP Settings

Edit `php/etc/php.ini`:

<details>
<summary><strong>💻 Code Block (ini) — 18 lines</strong></summary>

```ini
; Production settings
display_errors = Off
display_startup_errors = Off
log_errors = On
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; OPcache
opcache.enable = 1
opcache.validate_timestamps = 0
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.jit = 1255
opcache.jit_buffer_size = 128M

; Security
expose_php = Off
session.cookie_secure = 1
session.cookie_httponly = 1
```

</details>

## 10.3 Production Nginx Settings

<details>
<summary><strong>💻 Code Block (nginx) — 26 lines</strong></summary>

```nginx
# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;

# Rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_conn_zone $binary_remote_addr zone=conn:10m;

server {
    # Rate limit for API
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        limit_conn conn 10;
        # ...
    }
    
    # Restrict phpMyAdmin
    location /phpmyadmin {
        allow 192.168.1.0/24;  # Allow local network
        deny all;
        # ...
    }
}
```

</details>

## 10.4 SSL Certificate (Let's Encrypt)

Using certbot standalone:

<details>
<summary><strong>💻 Code Block (bash) — 16 lines</strong></summary>

```bash
# Install certbot
sudo apt install certbot

# Stop nginx temporarily
./webstack stop

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ~/webstack/nginx/conf/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ~/webstack/nginx/conf/ssl/key.pem
sudo chown $(whoami) ~/webstack/nginx/conf/ssl/*.pem

# Restart
./webstack start
```

</details>

Auto-renewal script (`scripts/renew_letsencrypt.sh`):
<details>
<summary><strong>💻 Code Block (bash) — 16 lines</strong></summary>

```bash
#!/bin/bash
WEBSTACK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Stop nginx
"$WEBSTACK_ROOT/webstack" stop

# Renew
sudo certbot renew --quiet

# Copy new certs
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem "$WEBSTACK_ROOT/nginx/conf/ssl/cert.pem"
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem "$WEBSTACK_ROOT/nginx/conf/ssl/key.pem"
sudo chown $(whoami) "$WEBSTACK_ROOT/nginx/conf/ssl/"*.pem

# Start nginx
"$WEBSTACK_ROOT/webstack" start
```

</details>

Add to crontab:
<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
0 3 1 * * /home/user/webstack/scripts/renew_letsencrypt.sh
```

</details>

## 10.5 Systemd Service

Create `/etc/systemd/system/webstack.service`:

<details>
<summary><strong>💻 Code Block (ini) — 17 lines</strong></summary>

```ini
[Unit]
Description=WebStack Portable Web Server
After=network.target

[Service]
Type=forking
User=webuser
Group=webuser
WorkingDirectory=/home/webuser/webstack
ExecStart=/home/webuser/webstack/webstack start
ExecStop=/home/webuser/webstack/webstack stop
ExecReload=/home/webuser/webstack/webstack restart
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

</details>

Enable and start:
<details>
<summary><strong>💻 Code Block (bash) — 3 lines</strong></summary>

```bash
sudo systemctl daemon-reload
sudo systemctl enable webstack
sudo systemctl start webstack
```

</details>

## 10.6 Cloudflare Tunnel for Production

For reliable public access without opening ports:

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
# Start daemon
./webstack tunnel daemon

# The daemon will:
# - Auto-reconnect if tunnel dies
# - Create new tunnel if reconnection fails
# - Log all URLs to history
```

</details>

For permanent tunnel with fixed domain, use Cloudflare Zero Trust dashboard to create a named tunnel.

---

# 11. Backup & Recovery

## 11.1 Manual Backup

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
# Run backup script
./scripts/backup.sh
```

</details>

This creates:
- `backups/www_TIMESTAMP.tar.gz` - Web files
- `backups/mysql_TIMESTAMP.sql.gz` - Database dump
- `backups/config_TIMESTAMP.tar.gz` - Configuration files

## 11.2 Automated Backups

Add to crontab (`crontab -e`):

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# Daily backup at 2 AM
0 2 * * * /home/user/webstack/scripts/backup.sh >> /home/user/webstack/logs/backup.log 2>&1

# Weekly cleanup of old backups
0 3 * * 0 find /home/user/webstack/backups -mtime +30 -delete
```

</details>

## 11.3 Restore from Backup

### Restore Web Files

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~/webstack
tar -xzf backups/www_20240115_020000.tar.gz
```

</details>

### Restore Database

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
gunzip -c backups/mysql_20240115_020000.sql.gz | \
    ~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root
```

</details>

### Restore Configuration

<details>
<summary><strong>💻 Code Block (bash) — 3 lines</strong></summary>

```bash
cd ~/webstack
tar -xzf backups/config_20240115_020000.tar.gz
./webstack restart
```

</details>

## 11.4 Full System Backup

For complete backup including binaries:

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~
tar -czvf webstack_full_backup_$(date +%Y%m%d).tar.gz webstack/
```

</details>

## 11.5 Remote Backup

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# Backup to remote server
rsync -avz ~/webstack/backups/ user@remote:/backups/webstack/

# Or use rclone for cloud storage
rclone sync ~/webstack/backups remote:webstack-backups
```

</details>

---

# 12. Troubleshooting

## 12.1 Common Issues

### Nginx Won't Start

**Error:** `bind() to 0.0.0.0:80 failed (13: Permission denied)`

**Solution:**
<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Option 1: Use setcap
sudo setcap 'cap_net_bind_service=+ep' ~/webstack/nginx/sbin/nginx

# Option 2: Use ports above 1024
# Edit nginx.conf: listen 8080;

# Option 3: Run as root (not recommended)
sudo ./nginx/sbin/nginx -p ~/webstack/nginx
```

</details>

**Error:** `nginx: [emerg] unknown directive "push_stream_shared_memory_size"`

**Solution:** Push stream module not compiled. Rebuild Nginx or remove push_stream directives.

### PHP-FPM Won't Start

**Error:** `unable to bind listening socket for address`

**Solution:**
<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# Remove stale socket
rm -f ~/webstack/tmp/php-fpm.sock

# Check if another process is using it
lsof ~/webstack/tmp/php-fpm.sock
```

</details>

**Error:** `pool www: cannot get uid for user 'username'`

**Solution:** Run `./setup.sh` to regenerate config with correct username.

### MySQL Won't Start

**Error:** `Can't start server: can't create PID file`

**Solution:**
<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Create tmp directory
mkdir -p ~/webstack/tmp

# Check permissions
ls -la ~/webstack/tmp/

# Remove stale files
rm -f ~/webstack/tmp/mysql.pid ~/webstack/tmp/mysql.sock
```

</details>

**Error:** `InnoDB: Unable to lock ./ibdata1`

**Solution:** Another MySQL instance is running. Kill it:
<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
pkill -f mysqld
```

</details>

### Node.js Issues

**Error:** `Cannot find module 'ws'`

**Solution:**
<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~/webstack/ws
../node/bin/node ../node/bin/npm install
```

</details>

### Cloudflare Tunnel Issues

**Error:** `Tunnel not starting`

**Solution:**
<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# Check cloudflared is installed
./deps/bin/cloudflared --version

# Check logs
cat logs/cloudflare/cloudflared.log

# Restart
./webstack tunnel stop
./webstack tunnel start
```

</details>

## 12.2 Checking Logs

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# All logs at once
./scripts/logs.sh

# Specific logs
./scripts/logs.sh nginx
./scripts/logs.sh php
./scripts/logs.sh mysql
./scripts/logs.sh node
./scripts/logs.sh cloudflare

# Tail specific log file
tail -f nginx/logs/error.log
tail -f php/var/log/php-fpm.log
tail -f logs/mysql-error.log
```

</details>

## 12.3 Testing Components

<details>
<summary><strong>💻 Code Block (bash) — 22 lines</strong></summary>

```bash
# Test Nginx config
./nginx/sbin/nginx -t -p ~/webstack/nginx

# Test PHP
./php/bin/php -v
./php/bin/php -m

# Test MySQL connection
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -e "SELECT 1"

# Test HTTP
curl http://localhost
curl -k https://localhost

# Test PHP processing
curl http://localhost/phpinfo.php

# Test API
curl http://localhost/api/status

# Health check
./scripts/health.sh
```

</details>

## 12.4 Resetting Components

### Reset PHP-FPM

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
# Stop
kill $(cat php/var/run/php-fpm.pid) 2>/dev/null
rm -f tmp/php-fpm.sock php/var/run/php-fpm.pid

# Start fresh
./php/sbin/php-fpm -c ./php/etc/php.ini -y ./php/etc/php-fpm.conf
```

</details>

### Reset Nginx

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
# Stop
./nginx/sbin/nginx -p ~/webstack/nginx -s quit
rm -f tmp/nginx.pid

# Start fresh
./nginx/sbin/nginx -p ~/webstack/nginx
```

</details>

### Reset MySQL

<details>
<summary><strong>💻 Code Block (bash) — 12 lines</strong></summary>

```bash
# Stop
./scripts/stop_mysql.sh

# Clear data (WARNING: deletes all data!)
rm -rf data/mysql/*

# Reinitialize
cd mysql
./scripts/mysql_install_db --basedir=. --datadir=../data/mysql

# Start
../scripts/start_mysql.sh
```

</details>

### Complete Reset

<details>
<summary><strong>💻 Code Block (bash) — 12 lines</strong></summary>

```bash
# Stop everything
./webstack stop

# Clear runtime files
rm -rf tmp/*
mkdir -p tmp

# Regenerate config
./setup.sh

# Start fresh
./webstack start
```

</details>

## 12.5 Debug Mode

### PHP Debug

<details>
<summary><strong>💻 Code Block (ini) — 4 lines</strong></summary>

```ini
; Enable in php.ini temporarily
display_errors = On
error_reporting = E_ALL
xdebug.mode = debug
```

</details>

### Nginx Debug

<details>
<summary><strong>💻 Code Block (nginx) — 2 lines</strong></summary>

```nginx
# In nginx.conf
error_log /path/to/error.log debug;
```

</details>

### Node.js Debug

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
# Run with debugging
NODE_DEBUG=http,net ./node/bin/node www/app.js
```

</details>

---

# 13. Security

## 13.1 Security Checklist

- [ ] Change MySQL root password
- [ ] Remove or protect phpMyAdmin
- [ ] Disable directory listing
- [ ] Enable HTTPS only
- [ ] Configure firewall
- [ ] Keep components updated
- [ ] Regular backups
- [ ] Monitor logs

## 13.2 MySQL Security

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# Set root password
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

ALTER USER 'root'@'localhost' IDENTIFIED BY 'strongpassword';
FLUSH PRIVILEGES;

# Remove anonymous users
DELETE FROM mysql.user WHERE User='';

# Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

FLUSH PRIVILEGES;
```

</details>

## 13.3 Nginx Security Headers

<details>
<summary><strong>💻 Code Block (nginx) — 12 lines</strong></summary>

```nginx
# Add to server block
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;

# HTTPS only
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# Content Security Policy (adjust as needed)
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self' wss:; frame-ancestors 'self';" always;
```

</details>

## 13.4 PHP Security

<details>
<summary><strong>💻 Code Block (ini) — 22 lines</strong></summary>

```ini
; php.ini security settings
expose_php = Off
display_errors = Off
log_errors = On

; Disable dangerous functions
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_multi_exec,show_source

; Session security
session.cookie_httponly = 1
session.cookie_secure = 1
session.cookie_samesite = "Strict"
session.use_strict_mode = 1

; File uploads
file_uploads = On
upload_max_filesize = 10M  ; Limit upload size

; Limits
max_execution_time = 30
max_input_time = 30
memory_limit = 128M
```

</details>

## 13.5 Firewall (UFW)

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Allow only necessary ports
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
# sudo ufw allow 1935/tcp  # RTMP if needed
sudo ufw enable
```

</details>

## 13.6 Restrict phpMyAdmin

<details>
<summary><strong>💻 Code Block (nginx) — 12 lines</strong></summary>

```nginx
location /phpmyadmin {
    # Allow only from specific IPs
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    # Or use basic auth
    auth_basic "Admin Area";
    auth_basic_user_file /home/user/webstack/nginx/conf/.htpasswd;
    
    # ...existing config...
}
```

</details>

Create `.htpasswd`:
<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
# Using openssl
echo "admin:$(openssl passwd -apr1 'password')" > nginx/conf/.htpasswd
```

</details>

---

# 14. Performance Tuning

## 14.1 Nginx Optimization

<details>
<summary><strong>💻 Code Block (nginx) — 55 lines</strong></summary>

```nginx
# Worker processes
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 65535;
    use epoll;
    multi_accept on;
}

http {
    # Buffers
    client_body_buffer_size 128k;
    client_max_body_size 100M;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 32k;
    output_buffers 1 32k;
    postpone_output 1460;
    
    # Timeouts
    client_header_timeout 60s;
    client_body_timeout 60s;
    send_timeout 60s;
    keepalive_timeout 65s;
    keepalive_requests 1000;
    
    # TCP optimization
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    
    # Gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml;
    
    # Brotli (if available)
    brotli on;
    brotli_comp_level 6;
    brotli_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml;
    
    # FastCGI cache
    fastcgi_cache_path /home/user/webstack/tmp/fastcgi levels=1:2 keys_zone=FASTCGI:100m inactive=60m;
    fastcgi_cache_key "$scheme$request_method$host$request_uri";
    
    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff2|woff|ttf|svg)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
}
```

</details>

## 14.2 PHP-FPM Optimization

<details>
<summary><strong>💻 Code Block (ini) — 14 lines</strong></summary>

```ini
[www]
; Process manager
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 1000
pm.process_idle_timeout = 10s

; Emergency restart
emergency_restart_threshold = 10
emergency_restart_interval = 1m
process_control_timeout = 10s
```

</details>

### OPcache Settings

<details>
<summary><strong>💻 Code Block (ini) — 12 lines</strong></summary>

```ini
; php.ini
opcache.enable = 1
opcache.enable_cli = 1
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 32
opcache.max_accelerated_files = 30000
opcache.max_wasted_percentage = 10
opcache.validate_timestamps = 0  ; Disable for production
opcache.revalidate_freq = 0
opcache.fast_shutdown = 1
opcache.jit = 1255
opcache.jit_buffer_size = 128M
```

</details>

## 14.3 MySQL Optimization

<details>
<summary><strong>💻 Code Block (ini) — 36 lines</strong></summary>

```ini
[mysqld]
# InnoDB
innodb_buffer_pool_size = 1G  ; 70-80% of available RAM for dedicated server
innodb_buffer_pool_instances = 4
innodb_log_file_size = 256M
innodb_log_buffer_size = 64M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
innodb_file_per_table = 1
innodb_io_capacity = 2000
innodb_io_capacity_max = 4000

# Connections
max_connections = 500
thread_cache_size = 50
table_open_cache = 4000
table_definition_cache = 2000

# Temp tables
tmp_table_size = 64M
max_heap_table_size = 64M

# Query cache
query_cache_type = 1
query_cache_size = 64M
query_cache_limit = 2M

# Buffers
sort_buffer_size = 4M
join_buffer_size = 4M
read_buffer_size = 2M
read_rnd_buffer_size = 8M

# Logging
slow_query_log = 1
long_query_time = 1
```

</details>

## 14.4 System Optimization

### sysctl settings (`/etc/sysctl.conf`):

<details>
<summary><strong>💻 Code Block — 16 lines</strong></summary>

```
# Network
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

# Memory
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 5

# File handles
fs.file-max = 2097152
fs.nr_open = 2097152
```

</details>

Apply: `sudo sysctl -p`

### ulimits (`/etc/security/limits.conf`):

<details>
<summary><strong>💻 Code Block — 4 lines</strong></summary>

```
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
```

</details>

---

# 15. API Reference

## 15.1 Built-in Node.js API

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/status` | Health check |
| GET | `/api/*` | Generic endpoint |
| POST | `/api/*` | Generic endpoint |
| GET | `/events` | Server-Sent Events stream |

### Response Format

<details>
<summary><strong>💻 Code Block (json) — 5 lines</strong></summary>

```json
{
    "status": "ok",
    "time": "2024-01-15T12:00:00.000Z",
    "node": "v20.10.0"
}
```

</details>

## 15.2 WebSocket API

### Connection

<details>
<summary><strong>💻 Code Block (javascript) — 2 lines</strong></summary>

```javascript
const ws = new WebSocket('ws://localhost/ws');
// or wss:// for secure
```

</details>

### Messages

**Server → Client:**

<details>
<summary><strong>💻 Code Block (json) — 8 lines</strong></summary>

```json
// Welcome message
{"type": "welcome", "id": 1, "time": "2024-01-15T12:00:00.000Z"}

// Echo response
{"type": "echo", "data": "your message", "time": "2024-01-15T12:00:00.000Z"}

// Broadcast from another client
{"type": "broadcast", "from": 2, "data": "message"}
```

</details>

**Client → Server:**

<details>
<summary><strong>💻 Code Block (javascript) — 2 lines</strong></summary>

```javascript
ws.send("Hello, server!");
ws.send(JSON.stringify({ action: "subscribe", channel: "updates" }));
```

</details>

## 15.3 Server-Sent Events (Push Stream)

### Subscribe

<details>
<summary><strong>💻 Code Block (javascript) — 9 lines</strong></summary>

```javascript
const evtSource = new EventSource('/sse/sub?channel=mychannel');

evtSource.onmessage = (event) => {
    console.log('Received:', event.data);
};

evtSource.onerror = (error) => {
    console.error('Error:', error);
};
```

</details>

### Publish

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
curl -X POST "http://localhost/sse/pub?channel=mychannel" -d "Hello subscribers!"
```

</details>

## 15.4 RTMP Status API

### Get RTMP Statistics

<details>
<summary><strong>💻 Code Block (nginx) — 9 lines</strong></summary>

```nginx
# Add to nginx.conf
location /rtmp_stat {
    rtmp_stat all;
    rtmp_stat_stylesheet stat.xsl;
}

location /rtmp_stat.xsl {
    root /home/user/webstack/www;
}
```

</details>

Access: `http://localhost/rtmp_stat`

---

# 16. Examples

## 16.1 Simple PHP Application

`www/myapp/index.php`:

<details>
<summary><strong>💻 Code Block (php) — 50 lines</strong></summary>

```php
<?php
// Configuration
$config = [
    'db' => [
        'socket' => '/home/user/webstack/tmp/mysql.sock',
        'name' => 'myapp',
        'user' => 'root',
        'pass' => ''
    ]
];

// Database connection
try {
    $pdo = new PDO(
        "mysql:unix_socket={$config['db']['socket']};dbname={$config['db']['name']}",
        $config['db']['user'],
        $config['db']['pass'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
} catch (PDOException $e) {
    die("Database error: " . $e->getMessage());
}

// Simple router
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

header('Content-Type: application/json');

switch ($uri) {
    case '/':
        echo json_encode(['message' => 'Welcome to MyApp']);
        break;
        
    case '/users':
        if ($method === 'GET') {
            $stmt = $pdo->query('SELECT id, name, email FROM users');
            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        } elseif ($method === 'POST') {
            $data = json_decode(file_get_contents('php://input'), true);
            $stmt = $pdo->prepare('INSERT INTO users (name, email) VALUES (?, ?)');
            $stmt->execute([$data['name'], $data['email']]);
            echo json_encode(['id' => $pdo->lastInsertId()]);
        }
        break;
        
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Not found']);
}
```

</details>

## 16.2 Real-time Chat with WebSocket

`www/chat/index.html`:

<details>
<summary><strong>💻 Code Block (html) — 117 lines</strong></summary>

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebStack Chat</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: system-ui, sans-serif; background: #f5f5f5; }
        .container { max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: #007bff; color: white; padding: 15px; }
        .messages { height: 400px; overflow-y: auto; padding: 15px; }
        .message { margin: 10px 0; padding: 10px; border-radius: 8px; }
        .message.self { background: #007bff; color: white; margin-left: 20%; }
        .message.other { background: #e9ecef; margin-right: 20%; }
        .message.system { background: #ffc107; text-align: center; font-size: 0.9em; }
        .input-area { display: flex; padding: 15px; border-top: 1px solid #ddd; }
        .input-area input { flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 5px; margin-right: 10px; }
        .input-area button { padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
        .status { padding: 5px 15px; font-size: 0.8em; color: #666; }
        .status.connected { color: green; }
        .status.disconnected { color: red; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>💬 WebStack Chat</h2>
        </div>
        <div class="status" id="status">Connecting...</div>
        <div class="messages" id="messages"></div>
        <div class="input-area">
            <input type="text" id="input" placeholder="Type a message..." disabled>
            <button id="send" disabled>Send</button>
        </div>
    </div>

    <script>
        const messagesDiv = document.getElementById('messages');
        const statusDiv = document.getElementById('status');
        const input = document.getElementById('input');
        const sendBtn = document.getElementById('send');
        let ws;
        let myId;

        function connect() {
            const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
            ws = new WebSocket(`${protocol}//${location.host}/ws`);

            ws.onopen = () => {
                statusDiv.textContent = 'Connected';
                statusDiv.className = 'status connected';
                input.disabled = false;
                sendBtn.disabled = false;
            };

            ws.onmessage = (event) => {
                const data = JSON.parse(event.data);
                handleMessage(data);
            };

            ws.onclose = () => {
                statusDiv.textContent = 'Disconnected - Reconnecting...';
                statusDiv.className = 'status disconnected';
                input.disabled = true;
                sendBtn.disabled = true;
                setTimeout(connect, 3000);
            };

            ws.onerror = (error) => {
                console.error('WebSocket error:', error);
            };
        }

        function handleMessage(data) {
            const div = document.createElement('div');
            div.className = 'message';

            switch (data.type) {
                case 'welcome':
                    myId = data.id;
                    div.className = 'message system';
                    div.textContent = `Welcome! You are user #${data.id}`;
                    break;
                case 'echo':
                    div.className = 'message self';
                    div.textContent = data.data;
                    break;
                case 'broadcast':
                    div.className = 'message other';
                    div.textContent = `User #${data.from}: ${data.data}`;
                    break;
                default:
                    return;
            }

            messagesDiv.appendChild(div);
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }

        function sendMessage() {
            const message = input.value.trim();
            if (message && ws.readyState === WebSocket.OPEN) {
                ws.send(message);
                input.value = '';
            }
        }

        sendBtn.onclick = sendMessage;
        input.onkeypress = (e) => {
            if (e.key === 'Enter') sendMessage();
        };

        connect();
    </script>
</body>
</html>
```

</details>

## 16.3 Live Streaming Page

`www/live/index.html`:

<details>
<summary><strong>💻 Code Block (html) — 94 lines</strong></summary>

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Live Stream - WebStack</title>
    <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: system-ui, sans-serif; background: #000; color: #fff; min-height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; }
        .player-container { max-width: 1280px; width: 100%; }
        video { width: 100%; background: #111; }
        .controls { padding: 20px; text-align: center; }
        .controls input { padding: 10px; width: 300px; border: 1px solid #333; background: #222; color: #fff; border-radius: 5px; }
        .controls button { padding: 10px 20px; background: #dc3545; color: white; border: none; border-radius: 5px; cursor: pointer; margin-left: 10px; }
        .info { padding: 10px; font-size: 0.9em; color: #888; }
        .status { padding: 5px 10px; border-radius: 3px; display: inline-block; margin: 10px 0; }
        .status.live { background: #dc3545; }
        .status.offline { background: #666; }
    </style>
</head>
<body>
    <div class="player-container">
        <video id="video" controls playsinline></video>
        <div class="controls">
            <input type="text" id="streamKey" placeholder="Enter stream key" value="test">
            <button id="loadBtn">Load Stream</button>
        </div>
        <div class="info">
            <span class="status" id="status">Offline</span>
            <p>Stream URL: <code>rtmp://localhost:1935/live/YOUR_KEY</code></p>
        </div>
    </div>

    <script>
        const video = document.getElementById('video');
        const streamKeyInput = document.getElementById('streamKey');
        const loadBtn = document.getElementById('loadBtn');
        const statusEl = document.getElementById('status');
        let hls;

        function loadStream() {
            const streamKey = streamKeyInput.value.trim();
            if (!streamKey) return;

            const streamUrl = `/hls/${streamKey}.m3u8`;

            if (hls) {
                hls.destroy();
            }

            if (Hls.isSupported()) {
                hls = new Hls({
                    lowLatencyMode: true,
                    liveSyncDuration: 3,
                    liveMaxLatencyDuration: 10
                });

                hls.loadSource(streamUrl);
                hls.attachMedia(video);

                hls.on(Hls.Events.MANIFEST_PARSED, () => {
                    video.play();
                    statusEl.textContent = '🔴 LIVE';
                    statusEl.className = 'status live';
                });

                hls.on(Hls.Events.ERROR, (event, data) => {
                    if (data.fatal) {
                        statusEl.textContent = 'Offline';
                        statusEl.className = 'status offline';
                        console.error('HLS Error:', data);
                    }
                });
            } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
                video.src = streamUrl;
                video.play();
            }
        }

        loadBtn.onclick = loadStream;
        streamKeyInput.onkeypress = (e) => {
            if (e.key === 'Enter') loadStream();
        };

        // Auto-refresh when stream becomes available
        setInterval(() => {
            if (hls && hls.media && hls.media.paused) {
                loadStream();
            }
        }, 5000);
    </script>
</body>
</html>
```

</details>

## 16.4 File Upload with Progress

`www/upload/index.php`:

<details>
<summary><strong>💻 Code Block (php) — 143 lines</strong></summary>

```php
<?php
$uploadDir = '/home/user/webstack/www/uploads/';
$maxSize = 100 * 1024 * 1024; // 100MB

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Content-Type: application/json');
    
    if (!isset($_FILES['file'])) {
        http_response_code(400);
        echo json_encode(['error' => 'No file uploaded']);
        exit;
    }
    
    $file = $_FILES['file'];
    
    if ($file['error'] !== UPLOAD_ERR_OK) {
        http_response_code(400);
        echo json_encode(['error' => 'Upload error: ' . $file['error']]);
        exit;
    }
    
    if ($file['size'] > $maxSize) {
        http_response_code(400);
        echo json_encode(['error' => 'File too large']);
        exit;
    }
    
    $filename = time() . '_' . preg_replace('/[^a-zA-Z0-9._-]/', '', $file['name']);
    $destination = $uploadDir . $filename;
    
    if (move_uploaded_file($file['tmp_name'], $destination)) {
        echo json_encode([
            'success' => true,
            'filename' => $filename,
            'size' => $file['size'],
            'url' => '/uploads/' . $filename
        ]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to save file']);
    }
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>File Upload</title>
    <style>
        body { font-family: system-ui; max-width: 600px; margin: 50px auto; padding: 20px; }
        .drop-zone { border: 3px dashed #ccc; padding: 50px; text-align: center; cursor: pointer; border-radius: 10px; }
        .drop-zone.dragover { border-color: #007bff; background: #f0f7ff; }
        .progress { height: 20px; background: #eee; border-radius: 10px; overflow: hidden; margin: 20px 0; display: none; }
        .progress-bar { height: 100%; background: #007bff; transition: width 0.3s; }
        .result { padding: 15px; background: #d4edda; border-radius: 5px; margin: 20px 0; display: none; }
    </style>
</head>
<body>
    <h1>📤 File Upload</h1>
    
    <div class="drop-zone" id="dropZone">
        <p>Drag & drop files here or click to select</p>
        <input type="file" id="fileInput" style="display: none">
    </div>
    
    <div class="progress" id="progress">
        <div class="progress-bar" id="progressBar"></div>
    </div>
    
    <div class="result" id="result"></div>

    <script>
        const dropZone = document.getElementById('dropZone');
        const fileInput = document.getElementById('fileInput');
        const progress = document.getElementById('progress');
        const progressBar = document.getElementById('progressBar');
        const result = document.getElementById('result');

        dropZone.onclick = () => fileInput.click();
        
        dropZone.ondragover = (e) => {
            e.preventDefault();
            dropZone.classList.add('dragover');
        };
        
        dropZone.ondragleave = () => {
            dropZone.classList.remove('dragover');
        };
        
        dropZone.ondrop = (e) => {
            e.preventDefault();
            dropZone.classList.remove('dragover');
            uploadFile(e.dataTransfer.files[0]);
        };
        
        fileInput.onchange = () => {
            if (fileInput.files.length) {
                uploadFile(fileInput.files[0]);
            }
        };

        function uploadFile(file) {
            const formData = new FormData();
            formData.append('file', file);
            
            const xhr = new XMLHttpRequest();
            
            xhr.upload.onprogress = (e) => {
                if (e.lengthComputable) {
                    const percent = (e.loaded / e.total) * 100;
                    progressBar.style.width = percent + '%';
                }
            };
            
            xhr.onload = () => {
                progress.style.display = 'none';
                const data = JSON.parse(xhr.responseText);
                
                if (xhr.status === 200) {
                    result.innerHTML = `
                        <strong>✅ Upload successful!</strong><br>
                        File: ${data.filename}<br>
                        Size: ${(data.size / 1024 / 1024).toFixed(2)} MB<br>
                        <a href="${data.url}" target="_blank">Download</a>
                    `;
                    result.style.display = 'block';
                    result.style.background = '#d4edda';
                } else {
                    result.innerHTML = `<strong>❌ Error:</strong> ${data.error}`;
                    result.style.display = 'block';
                    result.style.background = '#f8d7da';
                }
            };
            
            progress.style.display = 'block';
            progressBar.style.width = '0%';
            
            xhr.open('POST', '');
            xhr.send(formData);
        }
    </script>
</body>
</html>
```

</details>

---

# 17. FAQ

## General

**Q: Can I run WebStack on Windows?**
A: WebStack is designed for Linux. On Windows, use WSL2 (Windows Subsystem for Linux).

**Q: Does it require root/sudo?**
A: No, except for binding to ports 80/443. Use `setcap` or higher ports to avoid root.

**Q: Can I run multiple WebStack instances?**
A: Yes, but use different ports for each instance.

**Q: How do I update components?**
A: Rebuild from source with newer versions. Keep www/ and data/ separate.

## Nginx

**Q: How do I add a new website?**
A: Create a `.conf` file in `nginx/conf/conf.d/` and reload nginx.

**Q: Why can't I bind to port 80?**
A: Use `sudo setcap 'cap_net_bind_service=+ep' nginx/sbin/nginx` or use port 8080.

**Q: How do I enable Brotli compression?**
A: Already enabled if compiled with ngx_brotli module. Check with `nginx -V`.

## PHP

**Q: How do I install additional PHP extensions?**
A: Use `pecl` or compile from source with phpize. Extensions go in `php/lib/php/extensions/`.

**Q: Why doesn't OPcache update my code?**
A: Set `opcache.validate_timestamps = 1` in development.

**Q: How do I change PHP memory limit?**
A: Edit `php/etc/php.ini` and set `memory_limit = 512M`.

## MySQL

**Q: How do I reset the MySQL root password?**
A: Stop MySQL, start with `--skip-grant-tables`, reset password, restart normally.

**Q: Can I use remote MySQL connections?**
A: Yes, change `bind-address = 0.0.0.0` in my.cnf and open firewall.

**Q: Where is my data stored?**
A: In `data/mysql/` directory.

## Cloudflare Tunnel

**Q: How long does a tunnel URL last?**
A: Try Cloudflare URLs are temporary and change on restart.

**Q: Can I get a permanent URL?**
A: Yes, create a named tunnel through Cloudflare Zero Trust dashboard.

**Q: Why does my tunnel keep reconnecting?**
A: Network issues or cloudflared updates. The daemon handles this automatically.

## RTMP Streaming

**Q: What latency can I expect?**
A: HLS typically has 10-30 second latency. Use RTMP direct for lower latency.

**Q: Can I stream to YouTube/Twitch?**
A: Yes, use FFmpeg to re-stream: `ffmpeg -i rtmp://localhost:1935/live/key -c copy -f flv rtmp://youtube-server/stream-key`

**Q: How do I record streams?**
A: Enable `record all` in the RTMP application config.

---

# 18. Appendix

## 18.1 File Locations Quick Reference

| What | Where |
|------|-------|
| Web root | `www/` |
| Nginx config | `nginx/conf/nginx.conf` |
| Nginx sites | `nginx/conf/conf.d/` |
| SSL certs | `nginx/conf/ssl/` |
| PHP config | `php/etc/php.ini` |
| PHP-FPM config | `php/etc/php-fpm.conf` |
| MySQL config | `mysql/my.cnf` |
| MySQL data | `data/mysql/` |
| HLS output | `www/hls/` |
| Videos | `www/videos/` |
| Logs | `logs/`, `nginx/logs/`, `php/var/log/` |
| Backups | `backups/` |
| Temp files | `tmp/` |
| Scripts | `scripts/` |
| CA certs | `deps/ssl/certs/cacert.pem` |

## 18.2 Port Reference

| Port | Service | Protocol |
|------|---------|----------|
| 80 | HTTP | TCP |
| 443 | HTTPS/HTTP3 | TCP/UDP |
| 1935 | RTMP | TCP |
| 1936 | RTMPS | TCP |
| 3000 | Node.js API | TCP |
| 3306 | MySQL | TCP |
| 8081 | WebSocket | TCP |

## 18.3 Environment Variables

| Variable | Description |
|----------|-------------|
| `WEBSTACK_ROOT` | Base directory |
| `PATH` | Includes all binary directories |
| `LD_LIBRARY_PATH` | Shared library paths |
| `PKG_CONFIG_PATH` | Package config paths |
| `SSL_CERT_FILE` | CA certificate bundle |

## 18.4 Useful Commands Cheatsheet

<details>
<summary><strong>💻 Code Block (bash) — 38 lines</strong></summary>

```bash
# Start/stop
./webstack start
./webstack stop
./webstack restart
./webstack status

# Cloudflare tunnel
./webstack tunnel daemon       # Start with auto-reconnect
./webstack tunnel url          # Get URL
./webstack tunnel stop-daemon  # Stop

# Logs
./scripts/logs.sh              # All logs
./scripts/logs.sh nginx        # Nginx only

# Backup
./scripts/backup.sh

# Health check
./scripts/health.sh

# MySQL
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# PHP
./php/bin/php -v
./php/bin/php -m

# Nginx
./nginx/sbin/nginx -t -p ~/webstack/nginx  # Test config
./nginx/sbin/nginx -p ~/webstack/nginx -s reload  # Reload

# Composer
./composer install
./composer require package/name

# NPM (from ws directory)
cd ws && ../node/bin/node ../node/bin/npm install package
```

</details>

## 18.5 Support & Resources

- **GitHub Issues:** Report bugs and request features
- **Documentation:** This manual
- **Nginx Docs:** https://nginx.org/en/docs/
- **PHP Docs:** https://www.php.net/manual/
- **Node.js Docs:** https://nodejs.org/docs/
- **MariaDB Docs:** https://mariadb.com/kb/

---

# Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-01 | Initial release |

---

**WebStack Portable Web Server**  
*A fully self-contained web development environment*

---

