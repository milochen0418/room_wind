#!/usr/bin/env python3
"""無縫重複播放 RoomWind2.MP3。

作法：
1. 用 ffmpeg 把 MP3 解碼成 PCM 放進記憶體（避免每次重新開檔/解碼造成停頓）。
2. 去掉 MP3 編碼器在頭尾加的靜音（MP3 本身的 padding 會造成間斷感）。
3. 把結尾一小段與開頭做交叉淡化 (crossfade)，讓接縫處波形連續、不會有「咔」聲。
4. 用 sounddevice 的 callback 持續把環形緩衝送進音效卡，播放流從不中斷。

用法: python3 loop_play.py [檔案] [--fade 秒數]
需要: ffmpeg、pip install numpy sounddevice
"""
import argparse
import subprocess
import sys

import numpy as np
import sounddevice as sd

SR = 44100
CH = 2


def decode(path):
    cmd = ["ffmpeg", "-v", "error", "-i", path, "-f", "f32le",
           "-ac", str(CH), "-ar", str(SR), "-"]
    raw = subprocess.run(cmd, check=True, stdout=subprocess.PIPE).stdout
    return np.frombuffer(raw, dtype=np.float32).reshape(-1, CH).copy()


def trim_silence(a, thresh=1e-4):
    loud = np.where(np.abs(a).max(axis=1) > thresh)[0]
    return a if len(loud) == 0 else a[loud[0]:loud[-1] + 1]


def make_loop(a, fade_sec):
    n = int(fade_sec * SR)
    n = min(n, len(a) // 2)
    if n <= 0:
        return a
    t = np.linspace(0, np.pi / 2, n, dtype=np.float32)[:, None]
    fade_in, fade_out = np.sin(t), np.cos(t)  # 等功率交叉淡化
    head, tail = a[:n], a[-n:]
    body = a[n:-n]
    seam = tail * fade_out + head * fade_in
    # 迴圈 = body + seam；seam 結尾接回 body 開頭（即原本 head 之後），完全連續
    return np.concatenate([body, seam])


def main():
    p = argparse.ArgumentParser()
    p.add_argument("file", nargs="?", default="RoomWind2.MP3")
    p.add_argument("--fade", type=float, default=2.0, help="接縫交叉淡化秒數 (0=不淡化)")
    args = p.parse_args()

    loop = make_loop(trim_silence(decode(args.file)), args.fade)
    total = len(loop)
    pos = 0

    def callback(out, frames, time_info, status):
        nonlocal pos
        i = 0
        while i < frames:
            k = min(frames - i, total - pos)
            out[i:i + k] = loop[pos:pos + k]
            i += k
            pos = (pos + k) % total

    print(f"循環長度 {total / SR:.1f} 秒，按 Ctrl+C 停止")
    with sd.OutputStream(samplerate=SR, channels=CH, dtype="float32",
                         callback=callback, blocksize=2048, latency="high"):
        try:
            while True:
                sd.sleep(1000)
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    sys.exit(main())
