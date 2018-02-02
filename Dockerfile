FROM alpine:3.7 as builder

ENV GOPATH=/usr/src/go

RUN apk add --update --no-cache musl-dev go nodejs git && \
    mkdir -p /usr/src && \
    cd /usr/src && \
    git clone https://github.com/grafana/grafana.git && \
    mkdir -p "$GOPATH/src/github.com/grafana" && \
    ln -sv /usr/src/grafana "$GOPATH/src/github.com/grafana/grafana" && \
    cd "$GOPATH/src/github.com/grafana/grafana" && \
    go run build.go setup && \
    go run build.go build && \
    npm install -g yarn && \
    yarn install --pure-lockfile && \
    npx webpack --progress --colors --config scripts/webpack/webpack.prod.js

FROM alpine:3.7

ENV GF_SECURITY_ADMIN_USER=admin

ENV ENABLE_PROMETHEUS_DATASOURCE=false
ENV PROMETHEUS_ACCESS_MODE=proxy
ENV PROMETHEUS_URL=http://prometheus:9090/

COPY conf /usr/share/grafana/conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

COPY --from=builder /usr/src/grafana/bin/grafana-cli    /opt/grafana/bin/grafana-cli
COPY --from=builder /usr/src/grafana/bin/grafana-server /opt/grafana/bin/grafana-server
COPY --from=builder /usr/src/grafana/conf               /opt/grafana/conf
COPY --from=builder /usr/src/grafana/public             /opt/grafana/public

VOLUME /opt/grafana/conf
VOLUME /opt/grafana/data

WORKDIR /opt/grafana

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["bin/grafana-server"]
