version: '3.8'

services:
  campfire:
    image: campfire:latest
    container_name: campfire
    restart: unless-stopped
    expose:
      - "3000"
    volumes:
      - campfire_storage:/rails/storage
    environment:
      - SECRET_KEY_BASE=${secret_key_base}
      - VAPID_PUBLIC_KEY=${vapid_public_key}
      - VAPID_PRIVATE_KEY=${vapid_private_key}
      - SENTRY_DSN=${sentry_dsn}
      - DISABLE_SSL=true

  caddy:
    image: caddy:2-alpine
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    environment:
      - DOMAIN=${domain_name}

volumes:
  campfire_storage:
  caddy_data:
  caddy_config:
