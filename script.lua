-- ARCANIX v8 | Part 1/3
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting     = game:GetService("Lighting")
local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

local COLORS = {
    bg=Color3.fromRGB(18,18,22), panel=Color3.fromRGB(25,25,32),
    tabOff=Color3.fromRGB(30,30,38), tabHov=Color3.fromRGB(42,42,54),
    accent=Color3.fromRGB(0,255,255), green=Color3.fromRGB(50,220,90),
    text=Color3.fromRGB(230,230,240), textDim=Color3.fromRGB(140,140,160),
    close=Color3.fromRGB(255,70,70),
}
local FONT = Enum.Font.Arcade
local BASE_W, BASE_H = 350, 252

-- ================= LOCALIZATION =================
local L = {
    EN = {visual="Visual",combat="Combat",misc="Misc",settings="Settings",
        chams="Chams",esp="ESP Names",color="Chams Color",aimbot="Aimbot",
        target="Target Part",mode="Aim Mode",smooth="Smoothness",fov="FOV",
        wall="Wall Check",head="Head",neck="Neck",body="Body",legs="Legs",
        always="ALWAYS",shift="SHIFT LOCK",speed="Speed Boost",size="Menu Size",
        unload="Unload Arcanix",on="ON",off="OFF",perfect="PERFECT",
        teleport="Teleport to Player"},
    RU = {visual="Визуал",combat="Бой",misc="Разное",settings="Настройки",
        chams="Часы",esp="Ники ESP",color="Цвет часов",aimbot="Аимбот",
        target="Часть тела",mode="Режим аима",smooth="Плавность",fov="Радиус",
        wall="Сквозь стены",head="Голова",neck="Шея",body="Тело",legs="Ноги",
        always="ВСЕГДА",shift="SHIFT LOCK",speed="Скорость",size="Размер меню",
        unload="Выгрузить",on="ВКЛ",off="ВЫКЛ",perfect="ИДЕАЛ",
        teleport="Телепорт к игроку"},
}
local currentLang = "EN"
local langUpdates = {}
local function t(k) return (L[currentLang] and L[currentLang][k]) or k end
local function regLang(fn) table.insert(langUpdates, fn) end
local function applyLanguage(lang)
    currentLang = lang
    for _, fn in ipairs(langUpdates) do fn() end
end

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "ArcanixMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = PlayerGui

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "ArcanixFOV"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = false
fovGui.DisplayOrder = 999998
fovGui.Parent = PlayerGui

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, 300, 0, 300)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = fovGui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.new(1, 1, 1)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.4

RunService.RenderStepped:Connect(function()
    if not fovCircle.Visible then return end
    local vp = workspace.CurrentCamera.ViewportSize
    fovCircle.Position = UDim2.fromOffset(vp.X/2, vp.Y/2)
end)

local blur = Lighting:FindFirstChild("ArcanixBlur")
if not blur then
    blur = Instance.new("BlurEffect")
    blur.Name = "ArcanixBlur"
    blur.Size = 0
    blur.Parent = Lighting
end

-- ================= LANGUAGE BTN =================
local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.new(0, 120, 0, 30)
langBtn.Position = UDim2.new(1, -20, 0, 10)
langBtn.AnchorPoint = Vector2.new(1, 0)
langBtn.BackgroundColor3 = COLORS.bg
langBtn.TextColor3 = COLORS.accent
langBtn.Font = FONT
langBtn.TextSize = 14
langBtn.AutoButtonColor = false
langBtn.ZIndex = 10
langBtn.Parent = gui
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 6)
local langStroke = Instance.new("UIStroke", langBtn)
langStroke.Color = COLORS.accent
langStroke.Thickness = 1.5

local langDropdown = Instance.new("Frame")
langDropdown.Size = UDim2.new(0, 120, 0, 74)
langDropdown.Position = UDim2.new(1, -20, 0, 46)
langDropdown.AnchorPoint = Vector2.new(1, 0)
langDropdown.BackgroundColor3 = COLORS.panel
langDropdown.BorderSizePixel = 0
langDropdown.Visible = false
langDropdown.ZIndex = 11
langDropdown.Parent = gui
Instance.new("UICorner", langDropdown).CornerRadius = UDim.new(0, 6)
local langLayout = Instance.new("UIListLayout", langDropdown)
langLayout.Padding = UDim.new(0, 4)
local langPad = Instance.new("UIPadding", langDropdown)
langPad.PaddingTop = UDim.new(0, 5)
langPad.PaddingLeft = UDim.new(0, 5)
langPad.PaddingRight = UDim.new(0, 5)
langPad.PaddingBottom = UDim.new(0, 5)

local function addLangOption(key, label)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = COLORS.tabOff
    b.Text = label
    b.Font = FONT
    b.TextSize = 14
    b.TextColor3 = COLORS.text
    b.AutoButtonColor = false
    b.ZIndex = 12
    b.Parent = langDropdown
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.tabHov}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.tabOff}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        applyLanguage(key)
        langDropdown.Visible = false
    end)
