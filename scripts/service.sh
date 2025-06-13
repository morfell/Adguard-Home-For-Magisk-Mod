#!/system/bin/sh
AGH_DIR="/data/adb/agh"
BIN_DIR="$AGH_DIR/bin"
PID_FILE="$BIN_DIR/agh_pid"
LOG_FILE="$AGH_DIR/AdGuardHome.log"
MAIN_LOG="$AGH_DIR/agh.log"
export TZ='Asia/Shanghai'

# 所有输出重定向到日志
exec >>"$MAIN_LOG" 2>&1

# 启动 AdGuardHome
export SSL_CERT_DIR="/system/etc/security/cacerts/"
"$BIN_DIR/AdGuardHome" --logfile "$LOG_FILE" --no-check-update &
echo $! > "$PID_FILE"
sleep 2

# 验证是否启动成功
if ! kill -0 $(cat "$PID_FILE") 2>/dev/null; then
echo "$(date '+%F %T') 启动失败，尝试重启..."
exec "$0"
fi
echo "$(date '+%F %T') AdGuardHome 启动成功。"

# 日志超限时清空
check_and_clear_log() {
[ "$(stat -c %s "$1" 2>/dev/null || ls -l "$1" | awk '{print $5}')" -ge 102400 ] && : > "$1"
}
check_and_clear_log "$MAIN_LOG"
check_and_clear_log "$LOG_FILE"