FROM nginxinc/nginx-unprivileged:1.27-alpine

USER root
RUN mkdir -p /data && chown 101:101 /data
COPY index.html /usr/share/nginx/html/index.html
USER 101

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -q --spider http://127.0.0.1:8080/ || exit 1
