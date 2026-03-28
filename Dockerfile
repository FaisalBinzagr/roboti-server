FROM node:20-slim

# Install curl and ca-certificates to download arduino-cli
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install arduino-cli
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh \
    && mv /root/bin/arduino-cli /usr/local/bin/arduino-cli

# Initialize arduino-cli config and pre-install the AVR core
# This bakes the core into the image so the first student compile is fast (~5s, not 60s)
RUN arduino-cli config init \
    && arduino-cli core update-index \
    && arduino-cli core install arduino:avr

WORKDIR /app

# Install dependencies first (cached layer)
COPY package*.json ./
RUN npm ci --omit=dev

# Copy server source
COPY server.js ./

EXPOSE 3001

CMD ["node", "server.js"]
