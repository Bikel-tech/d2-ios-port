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
| **经典版数据 D2:LoD MPQ** | ✅ **已找到（2026-08-31）** | 见下方「数据源」一节，10 个 MPQ 全在、有效，仅 2 个需改小写 |
| **地图/世界引擎** | ✅ **已存在（实测）** | `map-engine-test.lua` 证明能从 MPQ 读 DS1 关卡、等距渲染、五幕预设全齐。比"仅主菜单"先进 |
| 游戏可玩度 | ⚠️ **地图通、缺"人"** | 能渲染/平移地图；角色精灵、移动、战斗、物品、技能、UI 尚未接 |
| 触屏操作 | ❌ 仅鼠标/键盘 | 需虚拟按键层（已给出骨架） |

## 数据源（经典暗黑2：毁灭之王 1.13c 数据，已确认）

> 引擎 `AbyssConfiguration.c` 期望的 MPQ 清单：
> `d2exp.MPQ, d2xmusic.MPQ, d2xtalk.MPQ, d2xvideo.MPQ, d2data.MPQ, d2char.MPQ, d2music.MPQ, d2sfx.MPQ, d2video.MPQ, d2speech.MPQ`

**找到位置**：`D:\BaiduNetdiskDownload\暗黑2 1.13c全整合\Diablo2 1.13c`
**校验**：10 个 MPQ 文件头均为 `4D 50`（"MP" 魔数），为真有效游戏数据。

| 引擎期望 | 包内实际 | 是否匹配 |
|---|---|---|
| d2data.MPQ | d2data.mpq | ✅ |
| d2exp.MPQ | d2exp.mpq | ✅ |
| d2char.MPQ | d2char.mpq | ✅ |
| d2music.MPQ | d2music.mpq | ✅ |
| d2sfx.MPQ | d2sfx.mpq | ✅ |
| d2speech.MPQ | d2speech.mpq | ✅ |
| d2video.MPQ | d2video.mpq | ✅ |
| d2xtalk.MPQ | d2xtalk.mpq | ✅ |
| d2xmusic.MPQ | **D2XMUSIC.MPQ** | ⚠️ 需改小写 `d2xmusic.MPQ` |
| d2xvideo.MPQ | **D2XVIDEO.MPQ** | ⚠️ 需改小写 `d2xvideo.MPQ` |

**只差一步**：iOS 文件系统区分大小写，故这两个文件在打进 App 包前需改名小写。
已提供一键整理脚本 `整理数据.bat`：双击即把 10 个 MPQ 按正确大小写复制到 `D2-Data-Ready/`，
之后再塞进 CI 产出的 `.app` 的 `game/` 目录即可。

> 备注：包内另有 `data/`（`global`/`local` 子目录）、`113map/`（地图包）为 1.13c 整合版附带的 MOD 扩展，
> 基础引擎不需它们，可先不管。

> ⚠️ **版权溯源提醒**：此 1.13c 整合包来自第三方网盘，属"再分发整包"，并非你本人购买介质的个人备份。
> 法律上最干净的来源是凭你已有的 D2R（重制版）所有权，在 Battle.net 客户端里**免费加装"经典暗黑2"**，
> 那会得到同一版本（1.13/1.14）的官方 MPQ。引擎本身开源免费，数据源请尽量走你自己的正版授权。

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

### M2 · 可玩（我方主导贡献，不再只等社区）
> 用户原话："剩下的得跟社区进度走，你走前面不行吗？开源的项目不就是大家一起完成吗"
> —— 已转为**贡献者模式**：fork 上游、在自己机器推敲、往上游提 PR。

- [x] **摸清真实进度（2026-08-31）**：地图/世界引擎已存在（`map-engine-test.lua` 能渲染五幕地图），
      真正缺口是"地图上没有人"——角色精灵/移动/战斗/物品/技能/UI。
- [x] **搭无头测试台** `build-linux.yml`：Ubuntu runner 上 Lua 语法检查 + 引擎交叉编译 + 无头启动，
      让我在无 Mac/无编译器的情况下也能验证 Lua 贡献（不用等别人）。
- [x] **首个玩法切片** `contrib/gameplay-test.lua`：Act 1 罗格营地 + 点击移动角色标记，
      证明 世界坐标↔屏幕坐标 / 地图渲染 / 鼠标输入 主干已通。下一步把标记换成真英雄 DC6 精灵。
- [ ] **v2 真英雄精灵**：用 `abyss.createSprite(英雄路径, 调色板)` 替换 Label 标记，接动画/朝向
      （需先在 MPQ 里确认角色精灵路径，由 Linux CI 跑通后反查）。
- [ ] **v3 移动插值 + 碰撞**：点击后角色走向目标格（而非瞬移），与地图碰撞体交互。
- [ ] **v4 怪物/战斗/物品/技能/UI**：按 OpenDiablo2 既有架构逐步接，每个切片一个 PR。
- [ ] **iOS 补丁上游化**：把 `patches-abyssengine-ios.diff` + 工具链作为 PR 提给 AbyssEngine，
      让项目本身 iOS 可构建（造福全员，也服务我们自己的目标）。
- [ ] 虚拟按键布局细化（技能栏/腰带/背包，已占位 4 个按钮，配合触屏适配层）。
- [ ] 外接手柄支持（SDL_GameController，SDL2 原生支持）。

> **约束（诚实）**：本工作机无编译器/Mac，无法本地运行引擎；上述 Lua 贡献靠
> `build-linux.yml` 云端验证，且完整"可玩 D2"是社区级工程量，我方做的是**持续往前推的增量**，
> 不是单枪匹马 overnight 做完。每推进一步即提 PR 回上游，与社区合流。

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
