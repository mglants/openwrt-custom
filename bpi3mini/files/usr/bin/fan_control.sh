#!/bin/sh

TEMP_MIN=$(uci get fancontrol.@fancontrol[0].temp_min 2>/dev/null)
TEMP_MAX=$(uci get fancontrol.@fancontrol[0].temp_max 2>/dev/null)
PWM_PATH=$(uci get fancontrol.@fancontrol[0].pwm_path 2>/dev/null)
PWM_ENABLE_PATH=$(uci get fancontrol.@fancontrol[0].pwm_enable_path 2>/dev/null)
SLEEP_INTERVAL=$(uci get fancontrol.@fancontrol[0].sleep_interval 2>/dev/null)
THERMAL_ZONE_CPU=$(uci get fancontrol.@fancontrol[0].thermal_zone_cpu 2>/dev/null)
MODEM_TEMP_METHOD=$(uci get fancontrol.@fancontrol[0].modem_temp_method 2>/dev/null)
DEVICE=$(uci get fancontrol.@fancontrol[0].modem_at_port 2>/dev/null)
LOG_FILE="/var/log/fan_control.log"
LOG_MAX_LINES=1000

get_modem_temp() {
    if [ "$MODEM_TEMP_METHOD" = "AT" ]; then
        response=$(sms_tool -d "$DEVICE" at "AT+ETHERMAL?")
        at_temp=$(echo "$response" | awk -F, '/\+ETHERMAL:/{ sum+=$2; count++ } END { if(count > 0) { printf "%.0f", sum/count } else { print 0 } }')
        temp_int=$(echo "${at_temp%.*}" | bc)
        if [ "$temp_int" -lt "120" ]; then
            echo "${at_temp%.*}"
        else
            # Fallback al metodo "vecchio"
            gt_response=$(sms_tool -d "$DEVICE" at "AT+GTSENRDTEMP=1")
            gt_temp=$(echo "$gt_response" | awk -F'[ ,:]+' '/\+GTSENRDTEMP:/{ value=$3; result=value/1000; printf "%.1f", result }')
            echo "${gt_temp%.*}"
        fi
    else
        echo "0"
    fi
}

set_pwm_value() {
    echo "$1" > "$PWM_PATH"
}

rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        line_count=$(wc -l < "$LOG_FILE")
        if [ "$line_count" -gt "$LOG_MAX_LINES" ]; then
            : > "$LOG_FILE"
        fi
    fi
}

echo "1" > "$PWM_ENABLE_PATH"

while true; do
    rotate_log
    modem_temp=$(get_modem_temp)
    modem_temp_int=${modem_temp%.*}

    cpu_temp=$(cat "$THERMAL_ZONE_CPU")
    cpu_temp_int=$((cpu_temp / 1000))

    if [ -z "$modem_temp_int" ] || [ "$modem_temp_int" -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Unable to read modem temperature. Using CPU temperature only." >> "$LOG_FILE"
        avg_temp="$cpu_temp_int"
    else
        avg_temp=$(( (modem_temp_int + cpu_temp_int) / 2 ))
    fi

    if [ "$avg_temp" -le "$TEMP_MIN" ]; then
        pwm_value=140
    elif [ "$avg_temp" -ge "$TEMP_MAX" ]; then
        pwm_value=0
    else
        temp_range=$((TEMP_MAX - TEMP_MIN))
        temp_offset=$((avg_temp - TEMP_MIN))
        pwm_value=$((140 - (temp_offset * 140 / temp_range)))
    fi

    pwm_value=$(( pwm_value < 0 ? 0 : pwm_value > 140 ? 140 : pwm_value ))
    set_pwm_value "$pwm_value"

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Modem: ${modem_temp_int}°C, CPU: ${cpu_temp_int}°C, Avg: ${avg_temp}°C, PWM: $pwm_value" >> "$LOG_FILE"
    sleep "$SLEEP_INTERVAL"
done
