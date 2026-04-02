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
    # 1. 自动识别架构 (amd64 或 arm64)
    arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    # 2. 从 API 获取最新版本号 (这一步必须用 api.github.com)
    latest_version=$(curl -s https://github.com | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    # 3. 下载 (注意这里的 $ 符号和完整的下载路径)
    wget -N https://github.com{latest_version}/x-ui-linux-${arch}.tar.gz && \
    # 4. 解压并安装
    tar zxvf x-ui-linux-${arch}.tar.gz && \
    rm -rf /usr/local/x-ui && \
    mv x-ui /usr/local/x-ui && \
    rm x-ui-linux-${arch}.tar.gz && \
    chmod +x /usr/local/x-ui/x-ui /usr/local/x-ui/x-ui-linux-* /usr/local/x-ui/bin/xray-linux-* && \
    # 5. 清理环境
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    chmod +x /entrypoint.sh && \
    chmod +x /usr/local/sbin/reboot && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

EXPOSE 22 2053

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
