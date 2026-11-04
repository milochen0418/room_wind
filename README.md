# RoomWind

[English](#english) | [中文](#中文)

---

## English

Turn your MacBook into the steady hum of an indoor central air conditioner.

Some people fall asleep more easily with the constant background sound of central A/C. Hospital staff, for example, spend long shifts in climate-controlled buildings and often get used to that sound. RoomWind plays a recording of central A/C airflow (`RoomWind2.MP3`) in a **seamless, gapless loop**, so there's no click or pause to wake you up.

### Features

- **Gapless looping**: the audio is decoded into memory, encoder padding and silence are trimmed, and the loop seam gets an equal-power crossfade, so the waveform stays continuous.
- **Battery-friendly** (optional): while it plays, Low Power Mode is turned on and the display goes to sleep. Your original power settings come back when you stop.
- **No sleep interruptions**: `caffeinate` keeps the Mac awake so playback never stops, while still letting the screen turn off.
- **Simple app for everyone**: double-click `RoomWind.app`. No Terminal needed.

### Requirements

- macOS
- An internet connection the first time (to install required components)

### Use the app (recommended)

1. **Build the app once** (in this folder):
   ```bash
   ./build_app.sh
   ```
   This creates `RoomWind.app`. You can move it anywhere, such as the Applications folder. It keeps working even if you delete this project folder.
2. **Double-click `RoomWind.app`.**
   - **First time only:** if anything is missing, you'll be asked to install it. Click **開始安裝** (Start Installation). An installer window opens and sets everything up (5–15 minutes). You may need to enter your Mac login password. When it's done, double-click RoomWind again.
3. Choose **播放** (Play) or **播放並省電** (Play & Save Power: turns on Low Power Mode and turns off the screen; asks for your Mac password once).
4. Click **停止** (Stop) to end playback. Power settings are restored automatically.

> The app's buttons and messages are currently in Chinese only.

> **Sharing the app:** the app isn't notarized by Apple. On another Mac, the first launch may be blocked. Right-click the app and choose **Open** to allow it.

### Use the command line

```bash
./play.sh [file] [--fade seconds]
```

| Option | Description | Default |
|---|---|---|
| `file` | Audio file to loop | `RoomWind2.MP3` |
| `--fade` | Crossfade length at the loop seam, in seconds (`0` = no crossfade) | `2.0` |

- The first run installs missing tools via [Homebrew](https://brew.sh) and creates a virtual environment (`.venv`) with Poetry.
- Power-saving mode is on by default and asks for your `sudo` password. To skip it: `ECO=0 ./play.sh`
- Press `Ctrl+C` to stop.

### Files

| File | Purpose |
|---|---|
| `RoomWind2.MP3` | The central A/C sound recording |
| `roomwind/loop_play.py` | Player: decodes the audio, trims silence, crossfades the seam, and loops it without gaps |
| `play.sh` | Command-line launcher: checks tools, creates/repairs the Python environment, handles power saving, and starts the player |
| `setup.sh` | One-time installer for Homebrew, ffmpeg, Python, Poetry, and the Python environment. The app runs it automatically when something is missing |
| `RoomWind.applescript` | Source code of the app's interface (dialogs, Play/Stop, power saving) |
| `build_app.sh` | Builds `RoomWind.app` from `RoomWind.applescript` and bundles the files needed for playback |
| `RoomWind.app` | The built app (generated, not tracked in git) |
| `pyproject.toml` / `poetry.lock` | Python project definition and locked dependency versions (numpy, sounddevice) |
| `poetry.toml` | Poetry setting that keeps the virtual environment inside the project folder (`.venv`) |
| `LICENSE` | MIT License |

**Created on your Mac by the app:**

| Location | Purpose |
|---|---|
| `~/Library/RoomWind/` | Working copy of the program and its Python environment |
| `~/Library/Logs/RoomWind.log` | Playback log, useful for troubleshooting |

To uninstall the app, delete `RoomWind.app`, `~/Library/RoomWind/`, and `~/Library/Logs/RoomWind.log`.

### License

[MIT](LICENSE)

---

## 中文

把你的 MacBook 變成室內中央空調持續、穩定的運轉聲。

有些人習慣在中央空調的背景聲中入睡，例如在醫院工作的人，長時間待在空調建築裡，對這種聲音特別熟悉。RoomWind 會**無縫循環**播放中央空調的風聲錄音（`RoomWind2.MP3`），接縫處不會有喀聲或停頓，不會把你吵醒。

### 功能

- **無縫循環**：音檔解碼到記憶體，去除 MP3 頭尾的靜音，接縫處做等功率交叉淡化，波形完全連續。
- **省電（可選）**：播放時開啟低耗電模式並關閉螢幕，停止後自動恢復原本的電源設定。
- **不會中途停掉**：用 `caffeinate` 防止 Mac 進入睡眠導致聲音中斷，螢幕仍可正常關閉。
- **一般人也能用**：雙擊 `RoomWind.app` 即可，不需要開終端機。

### 需求

- macOS
- 第一次使用需要網路（安裝必要元件）

### 使用 App（推薦）

1. **先建置 App（只需一次）**，在本資料夾執行：
   ```bash
   ./build_app.sh
   ```
   會產生 `RoomWind.app`。它可以放在任何地方（例如「應用程式」資料夾），刪掉本專案資料夾也能繼續使用。
2. **雙擊 `RoomWind.app`。**
   - **第一次使用：** 如果缺少必要元件，會出現提示，按「開始安裝」。接著會開啟安裝視窗自動完成設定（約 5–15 分鐘），過程中可能需要輸入這台 Mac 的登入密碼。完成後再雙擊一次 RoomWind。
3. 選擇「播放」或「播放並省電」（開啟低耗電模式並關閉螢幕，會詢問一次 Mac 密碼）。
4. 按「停止」結束播放，電源設定會自動恢復。

> **分享給別人：** 這個 App 沒有經過 Apple 公證，在別台 Mac 第一次打開時可能會被擋下。請對 App 按右鍵，選「打開」即可。

### 使用命令列

```bash
./play.sh [檔案] [--fade 秒數]
```

| 參數 | 說明 | 預設值 |
|---|---|---|
| `檔案` | 要循環播放的音檔 | `RoomWind2.MP3` |
| `--fade` | 循環接縫的交叉淡化秒數（`0` = 不淡化） | `2.0` |

- 第一次執行時，會用 [Homebrew](https://brew.sh) 安裝缺少的工具，並用 Poetry 建立虛擬環境（`.venv`）。
- 預設開啟省電模式，會要求輸入 `sudo` 密碼。不想使用可執行：`ECO=0 ./play.sh`
- 按 `Ctrl+C` 停止。

### 各檔案用途

| 檔案 | 用途 |
|---|---|
| `RoomWind2.MP3` | 中央空調的風聲錄音 |
| `roomwind/loop_play.py` | 播放程式：解碼音檔、去除靜音、接縫交叉淡化、無縫循環播放 |
| `play.sh` | 命令列啟動腳本：檢查工具、建立或修復 Python 環境、處理省電模式，然後啟動播放 |
| `setup.sh` | 一次性安裝腳本：安裝 Homebrew、ffmpeg、Python、Poetry，並建好 Python 環境。App 偵測到缺少元件時會自動執行 |
| `RoomWind.applescript` | App 操作介面的原始碼（對話框、播放／停止、省電） |
| `build_app.sh` | 從 `RoomWind.applescript` 建置 `RoomWind.app`，並把播放所需的檔案打包進去 |
| `RoomWind.app` | 建置出來的 App（自動產生，不納入 git） |
| `pyproject.toml` / `poetry.lock` | Python 專案定義與鎖定的套件版本（numpy、sounddevice） |
| `poetry.toml` | Poetry 設定，讓虛擬環境放在專案資料夾內（`.venv`） |
| `LICENSE` | MIT 授權條款 |

**App 會在你的 Mac 上建立：**

| 位置 | 用途 |
|---|---|
| `~/Library/RoomWind/` | 程式的工作副本與 Python 環境 |
| `~/Library/Logs/RoomWind.log` | 播放記錄，排除問題時使用 |

要移除 App，請刪除 `RoomWind.app`、`~/Library/RoomWind/` 與 `~/Library/Logs/RoomWind.log`。

### 授權

[MIT](LICENSE)
