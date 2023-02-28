version: '3.8'

services:
  app:
    image: {IMAGE}
    environment:
      NODE_ENV: {NODE_ENV}
      VIRTUAL_HOST: {VIRTUAL_HOST}
    env_file:
      - ./.env
    ports:
      - "8000:{PORT}"