end
addLangOption("EN", "EN  English")
addLangOption("RU", "RU  Русский")

local function refreshLangBtn()
    langBtn.Text = "Lang: " .. currentLang .. "  v"
end
refreshLangBtn()
regLang(refreshLangBtn)

langBtn.MouseButton1Click:Connect(function()
    langDropdown.Visible = not langDropdown.Visible
end)

-- ================= TOGGLE =================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 110, 0, 36)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -18)
toggleBtn.BackgroundColor3 = COLORS.bg
toggleBtn.TextColor3 = COLORS.accent
toggleBtn.Text = "ARCANIX"
toggleBtn.Font = FONT
toggleBtn.TextSize = 20
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)
local tStroke = Instance.new("UIStroke", toggleBtn)
tStroke.Color = COLORS.accent
tStroke.Thickness = 2

-- ================= MENU =================
local menu = Instance.new("Frame")
menu.AnchorPoint = Vector2.new(0.5, 0.5)
menu.Position = UDim2.new(0.5, 0, 0.5, 0)
menu.Size = UDim2.new(0, BASE_W, 0, BASE_H)
menu.BackgroundColor3 = COLORS.bg
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)
local mStroke = Instance.new("UIStroke", menu)
mStroke.Color = COLORS.accent
mStroke.Thickness = 1.5
mStroke.Transparency = 0.3
local menuScale = Instance.new("UIScale", menu)
menuScale.Scale = 1
local baseScale = 1.0

TweenService:Create(mStroke,
    TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {Transparency = 0.6}):Play()

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = COLORS.panel
titleBar.BorderSizePixel = 0
titleBar.Parent = menu
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
local tbCover = Instance.new("Frame")
tbCover.Size = UDim2.new(1, 0, 0, 15)
tbCover.Position = UDim2.new(0, 0, 1, -15)
tbCover.BackgroundColor3 = COLORS.panel
tbCover.BorderSizePixel = 0
tbCover.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ARCANIX"
title.Font = FONT
title.TextSize = 20
title.TextColor3 = COLORS.accent
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
closeBtn.BackgroundColor3 = COLORS.close
closeBtn.Text = "X"
closeBtn.Font = FONT
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 30)
tabBar.Position = UDim2.new(0, 8, 0, 36)
tabBar.BackgroundTransparency = 1
tabBar.Parent = menu
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 8)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -16, 1, -74)
content.Position = UDim2.new(0, 8, 0, 70)
content.BackgroundColor3 = COLORS.panel
content.BorderSizePixel = 0
content.Parent = menu
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

-- ================= TABS SETUP =================
local pages, tabButtons, tabIndicators, tabScales = {}, {}, {}, {}
local tabNames = {"Visual","Combat","Misc","Settings"}
local tabKeys = {Visual="visual",Combat="combat",Misc="misc",Settings="settings"}

local function selectTab(name)
    for n, page in pairs(pages) do page.Visible = (n == name) end
    for n, btn in pairs(tabButtons) do
        local active = (n == name)
        btn.TextColor3 = active and COLORS.accent or COLORS.textDim
        btn.BackgroundColor3 = active and COLORS.tabHov or COLORS.tabOff
        tabIndicators[n].Visible = active
    end
end

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -6, 1, 0)
    btn.BackgroundColor3 = COLORS.tabOff
    btn.Text = t(tabKeys[name])
    btn.Font = FONT
    btn.TextSize = 12
    btn.TextColor3 = COLORS.textDim
    btn.AutoButtonColor = false
    btn.LayoutOrder = i
    btn.Parent = tabBar
    tabButtons[name] = btn
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    tabScales[name] = Instance.new("UIScale", btn)
    regLang(function() btn.Text = t(tabKeys[name]) end)

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0.5, 0, 0, 2)
    ind.Position = UDim2.new(0.25, 0, 1, -4)
    ind.BackgroundColor3 = COLORS.accent
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.Parent = btn
    tabIndicators[name] = ind

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -14, 1, -14)
    page.Position = UDim2.new(0, 7, 0, 7)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = COLORS.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = content
    pages[name] = page
    local pL = Instance.new("UIListLayout", page)
    pL.Padding = UDim.new(0, 6)

    btn.MouseEnter:Connect(function()
        if btn.TextColor3 ~= COLORS.accent then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.tabHov}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.TextColor3 ~= COLORS.accent then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.tabOff}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        selectTab(name)
        local s = tabScales[name]
        TweenService:Create(s, TweenInfo.new(0.08), {Scale = 0.92}):Play()
        task.delay(0.08, function()
            TweenService:Create(s, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        end)
    end)
end
selectTab("Visual")
-- ================= HELPERS =================
local function addBtnHover(btn, getBase)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = COLORS.accent
    stroke.Thickness = 0
    stroke.Transparency = 1
    btn.MouseEnter:Connect(function()
        local b = getBase()
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.new(math.min(b.R+0.04,1), math.min(b.G+0.04,1), math.min(b.B+0.04,1))
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.12), {Thickness = 1.5, Transparency = 0.2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = getBase()}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.12), {Thickness = 0, Transparency = 1}):Play()
    end)
