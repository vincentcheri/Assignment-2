FROM alpine:3.22

RUN apk add --no-cache bash iputils-ping

WORKDIR /app
COPY app/ /app/
RUN chmod 755 /app/diagnostic.sh /app/health-check.sh

ENTRYPOINT ["/app/diagnostic.sh"]
CMD ["help"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=2s --retries=3 \
    CMD ["/app/health-check.sh"]
