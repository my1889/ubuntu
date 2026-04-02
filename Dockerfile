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
    # --- 修正后的 3x-ui 安装逻辑 ---
    arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    # 使用 API 获取真实的 tag 名称
    latest_version=$(curl -s https://github.com | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    # 确保下载链接完整正确
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

EXPOSE 22 2053

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
