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

COPY --from=builder /usr/src/grafana/bin/grafana-cli    /opt/grafana/bin/grafana-cli
COPY --from=builder /usr/src/grafana/bin/grafana-server /opt/grafana/bin/grafana-server
COPY --from=builder /usr/src/grafana/conf               /opt/grafana/conf
COPY --from=builder /usr/src/grafana/public             /opt/grafana/public

WORKDIR /opt/grafana

CMD ["bin/grafana-server"]
