FROM alpine:3.19

WORKDIR /app

RUN apk add --no-cache bash bind-tools iputils

COPY app/ ./app/
RUN chmod +x /app/*.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
    CMD ["/bin/bash", "/app/health-check.sh"] || exit 1

ENTRYPOINT ["/bin/bash", "/app/diagnostic.sh"]
CMD ["help"]
