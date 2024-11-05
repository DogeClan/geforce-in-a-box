# Use the slim version of Debian Bookworm as the base image
FROM debian:bookworm-slim

# Set environment variables for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    chromium \
    xvfb \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libpango1.0-0 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxss1 \
    x11-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add a user to run Chromium
RUN useradd -m chromiumuser

# Set the working directory
WORKDIR /home/chromiumuser

# Switch to the new user
USER chromiumuser

# Create the start-chromium.sh script inline, with the specified URL
RUN echo '#!/bin/bash\n\
\n\
# Start Xvfb in the background\n\
Xvfb :99 -ac &\n\
\n\
# Set the DISPLAY environment variable\n\
export DISPLAY=:99\n\
\n\
# Start Chromium in headless mode and open the specified URL\n\
chromium --headless --no-sandbox --disable-gpu --remote-debugging-port=9222 "https://play.geforcenow.com/mall"' \
> start-chromium.sh

# Give execution rights to the script
RUN chmod +x start-chromium.sh

# Command to run the script
CMD ["./start-chromium.sh"]
