#!/usr/bin/env bash
# RoomWind 一次安裝所有必要元件：Homebrew、ffmpeg、Python、Poetry，並建好 Python 環境。
# RoomWind.app 偵測到缺少元件時，會開啟「終端機」執行這個腳本。
set -euo pipefail
cd "$(dirname "$0")"
unset VIRTUAL_ENV
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

trap 'echo; echo "❌ 安裝沒有完成。請檢查網路連線後，再雙擊 RoomWind 重試一次。"' ERR

echo "=============================================="
echo "  RoomWind：安裝必要元件（約 5–15 分鐘）"
echo "=============================================="
echo

if ! command -v brew >/dev/null; then
  echo "▶ 安裝 Homebrew"
  echo "  需要時請輸入「這台 Mac 的登入密碼」（輸入時畫面不會顯示字元，打完按 Return）。"
  echo "  看到 \"Press RETURN to continue\" 時，請按 Return。"
  echo
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
fi

BREW_BIN="$(brew --prefix)/bin"
missing=()
[[ -x "$BREW_BIN/ffmpeg"  ]] || missing+=(ffmpeg)
[[ -x "$BREW_BIN/python3" ]] || missing+=(python)
[[ -x "$BREW_BIN/poetry"  ]] || missing+=(poetry)
if (( ${#missing[@]} )); then
  echo "▶ 安裝 ${missing[*]}"
  brew install "${missing[@]}"
fi

echo "▶ 準備播放程式"
ECO=0 ./play.sh --help >/dev/null

echo
echo "✅ 安裝完成！可以關閉這個視窗，再雙擊 RoomWind 開始播放。"
if [[ -z "${RW_NO_DIALOG:-}" ]]; then
  osascript -e 'display dialog "安裝完成！請再雙擊 RoomWind 開始播放。" buttons {"好"} default button "好" with title "RoomWind" with icon note' >/dev/null || true
fi
