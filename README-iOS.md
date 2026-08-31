# AbyssEngine × OpenDiablo2 — iOS 构建指南（开发者向）

目标：把开源引擎 AbyssEngine 编译成 iOS App，加载 OpenDiablo2 的正版数据，
在 iPhone 上玩《暗黑破坏神2：毁灭之王》（仅限你**自己合法拥有**的 D2:LOD）。

## 0. 前置条件（硬需求）
- 一台 Mac（Apple Silicon 或 Intel 均可）+ 最新 Xcode + 命令行工具
- 苹果开发者账号（免费即可 ad-hoc 旁载；长期发布需付费）
- 你自己的正版 Diablo II + Lord of Destruction 的 MPQ 数据文件

## 1. 拉代码
```bash
git clone https://github.com/AbyssEngine/AbyssEngine engine
git clone https://github.com/AbyssEngine/OpenDiablo2 game
git clone https://github.com/microsoft/vcpkg
./vcpkg/bootstrap-vcpkg.sh
```

## 2. 套用 iOS 平台补丁（已就绪）
```bash
cd engine
git apply /path/to/ios-port/patches-abyssengine-ios.diff
# 该补丁为 AbyssEngine.c 增加 iOS 分支（config 沙盒路径 + 窗口 HIGHDPI）
```

## 3. 安装 iOS 依赖
把 `ios-port/vcpkg/arm64-ios.cmake` 放到 vcpkg 的 `triplets/` 目录，然后：
```bash
cd engine
../vcpkg/vcpkg install --triplet arm64-ios
```
### ffmpeg 兜底（如 vcpkg 在 iOS 下编不过）
ffmpeg 在 iOS 上是历史难点。两个选择：
1. 用社区预编译 iOS ffmpeg：如 `lex-ib/ffmpeg-ios-build-script`，编出
   `libavcodec/libavformat/...` 的 arm64 静态库，手动 LINK；
2. 或暂时从 `engine/vcpkg.json` 去掉 `ffmpeg`（会失去过场视频，但能先跑游戏）。

## 4. 配置 + 构建
```bash
cmake -B build-ios -S engine \
  -DCMAKE_TOOLCHAIN_FILE=ios-port/ios.toolchain.cmake \
  -DVCPKG_TARGET_TRIPLET=arm64-ios \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build-ios --config Release
```

## 5. 打包 .app → .ipa
```bash
mkdir -p Payload/AbyssEngine.app
cp -r build-ios/AbyssEngine.app/* Payload/AbyssEngine.app/
cp ios-port/ios/Info.plist Payload/AbyssEngine.app/Info.plist
cp -r game Payload/AbyssEngine.app/game        # 放进正版数据
xcrun codesign --force --sign "-" Payload/AbyssEngine.app   # ad-hoc
/usr/bin/zip -r AbyssEngine-D2-iOS.ipa Payload
```

## 6. 装到 iPhone
- 免费账号：用 **AltStore** 或 **Sideloadly** 旁载（每 7 天需重签一次）；
- 付费账号：**Xcode 真机运行** 或 **TestFlight**。

## 7. 触屏适配（可选但推荐）
把 `ios-port/src/touch_adapter.*` 放进 `engine/src/`，并在
`src/AbyssEngine.c` 事件循环里、调用 `InputManager_ProcessSdlEvent` 之前加一行：
```c
if (TouchAdapter_Process(&sdl_event)) continue;
```
即可让单指点击=鼠标左键、拖动=移动；虚拟按钮区已占位，绑定动作待填。

## 8. 一键 CI
推送 `ios` 分支即可触发 `.github/workflows/build-ios.yml`，在 GitHub macOS
runner 上自动产出 `.ipa` 制品（无需本地 Mac 也能拿到包，但签名/安装仍需你操作）。

---
⚠️ 仅用于运行**你自己拥有**的正版游戏数据。本工程不附带、不分发任何游戏资源。
