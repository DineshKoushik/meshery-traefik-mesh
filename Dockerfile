FROM golang:1.13 as bd
RUN adduser --disabled-login appuser
WORKDIR /github.com/layer5io/meshery-traefik-mesh
ADD . .
RUN GOPROXY=https://proxy.golang.org GOSUMDB=off go build -ldflags="-w -s" -a -o /meshery-traefik-mesh .
RUN find . -name "*.go" -type f -delete

FROM alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN apk --update add ca-certificates
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
COPY --from=bd /meshery-traefik-mesh /app/
COPY --from=bd /etc/passwd /etc/passwd
USER appuser
WORKDIR /app
CMD ./meshery-traefik-mesh
