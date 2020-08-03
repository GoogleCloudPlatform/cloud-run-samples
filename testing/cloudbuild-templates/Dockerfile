# This Dockerfile provides a self-contained "Hello, World!" service.
# It is used to facilitate troubleshooting the Cloud Build templates.
FROM alpine:3

CMD while :; do nc -l -p $PORT -e sh -c 'echo -e "HTTP/1.1 200 OK\n\n Hello, World!"'; done