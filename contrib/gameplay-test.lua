--[[
    gameplay-test.lua  —  OpenDiablo2 首个"可玩切片"贡献（由工作室主导）
    ------------------------------------------------------------------
    目标：在 Act 1 罗格营地（Rogue Encampment）地图上，实现"点击移动
    一个角色标记"。这证明了 世界坐标 ↔ 屏幕坐标、地图渲染、鼠标输入
    这条玩法主干是通的——真正的英雄精灵、动画、碰撞、怪物、物品、UI
    都建立在这条主干之上。

    为什么先做"标记"而不是"真英雄"：
    本环境无编译器/Mac，无法本地运行引擎验证 `abyss.createSprite`
    的确切精灵路径；先用一个 Label 标记把坐标/输入主干跑通（用已验证
    的 API），待 Linux 无头 CI 跑通后再把标记换成真正的英雄 DC6 精灵。

    验证方式：.github/workflows/build-linux.yml
      - Lua 语法检查（所有 .lua，含本文件）
      - 引擎在 Ubuntu 上交叉编译 + 无头启动冒烟

    接入方式（放到 OpenDiablo2 后）：
      1. 复制本文件到 OpenDiablo2/screens/gameplay-test.lua
      2. 在 screens/screens.lua 注册 Screen.GAMEPLAY_TEST = ...
      3. 在 screens/main-menu.lua 加一个按钮 SetScreen(Screen.GAMEPLAY_TEST)
--]]

local GameplayTest = {}
GameplayTest.__index = GameplayTest

function GameplayTest:new()
    local this = setmetatable({}, GameplayTest)
    this:initialize()
    return this
end

function GameplayTest:initialize()
    self.rootNode = abyss.getRootNode()

    -- 1) 建地图区 + 渲染器（与 map-engine-test 同机制，已验证）
    self.zone = abyss.createZone()
    self.mapRenderer = abyss.createMapRenderer(self.zone)
    self.mapRenderer:setPosition(400, 300)

    -- 2) 载入 Act 1 城镇预设（preset 1 = 罗格营地）
    local levelType = LevelTypes[RegionDefs.Act1.Town]
    local preset = GetLevelPreset(levelType.id, 1)
    local ds1 = abyss.loadDS1(preset.files[1])
    self.zone:resetMap(levelType, preset.dt1Mask, ds1.width, ds1.height, 1337)
    self.zone:stamp(ds1, 0, 0)
    self.mapRenderer:compile(ResourceDefs.Palette.Act1)

    -- 3) 玩家标记（v1：用 Label 占位；v2：换成 abyss.createSprite(英雄路径, 调色板)）
    self.player = abyss.createLabel(SystemFonts.Fnt16)
    self.player:setColorMod(0x00, 0xFF, 0x00)
    self.player:setAlignment("middle", "middle")
    self.player.caption = "@"   -- 暂代英雄

    self.lastMouseX = 400
    self.lastMouseY = 300
    self.playerWorldX = math.floor(ds1.width / 2)
    self.playerWorldY = math.floor(ds1.height / 2)
    self:placePlayer()

    -- 4) 点击移动（暗黑2 原味操作）：左键点地图 → 角色跳到该地块
    self.input = abyss.createInputListener()
    self.mapRenderer:appendChild(self.input)
    self.input:onMouseMove(function(x, y)
        self.lastMouseX = x
        self.lastMouseY = y
    end)
    self.input:onMouseButton(function(button, isPressed)
        if button == 1 and isPressed then
            local mx, my = self.mapRenderer:getPosition()
            local tx, ty = abyss.orthoToWorld(self.lastMouseX - mx, self.lastMouseY - my)
            if tx >= 0 and ty >= 0 and tx < self.zone.width and ty < self.zone.height then
                self.playerWorldX = math.floor(tx)
                self.playerWorldY = math.floor(ty)
                self:placePlayer()
            end
        end
    end)

    self.rootNode:appendChild(self.mapRenderer)
    self.rootNode:appendChild(self.player)

    self.btnExit = CreateButton(ButtonTypes.Short, 0, 573, "Exit", function()
        SetScreen(Screen.MAIN_MENU)
    end)
    self.rootNode:appendChild(self.btnExit)
end

function GameplayTest:placePlayer()
    local ox, oy = self.mapRenderer:getPosition()
    local sx, sy = abyss.worldToOrtho(self.playerWorldX, self.playerWorldY)
    self.player:setPosition(sx + ox, sy + oy)
end

return GameplayTest
