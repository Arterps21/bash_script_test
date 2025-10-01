#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
STATE_FILE="/var/run/monitoring_test.state"
PROCESS_NAME="test"
URL="https://test.com/monitoring/test/api"

# Функция логирования
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Проверка процесса
if pgrep -x "$PROCESS_NAME" > /dev/null; then
    CURRENT_STATE=1
else
    CURRENT_STATE=0
fi

# Чтение предыдущего состояния
PREVIOUS_STATE=0
if [ -f "$STATE_FILE" ]; then
    PREVIOUS_STATE=$(cat "$STATE_FILE")
fi

# Проверка перезапуска процесса
if [ "$CURRENT_STATE" -eq 1 ] && [ "$PREVIOUS_STATE" -eq 0 ]; then
    log_message "PROCESS RESTARTED: $PROCESS_NAME"
fi

# Проверка доступности сервера
if [ "$CURRENT_STATE" -eq 1 ]; then
    if curl -s -f -I --connect-timeout 5 "$URL" > /dev/null; then
        :
    else
        log_message "SERVER UNREACHABLE: $URL"
    fi
fi

# Сохранение состояния
echo "$CURRENT_STATE" > "$STATE_FILE"