end

local function flashOn(btn)
    btn.BackgroundColor3 = COLORS.green
    local s = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
    s.Scale = 1
    TweenService:Create(s, TweenInfo.new(0.1), {Scale = 1.1}):Play()
    task.delay(0.1, function()
        TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Scale = 1}):Play()
        task.wait(0.15)
        if btn.BackgroundColor3 == COLORS.green then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.accent}):Play()
        end
    end)
end

-- ================= CHAMS / ESP =================
local chamsEnabled = false
local chamsColor = Color3.fromRGB(0, 255, 255)
local highlights = {}
local espEnabled = false
local nametags = {}

local function applyChams(plr, char)
    if not chamsEnabled or plr == LocalPlayer or not char then return end
    if not char:FindFirstChildOfClass("Humanoid") then return end
    if highlights[char] then highlights[char]:Destroy() end
    local h = Instance.new("Highlight")
    h.FillColor = chamsColor
    h.FillTransparency = 0.5
    h.OutlineColor = chamsColor
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
    highlights[char] = h
end
local function removeChams(char)
    if highlights[char] then highlights[char]:Destroy(); highlights[char] = nil end
end
local function applyNametag(plr)
    if not espEnabled or plr == LocalPlayer then return end
    if nametags[plr] then nametags[plr]:Destroy() end
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ArcanixNametag"
    bb.Size = UDim2.new(0, 200, 0, 24)
    bb.StudsOffset = Vector3.new(0, 2.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = plr.Name
    lbl.Font = FONT
    lbl.TextSize = 15
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.TextStrokeTransparency = 0
    lbl.Parent = bb
    nametags[plr] = bb
end
local function removeNametag(plr)
    if nametags[plr] then nametags[plr]:Destroy(); nametags[plr] = nil end
end
local function setupPlayer(plr)
    if plr == LocalPlayer then return end
    if plr.Character then
        applyChams(plr, plr.Character)
        applyNametag(plr)
    end
    plr.CharacterAdded:Connect(function(char)
        applyChams(plr, char)
        applyNametag(plr)
    end)
    plr.CharacterRemoving:Connect(function()
        if nametags[plr] then nametags[plr]:Destroy(); nametags[plr] = nil end
    end)
end
for _, plr in pairs(Players:GetPlayers()) do setupPlayer(plr) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeNametag)

-- ================= VISUAL PAGE =================
local chamsBtn = Instance.new("TextButton")
chamsBtn.Size = UDim2.new(1, 0, 0, 32)
chamsBtn.BackgroundColor3 = COLORS.tabOff
chamsBtn.Font = FONT
chamsBtn.TextSize = 13
chamsBtn.TextColor3 = COLORS.text
chamsBtn.AutoButtonColor = false
chamsBtn.LayoutOrder = 1
chamsBtn.Parent = pages["Visual"]
Instance.new("UICorner", chamsBtn).CornerRadius = UDim.new(0, 5)
addBtnHover(chamsBtn, function() return chamsEnabled and COLORS.accent or COLORS.tabOff end)
local function refreshChamsBtn() chamsBtn.Text = t("chams") .. ": " .. (chamsEnabled and t("on") or t("off")) end
refreshChamsBtn(); regLang(refreshChamsBtn)
chamsBtn.MouseButton1Click:Connect(function()
    chamsEnabled = not chamsEnabled
    chamsBtn.BackgroundColor3 = chamsEnabled and COLORS.accent or COLORS.tabOff
    chamsBtn.TextColor3 = chamsEnabled and Color3.new(1,1,1) or COLORS.text
    refreshChamsBtn()
    if chamsEnabled then
        flashOn(chamsBtn)
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then applyChams(plr, plr.Character) end
        end
    else
        for char in pairs(highlights) do removeChams(char) end
    end
end)

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, 0, 0, 32)
espBtn.BackgroundColor3 = COLORS.tabOff
espBtn.Font = FONT
espBtn.TextSize = 13
espBtn.TextColor3 = COLORS.text
espBtn.AutoButtonColor = false
espBtn.LayoutOrder = 2
espBtn.Parent = pages["Visual"]
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 5)
addBtnHover(espBtn, function() return espEnabled and COLORS.accent or COLORS.tabOff end)
local function refreshEspBtn() espBtn.Text = t("esp") .. ": " .. (espEnabled and t("on") or t("off")) end
refreshEspBtn(); regLang(refreshEspBtn)
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.BackgroundColor3 = espEnabled and COLORS.accent or COLORS.tabOff
    espBtn.TextColor3 = espEnabled and Color3.new(1,1,1) or COLORS.text
    refreshEspBtn()
    if espEnabled then
        flashOn(espBtn)
        for _, plr in pairs(Players:GetPlayers()) do applyNametag(plr) end
    else
        for plr in pairs(nametags) do removeNametag(plr) end
    end
