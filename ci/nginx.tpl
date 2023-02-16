worker_processes 1;

events { worker_connections 1024; }

http {
  upstream app {
    least_conn;
    server app:8000;
  }

  server {
    listen 80;
    location / {
      proxy_pass http://app;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
    }
  }
}
