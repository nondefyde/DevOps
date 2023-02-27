version: '3.8'

services:
  app:
    image: {IMAGE}
    volumes:
      - app-volume:/var/lib/app/content
    environment:
      NODE_ENV: {NODE_ENV}
      VIRTUAL_HOST: {VIRTUAL_HOST}
      CERT_PATH: {CERT_PATH}
      CERT_PASS: {CERT_PASS}
    env_file:
      - ./.env
    ports:
      - "8000:{PORT}"
    networks:
      - app-network

volumes:
  app-volume:
    external: true

networks:
  app-network:
    name: nginx-proxy
    external: true