end)

local colorLbl = Instance.new("TextLabel")
colorLbl.Size = UDim2.new(1, 0, 0, 18)
colorLbl.BackgroundTransparency = 1
colorLbl.Font = FONT
colorLbl.TextSize = 12
colorLbl.TextColor3 = COLORS.textDim
colorLbl.TextXAlignment = Enum.TextXAlignment.Left
colorLbl.LayoutOrder = 3
colorLbl.Parent = pages["Visual"]
local function refreshColorLbl() colorLbl.Text = t("color") .. ":" end
refreshColorLbl(); regLang(refreshColorLbl)

local colorRow = Instance.new("Frame")
colorRow.Size = UDim2.new(1, 0, 0, 30)
colorRow.BackgroundTransparency = 1
colorRow.LayoutOrder = 4
colorRow.Parent = pages["Visual"]
local cL = Instance.new("UIListLayout", colorRow)
cL.FillDirection = Enum.FillDirection.Horizontal
cL.Padding = UDim.new(0, 8)

for _, c in ipairs({
    Color3.fromRGB(0,255,255), Color3.fromRGB(255,60,60),
    Color3.fromRGB(60,255,60), Color3.fromRGB(255,255,60),
    Color3.fromRGB(255,60,255), Color3.fromRGB(255,255,255)
}) do
    local sw = Instance.new("TextButton")
    sw.Size = UDim2.new(0, 28, 0, 28)
    sw.BackgroundColor3 = c
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.Parent = colorRow
    Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 4)
    local swStroke = Instance.new("UIStroke", sw)
    swStroke.Color = Color3.new(1,1,1)
    swStroke.Thickness = 0
    swStroke.Transparency = 1
    local swScale = Instance.new("UIScale", sw)
    sw.MouseEnter:Connect(function()
        TweenService:Create(swScale, TweenInfo.new(0.12), {Scale = 1.18}):Play()
        TweenService:Create(swStroke, TweenInfo.new(0.12), {Thickness = 2, Transparency = 0}):Play()
    end)
    sw.MouseLeave:Connect(function()
        TweenService:Create(swScale, TweenInfo.new(0.12), {Scale = 1}):Play()
        TweenService:Create(swStroke, TweenInfo.new(0.12), {Thickness = 0, Transparency = 1}):Play()
    end)
    sw.MouseButton1Click:Connect(function()
        chamsColor = c
        for _, h in pairs(highlights) do
            h.FillColor = c
            h.OutlineColor = c
        end
    end)
end

-- ================= AIMBOT STATE =================
local aimbotEnabled    = false
local aimSmoothness    = 30
local aimFOV           = 150
local aimTargetPart    = "Head"
local aimMode          = "ALWAYS"
local wallCheckEnabled = false
local lockedTarget     = nil

local function getAimPosition(character)
    if not character then return nil end
    local head = character:FindFirstChild("Head")
    local hrp  = character:FindFirstChild("HumanoidRootPart")
    if aimTargetPart == "Head" then return head and head.Position
    elseif aimTargetPart == "Neck" then
        if head then return head.Position - Vector3.new(0, 0.4, 0) end
        return hrp and hrp.Position + Vector3.new(0, 1, 0)
    elseif aimTargetPart == "Body" then return hrp and hrp.Position
    elseif aimTargetPart == "Legs" then
        if hrp then return hrp.Position - Vector3.new(0, 2, 0) end
    end
    return head and head.Position
end

local function hasLineOfSight(targetPos, character)
    local cam = workspace.CurrentCamera
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, cam}
    local result = workspace:Raycast(cam.CFrame.Position, targetPos - cam.CFrame.Position, params)
    if not result then return true end
    return character and result.Instance:IsDescendantOf(character)
end

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then lockedTarget = nil; return end
    if not LocalPlayer.Character then return end
    local myHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then lockedTarget = nil; return end
    if aimMode == "SHIFT LOCK" and UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        lockedTarget = nil; return
    end
    local cam = workspace.CurrentCamera
    local center = cam.ViewportSize / 2
    if lockedTarget then
        local plr = lockedTarget.player
        local valid = false
        if plr and plr.Parent and plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local aimPos = getAimPosition(plr.Character)
                if aimPos then
                    local sp, onScreen = cam:WorldToViewportPoint(aimPos)
                    if onScreen then
                        valid = true
                        if wallCheckEnabled and not hasLineOfSight(aimPos, plr.Character) then
                            valid = false
                        end
                    end
                end
            end
        end
        if not valid then lockedTarget = nil end
    end
    if not lockedTarget then
        local bestPlr, bestPos, bestDist = nil, nil, aimFOV
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local aimPos = getAimPosition(plr.Character)
                    if aimPos then
                        local sp, onScreen = cam:WorldToViewportPoint(aimPos)
                        if onScreen then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d <= aimFOV and d < bestDist then
                                if not wallCheckEnabled or hasLineOfSight(aimPos, plr.Character) then
                                    bestDist = d; bestPos = aimPos; bestPlr = plr
                                end
                            end
                        end
                    end
                end
            end
        end
        if bestPlr then lockedTarget = {player = bestPlr} end
    end
    if lockedTarget then
        local aimPos = getAimPosition(lockedTarget.player.Character)
        if aimPos then
            local targetCF = CFrame.lookAt(cam.CFrame.Position, aimPos)
            local alpha = aimSmoothness / 100
            if alpha >= 0.99 then cam.CFrame = targetCF
            else cam.CFrame = cam.CFrame:Lerp(targetCF, alpha) end
        end
    end
