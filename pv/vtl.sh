# ~/.config/sway/config中的Sway配置文件将调用此脚本。
# 保存此脚本后，应该会看到状态栏的更改。
# 如果没有，执行“killall swaybar”和$mod+Shift+c重新加载配置。

# 日期，时间，星期
date_formatted=$(date +"📅 %F 🕒 %T ⭐ %w")

# “upower --enumerate | grep'BAT'”从所有电源设备获取电池名称（例如“/org/freedesktop/UPower/devices/battery_BAT0”）。
# “upower --show-info”打印我们从中获取状态的电池信息（例如“正在充电”或“已充满电”）以及电池的充电百分比。
# 使用awk，我们删除了包含标识符的列。
# i3和sway会将电池状态和充电百分比之间的换行符自动转换为空格，从而产生“正在充电59％”或“已充满电100％”的结果。

battery_charge=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "percentage" | awk '{print $2}')
battery_status=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state" | awk '{print $2}')

# 充电状态文字转为图标
if [ $battery_status = "discharging" ];
then
    battery_pluggedin='⚠'
else
    battery_pluggedin='⚡'
fi

# “amixer -M”根据“man amixer”获得映射的音量，用于评估人耳更自然的百分比。
# 第5列在方括号中包含当前音量百分比，例如“[36％]”。 列号6是“[off]”还是“[on]”，具体取决于声音是否被静音。
# “tr -d []”删除卷周围的括号。
# 改编自https://bbs.archlinux.org/viewtopic.php?id=89648

audio_volume=$(amixer -M get Master |\
awk '/Left/&&/\[/ {print $6=="[off]" ?\
"🔇 "$5: \
"🔉 "$5}' |\
tr -d [])

# 1分钟内系统负载
loadavg_1min=$(cat /proc/loadavg | awk -F ' ' '{print $1}')

# 状态栏的其他表情符号和字符：
# 电力：⚡ ↯ ⭍ 🔌
# 音讯：🔈 🔊 🎧 🎶 🎵 🎤
# 分隔符：\| ❘ ❙ ❚
# 杂项：🐧 💎 💻 💡 ⭐ 📁 ↑ ↓ ✉ ✅ ❎
echo "$audio_volume 🏋 $loadavg_1min $battery_pluggedin $battery_charge $date_formatted"
