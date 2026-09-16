#!/bin/sh
set -e
apt-get update
apt-get install --yes --no-install-recommends lighttpd
rm -rf /var/lib/apt/lists/*
cp "$(dirname "$0")/vhosts.conf" /etc/lighttpd/conf-enabled/90-vhosts.conf
mkdir -p /var/www/welcome
cp "$(dirname "$0")/welcome/index.html" /var/www/welcome/

# Runs every time the container starts
cat > /usr/local/share/lighttpd-init.sh <<'EOF'
#!/bin/sh
if [ "$(id -u)" -eq 0 ]; then
    service lighttpd start
else
    sudo service lighttpd start
fi
EOF
chmod +x /usr/local/share/lighttpd-init.sh
