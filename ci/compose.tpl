version: '3.8'
services:
  app:
    image: {IMAGE}
    volumes:
      - app-volume:/var/lib/app/content
    environment:
      NODE_ENV: {NODE_ENV}
      VIRTUAL_HOST: {VIRTUAL_HOST}
    env_file:
      - ./.env
    ports:
      - "8000-8400:{PORT}"
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
