version: '3.8'

services:
  app:
    image: {IMAGE}
    container_name: app
    volumes:
      - app-volume:/var/lib/app/content
    environment:
      NODE_ENV: {NODE_ENV}
      VIRTUAL_HOST: {VIRTUAL_HOST}
    env_file:
      - ./.env
    ports:
      - "{PORT}"
    restart: always
    networks:
      - app-network

  nginx-proxy:
    image: jwilder/nginx-proxy:alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/etc/nginx/certs"
      - "/etc/nginx/vhost.d"
      - "/usr/share/nginx/html"
      - "/var/run/docker.sock:/tmp/docker.sock:ro"
    networks:
      - app-network

  letsencrypt-nginx-proxy-companion:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: letsencrypt-nginx-proxy-companion
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "/etc/nginx/certs"
      - "/etc/nginx/vhost.d"
      - "/usr/share/nginx/html"
    environment:
      NGINX_PROXY_CONTAINER: nginx-proxy
    restart: always
    networks:
      - app-network

volumes:
  app-volume:
    external: true

networks:
  app-network:
    name: nginx-proxy
    external: true