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
