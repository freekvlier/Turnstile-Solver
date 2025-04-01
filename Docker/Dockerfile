FROM ubuntu:latest

COPY ./Docker/.env /.env

RUN mkdir -p /root/Desktop
COPY . /root/Desktop/Turnstile-Solver/

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends tzdata locales

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    screen \
    sudo \
    xrdp \
    xfce4 \
    xorgxrdp \
    dbus-x11 \
    xfce4-terminal \
    python3-pip \
    ca-certificates

RUN apt remove -y light-locker xscreensaver && \
    apt autoremove -y && \
    rm -rf /var/cache/apt /var/lib/apt/lists

RUN apt-get update && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm ./google-chrome-stable_current_amd64.deb

RUN if [ -f "/root/Desktop/Turnstile-Solver/requirements.txt" ]; then \
    pip3 install -r /root/Desktop/Turnstile-Solver/requirements.txt --break-system-packages; \
    else echo "requirements.txt not found"; \
    fi

COPY ./Docker/run.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh

EXPOSE 3389
ENTRYPOINT ["/usr/bin/run.sh"]