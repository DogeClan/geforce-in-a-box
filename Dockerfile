# Use a smaller Debian base image
FROM debian:slim

# Set environment variables to avoid interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update packages and install essential dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    python3-venv \
    python3-setuptools \
    build-essential \
    pkg-config \
    python3-dev \
    python3-cairo-dev \
    python3-gi \
    python3-gi-cairo \
    libgtk-3-dev \
    libglib2.0-dev \
    libgdk-pixbuf2.0-dev \
    libgirepository1.0-dev \
    libcairo2-dev \
    libatk1.0-dev \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxrandr-dev \
    libxi-dev \
    libxinerama-dev \
    libgl1-mesa-dev \
    libxxhash-dev \
    libxkbfile-dev \
    libxres-dev \
    libx264-dev \
    libvpx-dev \
    xvfb \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Add the Xpra GPG key and repository
RUN wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
    echo "deb [signed-by=/usr/share/keyrings/xpra.asc] https://xpra.org/debian bullseye main" | tee /etc/apt/sources.list.d/xpra.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends xpra && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a virtual environment for Python
RUN python3 -m venv /opt/venv

# Upgrade pip and install any additional Python packages you need
RUN /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install cython setuptools

# Set the path to the virtual environment's binaries
ENV PATH="/opt/venv/bin:$PATH"

# Create a script to start Xpra server and launch Chromium
RUN echo '#!/bin/bash\n' \
         'Xvfb :99 -screen 0 1920x1080x24 &\n' \
         'export DISPLAY=:99\n' \
         'xpra start :100 --start-child="/usr/bin/chromium --no-sandbox --headless --disable-gpu --remote-debugging-port=9222 https://play.geforcenow.com/mall/" --bind-tcp=0.0.0.0:10000 --html=off\n' \
         'xpra attach :100' \
    > /start.sh && chmod +x /start.sh

# Expose Xpra port
EXPOSE 10000

# Set the default command to execute the script
CMD ["/start.sh"]
