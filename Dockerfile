# Use a lightweight base image
FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# Install necessary packages, including x11vnc
RUN apt-get update && apt-get install -y \
    xvfb \
    websockify \
    git \
    libpci-dev \
    libegl-dev \
    firefox-esr \
    x11vnc \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download noVNC
RUN git clone https://github.com/novnc/noVNC.git /noVNC && \
    git clone https://github.com/novnc/websockify.git /noVNC/utils/websockify

# Create the startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'Xvfb :99 -screen 0 1280x720x24 & ' >> /start.sh && \
    echo 'export DISPLAY=:99' >> /start.sh && \
    echo 'firefox-esr --no-remote --new-instance https://play.geforcenow.com/mall & ' >> /start.sh && \
    echo 'sleep 5' >> /start.sh && \
    echo 'x11vnc -display :99 -nopw -forever & ' >> /start.sh && \
    echo 'websockify --web=/noVNC/ 6080 localhost:5900 & ' >> /start.sh && \
    echo 'while true; do sleep 2; done' >> /start.sh 

# Make the startup script executable
RUN chmod +x /start.sh

# Expose the ports
EXPOSE 6080

# Start the application
CMD ["/start.sh"]
