@echo off
chcp 65001 >nul
title 暗黑2 iOS 移植 · 一键推送到 GitHub（云端自动出 IPA）
echo ============================================================
echo   暗黑2 iOS 移植 · 一键推送到 GitHub
echo   推送后，GitHub 的云端 Mac 会自动编译并产出 .ipa
echo ============================================================
echo.
echo 【第1步】你的 GitHub 用户名（登录 github.com 右上角看到的名字）
set /p GH_USER=请输入 GitHub 用户名：
echo.
echo 【第2步】GitHub 令牌 (Personal Access Token, 需勾选 repo 权限)
echo   获取地址：https://github.com/settings/tokens  （生成后只显示一次，复制好）
set /p GH_TOKEN=请输入 Token：
echo.
echo 【第3步】仓库名（会在你账号下新建一个公开仓库，默认 d2-ios-port）
set /p REPO_NAME=请输入仓库名[回车=d2-ios-port]：
if "%REPO_NAME%"=="" set REPO_NAME=d2-ios-port
echo.
echo 准备把本文件夹推送到： https://github.com/%GH_USER%/%REPO_NAME%
echo.

cd /d "%~dp0"

git init -q
git config user.email "%GH_USER%@users.noreply.github.com"
git config user.name "%GH_USER%"
git add -A
git commit -q -m "AbyssEngine iOS port scaffold (cloud build)"
git branch -M main

echo 正在创建 GitHub 仓库 %REPO_NAME% ...
curl -s -o nul -w "HTTP %{http_code}\n" ^
  -H "Authorization: token %GH_TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"%REPO_NAME%\",\"private\":false}" ^
  https://api.github.com/user/repos

git remote remove origin >nul 2>&1
git remote add origin https://%GH_TOKEN%@github.com/%GH_USER%/%REPO_NAME%.git
echo 正在推送代码 ...
git push -u origin main

echo.
echo ============================================================
echo  推送完成！接下来在浏览器里触发云端构建：
echo   1. 打开 https://github.com/%GH_USER%/%REPO_NAME%
echo   2. 点上方 "Actions" 标签
echo   3. 左侧选 "Build iOS IPA (AbyssEngine + OpenDiablo2)"
echo   4. 点 "Run workflow" 按钮（右侧）
echo   5. 等 20~40 分钟，完成后在 Artifacts 里下载 AbyssEngine-D2-iOS.ipa
echo   6. iPhone 上用 AltStore 或 Sideloadly 安装该 .ipa
echo ============================================================
pause
