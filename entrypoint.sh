#!/usr/bin/env sh

# 1. 启动 3x-ui 面板到后台 (新增)
if [ -f "/usr/local/x-ui/x-ui" ]; then
    /usr/local/x-ui/x-ui &
fi

# 2. 原有逻辑：创建用户并设置权限
useradd -m -s /bin/bash $SSH_USER
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo $SSH_USER
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-users
echo 'PermitRootLogin no' > /etc/ssh/sshd_config.d/my_sshd.conf

# 3. 原有逻辑：执行自定义启动命令
if [ -n "$START_CMD" ]; then
    set -- $START_CMD
fi

exec "$@"
