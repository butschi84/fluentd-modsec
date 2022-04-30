FROM fluent/fluentd:v1.14.5-debian-1.0
USER root

RUN apt-get -y update && \
    apt-get -y install ruby-dev make gcc

WORKDIR /home/fluent

# Add the ES forwarder
RUN gem install fluent-plugin-elasticsearch

RUN mkdir -p /var/log/modsec && \
    touch /var/log/modsecurity_audit.log

# add fluentd geoip plugin
RUN apt install -y build-essential libgeoip-dev libmaxminddb-dev
RUN gem install fluent-plugin-geoip
RUN fluent-gem install fluent-plugin-geoip

# Add fluentd-modsec plugin
COPY fluentd-modsecurity /tmp/fluentd-modsecurity
RUN fluent-gem install bundler:1.16.1
RUN cd /tmp/fluentd-modsecurity && \
    gem build fluent-plugin-modsecurity.gemspec && \
    fluent-gem install ./fluent-plugin-modsecurity-*.gem && \
    rm -rf /tmp/fluentd-modsecurity-master && \
    rm -rf *.zip

COPY config /home/fluent/config
CMD ["fluentd", "-c", "/home/fluent/config/fluent.conf"]