end)

-- ================= SLIDER =================
local function makeSlider(parent, labelKey, minV, maxV, defaultV, order, formatFn, callback)
    formatFn = formatFn or function(v) return tostring(math.floor(v)) end
    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(1, 0, 0, 44)
    cont.BackgroundTransparency = 1
    cont.LayoutOrder = order
    cont.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Font = FONT
    label.TextSize = 12
    label.TextColor3 = COLORS.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = cont
    local currentVal = defaultV
    local function refreshLabel() label.Text = t(labelKey) .. ": " .. formatFn(currentVal) end
    refreshLabel(); regLang(refreshLabel)
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = COLORS.tabOff
    track.BorderSizePixel = 0
    track.Parent = cont
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local rel0 = (defaultV - minV) / (maxV - minV)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(rel0, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(rel0, -7, 0.5, -7)
    knob.BackgroundColor3 = COLORS.accent
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local dragging, dragAbsX, dragW = false, 0, 0
    local function update(input)
        if dragW <= 0 then return end
        local rx = math.clamp((input.Position.X - dragAbsX) / dragW, 0, 1)
        currentVal = minV + rx * (maxV - minV)
        fill.Size = UDim2.new(rx, 0, 1, 0)
        knob.Position = UDim2.new(rx, -7, 0.5, -7)
        refreshLabel(); callback(currentVal)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragAbsX = track.AbsolutePosition.X
            dragW = track.AbsoluteSize.X
            update(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ================= COMBAT PAGE =================
local aimBtn = Instance.new("TextButton")
aimBtn.Size = UDim2.new(1, 0, 0, 32)
aimBtn.BackgroundColor3 = COLORS.tabOff
aimBtn.Font = FONT
aimBtn.TextSize = 13
aimBtn.TextColor3 = COLORS.text
aimBtn.AutoButtonColor = false
aimBtn.LayoutOrder = 1
aimBtn.Parent = pages["Combat"]
Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(0, 5)
addBtnHover(aimBtn, function() return aimbotEnabled and COLORS.accent or COLORS.tabOff end)
local function refreshAimBtn() aimBtn.Text = t("aimbot") .. ": " .. (aimbotEnabled and t("on") or t("off")) end
refreshAimBtn(); regLang(refreshAimBtn)

local aimSettings = Instance.new("Frame")
aimSettings.Size = UDim2.new(1, 0, 0, 0)
aimSettings.BackgroundTransparency = 1
aimSettings.ClipsDescendants = true
aimSettings.Visible = false
aimSettings.LayoutOrder = 2
aimSettings.Parent = pages["Combat"]

local aimInner = Instance.new("Frame")
aimInner.Size = UDim2.new(1, 0, 0, 210)
aimInner.BackgroundTransparency = 1
aimInner.Parent = aimSettings
local aLayout = Instance.new("UIListLayout", aimInner)
aLayout.Padding = UDim.new(0, 3)

local targetLbl = Instance.new("TextLabel")
targetLbl.Size = UDim2.new(1, 0, 0, 16)
targetLbl.BackgroundTransparency = 1
targetLbl.Font = FONT
targetLbl.TextSize = 11
targetLbl.TextColor3 = COLORS.textDim
targetLbl.TextXAlignment = Enum.TextXAlignment.Left
targetLbl.LayoutOrder = 1
targetLbl.Parent = aimInner
local function refreshTargetLbl() targetLbl.Text = t("target") .. ":" end
refreshTargetLbl(); regLang(refreshTargetLbl)

local targetRow = Instance.new("Frame")
targetRow.Size = UDim2.new(1, 0, 0, 24)
targetRow.BackgroundTransparency = 1
targetRow.LayoutOrder = 2
targetRow.Parent = aimInner
local tL = Instance.new("UIListLayout", targetRow)
tL.FillDirection = Enum.FillDirection.Horizontal
tL.Padding = UDim.new(0, 4)
local targetButtons = {}
local function updateTargetVisuals()
    for n, b in pairs(targetButtons) do
        b.BackgroundColor3 = (n == aimTargetPart) and COLORS.accent or COLORS.tabOff
        b.TextColor3 = (n == aimTargetPart) and Color3.new(1,1,1) or COLORS.text
    end
end
for _, name in ipairs({"Head","Neck","Body","Legs"}) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.25, -4, 1, 0)
    b.BackgroundColor3 = COLORS.tabOff
    b.Text = t(name:lower())
    b.Font = FONT
    b.TextSize = 11
    b.TextColor3 = COLORS.text
    b.AutoButtonColor = false
    b.Parent = targetRow
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    targetButtons[name] = b
    regLang(function() b.Text = t(name:lower()) end)
    b.MouseButton1Click:Connect(function() aimTargetPart = name; updateTargetVisuals() end)
end
updateTargetVisuals()

local modeLbl = Instance.new("TextLabel")
modeLbl.Size = UDim2.new(1, 0, 0, 16)
modeLbl.BackgroundTransparency = 1
modeLbl.Font = FONT
modeLbl.TextSize = 11
modeLbl.TextColor3 = COLORS.textDim
modeLbl.TextXAlignment = Enum.TextXAlignment.Left
modeLbl.LayoutOrder = 3
modeLbl.Parent = aimInner
local function refreshModeLbl() modeLbl.Text = t("mode") .. ":" end
refreshModeLbl(); regLang(refreshModeLbl)

local modeRow = Instance.new("Frame")
modeRow.Size = UDim2.new(1, 0, 0, 24)
modeRow.BackgroundTransparency = 1
modeRow.LayoutOrder = 4
modeRow.Parent = aimInner
local mL = Instance.new("UIListLayout", modeRow)
mL.FillDirection = Enum.FillDirection.Horizontal
mL.Padding = UDim.new(0, 6)
local modeButtons = {}
local function updateModeVisuals()
    for n, b in pairs(modeButtons) do
        b.BackgroundColor3 = (n == aimMode) and COLORS.accent or COLORS.tabOff
        b.TextColor3 = (n == aimMode) and Color3.new(1,1,1) or COLORS.text
    end
end
for _, name in ipairs({"ALWAYS","SHIFT LOCK"}) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -3, 1, 0)
    b.BackgroundColor3 = COLORS.tabOff
    b.Text = (name == "ALWAYS") and t("always") or t("shift")
    b.Font = FONT
    b.TextSize = 11
    b.TextColor3 = COLORS.text
    b.AutoButtonColor = false
    b.Parent = modeRow
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    modeButtons[name] = b
    local lk = (name == "ALWAYS") and "always" or "shift"
    regLang(function() b.Text = t(lk) end)
    b.MouseButton1Click:Connect(function() aimMode = name; updateModeVisuals() end)
