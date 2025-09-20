#!/bin/bash

# 系统性能调优脚本
# 需要 root 权限执行

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 root 权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本必须以 root 权限运行"
        exit 1
    fi
}

# 备份当前配置
backup_config() {
    log_info "备份当前 sysctl 配置..."
    if [ -f /etc/sysctl.conf ]; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bak.$(date +%Y%m%d%H%M%S)
    fi
    
    if [ -d /etc/sysctl.d ]; then
        tar -czf /etc/sysctl.d.bak.$(date +%Y%m%d%H%M%S).tar.gz /etc/sysctl.d/
    fi
    log_info "备份完成"
}

# 应用优化配置
apply_optimizations() {
    log_info "应用系统优化参数..."
    
    # 创建优化配置文件
    cat > /etc/sysctl.d/99-system-optimizations.conf << EOF
# 系统性能优化配置
# 生成时间: $(date)

# 进程与文件描述符限制
kernel.pid_max = 4194304
fs.file-max = 6553560

# 文件系统安全保护
fs.protected_fifos = 1
fs.protected_hardlinks = 1
fs.protected_regular = 2
fs.protected_symlinks = 1

# 网络性能优化 - 拥塞控制
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# 网络性能优化 - 常规设置
net.ipv4.conf.all.rp_filter = 0
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_frto = 0
net.ipv4.tcp_mtu_probing = 0
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_moderate_rcvbuf = 1

# 网络性能优化 - 缓冲区设置
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192

# 网络性能优化 - 连接管理
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.core.somaxconn = 4096
net.ipv4.tcp_abort_on_overflow = 1

# 内存管理
vm.swappiness = 10
EOF

    # 应用配置
    sysctl --system
    
    log_info "优化参数已应用"
}

# 检查 BBR 是否已启用
check_bbr() {
    log_info "检查 BBR 拥塞控制是否启用..."
    if sysctl net.ipv4.tcp_congestion_control | grep -q "bbr"; then
        log_info "BBR 拥塞控制已启用"
    else
        log_warning "BBR 拥塞控制未启用，可能需要重启系统"
    fi
}

# 显示优化结果
show_results() {
    log_info "优化完成！以下是一些关键参数的当前值："
    echo "=========================================="
    sysctl kernel.pid_max
    sysctl fs.file-max
    sysctl net.ipv4.tcp_congestion_control
    sysctl net.core.default_qdisc
    sysctl net.ipv4.tcp_rmem
    sysctl net.ipv4.tcp_wmem
    sysctl net.ipv4.tcp_tw_reuse
    sysctl vm.swappiness
    echo "=========================================="
}

# 主函数
main() {
    log_info "开始系统性能优化"
    check_root
    backup_config
    apply_optimizations
    check_bbr
    show_results
    log_info "优化完成！部分设置可能需要重启才能完全生效"
}

# 执行主函数
main "$@"
