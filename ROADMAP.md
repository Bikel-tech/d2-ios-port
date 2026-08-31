# 暗黑2 · iOS 原生移植 路线图（基于真实代码）

> 结论先说：引擎从 Go 重写为 **C++/CMake + SDL2**，渲染走 SDL 可移植渲染器
> （iOS 自动走 OpenGL ES 2.0），平台分支只有 Win/macOS/Linux——**编译到 iPhone
> 的技术地基是成立的**。真正的长 pole 不是"能不能编"，而是**游戏本体还没做到可玩**。

## 当前真实状态（已核查源码）

| 项 | 状态 | 说明 |
|---|---|---|
| 引擎语言/构建 | ✅ C++ / CMake 3.20 | 比旧 Go 版好移植 |
| 渲染 API | ✅ SDL_Render（可移植） | iOS 走 OpenGLES，无需重写 |
| 窗口/输入 | ✅ SDL2 标准模式 | iOS UIKit 后端直接支持 |
| 依赖（vcpkg） | ✅ sdl2 / libarchive / zlib / ffmpeg | 全部支持 `arm64-ios` 三元组 |
| 平台分支 | ⚠️ 无 iOS | 仅 `_WIN32` / `__APPLE__`(macOS) / Linux |
| 游戏可玩度 | ❌ 仅主菜单+过场 | OpenDiablo2 还在早期，玩法未实现 |
| 触屏操作 | ❌ 仅鼠标/键盘 | 需虚拟按键层（已给出骨架） |

## 里程碑（从代码到真机 IPA）

### M0 · 引擎 iOS 构建打通（我方已开干的部分）
- [x] iOS 平台分支（config 路径 + 窗口 HIGHDPI）—— 已改 `AbyssEngine.c` 并导出 patch
- [x] iOS CMake 工具链 `ios.toolchain.cmake`
- [x] vcpkg `arm64-ios` 三元组
- [x] App `Info.plist`（横屏、iOS15+）
- [x] GitHub Actions 真 CI（macOS runner → .ipa）
- [ ] **待 Mac 环境验证**：在 macOS + Xcode 上跑通 `cmake ... --toolchain` 出 `.app`
- [ ] ffmpeg for iOS 验证（风险点，必要时换预编译版）

### M1 · 真机可运行（能进主菜单）
- [ ] 出 `.app` 并 ad-hoc 签名 → 用 AltStore/Sideloadly 装到 iPhone
- [ ] 把 OpenDiablo2 游戏内容打进 App 包（CI 已含此步）
- [ ] 触屏适配层接入事件循环（已给 `touch_adapter.c` 骨架，需接一行调用）
- [ ] 横屏/高 DPI 渲染验证（800x600 逻辑分辨率自动缩放）

### M2 · 可玩（跟社区进度走，非我方可控）
- [ ] 等待/推动 OpenDiablo2 实现：地图引擎 → 角色/战斗 → 第一幕通关
- [ ] 虚拟按键布局细化（技能栏/腰带/背包，已占位 4 个按钮）
- [ ] 外接手柄支持（SDL_GameController，SDL2 原生支持）

### M3 · 发布形态
- [ ] 正式签名（个人/企业开发者账号）
- [ ] 旁载分发（AltStore 7 天重签 / 企业证 / TestFlight）

## 风险与红线
- **版权**：只认「开源引擎 + 你自己的正版 D2:LOD 的 MPQ 数据」。不要下载盗版、不要上架 App Store 分发游戏文件。
- **假下载站**：任何"暗黑2 手机版/iOS版 下载"都是盗版/木马，暴雪从没出过。
- **时间**：M2 取决于社区，可能数月到更久；M0/M1 是几天到几周的量（需 Mac）。

## 我方已交付（本目录）
- `ios.toolchain.cmake` · `vcpkg/arm64-ios.cmake` · `ios/Info.plist`
- `.github/workflows/build-ios.yml` · `src/touch_adapter.*`
- `patches-abyssengine-ios.diff`（已改引擎的 upstreamable patch）
- 本地引擎工作副本 `../engine`（已含 iOS 改动）