end
updateModeVisuals()

local wallBtn = Instance.new("TextButton")
wallBtn.Size = UDim2.new(1, 0, 0, 24)
wallBtn.BackgroundColor3 = COLORS.tabOff
wallBtn.Font = FONT
wallBtn.TextSize = 12
wallBtn.TextColor3 = COLORS.text
wallBtn.AutoButtonColor = false
wallBtn.LayoutOrder = 5
wallBtn.Parent = aimInner
Instance.new("UICorner", wallBtn).CornerRadius = UDim.new(0, 4)
local function refreshWallBtn() wallBtn.Text = t("wall") .. ": " .. (wallCheckEnabled and t("on") or t("off")) end
refreshWallBtn(); regLang(refreshWallBtn)
wallBtn.MouseButton1Click:Connect(function()
    wallCheckEnabled = not wallCheckEnabled
    wallBtn.BackgroundColor3 = wallCheckEnabled and COLORS.accent or COLORS.tabOff
    wallBtn.TextColor3 = wallCheckEnabled and Color3.new(1,1,1) or COLORS.text
    refreshWallBtn()
    if wallCheckEnabled then flashOn(wallBtn); lockedTarget = nil end
end)

makeSlider(aimInner, "smooth", 1, 100, 30, 6, function(v)
    if v >= 99 then return t("perfect") end
    return tostring(math.floor(v))
end, function(v) aimSmoothness = v end)

makeSlider(aimInner, "fov", 50, 400, 150, 7, function(v)
    return tostring(math.floor(v))
end, function(v)
    aimFOV = v
    local size = aimFOV * 2
    fovCircle.Size = UDim2.new(0, size, 0, size)
end)

aimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimBtn.BackgroundColor3 = aimbotEnabled and COLORS.accent or COLORS.tabOff
    aimBtn.TextColor3 = aimbotEnabled and Color3.new(1,1,1) or COLORS.text
    refreshAimBtn()
    aimSettings.Visible = aimbotEnabled
    if aimbotEnabled then
        flashOn(aimBtn)
        aimSettings.Size = UDim2.new(1, 0, 0, 0)
        TweenService:Create(aimSettings, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 0, 210)}):Play()
        fovCircle.Visible = true
    else
        TweenService:Create(aimSettings, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.delay(0.18, function()
            if not aimbotEnabled then aimSettings.Visible = false end
        end)
        fovCircle.Visible = false
        lockedTarget = nil
    end
end)
-- ================= MISC PAGE =================
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, 0, 0, 32)
speedBtn.BackgroundColor3 = COLORS.tabOff
speedBtn.Font = FONT
speedBtn.TextSize = 13
speedBtn.TextColor3 = COLORS.text
speedBtn.AutoButtonColor = false
speedBtn.LayoutOrder = 1
speedBtn.Parent = pages["Misc"]
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 5)
local speedOn = false
addBtnHover(speedBtn, function() return speedOn and COLORS.accent or COLORS.tabOff end)
local function refreshSpeedBtn() speedBtn.Text = t("speed") .. ": " .. (speedOn and t("on") or t("off")) end
refreshSpeedBtn(); regLang(refreshSpeedBtn)
speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    speedBtn.BackgroundColor3 = speedOn and COLORS.accent or COLORS.tabOff
    speedBtn.TextColor3 = speedOn and Color3.new(1,1,1) or COLORS.text
    refreshSpeedBtn()
    if speedOn then flashOn(speedBtn) end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedOn and 60 or 16 end
end)

-- ================= SETTINGS PAGE =================
makeSlider(pages["Settings"], "size", 0.5, 1.5, 1.0, 1, function(v)
    return string.format("%.2fx", v)
end, function(v)
    baseScale = v
    menuScale.Scale = v
end)

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, 0, 0, 32)
unloadBtn.BackgroundColor3 = COLORS.close
unloadBtn.Text = t("unload")
unloadBtn.Font = FONT
unloadBtn.TextSize = 13
unloadBtn.TextColor3 = Color3.new(1,1,1)
unloadBtn.AutoButtonColor = false
unloadBtn.LayoutOrder = 2
unloadBtn.Parent = pages["Settings"]
Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 5)
regLang(function() unloadBtn.Text = t("unload") end)
unloadBtn.MouseButton1Click:Connect(function()
    for char in pairs(highlights) do removeChams(char) end
    for plr in pairs(nametags) do removeNametag(plr) end
    gui:Destroy(); fovGui:Destroy()
    if blur then blur:Destroy() end
end)

-- ================= DRAG =================
local function makeDraggable(frame, dragArea)
    dragArea = dragArea or frame
    local dragging, dragStart, startPos, wasMoved = false, nil, nil, false
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, wasMoved = true, false
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then wasMoved = true end
            if wasMoved then
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    return function()
        local r = wasMoved
        wasMoved = false
        return r
    end
end
makeDraggable(menu, titleBar)
local btnDragged = makeDraggable(toggleBtn)

-- ================= OPEN/CLOSE =================
local menuOpen = false
local function setOpen(state)
    menuOpen = state
    if state then
        menu.Visible = true
        menuScale.Scale = baseScale * 0.85
        TweenService:Create(menuScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Scale = baseScale}):Play()
        TweenService:Create(blur, TweenInfo.new(0.25), {Size = 8}):Play()
        toggleBtn.TextColor3 = COLORS.accent
        tStroke.Color = COLORS.accent
        tStroke.Transparency = 0
    else
        TweenService:Create(menuScale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Scale = baseScale * 0.85}):Play()
        TweenService:Create(blur, TweenInfo.new(0.25), {Size = 0}):Play()
        task.delay(0.22, function()
            if not menuOpen then
                menu.Visible = false
                menuScale.Scale = baseScale
            end
        end)
        toggleBtn.TextColor3 = COLORS.textDim
        tStroke.Color = COLORS.textDim
        tStroke.Transparency = 0.5
    end
end
toggleBtn.MouseButton1Click:Connect(function()
    if btnDragged() then return end
    setOpen(not menuOpen)
end)
closeBtn.MouseButton1Click:Connect(function()
    setOpen(false)
end)

-- ================= TELEPORT =================
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1, 0, 0, 32)
tpBtn.BackgroundColor3 = COLORS.tabOff
tpBtn.Font = FONT
tpBtn.TextSize = 13
tpBtn.TextColor3 = COLORS.text
tpBtn.AutoButtonColor = false
tpBtn.LayoutOrder = 2
tpBtn.Parent = pages["Misc"]
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)
addBtnHover(tpBtn, function() return COLORS.tabOff end)
local function refreshTpBtn() tpBtn.Text = t("teleport") end
refreshTpBtn(); regLang(refreshTpBtn)

local tpGui = Instance.new("ScreenGui")
tpGui.Name = "ArcanixTeleport"
tpGui.ResetOnSpawn = false
tpGui.IgnoreGuiInset = true
tpGui.DisplayOrder = 1000000
tpGui.Enabled = false
tpGui.Parent = PlayerGui

local tpFrame = Instance.new("Frame")
tpFrame.AnchorPoint = Vector2.new(0.5, 0.5)
tpFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
tpFrame.Size = UDim2.new(0, 320, 0, 380)
tpFrame.BackgroundColor3 = COLORS.bg
tpFrame.BorderSizePixel = 0
tpFrame.Parent = tpGui
Instance.new("UICorner", tpFrame).CornerRadius = UDim.new(0, 10)
local tpStroke = Instance.new("UIStroke", tpFrame)
tpStroke.Color = COLORS.accent
tpStroke.Thickness = 1.5
tpStroke.Transparency = 0.3
local tpScale = Instance.new("UIScale", tpFrame)

