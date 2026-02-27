
#!/bin/bash
# setup_directories.sh - Create the complete directory structure

set -e

export WEBSTACK_ROOT="$HOME/webstack"

echo "========================================"
echo "Creating WebStack Directory Structure"
echo "========================================"
echo ""
echo "Location: $WEBSTACK_ROOT"
echo ""

# Create all directories
mkdir -p "$WEBSTACK_ROOT"/{nginx/{sbin,conf/{conf.d,sites-available,sites-enabled,ssl},logs,html,modules},php/{bin,sbin,lib,etc/conf.d,var/{run,log},include},node/{bin,lib},mysql/{bin,lib},deps/{bin,lib,include,ssl/certs},src,www/{hls,videos,recordings},ws,data/mysql,tmp/{sessions,uploads,client_body,proxy,fastcgi,uwsgi,scgi},logs,backups,scripts}

echo "Directory structure created:"
echo ""
find "$WEBSTACK_ROOT" -type d | head -40
echo "..."
echo ""
echo "Total directories: $(find "$WEBSTACK_ROOT" -type d | wc -l)"
echo ""
echo "Done!"