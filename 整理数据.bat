@echo off
chcp 65001 >nul
title 暗黑2 iOS 移植 · 整理经典版数据（一键）
echo ============================================================
echo   整理经典暗黑2：毁灭之王 1.13c 的 MPQ 数据
echo   产出 D2-Data-Ready/ （大小写已按 iOS 要求修正）
echo ============================================================
echo.

set "SRC=D:\BaiduNetdiskDownload\暗黑2 1.13c全整合\Diablo2 1.13c"
set "OUT=%~dp0D2-Data-Ready"

if not exist "%SRC%" (
  echo [错误] 找不到数据源目录：
  echo   %SRC%
  echo 请确认该路径存在，或修改本脚本里的 SRC 变量。
  goto :end
)

if not exist "%OUT%" mkdir "%OUT%"

echo 正在复制并修正大小写 ...
copy /Y "%SRC%\d2data.mpq"   "%OUT%\d2data.MPQ"    >nul
copy /Y "%SRC%\d2exp.mpq"    "%OUT%\d2exp.MPQ"     >nul
copy /Y "%SRC%\d2char.mpq"   "%OUT%\d2char.MPQ"    >nul
copy /Y "%SRC%\d2music.mpq"  "%OUT%\d2music.MPQ"   >nul
copy /Y "%SRC%\d2sfx.mpq"    "%OUT%\d2sfx.MPQ"     >nul
copy /Y "%SRC%\d2speech.mpq" "%OUT%\d2speech.MPQ"  >nul
copy /Y "%SRC%\d2video.mpq"  "%OUT%\d2video.MPQ"   >nul
copy /Y "%SRC%\d2xtalk.mpq"  "%OUT%\d2xtalk.MPQ"   >nul
copy /Y "%SRC%\D2XMUSIC.MPQ" "%OUT%\d2xmusic.MPQ"  >nul
copy /Y "%SRC%\D2XVIDEO.MPQ" "%OUT%\d2xvideo.MPQ"  >nul

echo.
echo 完成！以下文件已就绪（大小写已修正为 iOS 要求）：
echo ------------------------------------------------------------
dir "%OUT%" /B
echo ------------------------------------------------------------
echo.
echo 下一步：把整个 D2-Data-Ready/ 目录塞进 CI 产出的 .app 里的 game/ 目录，
echo 再用 AltStore / Sideloadly 旁载安装到 iPhone。详见 README-iOS.md。

:end
pause
