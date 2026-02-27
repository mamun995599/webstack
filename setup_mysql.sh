#!/bin/bash
# setup_mysql.sh - Install and configure MariaDB

set -e

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
MYSQL_DIR="$WEBSTACK_ROOT/mysql"
DATA_DIR="$WEBSTACK_ROOT/data/mysql"
MARIADB_VERSION="11.2.2"

echo "========================================"
echo "Setting up MySQL (MariaDB)"
echo "========================================"
echo ""

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    MARIADB_ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ]; then
    MARIADB_ARCH="aarch64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

mkdir -p "$MYSQL_DIR" "$DATA_DIR" "$WEBSTACK_ROOT/tmp" "$WEBSTACK_ROOT/logs"
cd "$WEBSTACK_ROOT"

# Download
echo "[1/5] Downloading MariaDB $MARIADB_VERSION..."

MARIADB_FILE="mariadb-${MARIADB_VERSION}-linux-systemd-${MARIADB_ARCH}.tar.gz"
MARIADB_URL="https://archive.mariadb.org/mariadb-${MARIADB_VERSION}/bintar-linux-systemd-${MARIADB_ARCH}/${MARIADB_FILE}"

if [ ! -f "$MARIADB_FILE" ]; then
    wget "$MARIADB_URL" || {
        MARIADB_FILE="mariadb-${MARIADB_VERSION}-linux-${MARIADB_ARCH}.tar.gz"
        wget "https://archive.mariadb.org/mariadb-${MARIADB_VERSION}/bintar-linux-${MARIADB_ARCH}/${MARIADB_FILE}"
    }
fi

# Extract
echo "[2/5] Extracting..."
tar -xzf "$MARIADB_FILE"
MARIADB_EXTRACTED=$(ls -d mariadb-${MARIADB_VERSION}* 2>/dev/null | head -1)

rm -rf "$MYSQL_DIR"/*
cp -r "$MARIADB_EXTRACTED"/* "$MYSQL_DIR/"
rm -rf "$MARIADB_EXTRACTED"

# Create my.cnf
echo "[3/5] Creating configuration..."

cat > "$MYSQL_DIR/my.cnf" << MYCNF
[mysqld]
basedir = $MYSQL_DIR
datadir = $DATA_DIR
tmpdir = $WEBSTACK_ROOT/tmp
socket = $WEBSTACK_ROOT/tmp/mysql.sock
pid-file = $WEBSTACK_ROOT/tmp/mysql.pid
log-error = $WEBSTACK_ROOT/logs/mysql-error.log

port = 3306
bind-address = 127.0.0.1

max_connections = 100
max_allowed_packet = 64M
innodb_buffer_pool_size = 128M
innodb_log_file_size = 48M
innodb_file_per_table = 1

character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

skip-external-locking
skip-name-resolve

[client]
socket = $WEBSTACK_ROOT/tmp/mysql.sock
port = 3306
default-character-set = utf8mb4

[mysql]
socket = $WEBSTACK_ROOT/tmp/mysql.sock
default-character-set = utf8mb4
MYCNF

# Initialize
echo "[4/5] Initializing database..."

cd "$MYSQL_DIR"
./scripts/mysql_install_db \
    --basedir="$MYSQL_DIR" \
    --datadir="$DATA_DIR" \
    --defaults-file="$MYSQL_DIR/my.cnf" \
    --auth-root-authentication-method=normal 2>/dev/null || \
./scripts/mariadb-install-db \
    --basedir="$MYSQL_DIR" \
    --datadir="$DATA_DIR" \
    --defaults-file="$MYSQL_DIR/my.cnf" 2>/dev/null || true

# Create scripts
echo "[5/5] Creating management scripts..."

cat > "$WEBSTACK_ROOT/scripts/start_mysql.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/mysql/lib:$LD_LIBRARY_PATH"

echo "Starting MySQL..."
if [ -f "$WEBSTACK_ROOT/tmp/mysql.pid" ] && kill -0 $(cat "$WEBSTACK_ROOT/tmp/mysql.pid") 2>/dev/null; then
    echo "  Already running"
    exit 0
fi

"$WEBSTACK_ROOT/mysql/bin/mysqld_safe" --defaults-file="$WEBSTACK_ROOT/mysql/my.cnf" &
sleep 3

if [ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ]; then
    echo "  Started successfully"
else
    echo "  Failed - check $WEBSTACK_ROOT/logs/mysql-error.log"
fi
SCRIPT

cat > "$WEBSTACK_ROOT/scripts/stop_mysql.sh" << 'SCRIPT'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/mysql/lib:$LD_LIBRARY_PATH"

echo "Stopping MySQL..."
if [ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ]; then
    "$WEBSTACK_ROOT/mysql/bin/mysqladmin" --socket="$WEBSTACK_ROOT/tmp/mysql.sock" -u root shutdown 2>/dev/null
fi

if [ -f "$WEBSTACK_ROOT/tmp/mysql.pid" ]; then
    kill $(cat "$WEBSTACK_ROOT/tmp/mysql.pid") 2>/dev/null
    rm -f "$WEBSTACK_ROOT/tmp/mysql.pid"
fi
rm -f "$WEBSTACK_ROOT/tmp/mysql.sock"
echo "  Stopped"
SCRIPT

chmod +x "$WEBSTACK_ROOT/scripts/start_mysql.sh"
chmod +x "$WEBSTACK_ROOT/scripts/stop_mysql.sh"

# Install phpMyAdmin
echo ""
echo "Installing phpMyAdmin..."

PHPMYADMIN_VERSION="5.2.1"
cd "$WEBSTACK_ROOT/www"

if [ ! -d "phpmyadmin" ]; then
    wget "https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz" -O phpmyadmin.tar.gz
    tar -xzf phpmyadmin.tar.gz
    mv "phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages" phpmyadmin
    rm phpmyadmin.tar.gz
fi

cat > "$WEBSTACK_ROOT/www/phpmyadmin/config.inc.php" << PMACONFIG
<?php
\$cfg['blowfish_secret'] = '$(openssl rand -hex 16)';
\$i = 0;
\$i++;
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][\$i]['host'] = 'localhost';
\$cfg['Servers'][\$i]['socket'] = '$WEBSTACK_ROOT/tmp/mysql.sock';
\$cfg['Servers'][\$i]['AllowNoPassword'] = true;
\$cfg['TempDir'] = '$WEBSTACK_ROOT/tmp';
PMACONFIG

mkdir -p "$WEBSTACK_ROOT/www/phpmyadmin/tmp"
chmod 777 "$WEBSTACK_ROOT/www/phpmyadmin/tmp"

rm -f "$WEBSTACK_ROOT/$MARIADB_FILE"

echo ""
echo "========================================"
echo "MySQL Setup Complete!"
echo "========================================"
echo ""
echo "Commands:"
echo "  Start:  ./scripts/start_mysql.sh"
echo "  Stop:   ./scripts/stop_mysql.sh"
echo "  CLI:    ./mysql/bin/mysql --socket=./tmp/mysql.sock -u root"
echo ""
echo "phpMyAdmin: http://localhost/phpmyadmin"
echo "Default login: root (no password)"
echo ""
echo "IMPORTANT: Set a root password after first login!"