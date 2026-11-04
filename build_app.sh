#!/usr/bin/env bash
# 建置可獨立使用的 RoomWind.app（播放所需檔案都打包在 App 內，可放在任何地方）
set -euo pipefail
cd "$(dirname "$0")"

rm -rf RoomWind.app
osacompile -o RoomWind.app RoomWind.applescript

R=RoomWind.app/Contents/Resources/app
mkdir -p "$R"
cp play.sh setup.sh pyproject.toml poetry.lock poetry.toml RoomWind2.MP3 LICENSE "$R"/
rsync -a --exclude __pycache__ roomwind "$R"/

# 加入檔案後重新簽署（ad-hoc），否則簽章失效
codesign --force --deep -s - RoomWind.app
echo "已建置 RoomWind.app"
