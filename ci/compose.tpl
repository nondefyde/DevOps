version: '3.8'

services:
  nginx-proxy:
    image: jwilder/nginx-proxy
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
  app:
    image: {IMAGE}
    ports:
      - "8000-8400:{PORT}"
    environment:
      - VIRTUAL_HOST={VIRTUAL_HOST}
      - NODE_ENV={NODE_ENV}
    depends_on:
      - nginx-proxy
    networks:
      default:
        aliases:
          - bytegum.com