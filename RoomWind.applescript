-- RoomWind：給一般使用者的簡易介面（不開終端機）
-- 建置：./build_app.sh（會把播放所需檔案打包進 App，App 可放在任何地方）
-- 執行時把 App 內的檔案同步到 ~/Library/RoomWind/，在那裡建環境並播放，
-- 這樣 App 搬家不會讓 Python 環境的路徑失效。

on run
	set resDir to POSIX path of (path to me) & "Contents/Resources/app/"
	-- 注意：路徑不可含空格（如 Application Support），否則 .venv 內程式的 #! 路徑會失效
	set workDir to POSIX path of (path to library folder from user domain) & "RoomWind/"
	set logFile to POSIX path of (path to library folder from user domain) & "Logs/RoomWind.log"

	-- 同步程式檔（保留已建好的 .venv）
	try
		do shell script "test -x " & quoted form of (resDir & "play.sh") & " && mkdir -p " & quoted form of workDir & " && rsync -a --delete --exclude .venv --exclude __pycache__ " & quoted form of resDir & " " & quoted form of workDir
	on error
		display alert "RoomWind 無法啟動" message "App 內容不完整，請重新下載 RoomWind。" as critical
		return
	end try

	-- 環境檢查：缺少任何元件就引導一次安裝
	set envOK to do shell script "B=''; for p in /opt/homebrew /usr/local; do [ -x $p/bin/brew ] && B=$p && break; done; [ -n \"$B\" ] && [ -x $B/bin/ffmpeg ] && [ -x $B/bin/python3 ] && [ -x $B/bin/poetry ] && [ -x " & quoted form of (workDir & ".venv/bin/roomwind") & " ] && echo ok || echo missing"
	if envOK is not "ok" then
		display dialog "第一次使用 RoomWind，需要先安裝一些必要元件（約 5–15 分鐘，需要網路）。" & return & return & "按「開始安裝」會開啟一個安裝視窗，過程中可能需要輸入這台 Mac 的登入密碼。安裝完成後，再雙擊 RoomWind 就能播放。" buttons {"取消", "開始安裝"} default button "開始安裝" cancel button "取消" with title "RoomWind" with icon note
		tell application "Terminal"
			activate
			do script "clear; bash " & quoted form of (workDir & "setup.sh")
		end tell
		return
	end if

	set r to display dialog "播放中央空調的風聲，陪你入睡。" buttons {"取消", "播放", "播放並省電"} default button "播放並省電" cancel button "取消" with title "RoomWind" with icon note
	set eco to (button returned of r is "播放並省電")

	-- 背景啟動播放，取得 play.sh 的 PID
	-- 注意：不可寫成「cd … && play.sh &」，那會讓背景子 shell 佔住輸出，do shell script 永遠不返回
	set pid to do shell script "cd " & quoted form of workDir & " || exit 1; ECO=0 nohup ./play.sh > " & quoted form of logFile & " 2>&1 < /dev/null & echo $!"

	-- 等待播放開始
	set started to false
	repeat 120 times
		if (do shell script "pgrep -f " & quoted form of (workDir & ".venv/bin/roomwind") & " >/dev/null && echo y || echo n") is "y" then
			set started to true
			exit repeat
		end if
		if (do shell script "kill -0 " & pid & " 2>/dev/null && echo y || echo n") is "n" then exit repeat
		delay 1
	end repeat
	if not started then
		do shell script "kill " & pid & " 2>/dev/null; true"
		display alert "無法播放" message "請稍後再試一次。" as critical
		return
	end if

	-- 省電：開啟低耗電模式，播放結束後由背景程序自動恢復（只需輸入一次密碼）
	if eco then
		try
			set orig to do shell script "pmset -g | awk '/lowpowermode/ {print $2}'"
			if orig is "" then set orig to "0"
			do shell script "pmset -a lowpowermode 1; nohup sh -c 'while kill -0 " & pid & " 2>/dev/null; do sleep 5; done; pmset -a lowpowermode " & orig & "' >/dev/null 2>&1 &" with administrator privileges
		end try
		do shell script "(sleep 3; pmset displaysleepnow) >/dev/null 2>&1 &"
	end if

	display dialog "正在播放空調聲。" buttons {"停止"} default button "停止" with title "RoomWind" with icon note giving up after 86400
	-- 背景程序會忽略 SIGINT，所以用 SIGTERM 停止播放器；play.sh 隨後自行結束
	do shell script "pkill -TERM -f " & quoted form of (workDir & ".venv/bin/roomwind") & "; sleep 1; kill " & pid & " 2>/dev/null; true"
end run
