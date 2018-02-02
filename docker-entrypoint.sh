#!/bin/sh -e

echo '> reconfigure grafana'

if [ "$ENABLE_PROMETHEUS_DATASOURCE" = 'true' ]; then
  cp /usr/share/grafana/conf/provisioning/datasources/prometheus.yml /opt/grafana/conf/provisioning/datasources/prometheus.yml
  sed -i "s%url: http://prometheus:9090%url: $PROMETHEUS_URL%" /opt/grafana/conf/provisioning/datasources/prometheus.yml
  sed -i "s%access: proxy%access: $PROMETHEUS_ACCESS_MODE%" /opt/grafana/conf/provisioning/datasources/prometheus.yml
fi

echo "> $@" && exec "$@"
