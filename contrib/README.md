# contrib/ — 我方主导的 OpenDiablo2 玩法贡献

这里放**工作室自己写、准备提给上游 AbyssEngine/OpenDiablo2 的玩法代码**。
开源项目靠所有人一起往前拱——我们不再只等社区，改为"贡献者模式"。

## 当前进度
- `gameplay-test.lua` —— 首个可玩切片：Act 1 罗格营地地图 + 点击移动角色标记。
  证明了 世界坐标↔屏幕坐标 / 地图渲染 / 鼠标输入 这条玩法主干已通。

## 如何在本地/云端验证（无需 Mac、无需本机编译器）
本工作机没有 C++ 编译器也没有 Mac，所以靠 GitHub Actions 的 Ubuntu runner 当测试台：

1. 把本 `ios-port` 仓库推到 GitHub（用户建好空仓库 `d2-ios-port` 后我代推）。
2. 在仓库 **Actions → Build + Smoke Test (Linux, headless)** 点 **Run workflow**。
3. 该 CI 会：
   - 对所有 `.lua`（含 `contrib/`）做语法检查 → 抓出我写的 Lua 语法错；
   - 在 Ubuntu 上交叉编译引擎（与 iOS 同套 C++/SDL2）；
   - 用 SDL 虚拟显示无头启动引擎做冒烟。
4. 红了自己看日志修，绿了就能放心往上游提 PR。

## 提 PR 流程
1. Fork `AbyssEngine/OpenDiablo2`。
2. 把 `contrib/gameplay-test.lua` 复制到 `OpenDiablo2/screens/gameplay-test.lua`。
3. 在 `screens/screens.lua` 注册 `Screen.GAMEPLAY_TEST`；在 `screens/main-menu.lua`
   加一个按钮 `SetScreen(Screen.GAMEPLAY_TEST)`。
4. 提 PR，描述里注明"offers a click-to-move gameplay slice as a foundation"。

## 下一步切片（每个一个 PR）
- v2：用 `abyss.createSprite(英雄路径, 调色板)` 替换 Label 标记，接动画/朝向。
- v3：点击后角色"走"向目标格（移动插值）+ 地图碰撞。
- v4+：怪物、战斗、物品、技能、UI、存档。
