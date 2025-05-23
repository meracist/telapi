FROM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update &&    apt-get upgrade -y &&    apt-get install -y    build-essential    make    git    zlib1g-dev    libssl-dev    gperf    cmake    g++    && apt-get clean    && rm -rf /var/lib/apt/lists/*

# Clone and build the telegram-bot-api
WORKDIR /app
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git &&    cd telegram-bot-api &&    rm -rf build &&    mkdir build &&    cd build &&    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. &&    cmake --build . --target install

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
# Set default port values
ENV HEALTH_CHECK_PORT=10000
ENV BOT_API_PORT=8081
ENV WEB_PORT=8080

# Install dependencies
RUN apt-get update &&    apt-get install -y    libssl-dev    python3    python3-pip    nginx    supervisor    gettext-base    && apt-get clean    && rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /app/telegram-bot-api/bin/telegram-bot-api /usr/local/bin/

# Create necessary directories
RUN mkdir -p /app/data /app/data/temp

# Copy configuration files
COPY health_server.py /app/health_server.py
COPY nginx.conf.template /app/nginx.conf.template
COPY supervisord.conf.template /app/supervisord.conf.template
COPY start.sh /app/start.sh

# Make scripts executable
RUN chmod +x /app/health_server.py /app/start.sh

# Expose ports
EXPOSE 8080 8081 10000

# Run the start script
CMD ["/app/start.sh"]
