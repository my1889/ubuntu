FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com"

ENV TZ=Asia/Shanghai \
    SSH_USER=ubuntu \
    SSH_PASSWORD=ubuntu!23 \
    START_CMD='' \
    DEBIAN_FRONTEND=noninteractive

COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

RUN apt-get update && \
    apt-get install -y tzdata openssh-server sudo curl ca-certificates wget vim net-tools supervisor cron unzip iputils-ping telnet git iproute2 --no-install-recommends && \
    # --- 自动识别架构并安装 3x-ui 面板 ---
    arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    latest_version=$(curl -s https://github.com | grep tag_name | cut -d : -f 2 | sed 's/\"//g;s/\,//g;s/\ //g') && \
    wget -N https://github.com{latest_version}/x-ui-linux-${arch}.tar.gz && \
    tar zxvf x-ui-linux-${arch}.tar.gz && \
    mv x-ui /usr/local/x-ui && \
    rm x-ui-linux-${arch}.tar.gz && \
    chmod +x /usr/local/x-ui/x-ui /usr/local/x-ui/x-ui-linux-* /usr/local/x-ui/bin/xray-linux-* && \
    # --- 基础配置 ---
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd && \
    chmod +x /entrypoint.sh && \
    chmod +x /usr/local/sbin/reboot && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# 暴露 SSH(22) 和 3x-ui 默认端口(2053)
EXPOSE 22 2053

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
