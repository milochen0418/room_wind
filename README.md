# RoomWind

Turn your MacBook into the steady hum of an indoor central air conditioner.

Some people fall asleep more easily with the constant background sound of central A/C. Hospital staff, for example, spend long shifts in climate-controlled buildings and often get used to that sound. RoomWind plays a recording of central A/C airflow (`RoomWind2.MP3`) in a **seamless, gapless loop**, so there's no click or pause to wake you up.

## Features

- **Gapless looping**: the audio is decoded into memory, encoder padding and silence are trimmed, and the loop seam gets an equal-power crossfade, so the waveform stays continuous.
- **Battery-friendly**: while it plays, Low Power Mode is turned on and the display goes to sleep. Your original power settings come back when you stop.
- **No sleep interruptions**: `caffeinate` keeps the Mac awake so playback never stops, while still letting the screen turn off.
- **One-command setup**: missing dependencies (ffmpeg, Python, Poetry) are installed via Homebrew automatically.

## Requirements

- macOS
- [Homebrew](https://brew.sh) (used to install missing dependencies)

## Usage

```bash
./play.sh
```

The first run sets up a local virtual environment (`.venv`). You'll be asked for your `sudo` password to turn on Low Power Mode.

Press `Ctrl+C` to stop. Your power settings are restored automatically.

### Options

```bash
./play.sh [file] [--fade seconds]
```

| Option | Description | Default |
|---|---|---|
| `file` | Audio file to loop | `RoomWind2.MP3` |
| `--fade` | Crossfade length at the loop seam, in seconds (`0` = no crossfade) | `2.0` |

To skip the power-saving behavior (no Low Power Mode, no `sudo`, screen stays on):

```bash
ECO=0 ./play.sh
```

## License

[MIT](LICENSE)
