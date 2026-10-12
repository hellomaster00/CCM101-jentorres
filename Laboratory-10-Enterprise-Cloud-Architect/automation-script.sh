#!/bin/bash
# CloudNova automated database backup
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"
DATE=$(date +%F_%H-%M-%S)

source "$STACK_DIR/.env"
mkdir -p "$BACKUP_DIR"

docker exec cloudnova-mysql mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" \
  "$MYSQL_DATABASE" | gzip > "$BACKUP_DIR/wordpress_db_$DATE.sql.gz"

# Delete backups older than 7 days
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

echo "[$(date)] Backup completed: wordpress_db_$DATE.sql.gz" >> "$BACKUP_DIR/backup.log"
