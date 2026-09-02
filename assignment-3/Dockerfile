FROM alpine:3.19

WORKDIR /app

RUN apk add --no-cache bash bind-tools iputils netcat-openbsd

COPY app/ ./app/
COPY scripts/ ./scripts/
RUN chmod +x /app/*.sh /scripts/*.sh

ENTRYPOINT ["/bin/bash", "/app/app.sh"]
CMD ["help"]
