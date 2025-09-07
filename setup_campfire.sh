#!/bin/bash

echo "🐳 Building Campfire Docker image..."
cd /opt/campfire
docker build -t campfire:latest https://github.com/basecamp/once-campfire.git

echo "📝 Creating Caddyfile..."
cat > /opt/campfire/Caddyfile << EOF
${DOMAIN_NAME} {
    reverse_proxy campfire:3000
    
    # Security headers
    header {
        # Enable HSTS
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        
        # Prevent clickjacking
        X-Frame-Options "SAMEORIGIN"
        
        # Prevent MIME type sniffing
        X-Content-Type-Options "nosniff"
        
        # XSS Protection
        X-XSS-Protection "1; mode=block"
        
        # Referrer Policy
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    # Logging
    log {
        output file /var/log/caddy/access.log
        format json
    }
}
EOF

echo "🚀 Starting Campfire application with Caddy..."
docker-compose up -d

echo "📋 Creating systemd service..."
cat > /etc/systemd/system/campfire.service << 'EOF'
[Unit]
Description=Campfire Chat Application with Caddy
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/campfire
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl enable campfire.service
systemctl start campfire.service

echo "✅ Campfire deployment with Caddy completed!"
echo "🌐 Campfire URL: https://${DOMAIN_NAME}"
echo "📊 Checking application status..."
docker-compose ps
