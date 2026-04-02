#!/usr/bin/env sh

# 启动 3x-ui 面板到后台
if [ -f "/usr/local/x-ui/x-ui" ]; then
    /usr/local/x-ui/x-ui &
fi

# 原有逻辑：用户与权限设置
useradd -m -s /bin/bash $SSH_USER
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo $SSH_USER
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-users
echo 'PermitRootLogin no' > /etc/ssh/sshd_config.d/my_sshd.conf

# 原有逻辑：执行自定义命令
if [ -n "$START_CMD" ]; then
    set -- $START_CMD
fi

exec "$@"
