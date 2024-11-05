# Use Ubuntu as base image to ensure access to necessary packages
FROM ubuntu:20.04

# Set environment variable to avoid user interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential dependencies and upgrade the package index
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    gnupg2 \
    lsb-release && \
    # Add deadsnakes PPA
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 6A9C37B5 && \
    echo "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu focal main" > /etc/apt/sources.list.d/deadsnakes-ubuntu-ppa.list

# Update repositories to get the new packages from PPA
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    git \
    build-essential \
    python3-pip \
    python3-setuptools \
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
    python3-requests \
    python3-pyqt5 \
    xvfb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone the Xpra repository
RUN git clone --recursive https://github.com/Xpra-org/xpra.git /xpra

# Set the working directory to /xpra
WORKDIR /xpra

# Create a virtual environment for Python 3.10
RUN python3.10 -m venv /opt/venv

# Upgrade pip
RUN /opt/venv/bin/pip install --upgrade pip

# Install Xpra's dependencies
RUN /opt/venv/bin/pip install \
    pillow \
    numpy \
    python-dbus \
    python-xlib \
    Pyro4 \
    protobuf \
    pyqt5

# Build and install Xpra
RUN /opt/venv/bin/python setup.py build && \
    /opt/venv/bin/python setup.py install

# Set the path to the virtual environment's binaries
ENV PATH="/opt/venv/bin:$PATH"

# Create a script to start Xpra server and launch Chromium
RUN echo '#!/bin/bash\n' \
         'Xvfb :99 -screen 0 1920x1080x24 &\n' \
         'export DISPLAY=:99\n' \
         'xpra start :100 --start-child="/usr/bin/chromium --no-sandbox --headless --disable-gpu --remote-debugging-port=9222 https://play.geforcenow.com/mall/" --bind-tcp=0.0.0.0:10000 --html=off\n' \
         'xpra attach :100' \
    > /start.sh && chmod +x /start.sh

# Expose the Xpra port
EXPOSE 10000

# Set the default command to execute the start script
CMD ["/start.sh"]
