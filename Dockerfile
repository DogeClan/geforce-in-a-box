# Use the latest Alpine base image
FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    openbox \
    x11vnc \
    xvfb \
    chromium \
    bash \
    bash-completion \
    ttf-freefont \
    && mkdir -p /root/.vnc \
    && x11vnc -storepasswd 123456 /root/.vnc/passwd

# Setup the environment
ENV USER=root
ENV DISPLAY=:1

# Start VNC server and Openbox on entry
CMD /usr/bin/xvfb-run --server-args="-screen 0 1920x1080x24 -ac" & \
 && sleep 1 && \
    openbox & \
    x11vnc -display :1 -usepw -forever -background -display :1 -N -o /var/log/x11vnc.log & \
    chromium --no-sandbox --disable-gpu --disable-software-rasterizer --remote-debugging-port=9222 "https://play.geforcenow.com" 

# Expose the VNC port
EXPOSE 5900
