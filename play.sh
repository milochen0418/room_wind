#!/usr/bin/env bash
# 一鍵建好環境並無縫循環播放 RoomWind2.MP3
# 用法: ./play.sh [檔案] [--fade 秒數]
set -euo pipefail
cd "$(dirname "$0")"

need_brew() {
  command -v brew >/dev/null || { echo "需要 Homebrew：https://brew.sh" >&2; exit 1; }
}

command -v ffmpeg  >/dev/null || { echo "安裝 ffmpeg..."; need_brew; brew install ffmpeg; }
command -v python3 >/dev/null || { echo "安裝 python..."; need_brew; brew install python; }
command -v poetry  >/dev/null || { echo "安裝 poetry..."; need_brew; brew install poetry; }

# 虛擬環境放在專案內 (.venv)；壞掉或不存在就重建
if ! .venv/bin/python3 -c "import numpy, sounddevice" >/dev/null 2>&1; then
  echo "建立 Python 環境..."
  rm -rf .venv
  poetry env use "$(command -v python3)" >/dev/null
  poetry install
fi

# ---- 省電模式：播放期間開啟低耗電、關螢幕；結束後恢復 ----
# 設 ECO=0 可停用：ECO=0 ./play.sh
if [[ "${ECO:-1}" == "1" ]]; then
  orig_lpm=$(pmset -g | awk '/lowpowermode/ {print $2}')
  orig_lpm=${orig_lpm:-0}
  echo "啟用低耗電模式（需要 sudo 密碼）..."
  sudo pmset -a lowpowermode 1 || echo "無法開啟低耗電模式，略過" >&2
  restore() {
    echo "恢復電源設定 (lowpowermode=$orig_lpm)..."
    sudo pmset -a lowpowermode "$orig_lpm" || true
  }
  trap restore EXIT INT TERM
  # 3 秒後關螢幕（播放不受影響），按任意鍵/動滑鼠即可喚醒
  ( sleep 3; pmset displaysleepnow ) &
fi

# caffeinate -i：防止系統閒置睡眠讓聲音中斷，但允許螢幕關閉
caffeinate -i -s poetry run roomwind "$@"