local tpTitle = Instance.new("TextLabel")
tpTitle.Size = UDim2.new(1, -60, 0, 32)
tpTitle.Position = UDim2.new(0, 12, 0, 0)
tpTitle.BackgroundTransparency = 1
tpTitle.Font = FONT
tpTitle.TextSize = 18
tpTitle.TextColor3 = COLORS.accent
tpTitle.TextXAlignment = Enum.TextXAlignment.Left
tpTitle.Parent = tpFrame
regLang(function() tpTitle.Text = t("teleport") end)
tpTitle.Text = t("teleport")

local tpClose = Instance.new("TextButton")
tpClose.Size = UDim2.new(0, 22, 0, 22)
tpClose.Position = UDim2.new(1, -30, 0, 5)
tpClose.BackgroundColor3 = COLORS.close
tpClose.Text = "X"
tpClose.Font = FONT
tpClose.TextSize = 14
tpClose.TextColor3 = Color3.new(1,1,1)
tpClose.AutoButtonColor = false
tpClose.Parent = tpFrame
Instance.new("UICorner", tpClose).CornerRadius = UDim.new(0, 4)
tpClose.MouseButton1Click:Connect(function()
    tpGui.Enabled = false
    TweenService:Create(blur, TweenInfo.new(0.2), {Size = 0}):Play()
end)

local tpScroll = Instance.new("ScrollingFrame")
tpScroll.Size = UDim2.new(1, -16, 1, -48)
tpScroll.Position = UDim2.new(0, 8, 0, 40)
tpScroll.BackgroundTransparency = 1
tpScroll.BorderSizePixel = 0
tpScroll.ScrollBarThickness = 4
tpScroll.ScrollBarImageColor3 = COLORS.accent
tpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tpScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
tpScroll.Parent = tpFrame
local tpList = Instance.new("UIListLayout", tpScroll)
tpList.Padding = UDim.new(0, 6)

makeDraggable(tpFrame, tpTitle)

local function teleportToPlayer(plr)
    if not plr or plr == LocalPlayer then return end
    if not LocalPlayer.Character or not plr.Character then return end
    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tHRP  = plr.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP or not tHRP then return end
    tpGui.Enabled = false
    setOpen(false)
    myHRP.Anchored = true
    local targetPos = tHRP.CFrame + Vector3.new(3, 0, 3)
    local tw = TweenService:Create(myHRP, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = targetPos})
    tw:Play()
    tw.Completed:Wait()
    task.wait(2)
    if myHRP and myHRP.Parent then myHRP.Anchored = false end
end

local function refreshTpList()
    for _, child in ipairs(tpScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, 0, 0, 52)
            entry.BackgroundColor3 = COLORS.tabOff
            entry.BorderSizePixel = 0
            entry.Parent = tpScroll
            Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 6)
            local av = Instance.new("ImageLabel")
            av.Size = UDim2.new(0, 44, 0, 44)
            av.Position = UDim2.new(0, 4, 0.5, -22)
            av.BackgroundColor3 = COLORS.panel
            av.BorderSizePixel = 0
            av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=150&h=150"
            av.Parent = entry
            Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -100, 1, 0)
            nameLbl.Position = UDim2.new(0, 56, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = plr.Name
            nameLbl.Font = FONT
            nameLbl.TextSize = 13
            nameLbl.TextColor3 = COLORS.text
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = entry
            local goBtn = Instance.new("TextButton")
            goBtn.Size = UDim2.new(0, 40, 0, 30)
            goBtn.Position = UDim2.new(1, -46, 0.5, -15)
            goBtn.BackgroundColor3 = COLORS.accent
            goBtn.Text = "->"
            goBtn.Font = FONT
            goBtn.TextSize = 18
            goBtn.TextColor3 = Color3.new(1,1,1)
            goBtn.AutoButtonColor = false
            goBtn.Parent = entry
            Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0, 5)
            goBtn.MouseButton1Click:Connect(function() teleportToPlayer(plr) end)
            entry.MouseEnter:Connect(function()
                TweenService:Create(entry, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.tabHov}):Play()
            end)
            entry.MouseLeave:Connect(function()
                TweenService:Create(entry, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.tabOff}):Play()
            end)
        end
    end
end

tpBtn.MouseButton1Click:Connect(function()
    refreshTpList()
    tpGui.Enabled = not tpGui.Enabled
    if tpGui.Enabled then
        tpScale.Scale = 0.85
        TweenService:Create(tpScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Scale = 1}):Play()
        TweenService:Create(blur, TweenInfo.new(0.2), {Size = 8}):Play()
    else
        TweenService:Create(blur, TweenInfo.new(0.2), {Size = 0}):Play()
    end
end)
