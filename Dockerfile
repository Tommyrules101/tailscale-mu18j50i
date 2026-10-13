FROM debian:latest
WORKDIR /render

ARG TAILSCALE_VERSION
ENV TAILSCALE_VERSION=$TAILSCALE_VERSION

RUN apt-get -qq update \
  && apt-get -qq install --upgrade -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    netcat-openbsd \
    wget \
    dnsutils \
  > /dev/null \
  && apt-get -qq clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
  && :

RUN echo "+search +short" > /root/.digrc

# Copy scripts into the container
COPY run-tailscale.sh /render/
COPY install-tailscale.sh /tmp

# Run the installer and clean up temporary build layers
RUN chmod +x /tmp/install-tailscale.sh \
  && /tmp/install-tailscale.sh \
  && rm -rf /tmp/* \
  && chmod +x /render/run-tailscale.sh

CMD ["./run-tailscale.sh"]
