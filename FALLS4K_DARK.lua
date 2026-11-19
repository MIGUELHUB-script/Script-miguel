repeat task.wait() until game:IsLoaded()
Players = game:GetService("Players")
RunService = game:GetService("RunService")
UIS = game:GetService("UserInputService")
Lighting = game:GetService("Lighting")
HS = game:GetService("HttpService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
TS_G = game:GetService("TweenService")
LP = Players.LocalPlayer
camera = workspace.CurrentCamera
CONFIG_FILE = "FALLS4K.json"
DISCORD_INVITE_URL = "https://discord.gg/bgsmy5ReNh"
PUREN_DUELS_IMAGE_URL = nil
PUREN_DUELS_IMAGE_FILE = nil
PUREN_DUELS_SANTA_URL = nil
PUREN_DUELS_SANTA_FILE = nil

local function resolvePurenDuelsImage()
    return nil
end

local function resolvePurenDuelsSantaAsset()
    return nil
end

local function decoratePurenChristmasButton(button)
    -- Decoración navideña desactivada para FALLS4K.
end

local function addPurenChristmasDecorations(parent, compact)
    -- Guirnaldas, luces y copos navideños desactivados.
end

HUB_COLOR_OPTIONS = {"original", "gold", "violet"}
DEFAULT_HUB_COLOR = HUB_COLOR_OPTIONS[1]


-- Identidade visual compartilhada: mantém o nome e os créditos originais.
DaHubBrandStyle = {
    text = "FALLS4K",
    fontMode = "original",
    labels = setmetatable({}, {__mode = "k"}),
    silver = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 160, 170)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(225, 230, 240)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(225, 230, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(155, 160, 170)),
    }),
}
function DaHubBrandStyle.apply(label)
    DaHubBrandStyle.labels[label] = label:GetAttribute("DaHubBaseTitleSize") or label.TextSize
    label:SetAttribute("DaHubBaseTitleSize", DaHubBrandStyle.labels[label])
    label.Font = DaHubBrandStyle.fontMode == "balloon" and Enum.Font.FredokaOne or Enum.Font.GothamBlack
    label.TextSize = DaHubBrandStyle.labels[label] * (DaHubBrandStyle.fontMode == "balloon" and 1.2 or 1)
    label.TextWrapped = false
    local sizeLimit = label:FindFirstChild("DaHubTitleSizeLimit") or Instance.new("UITextSizeConstraint", label)
    sizeLimit.Name = "DaHubTitleSizeLimit"
    sizeLimit.MinTextSize = 10
    sizeLimit.MaxTextSize = label.TextSize
    label.TextScaled = true
    local gradient = label:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", label)
    gradient.Name = "DaHubBrandShine"
    gradient.Color = DaHubBrandStyle.silver
    gradient.Rotation = 0
    -- Brilho prateado estático: evita um tween infinito para cada título.
end

function DaHubBrandStyle.setFont(mode, shouldSave)
    DaHubBrandStyle.fontMode = mode == "balloon" and "balloon" or "original"
    for label, baseSize in pairs(DaHubBrandStyle.labels) do
        if label.Parent then
            label.Font = DaHubBrandStyle.fontMode == "balloon" and Enum.Font.FredokaOne or Enum.Font.GothamBlack
            label.TextSize = baseSize * (DaHubBrandStyle.fontMode == "balloon" and 1.2 or 1)
            local limit = label:FindFirstChild("DaHubTitleSizeLimit")
            if limit then limit.MaxTextSize = label.TextSize end
        end
    end
    if S and S.refreshHubFontSelection then S.refreshHubFontSelection() end
    if shouldSave and saveConfig then saveConfig() end
end

-- INTRO AUTÓNOMA CON MÚSICA
-- Ejecutable en Roblox/Luau. Muestra la intro completa y permite omitirla
-- tocando o haciendo clic en cualquier parte.


-- Música de la intro. Se detiene al tocar “TAP ANYWHERE TO SKIP”.
INTRO_MUSIC_URL = "https://files.catbox.moe/y4q5y3.mp3"
INTRO_MUSIC_FILE = "cleanhub_intro_song_14.mp3"
INTRO_MUSIC_VOLUME = 1
SoundService = game:GetService("SoundService")

local function resolveIntroMusicId()
    local assetGetter = getcustomasset or getsynasset
    if type(assetGetter) == "function" and type(writefile) == "function" then
        local exists = false
        if type(isfile) == "function" then
            pcall(function() exists = isfile(INTRO_MUSIC_FILE) end)
        end
        if not exists then
            local ok, data = pcall(function() return game:HttpGet(INTRO_MUSIC_URL) end)
            if ok and type(data) == "string" and #data > 0 then
                pcall(writefile, INTRO_MUSIC_FILE, data)
            end
        end
        local ok, asset = pcall(assetGetter, INTRO_MUSIC_FILE)
        if ok and asset then return asset end
    end
    return INTRO_MUSIC_URL
end

-- Valores usados por la animación original.
v76 = {
    [1]=12, [6]=32, [10]=0.15, [13]=0.4, [14]=6, [20]=3,
    [26]=255, [31]=5, [37]=22, [52]=100, [58]=1, [72]=60,
    [89]=2, [94]="Frame", [95]=4, [100]=10, [104]=false,
    [150]="TextButton", [164]=0.5, [168]=1, [175]=0, [187]=6, [198]=true,
}
_G._VantaSkipIntro = false
_G._VantaIntroActive = true

									local function showIntro(onFinished)
									local introSound
									local function stopIntroMusic()
										if introSound then
											pcall(function() introSound:Stop() end)
											pcall(function() introSound:Destroy() end)
											introSound = nil
										end
									end

										if _G._VantaLoadIntroCleanup then
											pcall(_G._VantaLoadIntroCleanup)
										end


										local flag19 = UIS.TouchEnabled and not UIS.KeyboardEnabled
										local playerGui = LP:WaitForChild("PlayerGui")
										local vantaLoadIntro = playerGui:FindFirstChild("VantaLoadIntro")

										if vantaLoadIntro then
											vantaLoadIntro:Destroy()
										end

										local vantaLoadIntroBlur = Lighting:FindFirstChild("VantaLoadIntroBlur")

										if vantaLoadIntroBlur then
											vantaLoadIntroBlur:Destroy()
										end

										local screenGui = Instance.new("ScreenGui")
										screenGui.Name = "VantaLoadIntro"

										if _G._VantaMountOnTop then
											_G._VantaMountOnTop(screenGui, 1000005)
										else
											screenGui.ResetOnSpawn = v76[104]
											screenGui.DisplayOrder = 1000005
											screenGui.Parent = playerGui
										end

										screenGui.IgnoreGuiInset = true

										introSound = Instance.new("Sound")
										introSound.Name = "VantaIntroMusic"
										introSound.SoundId = resolveIntroMusicId()
										introSound.Volume = INTRO_MUSIC_VOLUME
										introSound.Looped = false
										introSound.Parent = SoundService
										pcall(function() introSound:Play() end)
										local instance = Instance.new(v76[94])
										instance.BackgroundColor3 = Color3.fromRGB(54, 8, 14)
										instance.BackgroundTransparency = 1
										instance.BorderSizePixel = 0
										instance.Size = UDim2.fromScale(1, 1)
										instance.ZIndex = 1000
										instance.Parent = screenGui
										addPurenChristmasDecorations(instance, false)

										-- Papai Noel atravessa a intro de um lado ao outro.

										local frame = Instance.new("Frame")
										frame.Name = "MovingStars"
										frame.BackgroundTransparency = 1
										frame.BorderSizePixel = v76[175]
										frame.Size = UDim2.fromScale(1, 1)
										frame.ClipsDescendants = v76[198]
										frame.ZIndex = 1001
										frame.Parent = instance
										frame.Visible = false -- FALLS4K: efecto navideño desactivado
										local tbl24 = {}
										local n32 = 0 -- FALLS4K: sin copos navideños

										for i = 1, n32 do
											local frame2 = Instance.new("Frame")
											frame2.BackgroundColor3 = i % 5 == 0 and Color3.fromRGB(255, 213, 92) or Color3.fromRGB(248, 248, 255)
											frame2.BackgroundTransparency = v76[168]
											frame2.BorderSizePixel = 0
											frame2.AnchorPoint = Vector2.new(0.5, 0.5)
											frame2.Size = UDim2.fromOffset(i % 9 == 0 and 3 or v76[89], i % 9 == 0 and 3 or 2)
											frame2.ZIndex = 1001
											frame2.Parent = frame
											local uiCorner = Instance.new("UICorner")
											uiCorner.CornerRadius = UDim.new(1, 0)
											uiCorner.Parent = frame2

											tbl24[i] = {
												frame = frame2,
												x = i * 37 % 101 / v76[52],
												y = i * 61 % 101 / 100,
												speed = 0.008 + i % v76[31] * 0.004,
												phase = i * 0.83,
												opacity = 0.35 + i % v76[95] * 0.1,
											}
										end

										local frame2 = Instance.new("Frame")
										frame2.Name = "VantaWordmark"
										frame2.BackgroundTransparency = v76[168]
										frame2.BorderSizePixel = 0
										frame2.AnchorPoint = Vector2.new(0.5, 0.5)
										frame2.Position = UDim2.fromScale(0.5, 0.43)
										frame2.Size = flag19 and UDim2.fromOffset(340, 105) or UDim2.fromOffset(820, 230)
										frame2.ClipsDescendants = false
										frame2.ZIndex = 1003
										frame2.Parent = instance
										local uiScale = Instance.new("UIScale")
										uiScale.Scale = 0.86
										uiScale.Parent = frame2
										local tbl25 = {}

										local tbl26 = {
											id = 116838820706368,
											from = Vector2.new(-v76[13], 0.2),
											final = Vector2.new(0.08, 0.5),
											rotation = -v76[6],
											delay = 0.02,
										}

										local tbl27 = {
											id = 100562870418590,
											from = Vector2.new(0.3, -0.55),
											final = Vector2.new(0.245, 0.5),
											rotation = 20,
											delay = 0.12,
										}

										local tbl28 = {
											id = 139374055352240,
											from = Vector2.new(1.42, 0.3),
											final = Vector2.new(0.41, 0.5),
											rotation = -22,
											delay = 0.22,
										}

										local tbl29 = {
											id = 102192810852440,
											from = Vector2.new(0.68, 1.55),
											final = Vector2.new(0.575, 0.5),
											rotation = 27,
											delay = 0.32,
										}

										local tbl30 = {
											id = 112072591999551,
											from = Vector2.new(1.48, -0.42),
											final = Vector2.new(0.74, 0.5),
											rotation = 18,
											delay = 0.42,
										}
										local tbl32 = {
											id = 92498386894715,
											from = Vector2.new(-0.35, 1.35),
											final = Vector2.new(0.905, 0.5),
											rotation = -14,
											delay = 0.52,
										}

										for i = 1, #DaHubBrandStyle.text do
										    local source = ({tbl26, tbl27, tbl28, tbl29, tbl30, tbl32})[(i - 1) % 6 + 1]
										    tbl25[i] = {
										        from = source.from,
										        final = Vector2.new((i - 0.5) / #DaHubBrandStyle.text, 0.5),
										        rotation = source.rotation,
										        delay = (i - 1) * 0.06,
										    }
										end
										local tbl31 = {}

										for i, v94 in ipairs(tbl25) do
											local frame3 = Instance.new("Frame")
											frame3.BackgroundTransparency = 1
											frame3.BorderSizePixel = 0
											frame3.AnchorPoint = Vector2.new(0.5, 0.5)
											frame3.Position = UDim2.fromScale(v94.from.X, v94.from.Y)
											frame3.Size = UDim2.fromScale(1 / #DaHubBrandStyle.text, v76[168])
											frame3.Rotation = v94.rotation
											frame3.ZIndex = 1003 + i
											frame3.Parent = frame2
											local imageLabel = Instance.new("TextLabel")
											imageLabel.BackgroundTransparency = 1
											imageLabel.BorderSizePixel = 0
											imageLabel.Text = string.sub(DaHubBrandStyle.text, i, i)
											imageLabel.Font = Enum.Font.GothamBlack
											imageLabel.TextScaled = true
											imageLabel.TextColor3 = Color3.fromRGB(255, 246, 220)
											imageLabel.TextTransparency = v76[168]
											imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
											imageLabel.Position = UDim2.fromScale(0.5, 0.5)
											imageLabel.Size = UDim2.fromScale(1, v76[168])
											imageLabel.ZIndex = 1004 + i
											imageLabel.Parent = frame3
											imageLabel.TextSize = flag19 and 100 or 230
											DaHubBrandStyle.apply(imageLabel)
                                            DaHubBrandStyle.apply(imageLabel)
											tbl31[i] = { slot = frame3, image = imageLabel, spec = v94 }
										end

										local textLabel = Instance.new("TextLabel")
										textLabel.BackgroundTransparency = v76[168]
										textLabel.Text = "TAP ANYWHERE TO SKIP"
										textLabel.TextColor3 = Color3.fromRGB(240, 240, 244)
										textLabel.TextTransparency = 1
										textLabel.TextSize = flag19 and 16 or 20
										textLabel.Font = Enum.Font.GothamMedium
										textLabel.AnchorPoint = Vector2.new(0.5, v76[164])
										textLabel.Position = flag19 and UDim2.new(0.5, 0, 0.43, 82) or UDim2.new(0.5, 0, 0.43, 155)
										textLabel.Size = UDim2.new(0.8, 0, 0, 24)
										textLabel.ZIndex = 1010
										textLabel.Parent = instance
										local textLabel2 = Instance.new("TextLabel")
										textLabel2.BackgroundTransparency = 1
										textLabel2.Text = "by Davy..."
										textLabel2.TextColor3 = Color3.fromRGB(166, 168, 178)
										textLabel2.TextTransparency = 1
										textLabel2.TextSize = flag19 and 14 or 18
										textLabel2.Font = Enum.Font.GothamMedium
										textLabel2.AnchorPoint = Vector2.new(0.5, v76[164])
										textLabel2.Position = flag19 and UDim2.new(0.5, 0, 0.43, 102) or UDim2.new(0.5, 0, 0.43, 183)
										textLabel2.Size = UDim2.new(0.8, 0, 0, 22)
										textLabel2.ZIndex = 1010
										textLabel2.Parent = instance
										local instance2 = Instance.new(v76[150])
										instance2.BackgroundTransparency = 1
										instance2.Text = ""
										instance2.AutoButtonColor = false
										instance2.Size = UDim2.fromScale(v76[168], 1)
										instance2.ZIndex = 1011
										instance2.Parent = instance
										local blurEffect = Instance.new("BlurEffect")
										blurEffect.Name = "VantaLoadIntroBlur"
										blurEffect.Size = v76[175]
										blurEffect.Parent = Lighting
										local flag20 = true
										local flag21 = false

										local function fn33(arg2)
											local n33 = math.clamp(arg2, 0, v76[168])
											return n33 * n33 * (v76[20] - 2 * n33)
										end

										local function fn34(arg2, arg3, arg4, arg5)
											local n33 = 1 - arg5
											return Vector2.new(n33 * n33 * arg2.X + v76[89] * n33 * arg5 * arg3.X + arg5 * arg5 * arg4.X, n33 * n33 * arg2.Y + 2 * n33 * arg5 * arg3.Y + arg5 * arg5 * arg4.Y)
										end

										local function fn35()
											if flag21 then
												return
											end
											flag21 = true
											flag20 = false
											stopIntroMusic()
											local tweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)


											TS_G:Create(instance, tweenInfo, { BackgroundTransparency = 1 }):Play()
											TS_G:Create(uiScale, tweenInfo, { Scale = 0.72 }):Play()
											TS_G:Create(blurEffect, tweenInfo, { Size = 0 }):Play()
											TS_G:Create(textLabel, tweenInfo, { TextTransparency = v76[168] }):Play()
											TS_G:Create(textLabel2, tweenInfo, { TextTransparency = 1 }):Play()

											for _, v94 in ipairs(tbl24) do
												TS_G:Create(v94.frame, tweenInfo, { BackgroundTransparency = 1 }):Play()
											end

											for _, v94 in ipairs(tbl31) do
												TS_G:Create(v94.image, tweenInfo, { TextTransparency = 1 }):Play()
											end

											task.delay(0.42, function()
												if screenGui.Parent then
													screenGui:Destroy()
												end

												if blurEffect.Parent then
													blurEffect:Destroy()
												end

												_G._VantaLoadIntroCleanup = nil

												if onFinished then
													onFinished()
												end
											end)
										end

										_G._VantaLoadIntroCleanup = function()
											flag20 = v76[104]
											flag21 = true
											stopIntroMusic()


											if screenGui.Parent then
												screenGui:Destroy()
											end

											if blurEffect.Parent then
												blurEffect:Destroy()
											end
										end

										instance2.Activated:Connect(fn35)
										TS_G:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.5 }):Play()
										TS_G:Create(blurEffect, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 10 }):Play()
										TS_G:Create(textLabel, TweenInfo.new(0.25), { TextTransparency = 0.22 }):Play()
										TS_G:Create(textLabel2, TweenInfo.new(0.25), { TextTransparency = 0.18 }):Play()

										task.spawn(function()
											local now2 = os.clock()

											while flag20 and not flag21 do
												local n33 = os.clock() - now2
												local v94 = fn33((n33 - 0.38) / 0.9)
												local n34 = math.sin(n33 * 1.62) * v94
												local n35 = math.sin(n33 * 3.24) * v94
												uiScale.Scale = 0.86 + fn33(n33 / 0.78) * 0.14 + n34 * 0.012
												local v95 = fn33(n33 / 0.42)

												for _, v96 in ipairs(tbl24) do
													local n36 = (v96.x + n33 * v96.speed) % 1.12 - 0.06
													local n37 = v96.y + math.sin(n33 * 0.78 + v96.phase) * 0.012
													local n38 = (math.sin(n33 * v76[89] + v96.phase) + 1) * 0.5
													v96.frame.Position = UDim2.fromScale(n36, n37)
													v96.frame.BackgroundTransparency = v76[168] - v95 * (v96.opacity + n38 * v76[10])
												end

												for i, v96 in ipairs(tbl31) do
													local spec = v96.spec
													local n36 = i - 3
													local n37 = math.abs(n36) / 2
													local n38 = math.clamp((n33 - spec.delay) / 0.96, 0, 1)
													local n39 = 1 - (v76[168] - n38) ^ 3
													local v97 = fn34(spec.from, Vector2.new((spec.from.X + spec.final.X) * 0.5 - n36 * 0.08, (spec.from.Y + spec.final.Y) * 0.5 + (i % v76[89] == 0 and -0.23 or 0.23)), spec.final, n39)
													v96.slot.Position = UDim2.fromScale(v97.X + n36 * n34 * 0.009, v97.Y + (n37 * n37 * v76[1] - v76[14]) * n34 / 230 + n35 * (1 - n37) * 2.4 / 230)
													v96.slot.Size = UDim2.fromScale(0.16 * (v76[168] + n34 * (0.035 + n37 * 0.055)), 1 - n34 * (0.028 + n37 * 0.045))
													v96.slot.Rotation = spec.rotation * (v76[168] - n39) + n36 * n34 * 5.8 + n35 * (v76[168] - n37) * 0.8
													local v98 = math.sin(n33 * 2.85 + i * 0.82)
													local v99 = math.sin(n33 * 2.1 + i * 0.64)
													v96.image.Position = UDim2.new(0.5, 0, 0.5, v99 * 1.35)
													v96.image.Size = UDim2.fromScale(1 + v98 * 0.026, 1 - v98 * 0.038)
													v96.image.Rotation = v99 * 0.9
													v96.image.TextTransparency = 1 - fn33((n38 - 0.02) / 0.18)
												end

												RunService.RenderStepped:Wait()
											end
										end)

										task.delay(v76[100], fn35)
									end

local function clearOldDaHubInterface()
    if type(_G._DaHubBatBypassCleanup) == "function" then
        pcall(_G._DaHubBatBypassCleanup)
        _G._DaHubBatBypassCleanup = nil
    end
    local playerGui = LP:WaitForChild("PlayerGui")
    local roots = {playerGui}
    local coreOk, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if coreOk and coreGui then table.insert(roots, coreGui) end

    for _, root in ipairs(roots) do
        for _, guiName in ipairs({"DaHub", "DaHubStealHUD", "StealBarMovableSmall", "DaHub_FloatingPanel", "FloatingModeMenu", "BrainrotIntroGui"}) do
            local oldGui = root:FindFirstChild(guiName)
            if oldGui then pcall(function() oldGui:Destroy() end) end
        end
    end

    local character = LP.Character
    local head = character and character:FindFirstChild("Head")
    local oldBillboard = head and head:FindFirstChild("DaHubSpeedBB")
    if oldBillboard then oldBillboard:Destroy() end
end

clearOldDaHubInterface()

removedAccessories = {}

local function removeCharacterAccessories()
    local char = LP.Character
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or (child:IsA("Model") and child:FindFirstChild("Handle")) then
            table.insert(removedAccessories, {parent = child.Parent, acc = child})
            child.Parent = nil
        end
    end
end

local function restoreAccessories()
    for _, item in ipairs(removedAccessories) do
        if item.acc and not item.acc.Parent then
            item.acc.Parent = item.parent
        end
    end
    removedAccessories = {}
end

local function safeWritefile(path, data) if type(writefile) == "function" then pcall(writefile, path, data) end end
local function safeReadfile(path) if type(readfile) == "function" then local ok, data = pcall(readfile, path) return ok and data or nil end return nil end
local function safeIsfile(path) if type(isfile) == "function" then local ok, res = pcall(isfile, path) return ok and res end return false end
local function safeSetfpscap(v) if type(setfpscap) == "function" then pcall(setfpscap, v) end end
local function safeSethiddenproperty(obj, prop, val) if type(sethiddenproperty) == "function" then pcall(sethiddenproperty, obj, prop, val) end end

S = {
    espEnabled = false, espPlayerCache = {players = {}, addConn = nil, remConn = nil, colorConn = nil, _colorAcc = 0}, setESPVisual = nil,
    NS = 70, CS = 45, LS = 22, LCS = 22,
    speedMode = false, laggerMode = 0,
    antiRagdollEnabled = false, medusaCounterEnabled = false,
    medusaDebounce = false, medusaLastUsed = 0, medusaConns = {}, MEDUSA_COOLDOWN = 25,
    unwalkEnabled = false,
    autoLeftEnabled = false, autoRightEnabled = false,
    autoLeftSetVisual = nil, autoRightSetVisual = nil,
    _btnAAL = nil, _bsAAL = nil, _l1AAL = nil, _l2AAL = nil,
    _btnAAR = nil, _bsAAR = nil, _l1AAR = nil, _l2AAR = nil,
    _btnBAT = nil, _bsBAT = nil, _l1BAT = nil, _l2BAT = nil,
    _setPButtonActive = nil, speedCounterLabel = nil, speedDiscordLabel = nil, speedLabelLastUpdate = 0,
    batBypassEnabled = false, setBatBypassVisual = nil,
    informationE01Enabled = true, setInformationE01Visual = nil,
    batAimbotEnabled = false, batAimbotSetVisual = nil, batAimbotConn = nil,
    tpBatEnabled = false, tpBatSetVisual = nil, tpBatConn = nil, tpBatHitCooldown = false,
    tpBatAntiDieConnections = {}, batTpEnabled = false, _smartBatTpDriving = false,
    autoSwingEnabled = true, autoBatEquippedThisRun = false,
    _autoBatTarget = nil, _autoBatLastScan = 0,
    resetAutoBatMotion = nil,
    batCounterEnabled = false, batCounterConn = nil, batCounterDebounce = false,
    setBatCounterVisual = nil,
    medusaSkinMode = "Off", medusaSkinSelectorLabel = nil,
    batSkinMode = "Off", batSkinSelectorLabel = nil, batSkinConnections = {},
    displaySkin = "Off", displaySkinSelectorLabel = nil, customSkinEnabled = false, _skinApplyToken = 0,
    fpsBoostEnabled = false,
    lockUIEnabled = false,
    mainMenuFrame = nil, miniToggleButton = nil, floatingPanelFrame = nil, floatingPanelGui = nil,
    _floatingButtonInfos = nil, _floatingFreeButtonLayer = nil, _floatingUpdateLayout = nil,
    mainGuiScaleObj = nil, floatingGuiScaleObj = nil,
    hubColor = DEFAULT_HUB_COLOR,
    optimizerMode = "standard", setTripaVisual = nil,
    _noclipTimer = 0, _fpsCount = 0, _lastFpsTime = tick(), currentFPS = 0,
    alConn = nil, arConn = nil, alPhase = 1, arPhase = 1,
    progressFill = nil, progressPct = nil, progressBarFrame = nil, topBarHUD = nil, stealHudCard = nil,
    stealActive = false,
    setLaggerVisual = nil, speedClk = nil, setFpsVisual = nil,
    setAntiRagVisual = nil, setMedusaVisual = nil,
    setUnwalkVisual = nil, setDarkVisual = nil, setInstaGrab = nil,
    normalBox = nil, carryBox = nil, laggerBox = nil,
    radInput = nil, setLockUI_Visual = nil, setHideOpiumButtons = nil,
    holdJumpEnabled = false, holdJumpConn = nil, setHoldJumpVisual = nil,
    stealDurationBox = nil,
    hudBgLabel = nil,
    hudBarPos = nil,
    dropBrainrotActive = false,
    dropMode = 1, -- Drakon: 1 = Fling, 2 = Jump Drop
    lastDropTime = 0,
    _dropSpeedMode = nil,
    _dropLaggerMode = nil,
    tpDownHeightTrigger = 20,
    Steal = {
        AutoStealEnabled = false, StealRadius = 61, StealDuration = 1.3,
        Data = {}, plotCache = {}, plotCacheTime = {}, cachedPrompts = {}, promptCacheTime = 0,
        isStealing = false, stealStartTime = nil, lastStealTick = 0,
    },
    KB = {
        DropBrainrot = {kb = Enum.KeyCode.X, gp = Enum.KeyCode.ButtonR2},
        AutoLeft = {kb = Enum.KeyCode.Z, gp = Enum.KeyCode.DPadLeft},
        AutoRight = {kb = Enum.KeyCode.C, gp = Enum.KeyCode.DPadRight},
        AutoBat = {kb = Enum.KeyCode.E, gp = Enum.KeyCode.ButtonY},
        BatBypass = {kb = Enum.KeyCode.V, gp = Enum.KeyCode.ButtonB},
        TPFlor = {kb = Enum.KeyCode.F, gp = Enum.KeyCode.ButtonA},
        GuiHide = {kb = Enum.KeyCode.LeftControl, gp = Enum.KeyCode.ButtonSelect},
        SpeedToggle = {kb = Enum.KeyCode.Q, gp = Enum.KeyCode.DPadUp},
        LaggerToggle = {kb = Enum.KeyCode.R, gp = Enum.KeyCode.DPadDown},
    },
    AP = {
        L1 = Vector3.new(-476.47, -6.28, 92.73), L2 = Vector3.new(-483.12, -4.95, 94.81),
        L_FACE = Vector3.new(-482.25, -4.96, 92.09),
        R1 = Vector3.new(-476.16, -6.52, 25.62), R2 = Vector3.new(-483.06, -5.03, 25.48),
        R_FACE = Vector3.new(-482.06, -6.93, 35.47),
    },
    Conns = {autoSteal = nil, antiRag = nil, anchor = {}, progress = nil},
    moveConn = nil, speedEnabled = true, h = nil, hrp = nil,
    lastMoveDir = Vector3.new(0,0,0),
    MOVE_KEYS = {
        [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
        [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
        [Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true,
        [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true,
    },
    lockMobileButtons = false,
    editMobileButtons = false,
    mobileButtonStyle = "original",
    IS_TOUCH_DEVICE = UIS.TouchEnabled,
    IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled,
    phoneGuiScale = 0.72,
    phoneButtonsScale = 0.86,
    mobileButtonPositions = {},
    mobileButtonRefs = {},
    floatingFreeButtonPositions = {},
    CONFIG_FILE = CONFIG_FILE,
    _floatingButtons = {},
    BAT_HIT_RANGE = 16,
    _holdJumpCooldownUntil = 0,
    holdJumpPressed = false,
    holdJumpActive = false,
    _youtResetInProgress = false,
    antiFlingEnabled = false, setAntiFlingVisual = nil,
    bodyLockEnabled = false, bodyLockRange = 20, bodyLockConnection = nil, bodyLockSetVisual = nil,
    currentAnimPack = "Off", originalAnimPack = nil, animPackConnection = nil, animSelectorLabel = nil,
    antiLagEnabled = false, setAntiLagVisual = nil,
    vividGraphicsEnabled = false, vividEffects = {},
    skyTheme = "Off", skySelectorLabel = nil,
    krobloxMode = "Off", krobloxSelectorLabel = nil,
    stretchEnabled = false, stretchFOV = 120,
    origFOV = nil, stretchConn = nil, stretchFovConn = nil,
}

-- ===== PLAYER ESP (VX7 COMPOSITE: BOX + HIGHLIGHT + SPEED CARD + TRACERS) =====
PLAYER_ESP_COLOR = Color3.fromRGB(255, 255, 255)
PLAYER_ESP_FILL_TRANSPARENCY = 0.7
PLAYER_ESP_OUTLINE_TRANSPARENCY = 0.3
PLAYER_ESP_BIND_NAME = "DaHub_VX7_PlayerESP"

local function ensurePlayerESPGui()
    local cache = S.espPlayerCache
    if cache.screenGui and cache.screenGui.Parent then return cache.screenGui end
    local playerGui = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DaHub_VX7_PlayerESP"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 998
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = playerGui
    cache.screenGui = screenGui
    return screenGui
end

local function removeESPHighlight(playerData)
    if playerData and playerData.highlight then
        pcall(function() playerData.highlight:Destroy() end)
        playerData.highlight = nil
    end
end

local function disconnectESPConnection(playerData, name)
    local connection = playerData and playerData[name]
    if connection then
        pcall(function() connection:Disconnect() end)
        playerData[name] = nil
    end
end

local function removeESPForPlayer(player)
    local cache = S.espPlayerCache
    local data = cache and cache.players[player]
    if not data then return end
    disconnectESPConnection(data, "charConn")
    disconnectESPConnection(data, "charRemovingConn")
    removeESPHighlight(data)
    for _, key in ipairs({"box", "infoFrame", "tracer"}) do
        if data[key] then pcall(function() data[key]:Destroy() end); data[key] = nil end
    end
    data.speedLabel = nil
    data.nameLabel = nil
    cache.players[player] = nil
end

local function clearESP()
    local cache = S.espPlayerCache
    if not cache then return end
    local players = {}
    for player in pairs(cache.players) do table.insert(players, player) end
    for _, player in ipairs(players) do removeESPForPlayer(player) end
end

local function createESPBox(parent)
    local box = Instance.new("Frame")
    box.Name = "VX7_ESPBox2D"
    box.BackgroundColor3 = PLAYER_ESP_COLOR
    box.BackgroundTransparency = 0.75
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 2
    box.Parent = parent
    local stroke = Instance.new("UIStroke")
    stroke.Color = PLAYER_ESP_COLOR
    stroke.Thickness = 1.5
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = box
    return box
end

local function createESPTracer(parent)
    local tracer = Instance.new("Frame")
    tracer.Name = "VX7_ESPTracer"
    tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    tracer.BackgroundColor3 = PLAYER_ESP_COLOR
    tracer.BackgroundTransparency = 0.1
    tracer.BorderSizePixel = 0
    tracer.Visible = false
    tracer.ZIndex = 1
    tracer.Parent = parent
    local stroke = Instance.new("UIStroke", tracer)
    stroke.Color = Color3.fromRGB(20, 20, 24)
    stroke.Thickness = 0.75
    stroke.Transparency = 0.25
    return tracer
end

local function updateESPTracer(tracer, camera, root)
    if not tracer then return end
    tracer.Visible = false
    if not camera or not root then return end
    local target, onScreen = camera:WorldToViewportPoint(root.Position)
    if not onScreen or target.Z <= 0 then return end
    local viewport = camera.ViewportSize
    local originX, originY = viewport.X * 0.5, viewport.Y - 8
    local dx, dy = target.X - originX, target.Y - originY
    local length = math.sqrt(dx * dx + dy * dy)
    if length ~= length or length == math.huge or length < 1 then return end
    tracer.Position = UDim2.fromOffset((originX + target.X) * 0.5, (originY + target.Y) * 0.5)
    tracer.Size = UDim2.fromOffset(length, 2)
    tracer.Rotation = math.deg(math.atan2(dy, dx))
    tracer.BackgroundColor3 = PLAYER_ESP_COLOR
    tracer.Visible = true
end

local function createESPInfoCard(parent, player)
    local root = Instance.new("Frame")
    root.Name = "VX7_EI_" .. tostring(player.UserId)
    root.Size = UDim2.fromOffset(174, 59)
    root.AnchorPoint = Vector2.new(0.5, 1)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Visible = false
    root.Parent = parent

    local avatarBack = Instance.new("Frame")
    avatarBack.Size = UDim2.fromOffset(34, 34)
    avatarBack.Position = UDim2.fromOffset(8, 3)
    avatarBack.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    avatarBack.BorderSizePixel = 0
    avatarBack.Parent = root
    Instance.new("UICorner", avatarBack).CornerRadius = UDim.new(1, 0)

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(1, -4, 1, -4)
    avatar.Position = UDim2.fromOffset(2, 2)
    avatar.BackgroundTransparency = 1
    avatar.ScaleType = Enum.ScaleType.Crop
    avatar.Parent = avatarBack
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok and image and avatar.Parent then avatar.Image = image end
    end)

    local speed = Instance.new("TextLabel")
    speed.Name = "Speed"
    speed.Size = UDim2.new(1, 0, 0, 40)
    speed.Position = UDim2.new(0, 0, 0, 0)
    speed.BackgroundTransparency = 1
    speed.Text = "0.0"
    speed.TextColor3 = PLAYER_ESP_COLOR
    speed.Font = Enum.Font.GothamBlack
    speed.TextSize = 30
    speed.TextXAlignment = Enum.TextXAlignment.Center
    speed.TextYAlignment = Enum.TextYAlignment.Center
    speed.TextStrokeTransparency = 0
    speed.TextStrokeColor3 = Color3.fromRGB(20, 20, 24)
    speed.Parent = root

    local displayName = Instance.new("TextLabel")
    displayName.Name = "DisplayName"
    displayName.Size = UDim2.new(1, 0, 0, 17)
    displayName.Position = UDim2.new(0, 0, 0, 40)
    displayName.BackgroundTransparency = 1
    displayName.Text = player.DisplayName
    displayName.TextColor3 = PLAYER_ESP_COLOR
    displayName.Font = Enum.Font.GothamBold
    displayName.TextSize = 10
    displayName.TextXAlignment = Enum.TextXAlignment.Center
    displayName.TextStrokeTransparency = 0
    displayName.TextStrokeColor3 = Color3.fromRGB(20, 20, 24)
    displayName.Parent = root
    return root, speed, displayName
end

local function setPlayerESPCharacter(playerData, character)
    removeESPHighlight(playerData)
    if not S.espEnabled or not character or not character.Parent then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "VX7_ESPPlayer"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = PLAYER_ESP_FILL_TRANSPARENCY
    highlight.OutlineTransparency = PLAYER_ESP_OUTLINE_TRANSPARENCY
    highlight.FillColor = PLAYER_ESP_COLOR
    highlight.OutlineColor = PLAYER_ESP_COLOR
    pcall(function() highlight:SetAttribute("VX7ESP", true) end)
    highlight.Parent = character
    playerData.highlight = highlight
end

local function watchESPPlayer(player)
    if not player or player == LP then return end
    removeESPForPlayer(player)
    local cache = S.espPlayerCache
    local data = {lastSpeedText = nil}
    cache.players[player] = data
    local screenGui = ensurePlayerESPGui()
    data.box = createESPBox(screenGui)
    data.tracer = createESPTracer(screenGui)
    data.infoFrame, data.speedLabel, data.nameLabel = createESPInfoCard(screenGui, player)
    setPlayerESPCharacter(data, player.Character)

    data.charConn = player.CharacterAdded:Connect(function(character)
        task.delay(0.1, function()
            if S.espEnabled and cache.players[player] == data then
                setPlayerESPCharacter(data, character)
            end
        end)
    end)
    data.charRemovingConn = player.CharacterRemoving:Connect(function(character)
        if data.highlight and data.highlight.Adornee == character then removeESPHighlight(data) end
        if data.box then data.box.Visible = false end
        if data.infoFrame then data.infoFrame.Visible = false end
        if data.tracer then data.tracer.Visible = false end
    end)
end

local function updateESP(deltaTime)
    if not S.espEnabled then return end
    local cache = S.espPlayerCache
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then
        for _, data in pairs(cache.players) do
            if data.tracer then data.tracer.Visible = false end
        end
        return
    end
    cache.infoAccumulator = (cache.infoAccumulator or 0) + (deltaTime or 1 / 60)
    local updateInfo = cache.infoAccumulator >= 1 / 30
    if updateInfo then cache.infoAccumulator = 0 end

    for player, data in pairs(cache.players) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        if character and humanoid and humanoid.Health > 0 and root then
            updateESPTracer(data.tracer, currentCamera, root)
            local headPos = (head and head.Position or root.Position + Vector3.new(0, 1, 0)) + Vector3.new(0, 1.6, 0)
            local footPos = root.Position - Vector3.new(0, 3, 0)
            local topScreen, topOnScreen = currentCamera:WorldToViewportPoint(headPos)
            local bottomScreen, bottomOnScreen = currentCamera:WorldToViewportPoint(footPos)
            if data.box and topOnScreen and bottomOnScreen and topScreen.Z > 0 and bottomScreen.Z > 0 then
                local height = math.abs(bottomScreen.Y - topScreen.Y)
                local width = height * 0.55
                if height == height and width == width and height > 0 then
                    data.box.Size = UDim2.fromOffset(width, height)
                    data.box.Position = UDim2.fromOffset((topScreen.X + bottomScreen.X) * 0.5 - width * 0.5, math.min(topScreen.Y, bottomScreen.Y))
                    data.box.Visible = true
                else
                    data.box.Visible = false
                end
            elseif data.box then
                data.box.Visible = false
            end

            if updateInfo and data.infoFrame and data.speedLabel then
                local cardPos, onScreen = currentCamera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.45, 0))
                if onScreen and cardPos.Z > 0 then
                    data.infoFrame.Position = UDim2.fromOffset(cardPos.X, cardPos.Y)
                    data.infoFrame.Visible = true
                    local velocity = root.AssemblyLinearVelocity
                    local speedText = tostring(math.floor(Vector3.new(velocity.X, 0, velocity.Z).Magnitude * 10 + 0.5) / 10)
                    if data.lastSpeedText ~= speedText then
                        data.lastSpeedText = speedText
                        data.speedLabel.Text = speedText
                    end
                    data.speedLabel.TextColor3 = PLAYER_ESP_COLOR
                else
                    data.infoFrame.Visible = false
                end
            end
            local highlight = data.highlight
            if (not highlight or not highlight.Parent or highlight.Adornee ~= character) and S.espEnabled then
                setPlayerESPCharacter(data, character)
            elseif highlight then
                if highlight.FillColor ~= PLAYER_ESP_COLOR then highlight.FillColor = PLAYER_ESP_COLOR end
                if highlight.OutlineColor ~= PLAYER_ESP_COLOR then highlight.OutlineColor = PLAYER_ESP_COLOR end
            end
        else
            if data.box then data.box.Visible = false end
            if data.infoFrame then data.infoFrame.Visible = false end
            if data.highlight then removeESPHighlight(data) end
            if data.tracer then data.tracer.Visible = false end
        end
    end
end

local function stopESPLoop()
    S.espEnabled = false
    local cache = S.espPlayerCache
    if not cache then return end
    for _, name in ipairs({"addConn", "remConn", "renderConn"}) do
        local connection = cache[name]
        if connection then pcall(function() connection:Disconnect() end); cache[name] = nil end
    end
    if cache.renderBound then
        pcall(function() RunService:UnbindFromRenderStep(PLAYER_ESP_BIND_NAME) end)
        cache.renderBound = false
    end
    clearESP()
    if cache.screenGui then
        pcall(function() cache.screenGui:Destroy() end)
        cache.screenGui = nil
    end
    cache.infoAccumulator = 0
end

local function startESPLoop()
    stopESPLoop()
    S.espEnabled = true
    local cache = S.espPlayerCache
    ensurePlayerESPGui()
    for _, player in ipairs(Players:GetPlayers()) do watchESPPlayer(player) end
    cache.addConn = Players.PlayerAdded:Connect(watchESPPlayer)
    cache.remConn = Players.PlayerRemoving:Connect(removeESPForPlayer)
    local bindOk = pcall(function()
        RunService:BindToRenderStep(PLAYER_ESP_BIND_NAME, Enum.RenderPriority.Camera.Value + 2, updateESP)
    end)
    if bindOk then
        cache.renderBound = true
    else
        cache.renderConn = RunService.RenderStepped:Connect(updateESP)
    end
end

local function toggleESP(on)
    if on then startESPLoop() else stopESPLoop() end
end

SWING_COOLDOWN = 0.25
AUTO_BAT_SPEED, AUTO_BAT_VERT_SPEED, AUTO_BAT_DIST, AUTO_BAT_HEIGHT, AUTO_BAT_V_OFF, AUTO_BAT_TURN_SPEED, AUTO_BAT_MAX_TURN_RATE =
    58, 52, 0.15, 0.35, 0.65, 285, 28

S.ui = function(pcVal, mobVal) return S.IS_MOBILE and mobVal or pcVal end
local function applyPhoneGuiScale(frame, scaleValue, storeKey)
    if not frame then return end
    local scaleObj = frame:FindFirstChild("DaHubPhoneScale")
    if not scaleObj then
        scaleObj = Instance.new("UIScale")
        scaleObj.Name = "DaHubPhoneScale"
        scaleObj.Parent = frame
    end
    scaleObj.Scale = S.IS_TOUCH_DEVICE and scaleValue or 1
    if storeKey then
        S[storeKey] = scaleObj
    end
end
S.getActiveSpeed = function()
    if S.laggerMode == 1 then return S.LS
    elseif S.laggerMode == 2 then return S.LCS
    elseif S.speedMode then return S.CS
    else return S.NS
    end
end
S.getSpeedModeName = function()
    if S.laggerMode == 1 then return "Lagger Normal Speed" end
    if S.laggerMode == 2 then return "Lagger Carry Speed" end
    return S.speedMode and "Carry" or "Normal"
end
S.getAutoPathSpeed = function()
    if S.laggerMode == 1 then return S.LS
    elseif S.laggerMode == 2 then return S.LCS
    else return S.NS end
end

local function isSpeedRagdollState(hum)
    if not hum then return true end
    local st = hum:GetState()
    return hum.PlatformStand
        or st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.FallingDown
end

-- VX7's original speed core: obstacle resolution, step assist, spoof hooks and LV sync.
S._vxSpeedMotion =
	{ smoothed = Vector2.zero, lastMagnitude = 0, stepToken = 0, stepTarget = nil, stepExpires = 0, root = nil }
S._unifiedMovementEnabled = S._unifiedMovementEnabled ~= false
S._vxSpeedCollisionParams = RaycastParams.new()
S._vxSpeedCollisionParams.FilterType = Enum.RaycastFilterType.Exclude
S._vxSpeedCollisionParams.IgnoreWater = true
pcall(function()
	S._vxSpeedCollisionParams.RespectCanCollide = true
end)
function S._vxSpeedPulseVertical(parent, arg, lineVelocity, arg2)
	if not parent or not parent.Parent then
		return
	end
	local name, name2 = arg .. "Attachment", arg .. "LinearVelocity"
	local attachment = parent:FindFirstChild(name)
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = name
		attachment.Parent = parent
	end
	local linearVelocity = parent:FindFirstChild(name2)
	if not linearVelocity then
		linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.Name = name2
		linearVelocity.Attachment0 = attachment
		linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
		linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
		linearVelocity.LineDirection = Vector3.new(0, 1, 0)
		linearVelocity.ForceLimitsEnabled = false
		linearVelocity.Parent = parent
	end
	linearVelocity:SetAttribute("VX7Pulse", {} and (os.clock()) or 0)
	local attribute = linearVelocity:GetAttribute("VX7Pulse")
	linearVelocity.LineVelocity = lineVelocity or 0
	linearVelocity.Enabled = true
	task.delay(arg2 or 0.12, function()
		if not linearVelocity.Parent or linearVelocity:GetAttribute("VX7Pulse") ~= attribute then
			return
		end
		pcall(function()
			linearVelocity:Destroy()
		end)
		if attachment.Parent then
			pcall(function()
				attachment:Destroy()
			end)
		end
	end)
end
function S._vxSpeedCheckRoof(arg, arg2)
	if not arg or not arg.Parent or S._youtResetInProgress or S.dropBrainrotActive then
		return false
	end
	if S.batTpEnabled or S._smartBatTpDriving then
		return false
	end
	local n23 = math.max(arg.AssemblyLinearVelocity.Y, 0)
	if n23 <= 0.25 then
		return false
	end
	local vxSpeedCollisionParams = S._vxSpeedCollisionParams
	vxSpeedCollisionParams.FilterDescendantsInstances = { arg.Parent }
	local n24 = math.clamp(arg2 or 0.016666666666666666, 0.004166666666666667, 0.06666666666666667)
	if
		not workspace:Raycast(
			arg.Position,
			Vector3.new(0, 3.05 + math.min(n23 * n24, 0.9), 0),
			vxSpeedCollisionParams
		)
	then
		return false
	end
	S._vxSpeedClearStep(arg)
	S._vxSpeedPulseVertical(arg, "VX7VampireRoofGuard", 0, 0.14)
	return true
end
function S._vxSpeedClearStep(arg)
	local vxSpeedMotion = S._vxSpeedMotion
	vxSpeedMotion.stepToken = vxSpeedMotion.stepToken + 1
	vxSpeedMotion.stepTarget = nil
	vxSpeedMotion.stepExpires = 0
	if not arg then
		return
	end
	local vX7SpeedStepLinearVelocity = arg:FindFirstChild("VX7SpeedStepLinearVelocity")
	if vX7SpeedStepLinearVelocity then
		pcall(function()
			vX7SpeedStepLinearVelocity:Destroy()
		end)
	end
	local vX7SpeedStepAttachment = arg:FindFirstChild("VX7SpeedStepAttachment")
	if vX7SpeedStepAttachment then
		pcall(function()
			vX7SpeedStepAttachment:Destroy()
		end)
	end
end
function S._vxSpeedRequestStep(root, stepTarget)
	if not root or not root.Parent or not stepTarget or stepTarget <= root.Position.Y + 0.05 then
		return
	end
	local vxSpeedMotion, now3 = S._vxSpeedMotion, os.clock()
	if vxSpeedMotion.stepTarget and vxSpeedMotion.root == root and now3 < vxSpeedMotion.stepExpires then
		vxSpeedMotion.stepTarget = math.max(vxSpeedMotion.stepTarget, stepTarget)
		vxSpeedMotion.stepExpires = math.max(vxSpeedMotion.stepExpires, now3 + 0.32)
		return
	end
	S._vxSpeedClearStep(root)
	vxSpeedMotion.root = root
	vxSpeedMotion.stepTarget = stepTarget
	vxSpeedMotion.stepExpires = now3 + 0.32
	local stepToken = vxSpeedMotion.stepToken
	task.spawn(function()
		while
			vxSpeedMotion.stepToken == stepToken
			and root.Parent
			and root.Parent == LP.Character
			and os.clock() < vxSpeedMotion.stepExpires
		do
			local n23 = (vxSpeedMotion.stepTarget or root.Position.Y) - root.Position.Y
			if n23 <= 0.05 then
				break
			end
			S._vxSpeedCollisionParams.FilterDescendantsInstances = { root.Parent }
			if
				workspace:Raycast(
					root.Position,
					Vector3.new(0, 3.05 + math.min(n23, 2.35), 0),
					S._vxSpeedCollisionParams
				)
			then
				break
			end
			local vX7SpeedStepAttachment = root:FindFirstChild("VX7SpeedStepAttachment")
			if not vX7SpeedStepAttachment then
				vX7SpeedStepAttachment = Instance.new("Attachment")
				vX7SpeedStepAttachment.Name = "VX7SpeedStepAttachment"
				vX7SpeedStepAttachment.Parent = root
			end
			local vX7SpeedStepLinearVelocity = root:FindFirstChild("VX7SpeedStepLinearVelocity")
			if not vX7SpeedStepLinearVelocity then
				vX7SpeedStepLinearVelocity = Instance.new("LinearVelocity")
				vX7SpeedStepLinearVelocity.Name = "VX7SpeedStepLinearVelocity"
				vX7SpeedStepLinearVelocity.Attachment0 = vX7SpeedStepAttachment
				vX7SpeedStepLinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
				vX7SpeedStepLinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
				vX7SpeedStepLinearVelocity.LineDirection = Vector3.new(0, 1, 0)
				vX7SpeedStepLinearVelocity.ForceLimitsEnabled = false
				vX7SpeedStepLinearVelocity.Parent = root
			end
			vX7SpeedStepLinearVelocity.LineVelocity = math.clamp(n23 * 11, 7, 17)
			vX7SpeedStepLinearVelocity.Enabled = true
			RunService.Heartbeat:Wait()
		end
		if vxSpeedMotion.stepToken == stepToken then
			S._vxSpeedClearStep(root)
		end
	end)
end
function S._vxSpeedWalkableStep(arg, arg2, arg3, arg4, arg5)
	if not arg2 or not arg or not arg.Parent or not arg3 or arg3.Magnitude < 0.01 then
		return false
	end
	local vxSpeedCollisionParams = S._vxSpeedCollisionParams
	vxSpeedCollisionParams.FilterDescendantsInstances = { arg.Parent }
	local hit = workspace:Raycast(arg.Position, Vector3.new(0, -7, 0), vxSpeedCollisionParams)
	if not hit or hit.Normal.Y < 0.45 then
		return false
	end
	local n23, n24 =
		math.clamp((arg2.HipHeight or 2) + 0.25, 1.35, 2.35),
		arg.Position + arg3.Unit * (arg5 + math.min(arg4, 0.65) + 0.08)
	arg3 = workspace:Raycast(
		Vector3.new(n24.X, hit.Position.Y + n23 + 0.25, n24.Z),
		Vector3.new(0, -n23 - 0.45, 0),
		vxSpeedCollisionParams
	)
	if not arg3 or arg3.Normal.Y < 0.55 then
		return false
	end
	n24 = arg3.Position.Y - hit.Position.Y
	if n24 > 0.05 and n24 <= n23 then
		return true, arg3.Position.Y + (arg2.HipHeight or 2) + arg.Size.Y * 0.5 + 0.06
	end
	return false
end
function S._vxSpeedResolveHorizontal(arg, arg2, arg3, arg4)
	local vector = Vector3.new(arg3.X, 0, arg3.Z)
	if vector.Magnitude < 0.01 then
		return vector, false, false
	end
	local vxSpeedCollisionParams = S._vxSpeedCollisionParams
	vxSpeedCollisionParams.FilterDescendantsInstances = { arg.Parent }
	local magnitude, n23, n24 =
		vector.Magnitude,
		math.clamp(
			math.max(arg4 or 0.016666666666666666, 0.011111111111111112),
			0.011111111111111112,
			0.06666666666666667
		),
		math.clamp(math.max(arg.Size.X, arg.Size.Z) * 0.5, 0.9, 1)
	arg3, arg4 = S._vxSpeedWalkableStep(arg, arg2, vector, vector.Magnitude * n23, n24)
	if arg3 then
		S._vxSpeedRequestStep(arg, arg4)
	end
	arg3, arg4 = false
	local flag15 = false
	for i = 1, 2, 1 do
		if vector.Magnitude < 0.02 then
			break
		end
		local n25, hit = vector.Magnitude * n23
		if
			not pcall(function()
				hit =
					workspace:Spherecast(arg.Position, n24, vector.Unit * (n25 + 0.03), vxSpeedCollisionParams)
			end)
		then
			hit = workspace:Raycast(arg.Position, vector.Unit * (n25 + n24 + 0.03), vxSpeedCollisionParams)
		end
		if not hit then
			break
		end
		i = math.cos(math.rad(math.clamp(arg2 and arg2.MaxSlopeAngle or 45, 0, 89)))
		if hit.Normal.Y >= i then
			break
		end
		local v45, vector2 = S._vxSpeedWalkableStep(arg, arg2, vector, n25, n24)
		if v45 then
			S._vxSpeedRequestStep(arg, vector2)
			break
		end
		vector2 = Vector3.new(hit.Normal.X, 0, hit.Normal.Z)
		if vector2.Magnitude < 0.05 then
			break
		end
		vector2 = vector2.Unit
		i = vector:Dot(vector2)
		if i >= 0 then
			break
		end
		arg3 = true
		v45 = vector
		if arg4 and arg4:Dot(vector2) < 0.55 then
			vector, flag15 = Vector3.zero, true
			break
		end
		arg4 = arg4 or vector2
		local n26, n27 = v45 - vector2 * i, math.max((hit.Distance or 0) - 0.03, 0)
		vector = n26 - vector2 * math.min(-i, n27 / n23)
	end
	if vector.Magnitude < 0.04 then
		vector = Vector3.zero
	end
	if vector.Magnitude > magnitude then
		vector = vector.Unit * magnitude
	end
	return vector, arg3, flag15
end

		_G.fakeVelocity = Vector3.zero
		_G.spoofedVelocity = _G.fakeVelocity
		fakeVelocity = _G.fakeVelocity
		spoofedVelocity = _G.fakeVelocity
		S._vx7SpoofedVelocity = _G.fakeVelocity
		local humanoidRootPart2, humanoid2
		local function fn86(character2)
			if not character2 then
				humanoidRootPart2, humanoid2 = nil, nil
				S._vxCachedRoot = nil
				S._vxCachedHum = nil
				return
			end
			local ok, result = pcall(character2.WaitForChild, character2, "HumanoidRootPart", 5)
			humanoidRootPart2 = ok and result or (character2:FindFirstChild("HumanoidRootPart"))
			ok, result = pcall(character2.WaitForChild, character2, "Humanoid", 5)
			humanoid2 = ok and result or (character2:FindFirstChildOfClass("Humanoid"))
			S._vxCachedRoot = humanoidRootPart2
			S._vxCachedHum = humanoid2
		end
		if LP.Character then
			task.spawn(fn86, LP.Character)
		end
		LP.CharacterAdded:Connect(fn86)
		LP.CharacterRemoving:Connect(function()
			humanoidRootPart2, humanoid2 = nil, nil
			S._vxCachedRoot = nil
			S._vxCachedHum = nil
		end)
		S._vx7Hooked = false
		function S._vx7SetupHooks()
			if S._vx7Hooked then
				return
			end
			local v45 = getrawmetatable and (getrawmetatable(game))
			if not v45 or type(v45) ~= "table" or not newcclosure then
				return
			end
			local v46, v47 = setreadonly or make_writeable, isreadonly or iswriteable
			S._vx7Hooked = pcall(function()
				if v47 and (v47(v45)) and v46 then
					v46(v45, false)
				elseif v46 then
					v46(v45, false)
				end
				local index, newindex = v45.__index, v45.__newindex
				v45.__index = newcclosure(function(arg, arg2)
					if
						(arg2 == "AssemblyLinearVelocity" or arg2 == "Velocity")
						and not checkcaller()
						and (rawequal(arg, humanoidRootPart2))
					then
						return _G.fakeVelocity
					end
					return index(arg, arg2)
				end)
				v45.__newindex = newcclosure(function(arg, arg2, fakeVelocity_)
					if
						(arg2 == "AssemblyLinearVelocity" or arg2 == "Velocity")
						and not checkcaller()
						and (rawequal(arg, humanoidRootPart2))
					then
						_G.fakeVelocity = fakeVelocity_
						fakeVelocity = fakeVelocity_
						_G.spoofedVelocity = fakeVelocity_
						spoofedVelocity = fakeVelocity_
						S._vx7SpoofedVelocity = fakeVelocity_
						return
					end
					return newindex(arg, arg2, fakeVelocity_)
				end)
				if v46 then
					v46(v45, true)
				end
			end)
		end
		function S._vxSyncSpoof(fakeVelocity_)
			_G.fakeVelocity = fakeVelocity_
			fakeVelocity = fakeVelocity_
			_G.spoofedVelocity = fakeVelocity_
			spoofedVelocity = fakeVelocity_
			S._vx7SpoofedVelocity = fakeVelocity_
		end
		task.spawn(function()
			pcall(S._vx7SetupHooks)
			task.wait(1)
			pcall(S._vx7SetupHooks)
		end)
		local function ensureLV(root)
			pcall(S._vx7SetupHooks)
			S._vxSpeedMotion.root = root
			if S._vxSyncSpoof then
				S._vxSyncSpoof(
					Vector3.new(
						root.AssemblyLinearVelocity.X,
						root.AssemblyLinearVelocity.Y,
						root.AssemblyLinearVelocity.Z
					)
				)
			end
		end
		local function setLV(arg, arg2, arg3, arg4)
			if not arg or not arg.Parent then
				return
			end
			ensureLV(arg)
			local y, vector = arg.AssemblyLinearVelocity.Y, Vector3.new(arg2 or 0, 0, arg3 or 0)
			arg4 = if S._unifiedLastJumpTime and os.clock() - S._unifiedLastJumpTime < 0.15
				then 0
				else if math.abs(y) > 20 then (math.clamp(y, -20, 20)) else y
			if vector.Magnitude > 0.05 then
				arg3, arg2 = math.min(vector.Magnitude, 16), vector.Unit
				if S._vxSyncSpoof then
					S._vxSyncSpoof(Vector3.new(arg2.X * arg3, arg4, arg2.Z * arg3))
				end
				arg.AssemblyLinearVelocity = Vector3.new(vector.X, y, vector.Z)
			elseif S._vxSyncSpoof then
				S._vxSyncSpoof(Vector3.new(0, arg4, 0))
			end
		end
		local function clearLV()
			local root = S._vxSpeedMotion.root
			if S._vxSpeedClearStep then
				S._vxSpeedClearStep(root)
			end
			if S._vxSyncSpoof then
				S._vxSyncSpoof(Vector3.zero)
			end
			S._vxSpeedMotion.smoothed = Vector2.zero
			S._vxSpeedMotion.lastMagnitude = 0
			S._vxSpeedMotion.root = nil
		end
LP.CharacterRemoving:Connect(clearLV)
S._vxClearSpeedVelocity = clearLV
S._vxSetSpeedVelocity = setLV

S._unifiedResolveSpeed = function()
    local ok, speed = pcall(S.getActiveSpeed)
    if ok and type(speed) == "number" then return speed end
    return tonumber(S.NS) or 16
end

saveConfig = nil
updateFloatingButtons = nil

-- Función central para actualizar el botón flotante de Lagger
local function updateLaggerButtonVisual()
    local fb = S._floatingButtons
    if not fb.lagger then return end
    local active = S.laggerMode ~= 0 and not S.speedMode
    fb.l2Lagger.Text = ""
    S._setPButtonActive(fb.lagger, fb.strokeLagger, fb.l1Lagger, fb.l2Lagger, active)
end

S.refreshSpeedModeLabel = function()
    if S.speedClk then S.speedClk(S.speedMode and S.laggerMode == 0) end
    if S.setLaggerVisual then S.setLaggerVisual(S.laggerMode ~= 0) end
    updateLaggerButtonVisual()
    if updateFloatingButtons then updateFloatingButtons() end
end

S.applySpeedVelocityNow = function(deltaTime)
    if S._youtResetInProgress or S.batBypassEnabled then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root or hum.Health <= 0 then return end
    if S._vxSpeedCheckRoof and S._vxSpeedCheckRoof(root, deltaTime or 1 / 60) then
        setLV(root, 0, 0, deltaTime)
        return
    end
    local direction = hum.MoveDirection
    if direction.Magnitude > 0.05 then
        direction = Vector3.new(direction.X, 0, direction.Z)
        local magnitude = direction.Magnitude
        if magnitude > 0.001 then
            direction = direction.Unit
            S.lastMoveDir = direction
            pcall(function() if root.SetNetworkOwner then root:SetNetworkOwner(LP) end end)
            local horizontal = Vector3.new(direction.X * S._unifiedResolveSpeed(), 0, direction.Z * S._unifiedResolveSpeed())
            if S._vxSpeedResolveHorizontal then
                local ok, result = pcall(S._vxSpeedResolveHorizontal, root, hum, horizontal, deltaTime or 1 / 60)
                if ok and typeof(result) == "Vector3" then horizontal = result end
            end
            setLV(root, horizontal.X, horizontal.Z, deltaTime)
        else
            setLV(root, 0, 0, deltaTime)
        end
    else
        setLV(root, 0, 0, deltaTime)
    end
end

S.setNormalSpeedMode = function()
    S.laggerMode = 0
    S.speedMode = false
    S.refreshSpeedModeLabel()
    S.applySpeedVelocityNow()
end

S.setCarrySpeedMode = function()
    S.laggerMode = 0
    S.speedMode = true
    S.refreshSpeedModeLabel()
    S.applySpeedVelocityNow()
end

S.setLaggerNormalMode = function()
    S.speedMode = false
    S.laggerMode = 1
    S.refreshSpeedModeLabel()
    S.applySpeedVelocityNow()
end
S.setLaggerCarryMode = function()
    S.speedMode = false
    S.laggerMode = 2
    S.refreshSpeedModeLabel()
    S.applySpeedVelocityNow()
end

S.setLaggerOffMode = function()
    S.laggerMode = 0
    S.refreshSpeedModeLabel()
end

S.toggleCarryMode = function()
    if S.laggerMode ~= 0 then
        S.laggerMode = 0
        S.speedMode = true
    else
        S.speedMode = not S.speedMode
    end
    S.refreshSpeedModeLabel()
    S.applySpeedVelocityNow()
end

S.toggleLaggerMode = function()
    if S.laggerMode == 2 then
        S.setLaggerNormalMode()
    else
        S.setLaggerCarryMode()
    end
end

S.setupSpeedBillboard = function(char)
    local head = char and (char:FindFirstChild("Head") or char:WaitForChild("Head", 5))
    if not head then return end
    local oldBB = head:FindFirstChild("DaHubSpeedBB")
    if oldBB then oldBB:Destroy() end

    -- Colores tomados del indicador sobre la cabeza de Ace Duels (tema 2):
    -- pale 210,218,228 -> accent 104,116,132 -> accent2 156,169,186.
    local bb = Instance.new("BillboardGui", head)
    bb.Name = "DaHubSpeedBB"
    bb.Size = UDim2.fromOffset(118, 36)
    bb.StudsOffset = Vector3.new(0, 1.75, 0)
    bb.AlwaysOnTop = true
    bb.ResetOnSpawn = false
    bb.LightInfluence = 0
    bb.MaxDistance = 150

    local function addAceGradient(label)
        local gradient = Instance.new("UIGradient", label)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 170, 170)),
        })
        return gradient
    end

    local discordLbl = Instance.new("TextLabel", bb)
    discordLbl.Name = "DiscordBillLbl"
    discordLbl.Size = UDim2.new(1, 0, 0.46, 0)
    discordLbl.BackgroundTransparency = 1
    discordLbl.Text = "FALLS4K"
    discordLbl:SetAttribute("DiscordInviteURL", DISCORD_INVITE_URL)
    discordLbl.Font = Enum.Font.GothamBlack
    discordLbl.TextScaled = true
    discordLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordLbl.TextStrokeTransparency = 0
    discordLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    local discordSize = Instance.new("UITextSizeConstraint", discordLbl)
    discordSize.MinTextSize = 4
    discordSize.MaxTextSize = 12
    DaHubBrandStyle.apply(discordLbl)

    local speedLbl = Instance.new("TextLabel", bb)
    speedLbl.Name = "SpeedBillLbl"
    speedLbl.Size = UDim2.new(1, 0, 0.46, 0)
    speedLbl.Position = UDim2.new(0, 0, 0.54, 0)
    speedLbl.BackgroundTransparency = 1
    speedLbl.Text = "Speed: 0"
    speedLbl.Font = Enum.Font.GothamBlack
    speedLbl.TextScaled = true
    speedLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLbl.TextStrokeTransparency = 0
    speedLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    local speedSize = Instance.new("UITextSizeConstraint", speedLbl)
    speedSize.MinTextSize = 4
    speedSize.MaxTextSize = 12
    addAceGradient(speedLbl)

    S.speedDiscordLabel = discordLbl
    S.speedCounterLabel = speedLbl
end

local function updateSpeedBillboard(hrp)
    if not S.speedCounterLabel then return end
    local now = os.clock()
    if now - S.speedLabelLastUpdate >= 0.12 then
        S.speedLabelLastUpdate = now
        local v = hrp.Velocity
        local flatSpeed = math.sqrt((v.X * v.X) + (v.Z * v.Z))
        S.speedCounterLabel.Text = string.format("Speed: %.1f", flatSpeed)
    end
end


-- Ragdoll Timer tomado únicamente de Ace Duels.
-- Es independiente del indicador de Discord/Speed de DaHub.
daHubRagdollTimer = {
    billboard = nil,
    label = nil,
    character = nil,
    active = false,
    startTime = 0,
    endTime = 0,
    goUntil = 0,
    wasRagdolled = false,
    duration = 2.6,
    connection = nil,
}

local function setupDaHubRagdollTimer(char)
    local head = char and (char:FindFirstChild("Head") or char:WaitForChild("Head", 5))
    if not head then return end
    local old = head:FindFirstChild("DaHubRagdollTimerBB")
    if old then old:Destroy() end
    if daHubRagdollTimer.connection then
        pcall(function() daHubRagdollTimer.connection:Disconnect() end)
        daHubRagdollTimer.connection = nil
    end
    local bb = Instance.new("BillboardGui", head)
    bb.Name = "DaHubRagdollTimerBB"
    bb.Size = UDim2.fromOffset(112, 28)
    bb.StudsOffset = Vector3.new(0, 4.45, 0)
    bb.AlwaysOnTop = true
    bb.ResetOnSpawn = false
    bb.LightInfluence = 0
    bb.MaxDistance = 150
    local label = Instance.new("TextLabel", bb)
    label.Name = "RagdollTimerLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = ""
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    local sizeConstraint = Instance.new("UITextSizeConstraint", label)
    sizeConstraint.MinTextSize = 4
    sizeConstraint.MaxTextSize = 17
    local gradient = Instance.new("UIGradient", label)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 170, 170)),
    })
    daHubRagdollTimer.billboard = bb
    daHubRagdollTimer.label = label
    daHubRagdollTimer.character = char
    daHubRagdollTimer.active = false
    daHubRagdollTimer.startTime = 0
    daHubRagdollTimer.endTime = 0
    daHubRagdollTimer.goUntil = 0
    daHubRagdollTimer.wasRagdolled = false

    local function isRagdolled(humanoid)
        if not humanoid then return false end
        local state = humanoid:GetState()
        return humanoid.PlatformStand
            or state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown
    end

    daHubRagdollTimer.connection = RunService.Heartbeat:Connect(function()
        if daHubRagdollTimer.character ~= char or not bb.Parent or not label.Parent then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            label.Text = ""
            daHubRagdollTimer.active = false
            return
        end
        local now = os.clock()
        local ragdolled = isRagdolled(humanoid)
        if ragdolled and not daHubRagdollTimer.wasRagdolled and not daHubRagdollTimer.active and daHubRagdollTimer.goUntil <= now then
            daHubRagdollTimer.active = true
            daHubRagdollTimer.startTime = now
            daHubRagdollTimer.endTime = now + daHubRagdollTimer.duration
            label.Text = string.format("%.1f", daHubRagdollTimer.duration)
        end
        if daHubRagdollTimer.active then
            local remaining = daHubRagdollTimer.endTime - now
            if remaining <= 0 then
                daHubRagdollTimer.active = false
                daHubRagdollTimer.goUntil = now + 0.65
                label.Text = "GO"
            else
                label.Text = string.format("%.1f", remaining)
            end
        elseif daHubRagdollTimer.goUntil > now then
            label.Text = "GO"
        else
            label.Text = ""
        end
        daHubRagdollTimer.wasRagdolled = ragdolled
    end)
end

-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- Forward declarations used by features defined later in the script.
startAntiRagdoll, stopAntiRagdoll = nil, nil
startBatCounter, stopBatCounter = nil, nil
setBatAimbot = nil
triggerBatCounter = nil
stopDropBrainrot = nil
startAutoLeft, stopAutoLeft, startAutoRight, stopAutoRight = nil, nil, nil, nil

-- Instant Reset adapted from Ace Duels.
-- Uses Ace's pulse/queue/camera flow and DaHub's local guard APIs.
aceInstaResetState = _G._AceInstaResetState or {}
_G._AceInstaResetState = aceInstaResetState

for _, connection in ipairs(aceInstaResetState.connections or {}) do
    pcall(function() connection:Disconnect() end)
end
if aceInstaResetState.cameraConnection then
    pcall(function() aceInstaResetState.cameraConnection:Disconnect() end)
end
aceInstaResetState.connections = {}
aceInstaResetState.cameraConnection = nil
aceInstaResetState.busy = false
aceInstaResetState.busyAt = 0
aceInstaResetState.queued = false
aceInstaResetState.queuedUntil = 0
aceInstaResetState.token = 0
aceInstaResetState.cameraHeld = false
aceInstaResetState.cameraHeldAt = 0
aceInstaResetState.suspended = nil
aceInstaResetState.speed = tonumber(aceInstaResetState.speed) or 1000000

resetHeartbeat = RunService.PreSimulation or RunService.Heartbeat
local function registerResetConnection(connection)
    table.insert(aceInstaResetState.connections, connection)
    return connection
end

local function suspendDaHubGuards()
    local state = {antiRagdoll = false, batCounter = false, batAimbot = false, autoLeft = false, autoRight = false, movement = false}
    if S.antiRagdollEnabled then
        state.antiRagdoll = true
        S.antiRagdollEnabled = false
        if stopAntiRagdoll then pcall(stopAntiRagdoll) end
        if S.setAntiRagVisual then pcall(S.setAntiRagVisual, false) end
    end
    if S.batCounterEnabled then
        state.batCounter = true
        S.batCounterEnabled = false
        if stopBatCounter then pcall(stopBatCounter) end
        if S.setBatCounterVisual then pcall(S.setBatCounterVisual, false) end
    end
    if S.batBypassEnabled and S.setBatBypass then
        state.batBypass = true
        S.setBatBypass(false)
    end
    if S.batAimbotEnabled then
        state.batAimbot = true
        if setBatAimbot then pcall(setBatAimbot, false) end
    end
    if S.autoLeftEnabled then state.autoLeft = true end
    if S.autoRightEnabled then state.autoRight = true end
    if S.moveConn then state.movement = true end
    if state.autoLeft then
        S.autoLeftEnabled = false
        if stopAutoLeft then pcall(stopAutoLeft) end
        if S.autoLeftSetVisual then pcall(S.autoLeftSetVisual, false) end
    end
    if state.autoRight then
        S.autoRightEnabled = false
        if stopAutoRight then pcall(stopAutoRight) end
        if S.autoRightSetVisual then pcall(S.autoRightSetVisual, false) end
    end
    if S.dropBrainrotActive and stopDropBrainrot then pcall(stopDropBrainrot) end
    if S.stopMovement then pcall(S.stopMovement) end
    S._unifiedGamepadHeld = false
    S._unifiedTouchHeld = false
    S.holdJumpPressed = false
    S.holdJumpActive = false
    aceInstaResetState.suspended = state
    return state
end

local function restoreDaHubGuards(state)
    state = state or aceInstaResetState.suspended or {}
    aceInstaResetState.suspended = nil
    if state.antiRagdoll then
        S.antiRagdollEnabled = true
        if startAntiRagdoll then pcall(startAntiRagdoll) end
        if S.setAntiRagVisual then pcall(S.setAntiRagVisual, true) end
    end
    if state.batCounter then
        S.batCounterEnabled = true
        if startBatCounter then pcall(startBatCounter) end
        if S.setBatCounterVisual then pcall(S.setBatCounterVisual, true) end
    end
    if state.batBypass and S.setBatBypass then pcall(S.setBatBypass, true) end
    if state.batAimbot and setBatAimbot then pcall(setBatAimbot, true) end
    if state.autoLeft then
        S.autoLeftEnabled = true
        if startAutoLeft then pcall(startAutoLeft) end
        if S.autoLeftSetVisual then pcall(S.autoLeftSetVisual, true) end
    end
    if state.autoRight then
        S.autoRightEnabled = true
        if startAutoRight then pcall(startAutoRight) end
        if S.autoRightSetVisual then pcall(S.autoRightSetVisual, true) end
    end
    if state.movement and S.startMovement then pcall(S.startMovement) end
    if updateFloatingButtons then pcall(updateFloatingButtons) end
    if saveConfig then pcall(saveConfig) end
end

local function holdResetCamera(oldCharacter)
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then return end
    if aceInstaResetState.cameraHeld and (os.clock() - (aceInstaResetState.cameraHeldAt or 0)) < 5 then return end
    aceInstaResetState.cameraHeld = true
    aceInstaResetState.cameraHeldAt = os.clock()
    local heldCFrame, heldFocus = currentCamera.CFrame, currentCamera.Focus
    pcall(function()
        currentCamera.CameraType = Enum.CameraType.Scriptable
        currentCamera.CFrame = heldCFrame
        currentCamera.Focus = heldFocus
    end)
    aceInstaResetState.cameraConnection = RunService.RenderStepped:Connect(function()
        if workspace.CurrentCamera ~= currentCamera then return end
        pcall(function()
            currentCamera.CameraType = Enum.CameraType.Scriptable
            currentCamera.CFrame = heldCFrame
            currentCamera.Focus = heldFocus
        end)
    end)
    task.spawn(function()
        local elapsed = 0
        while LP.Character == oldCharacter and elapsed < 3 do elapsed += task.wait() end
        if aceInstaResetState.cameraConnection then
            pcall(function() aceInstaResetState.cameraConnection:Disconnect() end)
            aceInstaResetState.cameraConnection = nil
        end
        local newCharacter = LP.Character
        aceInstaResetState.cameraHeld = false
        local newCamera = workspace.CurrentCamera or currentCamera
        if newCamera then
            pcall(function()
                newCamera.CameraType = Enum.CameraType.Custom
                local humanoid = newCharacter and newCharacter:FindFirstChildOfClass("Humanoid")
                if humanoid then newCamera.CameraSubject = humanoid end
            end)
        end
    end)
end

local function releaseResetCamera()
    if aceInstaResetState.cameraConnection then
        pcall(function() aceInstaResetState.cameraConnection:Disconnect() end)
        aceInstaResetState.cameraConnection = nil
    end
    aceInstaResetState.cameraHeld = false
end

local function aceFlingUp(character)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not (root and root:IsA("BasePart")) then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            humanoid.BreakJointsOnDeath = true
            humanoid.PlatformStand = true
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end)
    end
    local velocity = Vector3.new(0, math.clamp(aceInstaResetState.speed, 1000, 10000000), 0)
    local function pulse()
        if not root.Parent then return false end
        return pcall(function()
            root.AssemblyAngularVelocity = Vector3.zero
            root.AssemblyLinearVelocity = velocity
        end)
    end
    if not pulse() then return false end
    task.spawn(function()
        local elapsed = 0
        while elapsed < 1.2 do
            elapsed += resetHeartbeat:Wait()
            if not root.Parent or LP.Character ~= character then return end
            pulse()
        end
    end)
    return true
end

local function aceHardKill(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    pcall(function()
        humanoid.PlatformStand = false
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid.BreakJointsOnDeath = true
        if humanoid.MaxHealth == math.huge or humanoid.MaxHealth <= 0 then humanoid.MaxHealth = 100 end
        humanoid.Health = 0
    end)
    pcall(function() character:BreakJoints() end)
end

local function aceInstantReset()
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not (character and humanoid and root and root:IsA("BasePart")) then
        aceInstaResetState.queued = true
        aceInstaResetState.queuedUntil = os.clock() + 12
        return
    end
    if aceInstaResetState.busy and (os.clock() - (aceInstaResetState.busyAt or 0)) < 5 then return end
    aceInstaResetState.busy = true
    aceInstaResetState.busyAt = os.clock()
    aceInstaResetState.token += 1
    local token = aceInstaResetState.token
    S._youtResetInProgress = true
    local suspended = suspendDaHubGuards()
    task.spawn(function()
        pcall(function()
            holdResetCamera(character)
            if not aceFlingUp(character) then aceHardKill(character) end
            local elapsed = 0
            while LP.Character == character and elapsed < 1.2 do elapsed += task.wait() end
            if LP.Character == character then
                local currentHumanoid = character:FindFirstChildOfClass("Humanoid")
                if currentHumanoid and currentHumanoid.Health > 0 then aceHardKill(character) end
            end
            local waited = 0
            while LP.Character == character and waited < 8 do waited += task.wait() end
        end)
        if aceInstaResetState.token ~= token then return end
        releaseResetCamera()
        aceInstaResetState.busy = false
        S._youtResetInProgress = false
        restoreDaHubGuards(suspended)
    end)
end

registerResetConnection(resetHeartbeat:Connect(function()
    if not aceInstaResetState.busy then return end
    if (os.clock() - (aceInstaResetState.busyAt or 0)) >= 10 then
        aceInstaResetState.busy = false
        releaseResetCamera()
        S._youtResetInProgress = false
        restoreDaHubGuards()
    end
end))

registerResetConnection(LP.CharacterAdded:Connect(function(character)
    if not aceInstaResetState.queued then return end
    if (aceInstaResetState.queuedUntil or 0) < os.clock() then
        aceInstaResetState.queued = false
        return
    end
    aceInstaResetState.queued = false
    task.spawn(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
        local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.15)
        if humanoid and root and humanoid.Health > 0 and LP.Character == character then aceInstantReset() end
    end)
end))

_G._AceInstaReset = aceInstantReset
_G._CandyInstaReset = aceInstantReset
_G._AceInstaResetTune = function(value)
    local number = tonumber(value)
    if number then aceInstaResetState.speed = math.clamp(math.abs(number), 1000, 10000000) end
    return aceInstaResetState.speed
end
_G._CandyInstaResetTune = _G._AceInstaResetTune

_lastRequest = 0
local function sourceInstaResetTrigger()
    local now = os.clock()
    if now - _lastRequest < 0.15 then return end
    _lastRequest = now
    aceInstantReset()
end
_G.InstaReset = {Trigger = sourceInstaResetTrigger}
_G.VynxDoInstaReset = _G.InstaReset.Trigger
_G.daHubInstantReset = _G.InstaReset.Trigger
-- Rebind the camera to the Humanoid whenever the character respawns.
LP.CharacterAdded:Connect(function(character)
    task.defer(function()
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid and character then humanoid = character:WaitForChild("Humanoid", 5) end
        local camera = workspace.CurrentCamera
        if camera and humanoid then
            pcall(function()
                camera.CameraType = Enum.CameraType.Custom
                camera.CameraSubject = humanoid
            end)
        end
    end)
end)

-- Drop Brainrot adaptado do Drakon: Fling (0.30s) e Jump Drop (0.22s).
-- Todos os botões e atalhos existentes continuam usando runDropBrainrot.
DROP_FLING_COOLDOWN_FAST = 0.6
DROP_FLING_COOLDOWN_SLOW = 0.25
local function setDropActive(on)
    S.dropBrainrotActive = on
    if S.dropBrainrotSetVisual then pcall(S.dropBrainrotSetVisual, on) end
    if S.dropBrainrotFloatVisual and S.dropBrainrotFloatVisual ~= S.dropBrainrotSetVisual then
        pcall(S.dropBrainrotFloatVisual, on)
    end
end

stopDropBrainrot = function()
    local finish = S._dropFinish
    if finish then finish(true); return end
    setDropActive(false)
end

LP.CharacterRemoving:Connect(function()
    local finish = S._dropFinish
    if finish then finish(false) end
end)

local function runDropBrainrot()
    if S.dropBrainrotActive or _G.IsDropping or S._youtResetInProgress then return end
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 or root.Anchored then return end
    local mode = S.dropMode == 2 and 2 or 1
    local now = tick()
    if mode == 1 then
        local velocity = root.AssemblyLinearVelocity
        local speedH = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        local cooldown = speedH > 5 and DROP_FLING_COOLDOWN_FAST or DROP_FLING_COOLDOWN_SLOW
        if now - (S.lastDropTime or 0) < cooldown then return end
        S.lastDropTime = now
    end

    local savedSpeed = S.speedMode
    local savedLagger = S.laggerMode
    local savedBat = S.batAimbotEnabled == true
    if savedBat then setBatAimbot(false) end
    setDropActive(true)
    local finished = false
    local worker, timeout, connection
    local finishDrop
    finishDrop = function(restoreCharacter)
        if finished then return end
        finished = true
        if connection then connection:Disconnect(); connection = nil end
        if worker and worker ~= coroutine.running() then pcall(task.cancel, worker) end
        if timeout and timeout ~= coroutine.running() then pcall(task.cancel, timeout) end
        S._dropThread = nil
        S._dropConn = nil
        S._dropFinish = nil
        if restoreCharacter and LP.Character == character and root.Parent then
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                if root.Position.Y < -100 then root.CFrame = CFrame.new(root.Position.X, 5, root.Position.Z) end
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {character}
                params.FilterType = Enum.RaycastFilterType.Exclude
                local hit = workspace:Raycast(root.Position, Vector3.new(0, -2000, 0), params)
                if hit then
                    root.CFrame = CFrame.new(root.Position.X,
                        hit.Position.Y + humanoid.HipHeight + root.Size.Y / 2, root.Position.Z)
                end
                if humanoid.Health > 0 then humanoid:ChangeState(Enum.HumanoidStateType.Running) end
            end)
        end
        S.speedMode = savedSpeed
        S.laggerMode = savedLagger
        setDropActive(false)
        if savedBat then pcall(setBatAimbot, true) end
        if S.refreshSpeedModeLabel then pcall(S.refreshSpeedModeLabel) end
        if restoreCharacter and S.applySpeedVelocityNow then pcall(S.applySpeedVelocityNow) end
        if S.restartMovement then pcall(S.restartMovement) end
        if updateFloatingButtons then pcall(updateFloatingButtons) end
    end
    S._dropFinish = finishDrop

    if mode == 2 then
        connection = RunService.Heartbeat:Connect(function()
            local ok, err = pcall(function()
                if finished then return end
                if LP.Character ~= character or not root.Parent then finishDrop(false); return end
                if tick() - now >= 0.22 then finishDrop(true); return end
                local velocity = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(velocity.X, 160, velocity.Z)
            end)
            if not ok then finishDrop(true); warn("[FALLS4K] Jump Drop: " .. tostring(err)) end
        end)
        S._dropConn = connection
        timeout = task.delay(0.35, function() finishDrop(true) end)
        return
    end

    worker = task.defer(function()
        local ok, err = pcall(function()
            local startedAt = tick()
            while not finished and S.dropBrainrotActive and tick() - startedAt < 0.30 do
                RunService.Heartbeat:Wait()
                if finished or LP.Character ~= character or not root.Parent then break end
                local velocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
                root.AssemblyLinearVelocity = velocity * 10000 + Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                if finished or not root.Parent then break end
                root.AssemblyLinearVelocity = velocity
                RunService.Stepped:Wait()
                if finished or not root.Parent then break end
                root.AssemblyLinearVelocity = velocity + Vector3.new(0, 0.1, 0)
            end
        end)
        finishDrop(LP.Character == character)
        if not ok then warn("[FALLS4K] Fling Drop: " .. tostring(err)) end
    end)
    S._dropThread = worker
    timeout = task.delay(0.35, function() finishDrop(true) end)
end

S.startMovement = function()
    if S.moveConn then S.moveConn:Disconnect(); S.moveConn = nil end
    local movementSignal = RunService.PreSimulation or RunService.Stepped
    S.moveConn = movementSignal:Connect(function(firstDelta, secondDelta)
        local deltaTime = secondDelta or firstDelta or 1 / 60
        if not S.speedEnabled or not S._unifiedMovementEnabled or S._youtResetInProgress then return end
        local char = LP.Character
        local hum = char and (S._vxCachedHum and S._vxCachedHum.Parent and S._vxCachedHum or char:FindFirstChildOfClass("Humanoid"))
        local root = char and (S._vxCachedRoot and S._vxCachedRoot.Parent and S._vxCachedRoot or char:FindFirstChild("HumanoidRootPart"))
        if not char or not hum or not root or hum.Health <= 0 then return end
        S.h, S.hrp = hum, root
        if S.dropBrainrotActive or S.batBypassEnabled then return end
        if S.batAimbotEnabled or S.autoLeftEnabled or S.autoRightEnabled then
            setLV(root, 0, 0, deltaTime)
            return
        end
        local state = hum:GetState()
        if hum.PlatformStand or state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
            S.lastMoveDir = Vector3.zero
            setLV(root, 0, 0, deltaTime)
            return
        end
        if S._vxSpeedCheckRoof and S._vxSpeedCheckRoof(root, deltaTime) then
            setLV(root, 0, 0, deltaTime)
            return
        end
        local direction = hum.MoveDirection
        if direction.Magnitude <= 0.05 and S.antiRagdollEnabled and S.lastMoveDir.Magnitude > 0 then
            for key in pairs(S.MOVE_KEYS) do
                if UIS:IsKeyDown(key) then direction = S.lastMoveDir; break end
            end
        end
        if direction.Magnitude > 0.05 then
            direction = Vector3.new(direction.X, 0, direction.Z)
            local magnitude = direction.Magnitude
            if magnitude > 0.001 then
                direction = direction.Unit
                S.lastMoveDir = direction
                pcall(function() if root.SetNetworkOwner then root:SetNetworkOwner(LP) end end)
                local speed = S._unifiedResolveSpeed()
                local horizontal = Vector3.new(direction.X * speed, 0, direction.Z * speed)
                if S._vxSpeedResolveHorizontal then
                    local ok, result = pcall(S._vxSpeedResolveHorizontal, root, hum, horizontal, deltaTime)
                    if ok and typeof(result) == "Vector3" then horizontal = result end
                end
                setLV(root, horizontal.X, horizontal.Z, deltaTime)
            else
                setLV(root, 0, 0, deltaTime)
            end
        else
            setLV(root, 0, 0, deltaTime)
        end
        updateSpeedBillboard(root)
    end)
end

S.stopMovement = function()
    if S.moveConn then S.moveConn:Disconnect(); S.moveConn = nil end
    if clearLV then clearLV() end
end
S.restartMovement = function() S.stopMovement(); S.startMovement() end
S.speedEnabled = true
S.startMovement()

-- ── Hold Jump (ported from the attached DaHub; standalone Infinite Jump removed) ──
S.holdJumpPower = 55
S.holdJumpMinVelocity = 35
S.holdJumpFallClamp = -120
S._unifiedCanJump = true
S._unifiedLastJumpTime = S._unifiedLastJumpTime or 0
S._unifiedGamepadHeld = false
S._unifiedTouchHeld = false
S._mobileJumpButtonConns = S._mobileJumpButtonConns or {}
S._mobileJumpWatchConn = nil
S._mobileJumpButton = nil

local function clearHoldJump()
    S.holdJumpPressed = false
    S.holdJumpActive = false
    S._unifiedGamepadHeld = false
    S._unifiedTouchHeld = false
end

local function isJumpInputFocused()
    local ok, focused = pcall(function() return UIS:GetFocusedTextBox() end)
    return ok and focused ~= nil
end

local function getHoldJumpParts()
    local character = LP.Character
    if not character then return nil, nil, nil end
    return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

S._unifiedApplyJumpVelocity = function()
    if not S.holdJumpEnabled or not S._unifiedCanJump or S._youtResetInProgress or isJumpInputFocused() then return end
    if S.dropBrainrotActive then return end
    local character, humanoid, root = getHoldJumpParts()
    if not character or not humanoid or not root or humanoid.Health <= 0 then return end

    S._unifiedCanJump = false
    S._unifiedLastJumpTime = os.clock()
    humanoid.Jump = true
    pcall(function() if root.SetNetworkOwner then root:SetNetworkOwner(LP) end end)
    local velocity = root.AssemblyLinearVelocity
    if S._vxSyncSpoof then S._vxSyncSpoof(Vector3.new(velocity.X, 0, velocity.Z)) end
    root.AssemblyLinearVelocity = Vector3.new(velocity.X, S.holdJumpPower, velocity.Z)
    task.delay(0.08, function() S._unifiedCanJump = true end)
end

local function isGamepadInput(input)
    return input.UserInputType.Name:match("^Gamepad%d+$") ~= nil
end

local function bindMobileJumpButton(button)
    for _, connection in ipairs(S._mobileJumpButtonConns) do pcall(function() connection:Disconnect() end) end
    table.clear(S._mobileJumpButtonConns)
    S._unifiedTouchHeld = false
    S._mobileJumpButton = nil
    if not button or not button:IsA("GuiButton") then return end
    S._mobileJumpButton = button
    table.insert(S._mobileJumpButtonConns, button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            S._unifiedTouchHeld = true
            S.holdJumpPressed = true
        end
    end))
    table.insert(S._mobileJumpButtonConns, button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then clearHoldJump() end
    end))
    table.insert(S._mobileJumpButtonConns, button.AncestryChanged:Connect(function(_, parent)
        if not parent then clearHoldJump(); S._mobileJumpButton = nil end
    end))
end

local function findMobileJumpButton()
    local playerGui = LP:FindFirstChildOfClass("PlayerGui")
    local button = playerGui and playerGui:FindFirstChild("JumpButton", true)
    if button and button ~= S._mobileJumpButton then bindMobileJumpButton(button) end
end

local function stopHoldJumpConnections()
    clearHoldJump()
    if S.IJ_JumpConn then S.IJ_JumpConn:Disconnect(); S.IJ_JumpConn = nil end
    if S.IJ_InputBeganConn then S.IJ_InputBeganConn:Disconnect(); S.IJ_InputBeganConn = nil end
    if S.IJ_InputEndedConn then S.IJ_InputEndedConn:Disconnect(); S.IJ_InputEndedConn = nil end
    if S.IJ_HoldConn then S.IJ_HoldConn:Disconnect(); S.IJ_HoldConn = nil end
    if S._mobileJumpWatchConn then S._mobileJumpWatchConn:Disconnect(); S._mobileJumpWatchConn = nil end
    for _, connection in ipairs(S._mobileJumpButtonConns) do pcall(function() connection:Disconnect() end) end
    table.clear(S._mobileJumpButtonConns)
    S._mobileJumpButton = nil
    S._unifiedCanJump = true
end

local function ensureHoldJumpConnections()
    if not S.IJ_JumpConn then
        S.IJ_JumpConn = UIS.JumpRequest:Connect(function()
            if S.holdJumpEnabled and not isJumpInputFocused() then S._unifiedApplyJumpVelocity() end
        end)
    end
    if not S.IJ_InputBeganConn then
        S.IJ_InputBeganConn = UIS.InputBegan:Connect(function(input)
            if isJumpInputFocused() then return end
            if input.KeyCode == Enum.KeyCode.Space and input.UserInputType == Enum.UserInputType.Keyboard then
                S.holdJumpPressed = true
            elseif input.KeyCode == Enum.KeyCode.ButtonA and isGamepadInput(input) then
                S._unifiedGamepadHeld = true
                S.holdJumpPressed = true
            end
        end)
    end
    if not S.IJ_InputEndedConn then
        S.IJ_InputEndedConn = UIS.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space and input.UserInputType == Enum.UserInputType.Keyboard then
                clearHoldJump()
            elseif input.KeyCode == Enum.KeyCode.ButtonA and isGamepadInput(input) then
                S._unifiedGamepadHeld = false
                if not S._unifiedTouchHeld and not UIS:IsKeyDown(Enum.KeyCode.Space) then clearHoldJump() end
            end
        end)
    end
    if not S.IJ_HoldConn then
        S.IJ_HoldConn = RunService.Heartbeat:Connect(function()
            if not S.holdJumpEnabled or S.dropBrainrotActive or S._youtResetInProgress or isJumpInputFocused() then return end
            local character, humanoid, root = getHoldJumpParts()
            if not character or not humanoid or not root or humanoid.Health <= 0 then return end
            local keyboardHeld = false
            pcall(function() keyboardHeld = UIS:IsKeyDown(Enum.KeyCode.Space) end)
            local jumpHeld = keyboardHeld or humanoid.Jump == true or S._unifiedGamepadHeld == true or S._unifiedTouchHeld == true
            local velocity = root.AssemblyLinearVelocity
            if jumpHeld and velocity.Y < S.holdJumpMinVelocity then S._unifiedApplyJumpVelocity() end
            if velocity.Y < S.holdJumpFallClamp then
                local clamped = Vector3.new(velocity.X, S.holdJumpFallClamp, velocity.Z)
                if S._vxSyncSpoof then S._vxSyncSpoof(clamped) end
                root.AssemblyLinearVelocity = clamped
            end
        end)
    end
    if UIS.TouchEnabled then
        local playerGui = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")
        if not S._mobileJumpWatchConn then
            S._mobileJumpWatchConn = playerGui.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "JumpButton" and descendant:IsA("GuiButton") then bindMobileJumpButton(descendant) end
            end)
        end
        task.defer(findMobileJumpButton)
    end
end

local function startHoldJump()
    S.holdJumpEnabled = true
    S.holdJumpMode = true
    ensureHoldJumpConnections()
end

local function stopHoldJump()
    S.holdJumpEnabled = false
    S.holdJumpMode = false
    stopHoldJumpConnections()
end

TP_DOWN_MODE = "full"
S.tpDownHeightTrigger = tonumber(S.tpDownHeightTrigger) or 20

local function tpIsCarryingBrainrot(character)
    if not character then return false end
    if LP:GetAttribute("Stealing") == true or character:GetAttribute("Stealing") == true then return true end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            local name = child.Name:lower()
            if not (name:find("bat") or name:find("slap")) then return true end
        end
    end
    return false
end

local function runTPDownFull()
    pcall(function()
        local character = LP.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end

        local worldPosition = root.Position
        if worldPosition.Y <= -7 then
            root.CFrame = CFrame.new(worldPosition.X, -7, worldPosition.Z)
            root.AssemblyLinearVelocity = Vector3.zero
            return
        end

        local rootOffset = (humanoid.HipHeight or 2) + root.Size.Y * 0.5 + 0.2
        local ignoredNames = {"invis", "wall", "trigger", "barrier", "clip", "ghost"}

        local function hasIgnoredName(instance)
            while instance and instance ~= workspace do
                local name = string.lower(instance.Name or "")
                for _, ignored in ipairs(ignoredNames) do
                    if name:find(ignored, 1, true) then return true end
                end
                instance = instance.Parent
            end
            return false
        end

        local function shouldSkip(instance)
            if instance == workspace.Terrain then return false end
            if not instance or not instance:IsA("BasePart") then return true end
            if not instance.CanCollide then return true end
            if (instance.Transparency or 0) >= 0.75 then return true end
            if (instance.LocalTransparencyModifier or 0) >= 0.75 then return true end
            return hasIgnoredName(instance)
        end

        local function findFloorY(origin)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.IgnoreWater = true
            local filter = {character}
            for _ = 1, 80 do
                params.FilterDescendantsInstances = filter
                local hit = workspace:Raycast(origin, Vector3.new(0, -7 - origin.Y, 0), params)
                if not hit then return nil end
                if not shouldSkip(hit.Instance) then return hit.Position.Y end
                table.insert(filter, hasIgnoredName(hit.Instance) and hit.Instance.Parent or hit.Instance)
            end
            return nil
        end

        local radius = math.max(0.75, math.min(2, math.max(root.Size.X, root.Size.Z) * 0.55))
        local offsets = {
            Vector3.zero,
            Vector3.new(radius, 0, 0), Vector3.new(-radius, 0, 0),
            Vector3.new(0, 0, radius), Vector3.new(0, 0, -radius),
            Vector3.new(radius * 0.7, 0, radius * 0.7),
            Vector3.new(-radius * 0.7, 0, radius * 0.7),
            Vector3.new(radius * 0.7, 0, -radius * 0.7),
            Vector3.new(-radius * 0.7, 0, -radius * 0.7),
        }

        local floorY = findFloorY(worldPosition + Vector3.new(0, 0.25, 0))
        if not floorY then
            for i = 2, #offsets do
                local candidate = findFloorY(worldPosition + offsets[i] + Vector3.new(0, 0.25, 0))
                if candidate and (not floorY or candidate > floorY) then floorY = candidate end
            end
        end

        local targetY = -7
        if floorY then
            local candidateY = floorY + rootOffset
            if worldPosition.Y - 0.35 <= candidateY then return end
            targetY = math.max(candidateY, -7)
        end

        local _, yaw = root.CFrame:ToEulerAnglesYXZ()
        root.CFrame = CFrame.new(worldPosition.X, targetY, worldPosition.Z) * CFrame.Angles(0, yaw, 0)
        root.AssemblyLinearVelocity = Vector3.zero
    end)
end

local function executeTPDown()
    if S.dropBrainrotActive or _G.IsDropping then return end
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not root or not humanoid or humanoid.Health <= 0 or root.Anchored or humanoid.Sit or humanoid.SeatPart then return end
    if TP_DOWN_MODE == "full" then runTPDownFull() end
end

_G._VynxRunTPDown = executeTPDown

-- Yout visual features: Vivid Graphics, Stretch Rez, and Sky Theme.
local function applyStretchFOV(val)
    local cam = workspace.CurrentCamera
    if cam then pcall(function() cam.FieldOfView = val end) end
end

local function enableStretch()
    if S.stretchConn then return end
    S.stretchEnabled = true
    local cam = workspace.CurrentCamera
    if not cam then return end
    S.origFOV = cam.FieldOfView or 70
    applyStretchFOV(S.stretchFOV)
    S.stretchConn = RunService.RenderStepped:Connect(function()
        if not S.stretchEnabled then
            S.stretchConn:Disconnect()
            S.stretchConn = nil
            return
        end
        local c = workspace.CurrentCamera
        if c then c.CFrame = c.CFrame * _CFnew(0,0,0,1,0,0,0,0.7,0,0,0,1) end
    end)
    if S.stretchFovConn then S.stretchFovConn:Disconnect() end
    S.stretchFovConn = RunService.RenderStepped:Connect(function()
        if S.stretchEnabled then applyStretchFOV(S.stretchFOV)
        else S.stretchFovConn:Disconnect(); S.stretchFovConn = nil end
    end)
end

local function disableStretch()
    S.stretchEnabled = false
    if S.stretchConn then S.stretchConn:Disconnect(); S.stretchConn = nil end
    if S.stretchFovConn then S.stretchFovConn:Disconnect(); S.stretchFovConn = nil end
    local cam = workspace.CurrentCamera
    if cam then pcall(function() cam.FieldOfView = S.origFOV or 70 end) end
end

SKY_PRESETS_LIST = {"Off","Night","Aurora","Sunset","Galaxy","Cyber","Sakura","Pink Night","Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse","Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}

SKY_PRESETS = {
    ["Off"]={kind="off"},
    ["Night"]={clock=22,brightness=2,ambient={110,100,130},outAmb={120,110,140},sky={stars=4000,moon=18,sun=0,moonTex=true},atm={dens=0.45,color={120,60,180},decay={60,20,100},glare=0.5,haze=1.2}},
    ["Aurora"]={clock=14,brightness=3,ambient={150,120,150},outAmb={160,130,150},atm={dens=0.55,color={255,80,200},decay={255,20,150},glare=2.5,haze=3},clouds={cover=0.7,dens=0.7,color={255,240,250}}},
    ["Sunset"]={clock=17.2,brightness=2.5,ambient={170,120,100},outAmb={180,130,110},sky={stars=0,sun=25,moon=0},atm={dens=0.5,color={255,130,60},decay={255,80,30},glare=2,haze=2.5},clouds={cover=0.55,dens=0.55,color={255,200,140}}},
    ["Galaxy"]={clock=0,brightness=1.5,ambient={70,60,100},outAmb={80,70,110},sky={stars=10000,moon=30,sun=0},atm={dens=0.15,color={40,20,80},decay={20,10,50},glare=0.3,haze=0.5}},
    ["Cyber"]={clock=21,brightness=2.2,ambient={90,130,170},outAmb={100,140,180},sky={stars=2000,moon=12},atm={dens=0.4,color={0,200,255},decay={150,0,255},glare=2,haze=2},clouds={cover=0.4,dens=0.6,color={100,200,255}}},
    ["Sakura"]={clock=11,brightness=3.5,ambient={170,150,160},outAmb={180,160,170},sky={sun=8},atm={dens=0.3,color={255,200,220},decay={255,170,200},glare=1,haze=1.5},clouds={cover=0.6,dens=0.4,color={255,250,252}}},
    ["Pink Night"]={clock=23,brightness=2.2,ambient={120,60,110},outAmb={140,70,120},sky={stars=5000,moon=22,sun=0,moonTex=true},atm={dens=0.5,color={255,80,180},decay={140,30,100},glare=0.7,haze=1.4},clouds={cover=0.3,dens=0.5,color={180,90,150}}},
    ["Blood Moon"]={clock=22.5,brightness=1.6,ambient={130,40,40},outAmb={150,50,50},sky={stars=1500,moon=28,sun=0,moonTex=true},atm={dens=0.6,color={220,30,30},decay={120,10,10},glare=1.4,haze=2},clouds={cover=0.5,dens=0.7,color={120,30,30}}},
    ["Emerald Dawn"]={clock=6.5,brightness=2.8,ambient={130,170,140},outAmb={140,180,150},sky={sun=18,moon=0,stars=0},atm={dens=0.4,color={80,200,140},decay={40,150,90},glare=1.8,haze=2.2},clouds={cover=0.5,dens=0.5,color={200,255,220}}},
    ["Volcanic"]={clock=19,brightness=2,ambient={180,80,40},outAmb={200,90,50},sky={stars=200,sun=12,moon=0},atm={dens=0.75,color={255,60,0},decay={180,20,0},glare=3,haze=3.5},clouds={cover=0.8,dens=0.9,color={120,40,20}}},
    ["Arctic"]={clock=9,brightness=3.2,ambient={200,220,235},outAmb={210,230,245},sky={sun=10,stars=0,moon=0},atm={dens=0.3,color={180,220,255},decay={140,200,240},glare=1.5,haze=1.8},clouds={cover=0.7,dens=0.6,color={250,253,255}}},
    ["Midnight Ocean"]={clock=1.5,brightness=1.7,ambient={60,90,130},outAmb={70,100,140},sky={stars=6000,moon=24,sun=0,moonTex=true},atm={dens=0.5,color={20,60,140},decay={10,30,90},glare=0.6,haze=1.5}},
    ["Vaporwave"]={clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210},sky={stars=1000,moon=14},atm={dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4},clouds={cover=0.55,dens=0.55,color={200,150,255}}},
    ["Toxic"]={clock=13,brightness=2.5,ambient={140,180,80},outAmb={150,190,90},atm={dens=0.55,color={100,220,40},decay={60,150,20},glare=1.8,haze=2.6},clouds={cover=0.65,dens=0.7,color={180,255,120}}},
    ["Solar Eclipse"]={clock=12,brightness=0.9,ambient={50,40,60},outAmb={60,50,70},sky={stars=3500,sun=22,moon=0},atm={dens=0.5,color={255,140,40},decay={30,20,40},glare=2.8,haze=1.8}},
    ["Hellscape"]={clock=18,brightness=1.8,ambient={200,60,30},outAmb={220,70,40},sky={stars=100,sun=30,moon=0},atm={dens=0.85,color={255,30,0},decay={120,0,0},glare=3.5,haze=4},clouds={cover=0.95,dens=0.95,color={80,20,10}}},
    ["Heaven"]={clock=12,brightness=4,ambient={240,235,210},outAmb={250,245,220},sky={sun=16,moon=0,stars=0},atm={dens=0.25,color={255,250,220},decay={255,240,200},glare=3,haze=1.5},clouds={cover=0.85,dens=0.5,color={255,255,255}}},
    ["Storm"]={clock=15,brightness=1.4,ambient={90,90,110},outAmb={100,100,120},sky={stars=0,sun=6,moon=0},atm={dens=0.65,color={80,90,120},decay={40,50,80},glare=0.5,haze=3},clouds={cover=0.95,dens=0.95,color={60,65,80}}},
    ["Sunrise"]={clock=6.2,brightness=2.8,ambient={220,180,130},outAmb={230,190,140},sky={sun=22,stars=0,moon=0},atm={dens=0.45,color={255,180,100},decay={255,140,80},glare=2.4,haze=2.2},clouds={cover=0.4,dens=0.4,color={255,220,180}}},
    ["Deep Space"]={clock=0,brightness=1,ambient={30,25,50},outAmb={40,35,60},sky={stars=15000,moon=0,sun=0},atm={dens=0.08,color={15,5,40},decay={5,0,20},glare=0.2,haze=0.3}},
    ["Lavender Dream"]={clock=18.5,brightness=2.6,ambient={180,160,220},outAmb={190,170,230},sky={stars=800,moon=16,sun=0},atm={dens=0.4,color={200,160,255},decay={160,120,220},glare=1.4,haze=1.8},clouds={cover=0.55,dens=0.5,color={220,200,255}}},
    ["Inferno"]={clock=17.5,brightness=2.2,ambient={220,100,40},outAmb={235,110,50},sky={sun=26,moon=0,stars=0},atm={dens=0.6,color={255,90,20},decay={200,40,0},glare=3,haze=3.2},clouds={cover=0.7,dens=0.7,color={200,80,40}}},
    ["Mint Sky"]={clock=10,brightness=3.2,ambient={180,230,210},outAmb={190,240,220},sky={sun=10},atm={dens=0.32,color={150,255,210},decay={100,220,180},glare=1.6,haze=1.6},clouds={cover=0.55,dens=0.45,color={240,255,250}}},
}

local function _vC3(t) return Color3.fromRGB(t[1], t[2], t[3]) end

local function _v4mpClearSky()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:GetAttribute("_AdaptDuelsSky") then
            pcall(function() child:Destroy() end)
        end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:GetAttribute("_AdaptDuelsSky") then
                pcall(function() child:Destroy() end)
            end
        end
    end
end

local function applyCustomSky(mode)
    _v4mpClearSky()
    local preset = SKY_PRESETS[mode]
    if not preset or preset.kind == "off" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
        Lighting.Ambient = Color3.fromRGB(127,127,127)
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        S.skyTheme = "Off"
        return
    end
    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
    Lighting.FogColor = Color3.fromRGB(200,200,200)
    Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
    Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
    Lighting.GlobalShadows = true
    Lighting.ClockTime = preset.clock or 14
    Lighting.Brightness = preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient = _vC3(preset.outAmb) end
    if preset.ambient then Lighting.Ambient = _vC3(preset.ambient) end
    if preset.sky then
        local skyInst = Instance.new("Sky")
        skyInst:SetAttribute("_AdaptDuelsSky", true)
        if preset.sky.stars then skyInst.StarCount = preset.sky.stars end
        if preset.sky.moon then skyInst.MoonAngularSize = preset.sky.moon end
        if preset.sky.sun then skyInst.SunAngularSize = preset.sky.sun end
        if preset.sky.moonTex then skyInst.MoonTextureId = "rbxasset://sky/moon.jpg" end
        skyInst.Parent = Lighting
    end
    if preset.atm then
        local atm = Instance.new("Atmosphere")
        atm:SetAttribute("_AdaptDuelsSky", true)
        atm.Density = preset.atm.dens or 0.3
        atm.Color = _vC3(preset.atm.color)
        atm.Decay = _vC3(preset.atm.decay)
        atm.Glare = preset.atm.glare or 1
        atm.Haze = preset.atm.haze or 1
        atm.Parent = Lighting
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if preset.clouds and terrain then
        local clouds = Instance.new("Clouds")
        clouds:SetAttribute("_AdaptDuelsSky", true)
        clouds.Cover = preset.clouds.cover or 0.5
        clouds.Density = preset.clouds.dens or 0.5
        clouds.Color = _vC3(preset.clouds.color)
        clouds.Parent = terrain
    end
    S.skyTheme = mode
end

local function enableVividGraphics()
    if S.vividGraphicsEnabled and #S.vividEffects > 0 then return end
    S.vividGraphicsEnabled = true
    for _, eff in ipairs(S.vividEffects) do
        pcall(function() eff:Destroy() end)
    end
    S.vividEffects = {}
    local color = Instance.new("ColorCorrectionEffect")
    color.Parent = Lighting
    color.Saturation = 0.6; color.Contrast = 0.4; color.Brightness = 0.05
    color.TintColor = Color3.fromRGB(255, 240, 220)
    table.insert(S.vividEffects, color)
    local bloom = Instance.new("BloomEffect")
    bloom.Parent = Lighting
    bloom.Intensity = 0.8; bloom.Size = 24; bloom.Threshold = 1
    table.insert(S.vividEffects, bloom)
    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Parent = Lighting
    atmosphere.Density = 0.3; atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(220, 220, 225)
    atmosphere.Decay = Color3.fromRGB(106, 112, 125)
    atmosphere.Glare = 0.2; atmosphere.Haze = 1
    table.insert(S.vividEffects, atmosphere)
    local sun = Instance.new("SunRaysEffect")
    sun.Parent = Lighting
    sun.Intensity = 0.2; sun.Spread = 0.8
    table.insert(S.vividEffects, sun)
    local dof = Instance.new("DepthOfFieldEffect")
    dof.Parent = Lighting
    dof.FocusDistance = 25; dof.InFocusRadius = 10
    dof.NearIntensity = 0.2; dof.FarIntensity = 0.4
    table.insert(S.vividEffects, dof)
    task.spawn(function()
        while S.vividGraphicsEnabled and color and color.Parent do
            color.Contrast = 0.35 + math.sin(tick() * 2) * 0.05
            task.wait(0.03)
        end
    end)
end

local function disableVividGraphics()
    S.vividGraphicsEnabled = false
    for _, eff in ipairs(S.vividEffects) do
        pcall(function() eff:Destroy() end)
    end
    S.vividEffects = {}
end

local function toggleVividGraphics(on)
    if on then enableVividGraphics() else disableVividGraphics() end
    saveConfig()
end


YF = {}
-- Yout-to-DaHub ports: Anti Fling, Lock Enemy, Anim Pack, and Anti Lag.
-- Anti Fling and Lock Enemy, adapted to DaHub's state and movement system.
YF.antiFlingState = {connection = nil, threshold = 80, spinThreshold = 40}
function YF.startAntiFling()
    S.antiFlingEnabled = true
    if YF.antiFlingState.connection then return end
    YF.antiFlingState.connection = RunService.Heartbeat:Connect(function()
        if not S.antiFlingEnabled then return end
        local character = LP.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and (humanoid.Health <= 0 or humanoid.SeatPart) then return end
        if S._youtResetInProgress or S.dropBrainrotActive or _G.IsDropping then return end
        if S.autoLeftEnabled or S.autoRightEnabled or S.batAimbotEnabled or S.batBypassEnabled or S.bodyLockEnabled then return end
        local velocity = root.AssemblyLinearVelocity
        if Vector3.new(velocity.X, 0, velocity.Z).Magnitude > YF.antiFlingState.threshold then
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.new(0, velocity.Y, 0)
                root.AssemblyAngularVelocity = Vector3.zero
            end)
            return
        end
        if root.AssemblyAngularVelocity.Magnitude > YF.antiFlingState.spinThreshold then
            pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
        end
    end)
end
function YF.stopAntiFling()
    S.antiFlingEnabled = false
    if YF.antiFlingState.connection then YF.antiFlingState.connection:Disconnect(); YF.antiFlingState.connection = nil end
end

function YF.getClosestTargetBody()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local otherCharacter = player.Character
            local targetRoot = otherCharacter and otherCharacter:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = otherCharacter and otherCharacter:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (targetRoot.Position - root.Position).Magnitude
                if distance < minDistance then closest, minDistance = targetRoot, distance end
            end
        end
    end
    return closest
end

function YF.bodyLockTick()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if S.batBypassEnabled then return end
    if S._youtResetInProgress or S.dropBrainrotActive or S.autoLeftEnabled or S.autoRightEnabled or S.batAimbotEnabled then
        if not humanoid.AutoRotate then humanoid.AutoRotate = true end
        return
    end
    local target = YF.getClosestTargetBody()
    if not target or (target.Position - root.Position).Magnitude > S.bodyLockRange then
        if not humanoid.AutoRotate then humanoid.AutoRotate = true end
        return
    end
    if humanoid.AutoRotate then humanoid.AutoRotate = false end
    local targetVelocity = target.AssemblyLinearVelocity
    local predictTime = math.clamp(targetVelocity.Magnitude / 80, 0.08, 0.35)
    local predictedPosition = target.Position + targetVelocity * predictTime
    local targetHead = target.Parent and target.Parent:FindFirstChild("Head")
    local targetHeight = targetHead and targetHead.Position.Y or target.Position.Y
    local myHeight = root.Position.Y + (humanoid.HipHeight or 0)
    local verticalCorrection = math.clamp((targetHeight - myHeight) * 0.15, -1.5, 1.5)
    local lookPosition = Vector3.new(predictedPosition.X, root.Position.Y + verticalCorrection, predictedPosition.Z)
    if (lookPosition - root.Position).Magnitude > 0.1 then
        local goal = CFrame.lookAt(root.Position, lookPosition)
        local relative = root.CFrame:Inverse() * goal
        local _, yaw = relative:ToEulerAnglesXYZ()
        yaw = math.clamp(yaw, -2.5, 2.5)
        root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(0, yaw * 42, 0))
    end
end
function YF.startBodyLock()
    S.bodyLockEnabled = true
    if S.bodyLockConnection then return end
    local accumulator = 0
    S.bodyLockConnection = RunService.Heartbeat:Connect(function(dt)
        if not S.bodyLockEnabled then return end
        accumulator = accumulator + dt
        if accumulator < 0.033 then return end
        accumulator = 0
        YF.bodyLockTick()
    end)
end
function YF.stopBodyLock()
    S.bodyLockEnabled = false
    if S.bodyLockConnection then S.bodyLockConnection:Disconnect(); S.bodyLockConnection = nil end
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then pcall(function() root.AssemblyAngularVelocity = Vector3.zero end) end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.AutoRotate = true end
end

YF.ANIM_PACKS = {
    ["Zombie"] = { idle1="rbxassetid://616158929", idle2="rbxassetid://616160636", walk="rbxassetid://616168032", run="rbxassetid://616163682", jump="rbxassetid://616161997", fall="rbxassetid://616157476", climb="rbxassetid://616156119", swim="rbxassetid://616165109", swimidle="rbxassetid://616166655" },
    ["Ninja"] = { idle1="rbxassetid://656117400", idle2="rbxassetid://656117400", walk="rbxassetid://656121766", run="rbxassetid://656118852", jump="rbxassetid://656117878", fall="rbxassetid://656115606", climb="rbxassetid://656114359", swim="rbxassetid://656117400", swimidle="rbxassetid://656117400" },
    ["Knight"] = { idle1="rbxassetid://657595757", idle2="rbxassetid://657595757", walk="rbxassetid://657552124", run="rbxassetid://657564596", jump="rbxassetid://658409194", fall="rbxassetid://657600338", climb="rbxassetid://658360781", swim="rbxassetid://657595757", swimidle="rbxassetid://657595757" },
    ["Elder"] = { idle1="rbxassetid://845397899", idle2="rbxassetid://845397899", walk="rbxassetid://845403856", run="rbxassetid://845386501", jump="rbxassetid://845398858", fall="rbxassetid://845397673", climb="rbxassetid://845392038", swim="rbxassetid://845397899", swimidle="rbxassetid://845397899" },
    ["Levitate"] = { idle1="rbxassetid://616006778", idle2="rbxassetid://616006778", walk="rbxassetid://616013216", run="rbxassetid://616013216", jump="rbxassetid://616008936", fall="rbxassetid://616005863", climb="rbxassetid://616003713", swim="rbxassetid://616006778", swimidle="rbxassetid://616006778" },
    ["Astronaut"] = { idle1="rbxassetid://891621366", idle2="rbxassetid://891621366", walk="rbxassetid://891636393", run="rbxassetid://891636393", jump="rbxassetid://891627522", fall="rbxassetid://891617961", climb="rbxassetid://891609353", swim="rbxassetid://891621366", swimidle="rbxassetid://891621366" },
    ["Pirate"] = { idle1="rbxassetid://750781874", idle2="rbxassetid://750781874", walk="rbxassetid://750785693", run="rbxassetid://750783738", jump="rbxassetid://750782230", fall="rbxassetid://750780242", climb="rbxassetid://750779899", swim="rbxassetid://750781874", swimidle="rbxassetid://750781874" },
    ["Toy"] = { idle1="rbxassetid://782841498", idle2="rbxassetid://782841498", walk="rbxassetid://782843345", run="rbxassetid://782842708", jump="rbxassetid://782847020", fall="rbxassetid://782846423", climb="rbxassetid://782843869", swim="rbxassetid://782841498", swimidle="rbxassetid://782841498" },
    ["Vampire"] = { idle1="rbxassetid://1083445855", idle2="rbxassetid://1083445855", walk="rbxassetid://1083473930", run="rbxassetid://1083462077", jump="rbxassetid://1083455352", fall="rbxassetid://1083443587", climb="rbxassetid://1083439238", swim="rbxassetid://1083445855", swimidle="rbxassetid://1083445855" },
    ["Werewolf"] = { idle1="rbxassetid://1083195517", idle2="rbxassetid://1083195517", walk="rbxassetid://1083178339", run="rbxassetid://1083216690", jump="rbxassetid://1083218792", fall="rbxassetid://1083189019", climb="rbxassetid://1083182000", swim="rbxassetid://1083195517", swimidle="rbxassetid://1083195517" },
    ["Rthro"] = { idle1="rbxassetid://2510196951", idle2="rbxassetid://2510196951", walk="rbxassetid://2510202577", run="rbxassetid://2510198475", jump="rbxassetid://2510197830", fall="rbxassetid://2510195892", climb="rbxassetid://2510192778", swim="rbxassetid://2510196951", swimidle="rbxassetid://2510196951" },
    ["Stylish"] = { idle1="rbxassetid://616136790", idle2="rbxassetid://616136790", walk="rbxassetid://616146177", run="rbxassetid://616140816", jump="rbxassetid://616139451", fall="rbxassetid://616134815", climb="rbxassetid://616133594", swim="rbxassetid://616136790", swimidle="rbxassetid://616136790" },
}

YF.ANIM_PACK_ORDER = {{"Off", "Off"}, {"Zombie", "Zombie"}, {"Ninja", "Ninja"}, {"Knight", "Knight"}, {"Elder", "Elder"}, {"Levitate", "Levitate"}, {"Astronaut", "Astronaut"}, {"Pirate", "Pirate"}, {"Toy", "Toy"}, {"Vampire", "Vampire"}, {"Werewolf", "Werewolf"}, {"Rthro", "Rthro"}, {"Stylish", "Stylish"}}

function YF.isPackAnim(id)
    for _, pack in pairs(YF.ANIM_PACKS) do
        for _, v in pairs(pack) do
            if v == id then return true end
        end
    end
    return false
end

function YF.saveOriginalAnims(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function g(obj) return obj and obj.AnimationId or nil end
    local ids = {
        idle1 = g(animate.idle and animate.idle.Animation1),
        idle2 = g(animate.idle and animate.idle.Animation2),
        walk  = g(animate.walk and animate.walk.WalkAnim),
        run   = g(animate.run  and animate.run.RunAnim),
        jump  = g(animate.jump and animate.jump.JumpAnim),
        fall  = g(animate.fall and animate.fall.FallAnim),
        climb = g(animate.climb and animate.climb.ClimbAnim),
        swim  = g(animate.swim and animate.swim.Swim),
        swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
    }
    if not YF.isPackAnim(ids.walk) then S.originalAnimPack = ids end
end

function YF.applyAnimPack(packName)
    S.currentAnimPack = packName
    if S.animSelectorLabel then S.animSelectorLabel.Text = packName end
    if packName == "Off" then
        if S.originalAnimPack and LP.Character then
            local animate = LP.Character:FindFirstChild("Animate")
            if animate then
                local function s(obj,id) if obj and id then obj.AnimationId = id end end
                s(animate.idle and animate.idle.Animation1, S.originalAnimPack.idle1)
                s(animate.idle and animate.idle.Animation2, S.originalAnimPack.idle2)
                s(animate.walk and animate.walk.WalkAnim, S.originalAnimPack.walk)
                s(animate.run  and animate.run.RunAnim,   S.originalAnimPack.run)
                s(animate.jump and animate.jump.JumpAnim, S.originalAnimPack.jump)
                s(animate.fall and animate.fall.FallAnim, S.originalAnimPack.fall)
                s(animate.climb and animate.climb.ClimbAnim, S.originalAnimPack.climb)
                s(animate.swim and animate.swim.Swim, S.originalAnimPack.swim)
                s(animate.swimidle and animate.swimidle.SwimIdle, S.originalAnimPack.swimidle)
            end
        end
        if S.animPackConnection then S.animPackConnection:Disconnect(); S.animPackConnection = nil end
        return
    end
    local pack = YF.ANIM_PACKS[packName]
    if not pack then return end
    if S.animPackConnection then S.animPackConnection:Disconnect() end
    local observedCharacter, capturedCharacter = nil, nil
    S.animPackConnection = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        if not c then return end
        if c ~= observedCharacter then observedCharacter, capturedCharacter = c, nil end
        local animate = c:FindFirstChild("Animate")
        if not animate then return end
        if capturedCharacter ~= c then
            YF.saveOriginalAnims(c)
            capturedCharacter = c
        end
        if not animate then return end
        local function s(obj,id) if obj and id then obj.AnimationId = id end end
        s(animate.idle and animate.idle.Animation1, pack.idle1)
        s(animate.idle and animate.idle.Animation2, pack.idle2)
        s(animate.walk and animate.walk.WalkAnim, pack.walk)
        s(animate.run  and animate.run.RunAnim,   pack.run)
        s(animate.jump and animate.jump.JumpAnim, pack.jump)
        s(animate.fall and animate.fall.FallAnim, pack.fall)
        s(animate.climb and animate.climb.ClimbAnim, pack.climb)
        s(animate.swim and animate.swim.Swim, pack.swim)
        s(animate.swimidle and animate.swimidle.SwimIdle, pack.swimidle)
    end)
end

function YF.startAnimPack(packName)
    local char = LP.Character
    if char then
        YF.saveOriginalAnims(char)
        YF.applyAnimPack(packName)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) end
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    else
        YF.applyAnimPack(packName)
    end
    S.currentAnimPack = packName
end

function YF.stopAnimPack()
    S.currentAnimPack = "Off"
    if S.animSelectorLabel then S.animSelectorLabel.Text = "Off" end
    YF.applyAnimPack("Off")
end

YF._alSaved = setmetatable({}, { __mode = "k" })
YF._alDetached = {}
YF._alAnimators = setmetatable({}, { __mode = "k" })
YF._alStoppedTracks = setmetatable({}, { __mode = "k" })
YF._alGeneration = 0
YF._alScanCancel = nil
YF._alConns = {}
YF._alLightOrig = nil
YF._alWorldOrig = {}
YF._alFlagOriginals = {}
YF._alRunning = false

-- TRIPA adaptado: somente ajustes gráficos reversíveis, sem FPS 9999,
-- alterações de rede/physics, Destroy de objetos ou varreduras repetidas.
YF.TRIPA_FLAGS = {
    {"FFlagDisablePostFx", "True"},
    {"FFlagDisablePostProcess", "True"},
    {"FIntRenderGrassDetailStrands", "0"},
    {"DFIntDebugFRMQualityLevelOverride", "1"},
    {"FIntRenderShadowIntensity", "0"},
    {"FFlagFastGPULightCulling3", "True"},
    {"DFFlagTextureQualityOverrideEnabled", "True"},
    {"DFIntTextureQualityOverride", "0"},
    {"FIntTextureQualityLevel", "0"},
    {"FFlagRemoveGlobalShadows", "True"},
    {"FFlagRenderShadowSkip", "True"},
    {"DFIntShadowMapSize", "1"},
    {"FFlagDebugDisableParticles", "True"},
    {"FIntParticleCount", "0"},
    {"DFIntMaxParticleCount", "0"},
    {"FIntMaxParticlesPerEmitter", "0"},
    {"DFIntGrassMaxDistance", "0"},
    {"FIntGrassDetail", "0"},
    {"FFlagGrassRendering", "False"},
    {"FFlagWaterReflection", "False"},
    {"FFlagWaterRefraction", "False"},
}
YF.AL_LOW_FLAGS = {
    {"DFIntClusterSenderMaxJoinBandwidthBps", "2100000000"},
    {"DFIntClusterSenderMaxUpdateBandwidthBps", "2100000000"},
    {"DFIntServerFramesBetweenJoins", "1"},
    {"DFIntRaknetBandwidthInfluxHundredthsPercentageV2", "10000"},
    {"DFIntConnectionMTUSize", "1400"},
    {"FIntRakNetResendBufferArrayLength", "1024"},
    {"DFIntRakNetNakResendDelayMsMax", "1"},
    {"DFIntWaitOnUpdateNetworkLoopEndedMS", "100"},
    {"DFIntWaitOnRecvFromLoopEndedMS", "100"},
    {"DFIntLargePacketQueueSizeCutoffMB", "1000"},
    {"DFIntSendRakNetStatsInterval", "2147483647"},
    {"DFIntRakNetLoopMs", "1"},
    {"DFIntRakNetSelectTimeoutMs", "1"},
    {"DFIntNetworkClusterPacketCacheNumParallelTasks", "8"},
    {"DFIntReplicationDataCacheNumParallelTasks", "8"},
    {"DFIntMegaReplicatorNumParallelTasks", "16"},
    {"DFIntMaxProcessPacketsStepsPerCyclic", "512"},
    {"DFIntMaxProcessPacketsStepsAccumulated", "0"},
    {"DFIntMaxProcessPacketsJobScaling", "1000"},
    {"DFIntClientPacketMaxFrameMicroseconds", "200000"},
    {"DFIntClientPacketExcessMicroseconds", "10000"},
    {"DFIntClientPacketMinMicroseconds", "1"},
    {"DFIntClientPacketMaxDelayMs", "1"},
    {"DFIntMaxWaitTimeBeforeForcePacketProcessMS", "1"},
    {"DFIntMaxFrameBufferSize", "4"},
    {"DFIntBufferCompressionThreshold", "100"},
    {"DFIntOverrideISRReplicatorStepBandwidthBytes", "131072"},
    {"DFIntTaskSchedulerJobInitThreads", "8"},
    {"DFIntTaskSchedulerJobInGameThreads", "8"},
    {"FIntTaskSchedulerAutoThreadLimit", "16"},
    {"FIntTaskSchedulerAsyncTasksMinimumThreadCount", "4"},
    {"DFIntRuntimeConcurrency", "16"},
    {"FIntSimWorldTaskQueueParallelTasks", "20"},
    {"DFIntHttpBatchLimit", "256"},
    {"FIntHttpBatchLimit", "256"},
    {"DFIntHttpCurlConnectionCacheSize", "512"},
    {"FIntDefaultMeshCacheSizeMB", "512"},
    {"DFIntMemCacheMaxCapacityMB", "256"},
    {"DFIntNumAssetsMaxToPreload", "1"},
    {"DFFlagEnableSoundPreloading", "false"},
    {"FFlagSlimContentProvider", "true"},
    {"DFFlagDebugSkipMeshVoxelizer", "true"},
    {"DFFlagTextureQualityOverrideEnabled", "true"},
    {"DFIntTextureQualityOverride", "0"},
    {"FIntDebugTextureManagerSkipMips", "7"},
    {"DFIntDebugLimitMinTextureResolutionWhenSkipMips", "8"},
    {"FFlagTM2SkipMipsForUnstreamable2", "true"},
    {"DFFlagDoNotSkipMipsBasedOnSystemMemoryPS", "true"},
    {"FFlagRenderUseTextureManager224", "false"},
    {"DFIntDebugFRMQualityLevelOverride", "1"},
    {"DFFlagDebugPauseVoxelizer", "true"},
    {"FFlagFastGPULightCulling3", "true"},
    {"FIntRenderLocalLightFadeInMs", "0"},
    {"FIntRenderLocalLightUpdatesMax", "1"},
    {"FIntRenderShadowmapBias", "0"},
    {"FIntSSAOMipLevels", "0"},
    {"FIntDebugForceMSAASamples", "1"},
    {"FIntDebugFRMOptionalMSAALevelOverride", "0"},
    {"FIntRobloxGuiBlurIntensity", "0"},
    {"FIntFRMMinGrassDistance", "0"},
    {"FIntFRMMaxGrassDistance", "0"},
    {"DFFlagCoreScriptTelemetry2", "false"},
    {"DFFlagBrowserTrackerIdTelemetryEnabled", "false"},
    {"FFlagPerfDataOnTelemetryV2", "false"},
    {"FFlagSendRenderFidelityTelemetry2", "false"},
    {"FFlagEnableTelemetryServiceMemoryCPUInfo", "false"},
    {"DFIntTelemetryProfilerHundredthsPercentage", "0"},
    {"FIntTelemetryProfilerFrequency", "0"},
    {"FIntPerformanceTelemetryQueueProcessLimit", "0"},
    {"DFIntContentProviderPreloadHangTelemetryHundredthsPercentage", "0"},
}

function YF._alApplyLowFlags()
    local env = (getgenv and getgenv()) or _G
    local setter = rawget(env, "setfflag") or rawget(_G, "set_fflag")
    local getter = rawget(env, "getfflag") or rawget(_G, "get_fflag")
    -- Only change flags when the original values can also be queried and restored.
    if type(setter) ~= "function" or type(getter) ~= "function" then return end
    for _, flag in ipairs(S.optimizerMode == "tripa" and YF.TRIPA_FLAGS or YF.AL_LOW_FLAGS) do
        local ok, current = pcall(getter, flag[1])
        if ok and current ~= nil then
            if YF._alFlagOriginals[flag[1]] == nil then
                YF._alFlagOriginals[flag[1]] = tostring(current)
            end
            pcall(setter, flag[1], tostring(flag[2]))
        end
    end
end

function YF._alSaveLighting()
    if YF._alLightOrig then return end
    YF._alLightOrig = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
        GlobalShadows = Lighting.GlobalShadows,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
    }
end

function YF._alApplyLowPermanentSettings()
    if next(YF._alWorldOrig) == nil then
        pcall(function() YF._alWorldOrig.renderQuality = settings().Rendering.QualityLevel end)
        pcall(function() YF._alWorldOrig.savedQuality = UserSettings():GetService("UserGameSettings").SavedQualityLevel end)
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            YF._alWorldOrig.terrainObject = terrain
            YF._alWorldOrig.terrain = {
                Decoration = terrain.Decoration, WaterWaveSize = terrain.WaterWaveSize,
                WaterWaveSpeed = terrain.WaterWaveSpeed, WaterReflectance = terrain.WaterReflectance,
                WaterTransparency = terrain.WaterTransparency,
            }
            local clouds = terrain:FindFirstChildOfClass("Clouds")
            if clouds then YF._alWorldOrig.cloudsObject = clouds; YF._alWorldOrig.cloudsEnabled = clouds.Enabled end
        end
        YF._alWorldOrig.atmospheres = {}
        for _, atmosphere in ipairs(Lighting:GetChildren()) do
            if atmosphere:IsA("Atmosphere") then
                YF._alWorldOrig.atmospheres[atmosphere] = {
                    Density = atmosphere.Density, Glare = atmosphere.Glare, Haze = atmosphere.Haze,
                }
            end
        end
    end
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function()
        UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.FogStart = 0
        Lighting.FogEnd = 1e10
    end)
    pcall(function()
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            atmosphere.Density = 0
            atmosphere.Glare = 0
            atmosphere.Haze = 0
        end
    end)
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            local clouds = terrain:FindFirstChildOfClass("Clouds")
            if clouds then clouds.Enabled = false end
        end
    end)
end

function YF._alChange(object, property, value)
    pcall(function()
        local original = object[property]
        if original == value then return end
        object[property] = value
        local bucket = YF._alSaved[object]
        if not bucket then bucket = {}; YF._alSaved[object] = bucket end
        if not bucket[property] then bucket[property] = { value = original } end
    end)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Argian-dotcom/Jdkffkfo/refs/heads/main/Coding"))()
end

function YF._alIsProtectedVisual(object)
    local char = LP.Character
    if char and (object == char or object:IsDescendantOf(char)) then return true end
    if object:GetAttribute("_AdaptDuelsSky") then return true end
    for _, effect in ipairs(S.vividEffects or {}) do if effect == object then return true end end
    local parent = object
    while parent and parent ~= workspace do
        if S.optimizerMode == "tripa" then
            -- Mantém personagens (incluindo outros jogadores) e beams do hub.
            if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then return true end
            if parent.Name:match("^PlotBeam") or parent.Name:match("^BrainrotBeam")
                or parent.Name == "HighestValueBeam" or parent.Name == "BaseLineBeam" then return true end
        end
        if parent:IsA("LayerCollector") or parent:IsA("GuiObject") or parent:IsA("GuiBase2d") then
            return true
        end
        local name = parent.Name or ""
        if name:match("^Crystal") or name:match("^Eclipse") or name:match("^ESP_")
            or name:match("^BloodHounds") or name:match("^Yout") or name:match("^DaHub") then
            return true
        end
        parent = parent.Parent
    end
    return false
end

function YF.applyAntiLagDerender(obj)
    pcall(function()
        if not YF._alRunning then return end
        if YF._alIsProtectedVisual(obj) then return end
        if S.optimizerMode == "tripa" and (obj:IsA("Sky") or obj:IsA("Shirt")
            or obj:IsA("Pants") or obj:IsA("ShirtGraphic")) then return end

        if obj:IsA("Terrain") then
            YF._alChange(obj, "Decoration", false)
            YF._alChange(obj, "WaterWaveSize", 0)
            YF._alChange(obj, "WaterWaveSpeed", 0)
            YF._alChange(obj, "WaterReflectance", 0)
            YF._alChange(obj, "WaterTransparency", S.optimizerMode == "tripa" and 0 or 1)
        end
        if obj:IsA("BasePart") then
            YF._alChange(obj, "Material", Enum.Material.Plastic)
            YF._alChange(obj, "MaterialVariant", "")
            YF._alChange(obj, "Reflectance", 0)
            YF._alChange(obj, "CastShadow", false)
            if obj:IsA("MeshPart") then
                YF._alChange(obj, "TextureID", "")
                YF._alChange(obj, "RenderFidelity", Enum.RenderFidelity.Performance)
                YF._alChange(obj, "DoubleSided", false)
            elseif obj:IsA("PartOperation") then
                YF._alChange(obj, "RenderFidelity", Enum.RenderFidelity.Performance)
            end
        elseif obj:IsA("SpecialMesh") then
            YF._alChange(obj, "TextureId", "")
        elseif obj:IsA("SurfaceAppearance") then
            YF._alDetached[obj] = true
            YF._alChange(obj, "Parent", nil)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            YF._alChange(obj, "Transparency", 1)
            YF._alChange(obj, "Texture", "")
        elseif obj:IsA("ParticleEmitter") then
            YF._alChange(obj, "Enabled", false)
            YF._alChange(obj, "Rate", 0)
            pcall(function() obj:Clear() end)
        elseif obj:IsA("Trail") then
            YF._alChange(obj, "Enabled", false)
            pcall(function() obj:Clear() end)
        elseif obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke")
            or obj:IsA("Sparkles") or obj:IsA("Light") or obj:IsA("PostEffect")
            or obj:IsA("Clouds") then
            YF._alChange(obj, "Enabled", false)
        elseif obj:IsA("Atmosphere") then
            YF._alChange(obj, "Density", 0)
            YF._alChange(obj, "Haze", 0)
            YF._alChange(obj, "Glare", 0)
        elseif obj:IsA("Sky") then
            for _, face in ipairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp","SunTextureId","MoonTextureId"}) do
                YF._alChange(obj, face, "")
            end
            YF._alChange(obj, "StarCount", 0)
            YF._alChange(obj, "CelestialBodiesShown", false)
        elseif obj:IsA("Shirt") then
            YF._alChange(obj, "ShirtTemplate", "")
        elseif obj:IsA("Pants") then
            YF._alChange(obj, "PantsTemplate", "")
        elseif obj:IsA("ShirtGraphic") then
            YF._alChange(obj, "Graphic", "")
        elseif obj:IsA("Animator") then
            if not YF._alAnimators[obj] then
                local char = LP.Character
                if not (char and obj:IsDescendantOf(char)) then
                    YF._alAnimators[obj] = true
                    local token = YF._alGeneration
                    local ok, conn = pcall(function()
                        return obj.AnimationPlayed:Connect(function(track)
                            if not YF._alRunning or YF._alGeneration ~= token then return end
                            task.defer(function()
                                if YF._alRunning and YF._alGeneration == token then
                                    pcall(function()
                                        if track.IsPlaying and not YF._alStoppedTracks[track] then
                                            YF._alStoppedTracks[track] = {animator = obj, time = track.TimePosition, speed = track.Speed}
                                        end
                                        track:Stop(0)
                                    end)
                                end
                            end)
                        end)
                    end)
                    if ok then table.insert(YF._alConns, conn) end
                    pcall(function()
                        for _, track in ipairs(obj:GetPlayingAnimationTracks()) do
                            if track.IsPlaying then
                                YF._alStoppedTracks[track] = {
                                    animator = obj,
                                    time = track.TimePosition,
                                    speed = track.Speed,
                                }
                                track:Stop(0)
                            end
                        end
                    end)
                end
            end
        end
    end)
end

function YF.enableAntiLag()
    if YF._alRunning then return end
    YF._alRunning = true
    S.antiLagEnabled = true
    YF._alGeneration = YF._alGeneration + 1
    local token = YF._alGeneration

    YF._alSaveLighting()
    YF._alApplyLowFlags()
    YF._alApplyLowPermanentSettings()
    if S.optimizerMode == "tripa" then
        YF._alChange(Lighting, "Brightness", 3)
        YF._alChange(Lighting, "Ambient", Color3.fromRGB(255, 255, 255))
        YF._alChange(Lighting, "OutdoorAmbient", Color3.fromRGB(255, 255, 255))
        YF._alChange(Lighting, "ShadowSoftness", 0)
        YF._alChange(Lighting, "ClockTime", 0)
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then YF._alChange(terrain, "WaterTransparency", 0) end
    end

    table.insert(YF._alConns, workspace.DescendantAdded:Connect(function(obj)
        task.defer(function()
            if YF._alRunning and YF._alGeneration == token then
                pcall(YF.applyAntiLagDerender, obj)
            end
        end)
    end))
    table.insert(YF._alConns, Lighting.DescendantAdded:Connect(function(obj)
        task.defer(function()
            if YF._alRunning and YF._alGeneration == token then
                pcall(YF.applyAntiLagDerender, obj)
            end
        end)
    end))

    local function walkBatched(roots, apply, shouldContinue)
        task.spawn(function()
            local pending = {}
            for _, root in ipairs(roots) do
                if root then
                    local ok, children = pcall(function() return root:GetChildren() end)
                    if ok then for _, c in ipairs(children) do table.insert(pending, c) end end
                end
            end
            while #pending > 0 and YF._alRunning and YF._alGeneration == token and shouldContinue() do
                local deadline = os.clock() + 0.0008
                while #pending > 0 and os.clock() < deadline do
                    local obj = table.remove(pending)
                    pcall(apply, obj)
                    local ok, children = pcall(function() return obj:GetChildren() end)
                    if ok then for _, c in ipairs(children) do table.insert(pending, c) end end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end

    walkBatched({workspace, Lighting}, YF.applyAntiLagDerender, function()
        return YF._alRunning and YF._alGeneration == token
    end)
end

function YF.disableAntiLag()
    if not YF._alRunning then
        S.antiLagEnabled = false
        return
    end
    YF._alRunning = false
    S.antiLagEnabled = false
    YF._alGeneration = YF._alGeneration + 1

    if YF._alScanCancel then pcall(YF._alScanCancel); YF._alScanCancel = nil end

    for _, conn in ipairs(YF._alConns) do pcall(function() conn:Disconnect() end) end
    YF._alConns = {}

    for object, properties in pairs(YF._alSaved) do
        for property, original in pairs(properties) do
            pcall(function() object[property] = original.value end)
        end
    end
    YF._alSaved = setmetatable({}, { __mode = "k" })
    YF._alDetached = {}
    YF._alAnimators = setmetatable({}, { __mode = "k" })

    for track, state in pairs(YF._alStoppedTracks) do
        pcall(function()
            if state.animator.Parent and not track.IsPlaying then
                track:Play(0, 1, state.speed)
                track.TimePosition = state.time
            end
        end)
    end
    YF._alStoppedTracks = setmetatable({}, { __mode = "k" })

    if YF._alLightOrig then
        pcall(function()
            Lighting.Brightness = YF._alLightOrig.Brightness
            Lighting.ClockTime = YF._alLightOrig.ClockTime
            Lighting.OutdoorAmbient = YF._alLightOrig.OutdoorAmbient
            Lighting.Ambient = YF._alLightOrig.Ambient
            Lighting.GlobalShadows = YF._alLightOrig.GlobalShadows
            Lighting.EnvironmentDiffuseScale = YF._alLightOrig.EnvironmentDiffuseScale
            Lighting.EnvironmentSpecularScale = YF._alLightOrig.EnvironmentSpecularScale
            Lighting.FogStart = YF._alLightOrig.FogStart
            Lighting.FogEnd = YF._alLightOrig.FogEnd
        end)
    end
    pcall(function()
        if YF._alWorldOrig.renderQuality ~= nil then settings().Rendering.QualityLevel = YF._alWorldOrig.renderQuality end
        if YF._alWorldOrig.savedQuality ~= nil then UserSettings():GetService("UserGameSettings").SavedQualityLevel = YF._alWorldOrig.savedQuality end
        local terrain, state = YF._alWorldOrig.terrainObject, YF._alWorldOrig.terrain
        if terrain and terrain.Parent and state then
            for property, value in pairs(state) do terrain[property] = value end
        end
        local clouds = YF._alWorldOrig.cloudsObject
        if clouds and clouds.Parent and YF._alWorldOrig.cloudsEnabled ~= nil then clouds.Enabled = YF._alWorldOrig.cloudsEnabled end
        for atmosphere, values in pairs(YF._alWorldOrig.atmospheres or {}) do
            if atmosphere.Parent then for property, value in pairs(values) do atmosphere[property] = value end end
        end
    end)
    YF._alWorldOrig = {}
    YF._alLightOrig = nil
    local env = (getgenv and getgenv()) or _G
    local setter = rawget(env, "setfflag") or rawget(_G, "set_fflag")
    if type(setter) == "function" then
        for name, value in pairs(YF._alFlagOriginals) do pcall(setter, name, value) end
    end
    YF._alFlagOriginals = {}
end

function YF.setOptimizer(mode, enabled)
    if YF._alRunning and (not enabled or S.optimizerMode ~= mode) then YF.disableAntiLag() end
    if enabled then S.optimizerMode = mode; YF.enableAntiLag() end
    if S.setAntiLagVisual then S.setAntiLagVisual(S.antiLagEnabled and S.optimizerMode == "standard") end
    if S.setTripaVisual then S.setTripaVisual(S.antiLagEnabled and S.optimizerMode == "tripa") end
end

saveConfig = function()
    pcall(function()
        local function ks(e)
            return {kb = e.kb and e.kb.Name or nil, gp = e.gp and e.gp.Name or nil}
        end
        local cfg = {
            keybindVersion = 1,
            userMenuScale = S.userMenuScale or 1,
            userMobileScale = S.userMobileScale or 1,
            normalSpeed = S.NS, carrySpeed = S.CS, laggerSpeed = S.LS, laggerCarrySpeed = S.LCS,
            hubColor = S.hubColor,
            optimizerMode = S.optimizerMode,
            mobileButtonStyle = S.mobileButtonStyle,
            hubTitleFont = DaHubBrandStyle.fontMode,
            medusaSkin = S.medusaSkinMode or "Off",
            laggerMode = S.speedMode and 0 or S.laggerMode,
            tpDownHeightTrigger = S.tpDownHeightTrigger,
            dropMode = S.dropMode,
            dropBrainrotKey = ks(S.KB.DropBrainrot), autoLeftKey = ks(S.KB.AutoLeft),
            autoRightKey = ks(S.KB.AutoRight), autoBatKey = ks(S.KB.AutoBat),
            batBypassKey = ks(S.KB.BatBypass),
            informationE01 = S.informationE01Enabled,
            tpFloorKey = ks(S.KB.TPFlor), guiHideKey = ks(S.KB.GuiHide),
            speedToggleKey = ks(S.KB.SpeedToggle), laggerToggleKey = ks(S.KB.LaggerToggle),
            grabRadius = S.Steal.StealRadius, antiRagdoll = S.antiRagdollEnabled,
            autoStealEnabled = S.stealActive,
            medusaCounter = S.medusaCounterEnabled, carryMode = S.speedMode,
            batAimbot = S.batAimbotEnabled,
            batBypassVersion = S.batBypassVersion or "v5",
            batBypassSpeed = S.batBypassSpeed or 58,
            batSkin = S.batSkinMode,
            displaySkin = S.displaySkin,
            customSkin = S.customSkinEnabled,
            espEnabled = S.espEnabled,
            unwalkEnabled = S.unwalkEnabled,
            lockUI = S.lockUIEnabled, fpsBoost = S.fpsBoostEnabled,
            vividGraphics = S.vividGraphicsEnabled,
            stretchEnabled = S.stretchEnabled, stretchFOV = S.stretchFOV,
            skyTheme = S.skyTheme,
            krobloxMode = S.krobloxMode,
            antiFling = S.antiFlingEnabled,
            lockEnemy = S.bodyLockEnabled, lockEnemyRange = S.bodyLockRange,
            animPack = S.currentAnimPack,
            antiLag = S.antiLagEnabled,
            hideOpiumButtons = S.hideOpiumButtonsEnabled or false,
            holdJumpEnabled = S.holdJumpEnabled,
            batCounter = S.batCounterEnabled,
            stealDuration = S.Steal.StealDuration,
            mobileButtonPositions = S.mobileButtonPositions,
            lockMobileButtons = S.lockMobileButtons,
            floatingFreeButtonPositions = S.floatingFreeButtonPositions,
            mainMenuPos = S.menuOpenPosition and {
                XS = S.menuOpenPosition.X.Scale, X = S.menuOpenPosition.X.Offset,
                YS = S.menuOpenPosition.Y.Scale, Y = S.menuOpenPosition.Y.Offset,
            } or nil,
            floatingPanelPos = S.floatingPanelFrame and {
                XS = S.floatingPanelFrame.Position.X.Scale, X = S.floatingPanelFrame.Position.X.Offset,
                YS = S.floatingPanelFrame.Position.Y.Scale, Y = S.floatingPanelFrame.Position.Y.Offset,
            } or nil,
            stealHudPos = S.stealHudCard and {
                XS = S.stealHudCard.Position.X.Scale, X = S.stealHudCard.Position.X.Offset,
                YS = S.stealHudCard.Position.Y.Scale, Y = S.stealHudCard.Position.Y.Offset,
            } or nil,
        }
        local ok, data = pcall(function() return HS:JSONEncode(cfg) end)
        if ok and data then safeWritefile(S.CONFIG_FILE, data) end
    end)
end

task.spawn(function()
    while task.wait(10) do
        saveConfig()
    end
end)

local function resetFloatingPanel()
    S.editMobileButtons = false
    if S.setEditMobileButtonsVisual then S.setEditMobileButtonsVisual(false) end
    if S.refreshMobileEditMode then S.refreshMobileEditMode() end
    S.mobileButtonPositions = {}
    S.floatingFreeButtonPositions = {}
    if S.floatingPanelFrame then
        S.floatingPanelFrame.Position = UDim2.new(0.79, 0, 0, 0)
    end
    if S._floatingFreeButtonLayer then
        S._floatingFreeButtonLayer.Position = UDim2.new(0.79, 0, 0, 0)
    end
    if S.stealHudCard then
        S.stealHudCard.Position = UDim2.new(0.5, -150, 1, -75)
    end
    for _, info in ipairs(S._floatingButtonInfos or {}) do
        info.userMoved = false
    end
    if S._floatingUpdateLayout then pcall(S._floatingUpdateLayout) end
    saveConfig()
end

-- Visual-only progress targets; gameplay timing stays unchanged.
S.setProgressVisual = function(value)
    value = math.clamp(value, 0, 1)
    S.progressVisualTarget = value
    if value >= 1 then
        S.progressVisualCompleteUntil = os.clock() + 0.12
    end
end

local function resetProgressBar()
    S.setProgressVisual(0)
    -- Bar always stays visible; just reset fill width
end

AntiRagdollV2 = {
    Enabled = false,
    Connection = nil,
    ResetCooldown = 0,
}

local function startAntiRagdollV2()
    if AntiRagdollV2.Connection then return end
    AntiRagdollV2.Enabled = true
    AntiRagdollV2.Connection = RunService.Heartbeat:Connect(function()
        if not AntiRagdollV2.Enabled or not S.antiRagdollEnabled then return end
        local character = LP.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        if humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

        local state = humanoid:GetState()
        local now = tick()
        if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown then
            if now - AntiRagdollV2.ResetCooldown > 0.15 then
                AntiRagdollV2.ResetCooldown = now
                -- Disparar el contador antes de que V2 cambie el estado a GettingUp.
                if triggerBatCounter then triggerBatCounter(character) end
                pcall(function()
                    if humanoid:GetState() == Enum.HumanoidStateType.GettingUp then return end
                    if humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    for _, obj in ipairs(character:GetDescendants()) do
                        if obj:IsA("Motor6D") then obj.Enabled = true end
                        if obj:IsA("Constraint") then obj.Enabled = true end
                    end
                    local camera = workspace.CurrentCamera
                    if camera then camera.CameraSubject = humanoid end
                    local playerScripts = LP:FindFirstChild("PlayerScripts")
                    local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
                    local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
                    if controlModule then
                        local controls = require(controlModule)
                        if controls and controls.Enable then controls:Enable() end
                    end
                    humanoid.AutoRotate = true
                    humanoid.PlatformStand = false
                    humanoid.Sit = false
                end)
            end
        end
    end)
end

local function stopAntiRagdollV2()
    AntiRagdollV2.Enabled = false
    if AntiRagdollV2.Connection then
        AntiRagdollV2.Connection:Disconnect()
        AntiRagdollV2.Connection = nil
    end
    AntiRagdollV2.ResetCooldown = 0
end

startAntiRagdoll = function()
    startAntiRagdollV2()
end

stopAntiRagdoll = function()
    stopAntiRagdollV2()
end

local function toggleAntiRag(on)
    S.antiRagdollEnabled = (on == true)
    if S.antiRagdollEnabled then startAntiRagdoll() else stopAntiRagdoll() end
end

savedAnimate = nil

local function startUnwalk()
    local c = LP.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            t:Stop()
        end
    end
    local anim = c:FindFirstChild("Animate")
    if anim then
        if not savedAnimate then
            savedAnimate = anim:Clone()
        end
        anim:Destroy()
    end
    S.unwalkEnabled = true
end

local function stopUnwalk()
    if not S.unwalkEnabled then return end
    S.unwalkEnabled = false
    local c = LP.Character
    if c and savedAnimate then
        local existing = c:FindFirstChild("Animate")
        if existing and existing ~= savedAnimate then existing:Destroy() end
        savedAnimate.Parent = c
        savedAnimate.Disabled = false
        savedAnimate = nil
    end
end

POS = S.AP

function stopAutoLeft()
    if S.alConn then S.alConn:Disconnect(); S.alConn = nil end
    S.alPhase = 1
    local c = LP.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(Vector3.zero, false) end
    end
    if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
end

function stopAutoRight()
    if S.arConn then S.arConn:Disconnect(); S.arConn = nil end
    S.arPhase = 1
    local c = LP.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(Vector3.zero, false) end
    end
    if S.autoRightSetVisual then S.autoRightSetVisual(false) end
end

function startAutoLeft()
    if S.batBypassEnabled and S.setBatBypass then S.setBatBypass(false) end
    if S.alConn then S.alConn:Disconnect() end
    S.alPhase = 1
    S.alConn = RunService.Heartbeat:Connect(function()
        if not S.autoLeftEnabled or S._youtResetInProgress then return end
        local c = LP.Character; if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then return end
        if isSpeedRagdollState(hum) then
            hum:Move(Vector3.zero, false)
            return
        end
        local spd = S.getAutoPathSpeed()
        if S.alPhase == 1 then
            local tgt = Vector3.new(POS.L1.X, root.Position.Y, POS.L1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                S.alPhase = 2
                local d = POS.L2 - root.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.Velocity = Vector3.new(mv.X * spd, root.Velocity.Y, mv.Z * spd)
                return
            end
            local d = POS.L1 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.Velocity = Vector3.new(mv.X * spd, root.Velocity.Y, mv.Z * spd)
        elseif S.alPhase == 2 then
            local tgt = Vector3.new(POS.L2.X, root.Position.Y, POS.L2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                root.Velocity = Vector3.zero
                S.autoLeftEnabled = false
                if S.alConn then S.alConn:Disconnect(); S.alConn = nil end
                S.alPhase = 1
                if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
                if S._setPButtonActive and S._btnAAL then
                    S._setPButtonActive(S._btnAAL, S._bsAAL, S._l1AAL, S._l2AAL, false)
                end
                task.defer(S.startMovement)
                return
            end
            local d = POS.L2 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.Velocity = Vector3.new(mv.X * spd, root.Velocity.Y, mv.Z * spd)
        end
    end)
end

function startAutoRight()
    if S.batBypassEnabled and S.setBatBypass then S.setBatBypass(false) end
    if S.arConn then S.arConn:Disconnect() end
    S.arPhase = 1
    S.arConn = RunService.Heartbeat:Connect(function()
        if not S.autoRightEnabled or S._youtResetInProgress then return end
        local c = LP.Character; if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then return end
        if isSpeedRagdollState(hum) then
            hum:Move(Vector3.zero, false)
            return
        end
        local spd = S.getAutoPathSpeed()
        if S.arPhase == 1 then
            local tgt = Vector3.new(POS.R1.X, root.Position.Y, POS.R1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                S.arPhase = 2
                local d = POS.R2 - root.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.Velocity = Vector3.new(mv.X * spd, root.Velocity.Y, mv.Z * spd)
                return
            end
            local d = POS.R1 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.Velocity = Vector3.new(mv.X * spd, root.Velocity.Y, mv.Z * spd)
        elseif S.arPhase == 2 then
            local tgt = Vector3.new(POS.R2.X, root.Position.Y, POS.R2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                root.Velocity = Vector3.zero
                S.autoRightEnabled = false
                if S.arConn then S.arConn:Disconnect(); S.arConn = nil end
                S.arPhase = 1
                if S.autoRightSetVisual then S.autoRightSetVisual(false) end
                if S._setPButtonActive and S._btnAAR then
                    S._setPButtonActive(S._btnAAR, S._bsAAR, S._l1AAR, S._l2AAR, false)
                end
                task.defer(S.startMovement)
                return
            end
            local d = POS.R2 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.Velocity = Vector3.new(mv.X * spd, root.Velocity.Y, mv.Z * spd)
        end
    end)
end

-- Auto Path must never keep steering a new character after any reset/respawn.
LP.CharacterRemoving:Connect(function()
    S.autoLeftEnabled = false
    S.autoRightEnabled = false
    pcall(stopAutoLeft)
    pcall(stopAutoRight)
    if S._setPButtonActive and S._btnAAL then
        pcall(S._setPButtonActive, S._btnAAL, S._bsAAL, S._l1AAL, S._l2AAL, false)
    end
    if S._setPButtonActive and S._btnAAR then
        pcall(S._setPButtonActive, S._btnAAR, S._bsAAR, S._l1AAR, S._l2AAR, false)
    end
    if S.stopMovement then pcall(S.stopMovement) end
end)

_bubbleBatAim = {
    targetPlayer = nil,
    lastTargetPos = nil,
    targetVelocity = Vector3.zero,
    smoothedVelocity = Vector3.zero,
    velocityHistory = {},
    accelerationHistory = {},
    aerialVelocityHistory = {},
    previousDirection = nil,
    lastDirectionChangeTime = 0,
    airborneTime = 0,
    lastActivationTime = 0,
    currentPing = 0.1,
    realPingMs = 0,
    lastPingCheck = 0,
}

BUBBLE_BAT_AIM = {
    ACTIVATE_DISTANCE = 13,
    MIN_FOLLOW_DISTANCE = 1,
    PREDICTION_TIME = 0.22,
    PREDICT_AHEAD = 3,
    MAX_VELOCITY_CHANGE = 150,
    VELOCITY_SMOOTHING = 0.2,
    MAX_HORIZONTAL_VELOCITY = 80,
    SERVER_TICKRATE = 1 / 60,
    MIN_PING_COMPENSATION = 0.03,
    MAX_PING_COMPENSATION = 0.25,
    ACCELERATION_PREDICTION_WEIGHT = 0.3,
    DIRECTION_CHANGE_DETECTION_TIME = 0.12,
    QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5,
    GRAVITY = 196.2,
    AIR_CONTROL_FACTOR = 0.8,
    MIN_AIRBORNE_TIME = 0.08,
}
_batAimLastWarn = 0

local function bubbleAverage(list)
    if #list == 0 then return Vector3.zero end
    local sum = Vector3.zero
    for _, value in ipairs(list) do sum = sum + value end
    return sum / #list
end

local function bubblePush(list, value, maxCount)
    table.insert(list, value)
    if #list > maxCount then table.remove(list, 1) end
end

local function bubbleResetAimState()
    _bubbleBatAim.targetPlayer = nil
    _bubbleBatAim.lastTargetPos = nil
    _bubbleBatAim.targetVelocity = Vector3.zero
    _bubbleBatAim.smoothedVelocity = Vector3.zero
    _bubbleBatAim.velocityHistory = {}
    _bubbleBatAim.accelerationHistory = {}
    _bubbleBatAim.aerialVelocityHistory = {}
    _bubbleBatAim.previousDirection = nil
    _bubbleBatAim.airborneTime = 0
    _bubbleBatAim.lastActivationTime = 0
end

local function findAimbotBat(character)
    if not character then return nil end
    local backpack = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
    local function isBatTool(item)
        if not item or not item:IsA("Tool") then return false end
        local name = string.lower(item.Name)
        return name:find("bat", 1, true) ~= nil or name:find("slap", 1, true) ~= nil
    end
    for _, item in ipairs(character:GetChildren()) do
        if isBatTool(item) then return item end
    end
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if isBatTool(item) then return item end
        end
    end
    return nil
end

local function getAutoBatTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local now = tick()
    if now - S._autoBatLastScan <= 0.1 and S._autoBatTarget and S._autoBatTarget.Parent then
        local hum = S._autoBatTarget.Parent:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then return S._autoBatTarget end
    end
    S._autoBatLastScan = now
    S._autoBatTarget = nil
    local closest, minDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (targetRoot.Position - root.Position).Magnitude
                if distance < minDist then
                    minDist = distance
                    closest = targetRoot
                end
            end
        end
    end
    S._autoBatTarget = closest
    return closest
end

_batAimPreviousAutoRotate = nil
S.resetAutoBatMotion = function()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.3
        root.AssemblyAngularVelocity = Vector3.zero
    end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.AutoRotate = true end
    _batAimPreviousAutoRotate = nil
end

local function enableAutoBat()
    if S.autoLeftEnabled then
        S.autoLeftEnabled = false
        if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
        stopAutoLeft()
    end
    if S.autoRightEnabled then
        S.autoRightEnabled = false
        if S.autoRightSetVisual then S.autoRightSetVisual(false) end
        stopAutoRight()
    end
    S.autoBatEquippedThisRun = false
    S.batAimbotEnabled = true
end

local function disableAutoBat()
    if S.batAimbotConn then
        S.batAimbotConn:Disconnect()
        S.batAimbotConn = nil
    end
    S.batAimbotEnabled = false
    S.autoBatEquippedThisRun = false
    S._autoBatTarget = nil
    bubbleResetAimState()
    S.resetAutoBatMotion()
end

local function queueAutoBatStart()
    enableAutoBat()
end

-- Funcionamento do Bat Aimbot do Empire; o visual e os atalhos do FALLS4K são preservados.
function S.empireFindBatForAimbot() local char = LP.Character if not char then return nil end for _, tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end end local bp = LP:FindFirstChild("Backpack") if bp then for _, tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end end end return nil end 
function startBatAimbot()
    if S.batBypassEnabled and S.setBatBypass then S.setBatBypass(false) end
    if S.batAimbotConn then
        S.batAimbotConn:Disconnect()
        S.batAimbotConn = nil
    end
    queueAutoBatStart()
    S._autoBatTarget = nil
    S._autoBatLastScan = 0
    S.batAimbotConn = RunService.Heartbeat:Connect(function() if not S.batAimbotEnabled then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart") if not root then return end local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end if not char:FindFirstChildOfClass("Tool") then local bat = S.empireFindBatForAimbot() if bat then pcall(function() hum:EquipTool(bat) end) end end local now = tick() local target = S._autoBatTarget if now - (S._autoBatLastScan or 0) > 0.1 or not target or not target.Parent then S._autoBatLastScan = now target = nil local closest, minDist = nil, math.huge for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then local tRoot = plr.Character:FindFirstChild("HumanoidRootPart") local th = plr.Character:FindFirstChildOfClass("Humanoid") if tRoot and th and th.Health > 0 then local dist = (tRoot.Position - root.Position).Magnitude if dist < minDist then minDist = dist closest = tRoot end end end end target = closest S._autoBatTarget = target else local th = target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") if not th or th.Health <= 0 then S._autoBatTarget = nil target = nil end end if not target then hum.AutoRotate = true root.AssemblyAngularVelocity = Vector3.zero return end hum.AutoRotate = false local targetVel = target.AssemblyLinearVelocity local myPos = root.Position local targetPos = target.Position local predictPos = targetPos + targetVel * 0.14 predictPos = predictPos + target.CFrame.LookVector * 0.3 local direction = predictPos - myPos local flatDir = Vector3.new(direction.X, 0, direction.Z) if flatDir.Magnitude > 0.01 then flatDir = flatDir.Unit else flatDir = Vector3.new(0, 0, 1) end local chaseSpeed = 58 local desiredHeight = targetPos.Y + 3.7 local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8 if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end yVel = math.clamp(yVel, -70, 110) local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed) root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8) local speed3 = targetVel.Magnitude local predictTime = math.clamp(speed3 / 150, 0.05, 0.2) local predictedPos = targetPos + targetVel * predictTime local toPredict = predictedPos - myPos if toPredict.Magnitude > 0.1 then local goalCF = CFrame.lookAt(myPos, predictedPos) local diffCF = root.CFrame:Inverse() * goalCF local rx, ry, rz = diffCF:ToEulerAnglesXYZ() rx = math.clamp(rx, -2.5, 2.5) ry = math.clamp(ry, -2.5, 2.5) rz = math.clamp(rz, -2.5, 2.5) root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 42, ry * 42, rz * 42)) end if S.autoSwingEnabled then local bat = char:FindFirstChild("Bat") or S.empireFindBatForAimbot() if bat and bat:IsA("Tool") then pcall(function() bat:Activate() end) end end end) 
end

function stopBatAimbot()
    disableAutoBat()
end

local function disconnectTpBatAntiDie()
    for _, conn in ipairs(S.tpBatAntiDieConnections or {}) do pcall(function() conn:Disconnect() end) end
    S.tpBatAntiDieConnections = {}
end
local function hookTpBatAntiDie(character)
    disconnectTpBatAntiDie()
    if not S.tpBatEnabled or not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    pcall(function()
        humanoid.BreakJointsOnDeath = false
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dying, false)
    end)
    table.insert(S.tpBatAntiDieConnections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if S.tpBatEnabled and humanoid.Parent and humanoid.Health <= 0 then
            pcall(function() humanoid.Health = humanoid.MaxHealth; humanoid:ChangeState(Enum.HumanoidStateType.Running) end)
        end
    end))
end
local function findTpBatTool()
    local character=LP.Character
    if not character then return nil end
    local function matches(child)
        if not child:IsA("Tool") then return false end
        local name=child.Name:lower()
        return name:find("bat") or name:find("slap")
    end
    for _,child in ipairs(character:GetChildren()) do if matches(child) then return child end end
    local backpack=LP:FindFirstChildOfClass("Backpack")
    if backpack then
        for _,child in ipairs(backpack:GetChildren()) do
            if matches(child) then
                local humanoid=character:FindFirstChildOfClass("Humanoid")
                if humanoid then pcall(function() humanoid:EquipTool(child) end) end
                return child
            end
        end
    end
    return nil
end
local function findTpBatNearestTarget(root)
    if not root then return nil,math.huge end
    local best,bestDistance=nil,math.huge
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LP and player.Character then
            local otherRoot=player.Character:FindFirstChild("HumanoidRootPart")
            local otherHumanoid=player.Character:FindFirstChildOfClass("Humanoid")
            if otherRoot and otherHumanoid and otherHumanoid.Health>0 then
                local distance=(root.Position-otherRoot.Position).Magnitude
                if distance<bestDistance then bestDistance=distance; best=player end
            end
        end
    end
    return best,bestDistance
end
local function swingTpBat()
    if S.tpBatHitCooldown then return end
    S.tpBatHitCooldown=true
    pcall(function()
        local bat=findTpBatTool()
        if not bat then return end
        bat:Activate()
        local remote=bat:FindFirstChildWhichIsA("RemoteEvent")
        if remote then remote:FireServer() end
    end)
    task.delay(0.08,function() S.tpBatHitCooldown=false end)
end
local function tpBatTick()
    if not S.tpBatEnabled then return end
    local character=LP.Character
    if not character then return end
    local root=character:FindFirstChild("HumanoidRootPart")
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health<=0 then return end
    local animator=humanoid:FindFirstChildOfClass("Animator")
    if animator then pcall(function() for _,track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop() end end) end
    local bat=findTpBatTool()
    if bat and bat.Parent~=character then pcall(function() humanoid:EquipTool(bat) end) end
    local target,distance=findTpBatNearestTarget(root)
    if not target or distance>100 then return end
    local targetRoot=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    pcall(function() if root.SetNetworkOwner then root:SetNetworkOwner(nil) end end)
    if not S.tpBatEnabled or root.Parent~=character or not targetRoot.Parent then return end
    root.CFrame=CFrame.new(targetRoot.Position+Vector3.new(0,0.9,0))
    root.AssemblyLinearVelocity=targetRoot.AssemblyLinearVelocity
    pcall(function() if root.SetNetworkOwner then root:SetNetworkOwner(LP) end end)
    local currentCamera=workspace.CurrentCamera
    if currentCamera then currentCamera.CFrame=CFrame.new(currentCamera.CFrame.Position,targetRoot.Position) end
    swingTpBat()
    pcall(function() for _,descendant in ipairs(character:GetDescendants()) do if descendant:IsA("BasePart") then descendant.CanCollide=false end end end)
end
local function setTpBat(state)
    local enabled=state==true
    if enabled and S.batBypassEnabled and S.setBatBypass then S.setBatBypass(false) end
    S.tpBatEnabled=enabled; S.batTpEnabled=enabled; S._smartBatTpDriving=enabled
    if enabled then
        hookTpBatAntiDie(LP.Character)
        if S.tpBatConn then S.tpBatConn:Disconnect() end
        S.tpBatConn=RunService.Heartbeat:Connect(tpBatTick)
    else
        if S.tpBatConn then S.tpBatConn:Disconnect(); S.tpBatConn=nil end
        disconnectTpBatAntiDie()
        local character=LP.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        if root then pcall(function() if root.SetNetworkOwner then root:SetNetworkOwner(LP) end end) end
    end
end
LP.CharacterAdded:Connect(function(character)
    if S.tpBatEnabled then task.wait(0.1); hookTpBatAntiDie(character) end
end)
setBatAimbot = function(state)
    if state and S.batBypassEnabled and S.setBatBypass then S.setBatBypass(false) end
    if S.batAimbotEnabled == state then return end
    S.batAimbotEnabled = state
    if state then
        -- Every activation path keeps normal aimbot separate from Auto Path.
        if S.autoLeftEnabled then
            S.autoLeftEnabled = false
            stopAutoLeft()
            if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
        end
        if S.autoRightEnabled then
            S.autoRightEnabled = false
            stopAutoRight()
            if S.autoRightSetVisual then S.autoRightSetVisual(false) end
        end
        startBatAimbot()
    else
        stopBatAimbot()
    end
    if S.batAimbotSetVisual then S.batAimbotSetVisual(state) end
    if S._setPButtonActive and S._btnBAT then
        S._setPButtonActive(S._btnBAT, S._bsBAT, S._l1BAT, S._l2BAT, state)
    end
    S.restartMovement()
    saveConfig()
end

do
-- ===== BAT V2 (portado da primeira source / Macho Hub) =====
local BV2 = {
    on = false,
    conn = nil,
    pingConn = nil,
    cd = false,
    speed = 55,
    lastSwing = 0,
    targetPlayer = nil,
    lastTargetPos = nil,
    targetVelocity = Vector3.zero,
    smoothedVelocity = Vector3.zero,
    velocityHistory = {},
    accelerationHistory = {},
    aerialVelocityHistory = {},
    previousDirection = nil,
    lastDirectionChangeTime = 0,
    airborneTime = 0,
    lastActivationTime = 0,
    currentPing = 0.1,
    realPingMs = 0,
}

local BV2CFG = {
    FOLLOW_SPEED = 55,
    ACTIVATE_DISTANCE = 13,
    MIN_FOLLOW_DISTANCE = 1,
    PREDICTION_TIME = 0.22,
    PREDICT_AHEAD = 3,
    MAX_VELOCITY_CHANGE = 150,
    VELOCITY_SMOOTHING = 0.2,
    MAX_HORIZONTAL_VELOCITY = 80,
    SERVER_TICKRATE = 1 / 60,
    MIN_PING_COMPENSATION = 0.03,
    MAX_PING_COMPENSATION = 0.25,
    ACCELERATION_PREDICTION_WEIGHT = 0.3,
    DIRECTION_CHANGE_DETECTION_TIME = 0.12,
    QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5,
    GRAVITY = 196.2,
    AIR_CONTROL_FACTOR = 0.8,
    MIN_AIRBORNE_TIME = 0.08,
}

local function batV2FindTool()
    local char = LP.Character
    if not char then return nil end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then
        local n = equipped.Name:lower()
        if n:find("bat", 1, true) or n:find("slap", 1, true) then return equipped end
    end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
            return tool
        end
    end

    local backpack = LP:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
                return tool
            end
        end
    end
    return nil
end

local function bv2Average(history)
    if #history == 0 then return Vector3.zero end
    local total = Vector3.zero
    for _, v in ipairs(history) do total = total + v end
    return total / #history
end

local function bv2Push(history, value, maximum)
    table.insert(history, value)
    if #history > maximum then table.remove(history, 1) end
end

local function bv2ResetTarget()
    BV2.targetPlayer = nil
    BV2.lastTargetPos = nil
    BV2.targetVelocity = Vector3.zero
    BV2.smoothedVelocity = Vector3.zero
    BV2.velocityHistory = {}
    BV2.accelerationHistory = {}
    BV2.aerialVelocityHistory = {}
    BV2.previousDirection = nil
    BV2.airborneTime = 0
end

local function batV2ClosestRoot()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, math.huge end
    local closest, closestDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (targetRoot.Position - root.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closest = targetRoot
                end
            end
        end
    end
    return closest, closestDistance
end

local function bv2ClosestPlayer(root)
    local closestDistance, closestPlayer = math.huge, nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local tHum = player.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                local d = (root.Position - tRoot.Position).Magnitude
                if d < closestDistance then
                    closestDistance = d
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function bv2ApplyAngularAim(root, direction)
    if direction.Magnitude < 0.01 then return end
    local crossVector = root.CFrame.LookVector:Cross(direction.Unit)
    local angle = math.asin(math.clamp(crossVector.Magnitude, -1, 1))
    root.AssemblyAngularVelocity = crossVector.Magnitude > 0.1 and crossVector.Unit * angle * 80 or Vector3.zero
end

local function bv2UpdatePing()
    local ok, value = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and type(value) == "number" then BV2.realPingMs = math.floor(value) end
    BV2.currentPing = math.clamp(BV2.realPingMs / 1000, BV2CFG.MIN_PING_COMPENSATION, BV2CFG.MAX_PING_COMPENSATION)
end

local function batV2Swing()
    local now = tick()
    if now - (BV2.lastSwing or 0) < 0.05 then return end
    if S.autoSwingEnabled == false then return end
    BV2.lastSwing = now
    pcall(function()
        local char = LP.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local tool = batV2FindTool()
        if not tool then return end
        if tool.Parent ~= char and humanoid then
            pcall(function() humanoid:EquipTool(tool) end)
        end
        pcall(function() tool:Activate() end)
    end)
end

local function batV2Stop()
    BV2.on = false
    S.batBypassEnabled = false
    if BV2.conn then
        pcall(function() BV2.conn:Disconnect() end)
        BV2.conn = nil
    end
    BV2.pingConn = nil

    local char = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if humanoid then pcall(function() humanoid.AutoRotate = true end) end
    if root then pcall(function() root.AssemblyAngularVelocity = Vector3.zero end) end
    bv2ResetTarget()
    BV2.lastActivationTime = 0
    BV2.cd = false
    if S.setBatBypassVisual then S.setBatBypassVisual(false) end
    if S.setBatBypassRowVisual then S.setBatBypassRowVisual(false) end
    if S.restartMovement then S.restartMovement() end
end

local function batV2Start()
    if BV2.conn then
        pcall(function() BV2.conn:Disconnect() end)
        BV2.conn = nil
    end

    if S.batAimbotEnabled then setBatAimbot(false) end
    if S.tpBatEnabled then setTpBat(false) end
    if S.autoLeftEnabled then
        S.autoLeftEnabled = false; stopAutoLeft()
        if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
    end
    if S.autoRightEnabled then
        S.autoRightEnabled = false; stopAutoRight()
        if S.autoRightSetVisual then S.autoRightSetVisual(false) end
    end
    local char = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    bv2ResetTarget()
    BV2.on = true
    S.batBypassEnabled = true
    humanoid.AutoRotate = false

    local tool = batV2FindTool()
    if tool and tool.Parent ~= char then
        pcall(function() humanoid:EquipTool(tool) end)
    end

    if not BV2.pingConn then
        local generation = {}
        BV2.pingConn = generation
        task.spawn(function()
            while BV2.pingConn == generation do pcall(bv2UpdatePing); task.wait(0.5) end
        end)
    end

    BV2.conn = RunService.RenderStepped:Connect(function(deltaTime)
        if not BV2.on then batV2Stop(); return end
        if S._youtResetInProgress or S.dropBrainrotActive then return end

        BV2CFG.FOLLOW_SPEED = math.clamp(tonumber(BV2.speed) or 55, 1, 200)

        local cChar = LP.Character
        local cRoot = cChar and cChar:FindFirstChild("HumanoidRootPart")
        local cHum = cChar and cChar:FindFirstChildOfClass("Humanoid")
        if not cRoot or not cHum or cHum.Health <= 0 then batV2Stop(); return end
        cHum.AutoRotate = false
        root, humanoid = cRoot, cHum

        tool = cChar:FindFirstChildOfClass("Tool") or batV2FindTool()
        if tool and tool.Parent ~= cChar then
            pcall(function() cHum:EquipTool(tool) end)
        end

        local nextTarget = bv2ClosestPlayer(root)
        if nextTarget ~= BV2.targetPlayer then bv2ResetTarget() end
        BV2.targetPlayer = nextTarget
        local tChar = BV2.targetPlayer and BV2.targetPlayer.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        if not tRoot or not tHum or tHum.Health <= 0 then bv2ResetTarget(); return end

        local targetPos = tRoot.Position
        local safeDt = math.max(deltaTime, 1 / 240)

        if BV2.lastTargetPos then
            local rawVelocity = (targetPos - BV2.lastTargetPos) / safeDt
            local velocityDelta = rawVelocity - BV2.targetVelocity
            if velocityDelta.Magnitude > BV2CFG.MAX_VELOCITY_CHANGE then
                rawVelocity = BV2.targetVelocity + velocityDelta.Unit * BV2CFG.MAX_VELOCITY_CHANGE
            end
            local horizontal = Vector3.new(rawVelocity.X, 0, rawVelocity.Z)
            if horizontal.Magnitude > BV2CFG.MAX_HORIZONTAL_VELOCITY then
                horizontal = horizontal.Unit * BV2CFG.MAX_HORIZONTAL_VELOCITY
                rawVelocity = Vector3.new(horizontal.X, rawVelocity.Y, horizontal.Z)
            end
            bv2Push(BV2.accelerationHistory, (rawVelocity - BV2.targetVelocity) / safeDt, 4)
            bv2Push(BV2.velocityHistory, rawVelocity, 8)
            BV2.targetVelocity = rawVelocity
            BV2.smoothedVelocity = BV2.smoothedVelocity:Lerp(rawVelocity, BV2CFG.VELOCITY_SMOOTHING)
        end
        BV2.lastTargetPos = targetPos

        local airborne = tHum.FloorMaterial == Enum.Material.Air
        BV2.airborneTime = airborne and (BV2.airborneTime + safeDt) or 0
        if airborne and BV2.airborneTime >= BV2CFG.MIN_AIRBORNE_TIME then
            bv2Push(BV2.aerialVelocityHistory, BV2.targetVelocity, 6)
        elseif not airborne then
            BV2.aerialVelocityHistory = {}
        end

        local predictionVelocity = BV2.smoothedVelocity
        if airborne and #BV2.aerialVelocityHistory > 0 then
            local aerial = bv2Average(BV2.aerialVelocityHistory)
            predictionVelocity = Vector3.new(aerial.X, BV2.targetVelocity.Y, aerial.Z) * BV2CFG.AIR_CONTROL_FACTOR
        end

        local quickTurn = false
        local horizontalVelocity = Vector3.new(BV2.targetVelocity.X, 0, BV2.targetVelocity.Z)
        if horizontalVelocity.Magnitude > 5 then
            local direction = horizontalVelocity.Unit
            if BV2.previousDirection and BV2.previousDirection:Dot(direction) < 0.5 then
                quickTurn = tick() - BV2.lastDirectionChangeTime < BV2CFG.DIRECTION_CHANGE_DETECTION_TIME
                BV2.lastDirectionChangeTime = tick()
            end
            BV2.previousDirection = direction
        end

        local serverDelay = BV2.currentPing + BV2CFG.SERVER_TICKRATE
        if quickTurn then serverDelay *= BV2CFG.QUICK_DIRECTION_CHANGE_MULTIPLIER end

        local predicted = targetPos + predictionVelocity * serverDelay
            + bv2Average(BV2.accelerationHistory) * BV2CFG.ACCELERATION_PREDICTION_WEIGHT * serverDelay * serverDelay * 0.5

        local leadTime = BV2CFG.PREDICTION_TIME * 1.1
        if airborne then
            predicted += predictionVelocity * leadTime + Vector3.new(0, -0.5 * BV2CFG.GRAVITY * leadTime * leadTime, 0)
        else
            predicted += predictionVelocity * leadTime
        end

        local flatPrediction = Vector3.new(predictionVelocity.X, 0, predictionVelocity.Z)
        if flatPrediction.Magnitude > 1 then
            predicted += flatPrediction.Unit * BV2CFG.PREDICT_AHEAD
        end

        local toTarget = predicted - root.Position
        bv2ApplyAngularAim(root, toTarget)

        if (targetPos - root.Position).Magnitude <= BV2CFG.ACTIVATE_DISTANCE
            and tick() - BV2.lastActivationTime >= 0.3 then
            if tool then pcall(function() tool:Activate() end) end
            BV2.lastActivationTime = tick()
        end

        if toTarget.Magnitude > BV2CFG.MIN_FOLLOW_DISTANCE then
            root.AssemblyLinearVelocity = toTarget.Unit * BV2CFG.FOLLOW_SPEED
        else
            root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y * 0.5, 0)
        end
    end)
end



S.setBatBypass = function(enabled)
    if enabled == true then
        batV2Start()
    else
        batV2Stop()
    end
    if S.setBatBypassVisual then S.setBatBypassVisual(BV2.on == true) end
    if updateFloatingButtons then updateFloatingButtons() end
end
S.toggleBatBypass = function()
    S.setBatBypass(not S.batBypassEnabled)
end
_G._DaHubBatBypassCleanup = batV2Stop
LP.CharacterRemoving:Connect(function()
    if BV2.on then batV2Stop() end
end)
end -- prime.vs Bat V2 isolated module

-- EMBER V1-V4 + original FALLS4K V5. Engines are private and mutually exclusive.
do
    local Engines = {}
    local disposed = false
    S.batBypassVersion = S.batBypassVersion or "v5"
    S.batBypassSpeed = S.batBypassSpeed or 58
    local originalSet = S.setBatBypass
    local originalCleanup = _G._DaHubBatBypassCleanup
    local activeEngine = nil
    local v1Connection = nil
    local lastSwing = 0
    local function nearest(root)
        local target, distance = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                local other = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if other and hum and hum.Health > 0 then
                    local d = (other.Position - root.Position).Magnitude
                    if d < distance then target, distance = other, d end
                end
            end
        end
        return target, distance
    end
    Engines.v1 = {
        Start = function()
            local character = LP.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            humanoid.AutoRotate = false
            lastSwing = 0
            v1Connection = RunService.RenderStepped:Connect(function()
                if not S.batBypassEnabled then return end
                local char = LP.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 0 then return end
                local bat = S.empireFindBatForAimbot()
                if bat and bat.Parent ~= char then pcall(function() hum:EquipTool(bat) end) end
                local target, distance = nearest(root)
                if not target then
                    hum.AutoRotate = true
                    root.AssemblyAngularVelocity = Vector3.zero
                    return
                end
                hum.AutoRotate = false
                local myPos, targetPos = root.Position, target.Position
                local direction = targetPos - myPos
                local flat = Vector3.new(direction.X, 0, direction.Z)
                flat = flat.Magnitude > 0 and flat.Unit or Vector3.zero
                local speed = math.clamp(tonumber(S.batBypassSpeed) or 58, 1, 500)
                local yVel = (targetPos.Y + 3.7 - myPos.Y) * 19.5
                if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end
                yVel = math.clamp(yVel, -70, 110)
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(Vector3.new(flat.X * speed, yVel, flat.Z * speed), 0.8)
                if direction.Magnitude > 0.1 then
                    local diff = root.CFrame:Inverse() * CFrame.lookAt(myPos, targetPos)
                    local rx, ry, rz = diff:ToEulerAnglesXYZ()
                    root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(
                        math.clamp(rx, -2.5, 2.5) * 42,
                        math.clamp(ry, -2.5, 2.5) * 42,
                        math.clamp(rz, -2.5, 2.5) * 42))
                end
                if distance <= 8 and bat and tick() - lastSwing >= 0.08 then
                    lastSwing = tick()
                    pcall(function() bat:Activate() end)
                end
            end)
        end,
        Stop = function()
            if v1Connection then v1Connection:Disconnect(); v1Connection = nil end
        end,
        IsEnabled = function() return v1Connection ~= nil end,
    }
do
    local state = {
        enabled = false,
        connection = nil,
        autoSwing = true,
        approachSpeed = 58,
        laggerSpeed = 40,
        useLaggerSpeed = false,
        predCache = {},
        moverName = "Blast_AimbotV2_LV",
        attachmentName = "Blast_AimbotV2_Att",
        minForce = 1000000,
        maxForce = 50000000,
    }

    local function getCharacterParts()
        local char = LP.Character
        if not char then return nil, nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return nil, nil end
        return hrp, hum
    end

    local function getBatTool()
        local char = LP.Character
        if not char then return nil end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local n = string.lower(child.Name)
                if string.find(n, "bat", 1, true) or string.find(n, "slap", 1, true) then return child end
            end
        end
        local backpack = LP:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if child:IsA("Tool") then
                    local n = string.lower(child.Name)
                    if string.find(n, "bat", 1, true) or string.find(n, "slap", 1, true) then return child end
                end
            end
        end
        return nil
    end

    local function nearestTarget(fromPos)
        local bestDist, bestHRP = math.huge, nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - fromPos).Magnitude
                    if dist < bestDist then bestDist, bestHRP = dist, hrp end
                end
            end
        end
        return bestHRP
    end

    local function clearMover(hrp)
        if not hrp then return end
        local lv = hrp:FindFirstChild(state.moverName)
        local att = hrp:FindFirstChild(state.attachmentName)
        if lv and lv:IsA("LinearVelocity") then lv:Destroy() end
        if att and att:IsA("Attachment") then att:Destroy() end
    end

    local function ensureMover(hrp, speed)
        local att = hrp:FindFirstChild(state.attachmentName)
        if not att or not att:IsA("Attachment") then
            if att then att:Destroy() end
            att = Instance.new("Attachment")
            att.Name = state.attachmentName
            att.Parent = hrp
        end
        local lv = hrp:FindFirstChild(state.moverName)
        if not lv or not lv:IsA("LinearVelocity") then
            if lv then lv:Destroy() end
            lv = Instance.new("LinearVelocity")
            lv.Name = state.moverName
            lv.Attachment0 = att
            lv.RelativeTo = Enum.ActuatorRelativeTo.World
            lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            lv.ForceLimitsEnabled = true
            lv.ForceLimitMode = Enum.ForceLimitMode.PerAxis
            lv.VectorVelocity = Vector3.zero
            lv.Parent = hrp
        else
            lv.Attachment0 = att
        end
        local force = math.clamp(hrp.AssemblyMass * math.max(speed * 220, 6000), state.minForce, state.maxForce)
        lv.MaxAxesForce = Vector3.new(force, force, force)
        lv.Enabled = true
        return lv
    end

    local function applyMove(hrp, desiredVel, speed, dt)
        local lv = ensureMover(hrp, speed)
        local alpha = 1 - math.exp(-math.max(dt, 0) * 26)
        lv.VectorVelocity = lv.VectorVelocity:Lerp(desiredVel, alpha)
    end

    local function resetMotion()
        local character = LP.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if hrp then
            clearMover(hrp)
            hrp.Anchored = false
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            local look = hrp.CFrame.LookVector
            local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude > 0.01 then flat = flat.Unit else flat = Vector3.new(0, 0, -1) end
            hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flat)
        end
        if hum then
            hum.AutoRotate = true
            hum.PlatformStand = false
            pcall(function() hum:Move(Vector3.zero, false) end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
    end

    local function update(dt)
        if not state.enabled then return end
        if not S.batBypassEnabled then return end
        local hrp, hum = getCharacterParts()
        if not hrp or not hum then clearMover(hrp) return end
        local target = nearestTarget(hrp.Position)
        if not target then
            hum.AutoRotate = true
            hrp.AssemblyAngularVelocity = Vector3.zero
            clearMover(hrp)
            return
        end
        local speed = state.useLaggerSpeed and state.laggerSpeed or state.approachSpeed
        local configuredSpeed = S.batBypassSpeed
        speed = math.clamp(tonumber(configuredSpeed) or speed, 1, 500)
        local now = tick()
        local cache = state.predCache[target]
        local predictedVel = Vector3.zero
        if not cache then
            state.predCache[target] = { pos = target.Position, time = now, vel = Vector3.zero }
        else
            local dtPred = math.clamp(now - cache.time, 1/120, 0.25)
            local rawVel = (target.Position - cache.pos) / dtPred
            if rawVel.Magnitude > 80 then rawVel = rawVel.Unit * 80 end
            cache.vel = cache.vel:Lerp(rawVel, 0.25)
            cache.pos = target.Position
            cache.time = now
            predictedVel = cache.vel
        end
        local lookAhead = math.clamp(predictedVel.Magnitude / 130, 0.05, 0.12)
        local aimPoint = target.Position + predictedVel * lookAhead + Vector3.new(0, 1, 0)
        hum.AutoRotate = false
        local toTarget = aimPoint - hrp.Position
        local flatDir = Vector3.new(toTarget.X, 0, toTarget.Z)
        if toTarget.Magnitude > 0.01 and flatDir.Magnitude > 0.01 then
            local yawDelta = (math.deg(math.atan2(-flatDir.X, -flatDir.Z)) - hrp.Orientation.Y + 180) % 360 - 180
            local pitchDelta = (math.deg(math.atan2(toTarget.Y, flatDir.Magnitude)) - hrp.Orientation.X + 180) % 360 - 180
            local yawForce = math.clamp(math.rad(yawDelta) * 285, -28, 28)
            local pitchForce = math.clamp(math.rad(pitchDelta) * 285, -28, 28)
            local right = Vector3.new(math.cos(math.rad(hrp.Orientation.Y)), 0, -math.sin(math.rad(hrp.Orientation.Y)))
            hrp.AssemblyAngularVelocity = Vector3.new(0, yawForce, 0) + right * pitchForce
        else
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        local moveVec = (aimPoint + Vector3.new(0, 4.75, 0) - hrp.Position)
        local flatMove = Vector3.new(moveVec.X, 0, moveVec.Z)
        local horizontal = flatMove.Magnitude > 0.1 and flatMove.Unit * speed or Vector3.zero
        local vertical = math.abs(moveVec.Y) > 0.1 and Vector3.new(0, math.sign(moveVec.Y) * 52, 0) or Vector3.new(0, -2, 0)
        applyMove(hrp, horizontal + vertical, speed, dt)
        if flatMove.Magnitude > 0.5 then hum:Move(flatMove.Unit, false) end
        if state.autoSwing then
            local bat = getBatTool()
            if bat and bat.Parent == LP.Character then pcall(function() bat:Activate() end) end
        end
    end

    local AimbotV2 = {}
    function AimbotV2.Start(opts)
        opts = opts or {}
        if state.enabled then
            AimbotV2.Stop()
        end
        state.enabled = true
        state.autoSwing = opts.autoSwing ~= false
        if true == false then state.autoSwing = false end
        local configuredSpeed = S.batBypassSpeed
        state.approachSpeed = tonumber(opts.speed) or tonumber(configuredSpeed) or 58
        state.laggerSpeed = tonumber(opts.laggerSpeed) or 40
        state.useLaggerSpeed = opts.useLaggerSpeed == true
        state.predCache = {}
        local _, hum = getCharacterParts()
        if hum then
            local bat = getBatTool()
            if bat and bat.Parent ~= LP.Character then pcall(function() hum:EquipTool(bat) end) end
        end
        clearMover(select(1, getCharacterParts()))
        state.connection = RunService.RenderStepped:Connect(update)
        -- Connection belongs to this engine.
    end
    function AimbotV2.Stop()
        if not state.enabled and not state.connection then return end
        state.enabled = false
        if state.connection then state.connection:Disconnect() state.connection = nil end
        -- Connection cleared above.
        resetMotion()
        state.predCache = {}
    end
    function AimbotV2.IsEnabled() return state.enabled end
    function AimbotV2.SetLaggerMode(active) state.useLaggerSpeed = active == true end
    function AimbotV2.SetAutoSwing(active) state.autoSwing = active == true end
    function AimbotV2.SetSpeed(normal, lagger)
        if normal then state.approachSpeed = math.clamp(tonumber(normal) or 58, 1, 500) end
        if lagger then state.laggerSpeed = math.clamp(tonumber(lagger) or 40, 1, 500) end
    end

    Engines.v2 = AimbotV2
    -- Engine remains private to FALLS4K.
end

-- ============================================================
-- AIMBOT V3 = BAT BYPASS (retirado do Fluxo.Vs)
-- ============================================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local localPlayer = Players.LocalPlayer
    local BAT_V2_SPEED, BAT_V2_HIT_DIST, BAT_V2_LEAD_STUDS = 55, 13, 3
    local snowVS = { BatBypass = {} }
    do
        local batBypass = snowVS.BatBypass
        batBypass.Enabled = batBypass.Enabled or false
        batBypass.Connection = batBypass.Connection or nil
        batBypass.Z = batBypass.Z
            or {
                targetPlayer = nil,
                lastTargetPos = nil,
                targetVelocity = Vector3.zero,
                smoothedVelocity = Vector3.zero,
                velocityHistory = {},
                accelerationHistory = {},
                aerialVelocityHistory = {},
                previousDirection = nil,
                lastDirectionChangeTime = 0,
                airborneTime = 0,
                lastActivationTime = 0,
                currentPing = 0.1,
                realPingMs = 0,
            }
        batBypass.ZCFG = batBypass.ZCFG
            or {
                FOLLOW_SPEED = BAT_V2_SPEED,
                ACTIVATE_DISTANCE = BAT_V2_HIT_DIST,
                MIN_FOLLOW_DISTANCE = 1,
                PREDICTION_TIME = 0.22,
                PREDICT_AHEAD = BAT_V2_LEAD_STUDS,
                MAX_VELOCITY_CHANGE = 150,
                VELOCITY_SMOOTHING = 0.2,
                MAX_HORIZONTAL_VELOCITY = 80,
                SERVER_TICKRATE = 0.016666666666666666,
                MIN_PING_COMPENSATION = 0.03,
                MAX_PING_COMPENSATION = 0.25,
                ACCELERATION_PREDICTION_WEIGHT = 0.3,
                DIRECTION_CHANGE_DETECTION_TIME = 0.12,
                QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5,
                GRAVITY = 196.2,
                AIR_CONTROL_FACTOR = 0.8,
                MIN_AIRBORNE_TIME = 0.08,
            }
        local function averageVectors(vectors)
            if #vectors == 0 then
                return Vector3.zero
            end
            local sum = Vector3.zero
            for _, entry in ipairs(vectors) do
                sum += entry
            end
            return sum / #vectors
        end
        local function pushBounded(history, entry, maxEntries)
            table.insert(history, entry)
            if #history > maxEntries then
                table.remove(history, 1)
            end
        end
        batBypass.FindBat = function()
            local character = localPlayer.Character
            if not character then
                return nil
            end
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                local lowercaseText = tool.Name:lower()
                if lowercaseText:find("bat", 1, true) or lowercaseText:find("slap", 1, true) then
                    return tool
                end
            end
            local backpack = localPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, child in ipairs(backpack:GetChildren()) do
                    if child:IsA("Tool") then
                        local lowercaseText = child.Name:lower()
                        if lowercaseText:find("bat", 1, true) or lowercaseText:find("slap", 1, true) then
                            return child
                        end
                    end
                end
            end
            return nil
        end
        local function resetPredictionState()
            local z = batBypass.Z
            z.targetPlayer = nil
            z.lastTargetPos = nil
            z.targetVelocity = Vector3.zero
            z.smoothedVelocity = Vector3.zero
            z.velocityHistory = {}
            z.accelerationHistory = {}
            z.aerialVelocityHistory = {}
            z.previousDirection = nil
            z.airborneTime = 0
        end
        local function findClosestPlayer(rootPart)
            local closestDistance = math.huge
            local closestPlayer = nil
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoidRootPart and humanoid and humanoid.Health > 0 then
                        local magnitude = (rootPart.Position - humanoidRootPart.Position).Magnitude
                        if magnitude < closestDistance then
                            closestDistance = magnitude
                            closestPlayer = player
                        end
                    end
                end
            end
            return closestPlayer
        end
        local function applyAngularAim(rootPart, direction)
            if direction.Magnitude < 0.01 then
                return
            end
            local crossVector = rootPart.CFrame.LookVector:Cross(direction.Unit)
            local angle = math.asin(math.clamp(crossVector.Magnitude, -1, 1))
            rootPart.AssemblyAngularVelocity = crossVector.Magnitude > 0.1 and crossVector.Unit * angle * 80
                or Vector3.zero
        end
        local function updatePing()
            local ok, result = pcall(function()
                return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            local z = batBypass.Z
            if ok and type(result) == "number" then
                z.realPingMs = math.floor(result)
            end
            z.currentPing = math.clamp(
                z.realPingMs / 1000,
                batBypass.ZCFG.MIN_PING_COMPENSATION,
                batBypass.ZCFG.MAX_PING_COMPENSATION
            )
        end
        batBypass.PingGeneration = 0
        batBypass.StartBodyLock = function() end
        batBypass.StopBodyLock = function() end
        batBypass.Stop = function()
            local z = batBypass.Z
            batBypass.Enabled = false
            batBypass.PingGeneration = batBypass.PingGeneration + 1
            if batBypass.Connection then
                batBypass.Connection:Disconnect()
                batBypass.Connection = nil
            end
            local character = localPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            character = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid then
                humanoid.AutoRotate = true
            end
            if character then
                character.AssemblyAngularVelocity = Vector3.zero
            end
            resetPredictionState()
            z.lastActivationTime = 0
        end
        batBypass.Start = function()
            if batBypass.Connection then
                return
            end
            local character = localPlayer.Character
            local humanoid1387 = character and character:FindFirstChildOfClass("Humanoid")
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoid1387 or not rootPart then
                return
            end
            batBypass.Enabled = true
            batBypass.PingGeneration = batBypass.PingGeneration + 1
            local pingGeneration = batBypass.PingGeneration
            pcall(updatePing)
            task.spawn(function()
                while batBypass.Enabled and batBypass.PingGeneration == pingGeneration and not disposed do
                    pcall(updatePing)
                    task.wait(0.5)
                end
            end)
            humanoid1387.AutoRotate = false
            local tool = batBypass.FindBat()
            if tool and tool.Parent ~= character then
                pcall(function()
                    humanoid1387:EquipTool(tool)
                end)
            end
            batBypass.Connection = RunService.RenderStepped:Connect(function(deltaTime)
                if not batBypass.Enabled then
                    batBypass.Stop()
                    return
                end
                local z = batBypass.Z
                local zcfg = batBypass.ZCFG
                zcfg.FOLLOW_SPEED = math.clamp(tonumber(S.batBypassSpeed) or BAT_V2_SPEED, 1, 500)
                local character2 = localPlayer.Character
                local rootPart1394 = character2 and character2:FindFirstChild("HumanoidRootPart")
                local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")
                if not rootPart1394 or not humanoid or humanoid.Health <= 0 then
                    return
                end
                humanoid.AutoRotate = false
                rootPart = rootPart1394
                humanoid1387 = humanoid
                tool = character2:FindFirstChildOfClass("Tool") or batBypass.FindBat()
                if tool and tool.Parent ~= character2 then
                    pcall(humanoid.EquipTool, humanoid, tool)
                end
                z.targetPlayer = findClosestPlayer(rootPart)
                local character3 = z.targetPlayer and z.targetPlayer.Character
                local rootPart1442 = character3 and character3:FindFirstChild("HumanoidRootPart")
                character3 = character3 and character3:FindFirstChildOfClass("Humanoid")
                if not rootPart1442 or not character3 or character3.Health <= 0 then
                    resetPredictionState()
                    return
                end
                local position = rootPart1442.Position
                local sampleDeltaTime = math.max(deltaTime, 0.0041666666666666666)
                if z.lastTargetPos then
                    local targetVelocity = (position - z.lastTargetPos) / sampleDeltaTime
                    local vector = targetVelocity - z.targetVelocity
                    if zcfg.MAX_VELOCITY_CHANGE < vector.Magnitude then
                        targetVelocity = z.targetVelocity + vector.Unit * zcfg.MAX_VELOCITY_CHANGE
                    end
                    local vector3 = Vector3.new(targetVelocity.X, 0, targetVelocity.Z)
                    if vector3.Magnitude > zcfg.MAX_HORIZONTAL_VELOCITY then
                        local vector = vector3.Unit * zcfg.MAX_HORIZONTAL_VELOCITY
                        targetVelocity = Vector3.new(vector.X, targetVelocity.Y, vector.Z)
                    end
                    pushBounded(z.accelerationHistory, (targetVelocity - z.targetVelocity) / sampleDeltaTime, 4)
                    pushBounded(z.velocityHistory, targetVelocity, 8)
                    z.targetVelocity = targetVelocity
                    z.smoothedVelocity = z.smoothedVelocity:Lerp(targetVelocity, zcfg.VELOCITY_SMOOTHING)
                end
                z.lastTargetPos = position
                local isAirborne = character3.FloorMaterial == Enum.Material.Air
                z.airborneTime = isAirborne and z.airborneTime + sampleDeltaTime or 0
                if isAirborne and z.airborneTime >= zcfg.MIN_AIRBORNE_TIME then
                    pushBounded(z.aerialVelocityHistory, z.targetVelocity, 6)
                elseif not isAirborne then
                    z.aerialVelocityHistory = {}
                end
                local smoothedVelocity = z.smoothedVelocity
                if isAirborne and #z.aerialVelocityHistory > 0 then
                    local vector = averageVectors(z.aerialVelocityHistory)
                    smoothedVelocity = Vector3.new(vector.X, z.targetVelocity.Y, vector.Z) * zcfg.AIR_CONTROL_FACTOR
                end
                local changedDirectionQuickly = false
                local vector3 = Vector3.new(z.targetVelocity.X, 0, z.targetVelocity.Z)
                if vector3.Magnitude > 5 then
                    local unit = vector3.Unit
                    if z.previousDirection and z.previousDirection:Dot(unit) < 0.5 then
                        local lastDirectionChangeTime = z.lastDirectionChangeTime
                        changedDirectionQuickly = tick() - lastDirectionChangeTime
                            < zcfg.DIRECTION_CHANGE_DETECTION_TIME
                        z.lastDirectionChangeTime = tick()
                    end
                    z.previousDirection = unit
                end
                local predictionTime = z.currentPing + zcfg.SERVER_TICKRATE
                if changedDirectionQuickly then
                    predictionTime *= zcfg.QUICK_DIRECTION_CHANGE_MULTIPLIER
                end
                local accelerationPredictionWeight = zcfg.ACCELERATION_PREDICTION_WEIGHT
                local predictedPosition = position
                    + smoothedVelocity * predictionTime
                    + averageVectors(z.accelerationHistory)
                        * accelerationPredictionWeight
                        * predictionTime
                        * predictionTime
                        * 0.5
                local leadTime = zcfg.PREDICTION_TIME * 1.1
                local leadPosition
                if isAirborne then
                    leadPosition = predictedPosition
                        + smoothedVelocity * leadTime
                        + Vector3.new(0, -0.5 * zcfg.GRAVITY * leadTime * leadTime, 0)
                else
                    leadPosition = predictedPosition + smoothedVelocity * leadTime
                end
                local vector4 = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z)
                if vector4.Magnitude > 1 then
                    leadPosition += vector4.Unit * zcfg.PREDICT_AHEAD
                end
                local targetDirection = leadPosition - rootPart.Position
                applyAngularAim(rootPart, targetDirection)
                local withinActivationRange = (position - rootPart.Position).Magnitude <= zcfg.ACTIVATE_DISTANCE
                if withinActivationRange then
                    local lastActivationTime = z.lastActivationTime
                    withinActivationRange = tick() - lastActivationTime >= 0.3
                end
                if withinActivationRange then
                    if tool then
                        pcall(tool.Activate, tool)
                    end
                    z.lastActivationTime = tick()
                end
                if zcfg.MIN_FOLLOW_DISTANCE < targetDirection.Magnitude then
                    rootPart.AssemblyLinearVelocity = targetDirection.Unit * zcfg.FOLLOW_SPEED
                else
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y * 0.5, 0)
                end
            end)
        end
        batBypass.Toggle = function()
            if batBypass.Enabled then
                batBypass.Stop()
            else
                batBypass.Start()
            end
        end
    end
    Engines.v3 = {
        Start = function() snowVS.BatBypass.Start() end,
        Stop = function() snowVS.BatBypass.Stop() end,
        IsEnabled = function() return snowVS.BatBypass.Enabled end,
    }
end

-- ============================================================
-- AIMBOT V4 = BAT BYPASS (retirado do Clean)
-- ============================================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local localPlayer = Players.LocalPlayer
    local BAT_V2_SPEED, BAT_V2_HIT_DIST, BAT_V2_LEAD_STUDS = 55, 13, 3
    local snowVS = { BatBypass = {} }
    do
        local batBypass = snowVS.BatBypass
        batBypass.Enabled = batBypass.Enabled or false
        batBypass.Connection = batBypass.Connection or nil
        batBypass.Z = batBypass.Z
            or {
                targetPlayer = nil,
                lastTargetPos = nil,
                targetVelocity = Vector3.zero,
                smoothedVelocity = Vector3.zero,
                velocityHistory = {},
                accelerationHistory = {},
                aerialVelocityHistory = {},
                previousDirection = nil,
                lastDirectionChangeTime = 0,
                airborneTime = 0,
                lastActivationTime = 0,
                currentPing = 0.1,
                realPingMs = 0,
            }
        batBypass.ZCFG = batBypass.ZCFG
            or {
                FOLLOW_SPEED = BAT_V2_SPEED,
                ACTIVATE_DISTANCE = BAT_V2_HIT_DIST,
                MIN_FOLLOW_DISTANCE = 1,
                PREDICTION_TIME = 0.22,
                PREDICT_AHEAD = BAT_V2_LEAD_STUDS,
                MAX_VELOCITY_CHANGE = 150,
                VELOCITY_SMOOTHING = 0.2,
                MAX_HORIZONTAL_VELOCITY = 80,
                SERVER_TICKRATE = 0.016666666666666666,
                MIN_PING_COMPENSATION = 0.03,
                MAX_PING_COMPENSATION = 0.25,
                ACCELERATION_PREDICTION_WEIGHT = 0.3,
                DIRECTION_CHANGE_DETECTION_TIME = 0.12,
                QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5,
                GRAVITY = 196.2,
                AIR_CONTROL_FACTOR = 0.8,
                MIN_AIRBORNE_TIME = 0.08,
            }
        local function averageVectors(vectors)
            if #vectors == 0 then
                return Vector3.zero
            end
            local sum = Vector3.zero
            for _, entry in ipairs(vectors) do
                sum += entry
            end
            return sum / #vectors
        end
        local function pushBounded(history, entry, maxEntries)
            table.insert(history, entry)
            if #history > maxEntries then
                table.remove(history, 1)
            end
        end
        batBypass.FindBat = function()
            local character = localPlayer.Character
            if not character then
                return nil
            end
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                local lowercaseText = tool.Name:lower()
                if lowercaseText:find("bat", 1, true) or lowercaseText:find("slap", 1, true) then
                    return tool
                end
            end
            local backpack = localPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, child in ipairs(backpack:GetChildren()) do
                    if child:IsA("Tool") then
                        local lowercaseText = child.Name:lower()
                        if lowercaseText:find("bat", 1, true) or lowercaseText:find("slap", 1, true) then
                            return child
                        end
                    end
                end
            end
            return nil
        end
        local function resetPredictionState()
            local z = batBypass.Z
            z.targetPlayer = nil
            z.lastTargetPos = nil
            z.targetVelocity = Vector3.zero
            z.smoothedVelocity = Vector3.zero
            z.velocityHistory = {}
            z.accelerationHistory = {}
            z.aerialVelocityHistory = {}
            z.previousDirection = nil
            z.airborneTime = 0
        end
        local function findClosestPlayer(rootPart)
            local closestDistance = math.huge
            local closestPlayer = nil
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoidRootPart and humanoid and humanoid.Health > 0 then
                        local magnitude = (rootPart.Position - humanoidRootPart.Position).Magnitude
                        if magnitude < closestDistance then
                            closestDistance = magnitude
                            closestPlayer = player
                        end
                    end
                end
            end
            return closestPlayer
        end
        local function applyAngularAim(rootPart, direction)
            if direction.Magnitude < 0.01 then
                return
            end
            local crossVector = rootPart.CFrame.LookVector:Cross(direction.Unit)
            local angle = math.asin(math.clamp(crossVector.Magnitude, -1, 1))
            rootPart.AssemblyAngularVelocity = crossVector.Magnitude > 0.1 and crossVector.Unit * angle * 80
                or Vector3.zero
        end
        local function updatePing()
            local ok, result = pcall(function()
                return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            local z = batBypass.Z
            if ok and type(result) == "number" then
                z.realPingMs = math.floor(result)
            end
            z.currentPing = math.clamp(
                z.realPingMs / 1000,
                batBypass.ZCFG.MIN_PING_COMPENSATION,
                batBypass.ZCFG.MAX_PING_COMPENSATION
            )
        end
        batBypass.PingGeneration = 0
        batBypass.StartBodyLock = function() end
        batBypass.StopBodyLock = function() end
        batBypass.Stop = function()
            local z = batBypass.Z
            batBypass.Enabled = false
            batBypass.PingGeneration = batBypass.PingGeneration + 1
            if batBypass.Connection then
                batBypass.Connection:Disconnect()
                batBypass.Connection = nil
            end
            local character = localPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            character = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid then
                humanoid.AutoRotate = true
            end
            if character then
                character.AssemblyAngularVelocity = Vector3.zero
            end
            resetPredictionState()
            z.lastActivationTime = 0
        end
        batBypass.Start = function()
            if batBypass.Connection then
                return
            end
            local character = localPlayer.Character
            local humanoid1387 = character and character:FindFirstChildOfClass("Humanoid")
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoid1387 or not rootPart then
                return
            end
            batBypass.Enabled = true
            batBypass.PingGeneration = batBypass.PingGeneration + 1
            local pingGeneration = batBypass.PingGeneration
            pcall(updatePing)
            task.spawn(function()
                while batBypass.Enabled and batBypass.PingGeneration == pingGeneration and not disposed do
                    pcall(updatePing)
                    task.wait(0.5)
                end
            end)
            humanoid1387.AutoRotate = false
            local tool = batBypass.FindBat()
            if tool and tool.Parent ~= character then
                pcall(function()
                    humanoid1387:EquipTool(tool)
                end)
            end
            batBypass.Connection = RunService.RenderStepped:Connect(function(deltaTime)
                if not batBypass.Enabled then
                    batBypass.Stop()
                    return
                end
                local z = batBypass.Z
                local zcfg = batBypass.ZCFG
                zcfg.FOLLOW_SPEED = math.clamp(tonumber(S.batBypassSpeed) or BAT_V2_SPEED, 1, 500)
                local character2 = localPlayer.Character
                local rootPart1394 = character2 and character2:FindFirstChild("HumanoidRootPart")
                local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")
                if not rootPart1394 or not humanoid or humanoid.Health <= 0 then
                    return
                end
                humanoid.AutoRotate = false
                rootPart = rootPart1394
                humanoid1387 = humanoid
                tool = character2:FindFirstChildOfClass("Tool") or batBypass.FindBat()
                if tool and tool.Parent ~= character2 then
                    pcall(humanoid.EquipTool, humanoid, tool)
                end
                z.targetPlayer = findClosestPlayer(rootPart)
                local character3 = z.targetPlayer and z.targetPlayer.Character
                local rootPart1442 = character3 and character3:FindFirstChild("HumanoidRootPart")
                character3 = character3 and character3:FindFirstChildOfClass("Humanoid")
                if not rootPart1442 or not character3 or character3.Health <= 0 then
                    resetPredictionState()
                    return
                end
                local position = rootPart1442.Position
                local sampleDeltaTime = math.max(deltaTime, 0.0041666666666666666)
                if z.lastTargetPos then
                    local targetVelocity = (position - z.lastTargetPos) / sampleDeltaTime
                    local vector = targetVelocity - z.targetVelocity
                    if zcfg.MAX_VELOCITY_CHANGE < vector.Magnitude then
                        targetVelocity = z.targetVelocity + vector.Unit * zcfg.MAX_VELOCITY_CHANGE
                    end
                    local vector3 = Vector3.new(targetVelocity.X, 0, targetVelocity.Z)
                    if vector3.Magnitude > zcfg.MAX_HORIZONTAL_VELOCITY then
                        local vector = vector3.Unit * zcfg.MAX_HORIZONTAL_VELOCITY
                        targetVelocity = Vector3.new(vector.X, targetVelocity.Y, vector.Z)
                    end
                    pushBounded(z.accelerationHistory, (targetVelocity - z.targetVelocity) / sampleDeltaTime, 4)
                    pushBounded(z.velocityHistory, targetVelocity, 8)
                    z.targetVelocity = targetVelocity
                    z.smoothedVelocity = z.smoothedVelocity:Lerp(targetVelocity, zcfg.VELOCITY_SMOOTHING)
                end
                z.lastTargetPos = position
                local isAirborne = character3.FloorMaterial == Enum.Material.Air
                z.airborneTime = isAirborne and z.airborneTime + sampleDeltaTime or 0
                if isAirborne and z.airborneTime >= zcfg.MIN_AIRBORNE_TIME then
                    pushBounded(z.aerialVelocityHistory, z.targetVelocity, 6)
                elseif not isAirborne then
                    z.aerialVelocityHistory = {}
                end
                local smoothedVelocity = z.smoothedVelocity
                if isAirborne and #z.aerialVelocityHistory > 0 then
                    local vector = averageVectors(z.aerialVelocityHistory)
                    smoothedVelocity = Vector3.new(vector.X, z.targetVelocity.Y, vector.Z) * zcfg.AIR_CONTROL_FACTOR
                end
                local changedDirectionQuickly = false
                local vector3 = Vector3.new(z.targetVelocity.X, 0, z.targetVelocity.Z)
                if vector3.Magnitude > 5 then
                    local unit = vector3.Unit
                    if z.previousDirection and z.previousDirection:Dot(unit) < 0.5 then
                        local lastDirectionChangeTime = z.lastDirectionChangeTime
                        changedDirectionQuickly = tick() - lastDirectionChangeTime
                            < zcfg.DIRECTION_CHANGE_DETECTION_TIME
                        z.lastDirectionChangeTime = tick()
                    end
                    z.previousDirection = unit
                end
                local predictionTime = z.currentPing + zcfg.SERVER_TICKRATE
                if changedDirectionQuickly then
                    predictionTime *= zcfg.QUICK_DIRECTION_CHANGE_MULTIPLIER
                end
                local accelerationPredictionWeight = zcfg.ACCELERATION_PREDICTION_WEIGHT
                local predictedPosition = position
                    + smoothedVelocity * predictionTime
                    + averageVectors(z.accelerationHistory)
                        * accelerationPredictionWeight
                        * predictionTime
                        * predictionTime
                        * 0.5
                local leadTime = zcfg.PREDICTION_TIME * 1.1
                local leadPosition
                if isAirborne then
                    leadPosition = predictedPosition
                        + smoothedVelocity * leadTime
                        + Vector3.new(0, -0.5 * zcfg.GRAVITY * leadTime * leadTime, 0)
                else
                    leadPosition = predictedPosition + smoothedVelocity * leadTime
                end
                local vector4 = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z)
                if vector4.Magnitude > 1 then
                    leadPosition += vector4.Unit * zcfg.PREDICT_AHEAD
                end
                local targetDirection = leadPosition - rootPart.Position
                applyAngularAim(rootPart, targetDirection)
                local withinActivationRange = (position - rootPart.Position).Magnitude <= zcfg.ACTIVATE_DISTANCE
                if withinActivationRange then
                    local lastActivationTime = z.lastActivationTime
                    withinActivationRange = tick() - lastActivationTime >= 0.3
                end
                if withinActivationRange then
                    if tool then
                        pcall(tool.Activate, tool)
                    end
                    z.lastActivationTime = tick()
                end
                if zcfg.MIN_FOLLOW_DISTANCE < targetDirection.Magnitude then
                    rootPart.AssemblyLinearVelocity = targetDirection.Unit * zcfg.FOLLOW_SPEED
                else
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y * 0.5, 0)
                end
            end)
        end
        batBypass.Toggle = function()
            if batBypass.Enabled then
                batBypass.Stop()
            else
                batBypass.Start()
            end
        end
    end
    Engines.v4 = {
        Start = function() snowVS.BatBypass.Start() end,
        Stop = function() snowVS.BatBypass.Stop() end,
        IsEnabled = function() return snowVS.BatBypass.Enabled end,
    }
end
    local function stopAll()
        for _, engine in pairs(Engines) do
            if engine.IsEnabled() then pcall(engine.Stop) end
        end
        if originalCleanup then pcall(originalCleanup) end
        activeEngine = nil
        S.batBypassEnabled = false
        local character = LP.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if hum then hum.AutoRotate = true end
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            for _, name in ipairs({"Blast_AimbotV2_LV", "Blast_AimbotV2_Att"}) do
                local mover = root:FindFirstChild(name)
                if mover then mover:Destroy() end
            end
        end
    end
    S.setBatBypass = function(enabled)
        stopAll()
        if enabled == true and not disposed then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                if S.batAimbotEnabled then setBatAimbot(false) end
                if S.tpBatEnabled then setTpBat(false) end
                if S.autoLeftEnabled then
                    S.autoLeftEnabled = false; stopAutoLeft()
                    if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
                end
                if S.autoRightEnabled then
                    S.autoRightEnabled = false; stopAutoRight()
                    if S.autoRightSetVisual then S.autoRightSetVisual(false) end
                end
                if S.batBypassVersion == "v5" then
                    originalSet(true)
                else
                    local engine = Engines[S.batBypassVersion]
                    if engine then
                        S.batBypassEnabled = true
                        activeEngine = engine
                        engine.Start()
                        S.batBypassEnabled = engine.IsEnabled()
                    end
                end
            end
        end
        if S.setBatBypassVisual then S.setBatBypassVisual(S.batBypassEnabled) end
        if S.setBatBypassRowVisual then S.setBatBypassRowVisual(S.batBypassEnabled) end
        if S.restartMovement then S.restartMovement() end
        if updateFloatingButtons then updateFloatingButtons() end
        saveConfig()
    end
    S.selectBatBypassVersion = function(version, persist)
        if version ~= "v5" and not Engines[version] then return end
        if version == S.batBypassVersion then return end
        local restart = S.batBypassEnabled
        S.setBatBypass(false)
        S.batBypassVersion = version
        if S.refreshBatBypassVersions then S.refreshBatBypassVersions() end
        if restart then S.setBatBypass(true) end
        if persist ~= false then saveConfig() end
    end
    _G._DaHubBatBypassCleanup = function()
        disposed = true
        stopAll()
    end
    LP.CharacterRemoving:Connect(function()
        if S.batBypassEnabled then S.setBatBypass(false) end
    end)
end


BAT_COUNTER_SLAP_LIST = {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
    "Nuclear Slap", "Galaxy Slap", "Glitched Slap",
}

local function findBatForCounter()
    local character = LP.Character
    if not character then return nil end
    local backpack = LP:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        local tool = character:FindFirstChild(name) or (backpack and backpack:FindFirstChild(name))
        if tool then return tool end
    end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then
            return child
        end
    end
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then
                return child
            end
        end
    end
    return nil
end

local function swingBatForCounter(bat, character)
    if not bat or not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if bat.Parent ~= character and humanoid then
        pcall(function() humanoid:EquipTool(bat) end)
        task.wait(0.05)
    end
    local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer() end)
        task.wait(0.1)
        pcall(function() remote:FireServer() end)
    else
        pcall(function() bat:Activate() end)
        task.wait(0.1)
        pcall(function() bat:Activate() end)
    end
end

triggerBatCounter = function(character)
    if not S.batCounterEnabled or S.batCounterDebounce then return end
    character = character or LP.Character
    if not character then return end
    S.batCounterDebounce = true
    -- Clean integra estos hooks con body-lock; se usan solo si están disponibles.
    if type(_suppressBodyLock) == "function" then pcall(_suppressBodyLock) end
    task.spawn(function()
        task.wait(0.15)
        local ok, err = pcall(function()
            local bat = findBatForCounter()
            if bat then swingBatForCounter(bat, character) end
        end)
        if not ok then warn("[FALLS4K] Bat Counter error: " .. tostring(err)) end
        task.wait(0.3)
        S.batCounterDebounce = false
        if type(_unsuppressBodyLock) == "function" then pcall(_unsuppressBodyLock, true) end
    end)
end

stopBatCounter = function()
    if S.batCounterConn then
        S.batCounterConn:Disconnect()
        S.batCounterConn = nil
    end
    S.batCounterDebounce = false
end

startBatCounter = function()
    if S.batCounterConn then return end
    S.batCounterConn = RunService.Heartbeat:Connect(function()
        if not S.batCounterEnabled or S.batCounterDebounce then return end
        local character = LP.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown then
            triggerBatCounter(character)
        end
    end)
end
medusaWatchedCharacter = nil
medusaLastErrorWarn = 0

local function findMedusa(character)
    local c = character or LP.Character
    if not c then return nil end
    local function isMedusaTool(tool)
        if not tool or not tool:IsA("Tool") then return false end
        local name = tool.Name:lower()
        return name:find("medusa") or name:find("head") or name:find("stone")
    end
    for _, tool in ipairs(c:GetChildren()) do
        if isMedusaTool(tool) then return tool end
    end
    local backpack = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if isMedusaTool(tool) then return tool end
        end
    end
    return nil
end

local function useMedusaCounter()
    if not S.medusaCounterEnabled or S.medusaDebounce then return end
    local now = tick()
    if now - (S.medusaLastUsed or 0) < S.MEDUSA_COOLDOWN then return end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not humanoid or humanoid.Health <= 0 then return end

    S.medusaDebounce = true
    local ok, activated = pcall(function()
        local medusa = findMedusa(character)
        if not medusa then return false end
        if medusa.Parent ~= character then
            local equipOk = pcall(function() humanoid:EquipTool(medusa) end)
            if not equipOk then return false end
        end
        if not medusa.Parent then return false end
        local activateOk = pcall(function() medusa:Activate() end)
        if not activateOk then return false end
        return true
    end)
    S.medusaDebounce = false
    if ok and activated then
        S.medusaLastUsed = tick()
    elseif not ok and tick() - medusaLastErrorWarn >= 3 then
        medusaLastErrorWarn = tick()
        warn("[FALLS4K] Medusa Counter error: " .. tostring(activated))
    end
end

local function onAnchorChanged(part)
    if not part or not part:IsA("BasePart") then return nil end
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if not S.medusaCounterEnabled or not part.Parent then return end
        if part.Anchored and part.Transparency == 1 then
            useMedusaCounter()
        end
    end)
end

local function stopMedusaCounter()
    for _, connection in ipairs(S.medusaConns) do
        if connection then pcall(function() connection:Disconnect() end) end
    end
    S.medusaConns = {}
    medusaWatchedCharacter = nil
end

local function setupMedusaCounter(character)
    stopMedusaCounter()
    if not character or not S.medusaCounterEnabled or character ~= LP.Character then return end
    medusaWatchedCharacter = character
    local watchedParts = {}
    local function watchPart(part)
        if not S.medusaCounterEnabled or medusaWatchedCharacter ~= character then return end
        if not part or not part:IsA("BasePart") or watchedParts[part] then return end
        watchedParts[part] = true
        local ok, connection = pcall(onAnchorChanged, part)
        if ok and connection then table.insert(S.medusaConns, connection) end
    end
    for _, part in ipairs(character:GetDescendants()) do
        watchPart(part)
    end
    table.insert(S.medusaConns, character.DescendantAdded:Connect(watchPart))
end

LP.CharacterRemoving:Connect(function(character)
    if medusaWatchedCharacter == character then stopMedusaCounter() end
end)

local function applyFPSBoost()
    safeSetfpscap(999999999)
    removeCharacterAccessories()
    local function pO(v)
        pcall(function()
            if v:IsA("Model") then
                v.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
                v.ModelStreamingMode = Enum.ModelStreamingMode.Nonatomic
            elseif v:IsA("MeshPart") then
                v.CastShadow = false; v.DoubleSided = false
                v.RenderFidelity = Enum.RenderFidelity.Performance
            elseif v:IsA("BasePart") then
                v.CastShadow = false; v.Material = Enum.Material.Plastic; v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("SpecialMesh") then
                v.TextureId = ""
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke")
                or v:IsA("Sparkles") or v:IsA("ParticleEmitter")
                or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then
                v:Destroy()
            elseif v:IsA("Attachment") then
                v.Visible = false
            end
        end)
    end
    for _, v in pairs(workspace:GetDescendants()) do pO(v) end
    pcall(function()
        local L = Lighting
        for _, v in pairs(L:GetDescendants()) do
            pcall(function()
                if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect")
                    or v:IsA("BlurEffect") or v:IsA("SunRaysEffect")
                    or v:IsA("DepthOfFieldEffect") or v:IsA("Clouds")
                    or v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") then
                    v:Destroy()
                end
            end)
        end
        safeSethiddenproperty(L, "Technology", Enum.Technology.Legacy)
        L.GlobalShadows = false; L.FogEnd = 9e9; L.Brightness = 0
        local ter = workspace:FindFirstChildOfClass("Terrain")
        if ter then
            safeSethiddenproperty(ter, "Decoration", false)
            ter.WaterReflectance = 0; ter.WaterTransparency = 0.7
            ter.WaterWaveSize = 0; ter.WaterWaveSpeed = 0
        end
    end)
    workspace.DescendantAdded:Connect(function(v)
        if S.fpsBoostEnabled then task.spawn(pO, v) end
    end)
end

local function stopFPSBoost()
    S.fpsBoostEnabled = false
    restoreAccessories()
end

local function runTPFloor()
    pcall(function() executeTPDown() end)
end

getconnections = getconnections or get_signal_cons or getconnects or (syn and syn.get_signal_cons)

local function isMyPlotByName(plotName)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function sanitizeStealRadius(value, fallback)
    local raw = tostring(value or ""):gsub(",", ".")
    local n = tonumber(raw)
    if not n or n ~= n or n <= 0 or n == math.huge or n == -math.huge then
        return fallback or 61
    end
    return n
end

local function setStealRadius(value, fallback)
    S.Steal.StealRadius = sanitizeStealRadius(value, fallback or S.Steal.StealRadius)
    return S.Steal.StealRadius
end
local function sanitizeStealDuration(value, fallback)
    local raw = tostring(value or ""):gsub(",", ".")
    local number = tonumber(raw)
    if not number or number ~= number or number == math.huge or number == -math.huge then
        return fallback or 1.3
    end
    return math.clamp(number, 0.05, 2)
end
local function setStealDuration(value, fallback)
    S.Steal.StealDuration = sanitizeStealDuration(value, fallback or S.Steal.StealDuration)
    return S.Steal.StealDuration
end

autoGrabSetDelayRadius = 9
autoGrabStopTime = 0.96
autoGrabStopEnabled = true
_plotsCache = nil
_plotsCacheTime = 0

local function getPlotsRoot()
    local now = tick()
    if _plotsCache and now - _plotsCacheTime < 2 and _plotsCache.Parent then
        return _plotsCache
    end
    _plotsCache = workspace:FindFirstChild("Plots")
    _plotsCacheTime = now
    return _plotsCache
end

local function applyStealRadiusToPrompt(prompt)
    if not prompt then return end
    pcall(function()
        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance or 0, setStealRadius(S.Steal.StealRadius, 61))
    end)
end

local function findNearestPrompt()
    local char = LP.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local plotsRoot = getPlotsRoot()
    if not plotsRoot then return nil, nil end

    local nearestPrompt, nearestDist, nearestName = nil, math.huge, nil
    local rpos = root.Position
    local radius = setStealRadius(S.Steal.StealRadius, 61)
    for _, plot in ipairs(plotsRoot:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local sp = spawn.Position
                    local dx, dy, dz = sp.X - rpos.X, sp.Y - rpos.Y, sp.Z - rpos.Z
                    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
                    if dist < nearestDist and dist <= radius then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, child in ipairs(att:GetChildren()) do
                                if child:IsA("ProximityPrompt") and tostring(child.ActionText or ""):find("Steal") then
                                    applyStealRadiusToPrompt(child)
                                    nearestPrompt, nearestDist, nearestName = child, dist, pod.Name
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return nearestPrompt, nearestName
end

local function resetCleanStealProgress()
    S.setProgressVisual(0)
end

local function executeSteal(prompt, podName)
    if S.Steal.isStealing or not prompt then return end

    if math.random(30) == 1 then
        for cachedPrompt in pairs(S.Steal.Data) do
            if not cachedPrompt.Parent then S.Steal.Data[cachedPrompt] = nil end
        end
    end

    if not S.Steal.Data[prompt] then
        S.Steal.Data[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(S.Steal.Data[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(S.Steal.Data[prompt].trigger, c.Function) end
                end
            end
        end)
    end

    local data = S.Steal.Data[prompt]
    if not data.ready then return end
    data.ready = false
    S.Steal.isStealing = true
    S.Steal.stealStartTime = tick()
    resetCleanStealProgress()

    task.spawn(function()
        for _, fn in ipairs(data.hold) do task.spawn(fn) end

        local startTime = tick()
        local duration = setStealDuration(S.Steal.StealDuration, 1.3)
        local promptFired = false
        local stopProgress = 0

        if autoGrabStopEnabled then
            while S.Steal.isStealing and S.Steal.AutoStealEnabled do
                local elapsed = tick() - startTime
                if elapsed >= autoGrabStopTime then break end
                local progress = math.clamp(elapsed / duration, 0, 1)
                S.setProgressVisual(progress)
                if not prompt.Parent or not prompt.Parent.Parent then break end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > S.Steal.StealRadius then break end
                task.wait()
            end

            stopProgress = math.clamp(autoGrabStopTime / duration, 0, 1)
            S.setProgressVisual(stopProgress)

            local phase2Timeout = math.max(2.99 - autoGrabStopTime - math.max(duration - autoGrabStopTime, 0), 0.05)
            local phase2Start = tick()
            while S.Steal.isStealing and S.Steal.AutoStealEnabled do
                if tick() - phase2Start >= phase2Timeout then
                    resetCleanStealProgress()
                    data.ready = true
                    S.Steal.isStealing = false
                    task.wait()
                    local newPrompt, newName = findNearestPrompt()
                    if newPrompt then executeSteal(newPrompt, newName) end
                    return
                end
                if not prompt.Parent or not prompt.Parent.Parent then
                    resetCleanStealProgress()
                    data.ready = true
                    S.Steal.isStealing = false
                    return
                end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - prompt.Parent.Parent.Position).Magnitude
                    if dist <= autoGrabSetDelayRadius then
                        break
                    elseif dist > S.Steal.StealRadius then
                        resetCleanStealProgress()
                        data.ready = true
                        S.Steal.isStealing = false
                        return
                    end
                end
                task.wait()
            end

            if S.Steal.isStealing and S.Steal.AutoStealEnabled then
                local fillStart = tick()
                local fillDuration = math.max(duration - autoGrabStopTime, 0.05)
                while true do
                    local fp = math.clamp((tick() - fillStart) / fillDuration, 0, 1)
                    local totalProgress = stopProgress + fp * (1 - stopProgress)
                    S.setProgressVisual(totalProgress)
                    if fp >= 1 and not promptFired then
                        promptFired = true
                        pcall(function()
                            for _, fn in ipairs(data.trigger) do task.spawn(fn) end
                            local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
                            if remote and podName then remote:FireServer(podName) end
                            if prompt then prompt:Fire() end
                        end)
                        break
                    end
                    task.wait()
                end
            end
        else
            while S.Steal.isStealing and S.Steal.AutoStealEnabled do
                local elapsed = tick() - startTime
                local progress = math.clamp(elapsed / duration, 0, 1)
                S.setProgressVisual(progress)
                if not prompt.Parent or not prompt.Parent.Parent then break end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > S.Steal.StealRadius then break end
                if elapsed >= duration and not promptFired then
                    promptFired = true
                    pcall(function()
                        for _, fn in ipairs(data.trigger) do task.spawn(fn) end
                        local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
                        if remote and podName then remote:FireServer(podName) end
                        if prompt then prompt:Fire() end
                    end)
                    break
                end
                task.wait()
            end
        end

        resetCleanStealProgress()
        data.ready = true
        S.Steal.isStealing = false
    end)
end

local function startAutoSteal()
    if S.Conns.autoSteal then
        S.stealActive = true
        S.Steal.AutoStealEnabled = true
        return
    end
    S.stealActive = true
    S.Steal.AutoStealEnabled = true
    S.Conns.autoSteal = RunService.Heartbeat:Connect(function()
        if not S.Steal.AutoStealEnabled or S.Steal.isStealing then return end
        local prompt, podName = findNearestPrompt()
        if prompt then executeSteal(prompt, podName) end
    end)
end

local function stopAutoSteal()
    if S.Conns.autoSteal then S.Conns.autoSteal:Disconnect(); S.Conns.autoSteal = nil end
    S.stealActive = false
    S.Steal.AutoStealEnabled = false
    if S.Conns.progress then S.Conns.progress:Disconnect(); S.Conns.progress = nil end
    S.Steal.isStealing = false
    S.Steal.stealStartTime = nil
    resetCleanStealProgress()
end

_noclipCache = {}  -- [player] = {char, parts[]}
RunService.Stepped:Connect(function(_, dt)
    S._noclipTimer = S._noclipTimer + dt
    if S._noclipTimer < 0.15 then return end  -- 6fps es suficiente para noclip
    S._noclipTimer = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local cached = _noclipCache[p]
            if not cached or cached.char ~= p.Character then
                local parts = {}
                for _, obj in ipairs(p.Character:GetDescendants()) do
                    if obj:IsA("BasePart") then table.insert(parts, obj) end
                end
                _noclipCache[p] = {char = p.Character, parts = parts}
                cached = _noclipCache[p]
            end
            for _, part in ipairs(cached.parts) do
                if part and part.Parent then part.CanCollide = false end
            end
        else
            _noclipCache[p] = nil
        end
    end
end)

RunService.RenderStepped:Connect(function()
    S._fpsCount = S._fpsCount + 1
    local now = tick()
    if now - S._lastFpsTime >= 1 then
        S.currentFPS = math.floor(S._fpsCount/(now - S._lastFpsTime))
        S._fpsCount = 0
        S._lastFpsTime = now
    end
end)

updateFloatingButtons = function()
    if not S._setPButtonActive then return end
    local fb = S._floatingButtons
    if fb.lagger then updateLaggerButtonVisual() end
    if fb.carry then S._setPButtonActive(fb.carry, fb.strokeCarry, fb.l1Carry, fb.l2Carry, S.speedMode) end
    if fb.autoLeft then S._setPButtonActive(fb.autoLeft, fb.strokeAutoLeft, fb.l1AutoLeft, fb.l2AutoLeft, S.autoLeftEnabled) end
    if fb.autoRight then S._setPButtonActive(fb.autoRight, fb.strokeAutoRight, fb.l1AutoRight, fb.l2AutoRight, S.autoRightEnabled) end
    if fb.bat then S._setPButtonActive(fb.bat, fb.strokeBat, fb.l1Bat, fb.l2Bat, S.batAimbotEnabled) end
    if S.setBatBypassVisual then S.setBatBypassVisual(S.batBypassEnabled == true) end
end

local function setUILock(enabled)
    S.lockUIEnabled = enabled == true
    if S.lockUIEnabled then S._floatingPanelDragging = false end
    -- Lock bloquea únicamente el arrastre; las acciones siguen funcionando.
    if S.mainMenuFrame then S.mainMenuFrame.Active = true end
    if S.miniToggleButton then S.miniToggleButton.Active = true end
    -- El contenedor es solo visual; nunca debe capturar toques detrás.
    if S.floatingPanelFrame then S.floatingPanelFrame.Active = false end
end

local function makeDraggable(frame, isFloatingPanel, dragTarget, onMove)
    local dragging, dragStart, startPos = false, nil, nil
    local moved = false
    local target = dragTarget or frame
    frame.Active = true
    frame.InputBegan:Connect(function(inp)
        if S.lockUIEnabled then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            if isFloatingPanel then S._floatingPanelDragging = false end
            dragStart = inp.Position
            startPos = target.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if S.lockUIEnabled or not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            local delta = inp.Position - dragStart
            if delta.Magnitude > 2 then
                moved = true
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                target.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
                if onMove then pcall(onMove, target) end
                if isFloatingPanel then S._floatingPanelDragging = true end
            end
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging and moved and (isFloatingPanel or target == S.mainMenuFrame) then
                saveConfig()
            end
            dragging = false
            moved = false
            if isFloatingPanel then
                task.delay(0.12, function()
                    S._floatingPanelDragging = false
                end)
            end
        end
    end)
end

-- ===========================
-- ===========================
-- DaHub — VERTICAL GUI  (black / grey / red / white)
-- ===========================

-- Paleta do hub independente de imagens de fundo.
local DaHubThemeIndex = 1
local DaHubThemeBases = {}
local DaHubThemeReverse = {}
local DaHubPaletteKeys = {"C_BG", "C_HEADER", "C_CARD", "C_CARD_HOV", "C_BORDER",
    "C_HIGHLIGHT", "C_SHADE", "C_HIGHLIGHT_BRIGHT", "C_WHITE", "C_GREY", "C_DIM",
    "C_ACCENT", "C_SEPARATOR_GRAY", "C_CARD_ACTIVE_BG"}
local DaHubPaletteBases = {}
local function DaHubColorKey(color)
    return string.format("%.6f/%.6f/%.6f", color.R, color.G, color.B)
end
local function DaHubTint(color)
    if DaHubThemeIndex == 1 then return color end
    -- Preserve deliberately colored warning/action states; tint neutral UI roles.
    local high = math.max(color.R, color.G, color.B)
    local low = math.min(color.R, color.G, color.B)
    if high - low > 0.10 then return color end
    local level = (color.R + color.G + color.B) / 3
    if DaHubThemeIndex == 2 then
        return Color3.new(level, level * 0.48, level * 0.08)
    end
    return Color3.new(level * 0.72, level * 0.32, level)
end
local function DaHubThemeRGB(r, g, b)
    local base = Color3.fromRGB(r, g, b)
    local key = DaHubColorKey(base)
    DaHubThemeBases[key] = base
    local color = DaHubTint(base)
    DaHubThemeReverse[DaHubColorKey(color)] = base
    return color
end
local function DaHubApplyColorTheme(assetId)
    local index
    for i, optionId in ipairs(HUB_COLOR_OPTIONS) do
        if optionId == assetId then index = i; break end
    end
    if not index then return false end
    local previous = DaHubThemeReverse
    DaHubThemeIndex = index
    DaHubThemeReverse = {}
    for _, base in pairs(DaHubThemeBases) do
        DaHubThemeReverse[DaHubColorKey(DaHubTint(base))] = base
    end
    -- Explicit assignments also support executors whose script globals differ from _G.
    C_BG = DaHubTint(DaHubPaletteBases.C_BG)
    C_HEADER = DaHubTint(DaHubPaletteBases.C_HEADER)
    C_CARD = DaHubTint(DaHubPaletteBases.C_CARD)
    C_CARD_HOV = DaHubTint(DaHubPaletteBases.C_CARD_HOV)
    C_BORDER = DaHubTint(DaHubPaletteBases.C_BORDER)
    C_HIGHLIGHT = DaHubTint(DaHubPaletteBases.C_HIGHLIGHT)
    C_SHADE = DaHubTint(DaHubPaletteBases.C_SHADE)
    C_HIGHLIGHT_BRIGHT = DaHubTint(DaHubPaletteBases.C_HIGHLIGHT_BRIGHT)
    C_WHITE = DaHubTint(DaHubPaletteBases.C_WHITE)
    C_GREY = DaHubTint(DaHubPaletteBases.C_GREY)
    C_DIM = DaHubTint(DaHubPaletteBases.C_DIM)
    C_ACCENT = DaHubTint(DaHubPaletteBases.C_ACCENT)
    C_SEPARATOR_GRAY = DaHubTint(DaHubPaletteBases.C_SEPARATOR_GRAY)
    C_CARD_ACTIVE_BG = DaHubTint(DaHubPaletteBases.C_CARD_ACTIVE_BG)
    local function recolor(color)
        local base = previous[DaHubColorKey(color)] or DaHubThemeBases[DaHubColorKey(color)]
        return base and DaHubTint(base) or color
    end
    local roots = {}
    local menuRoot = S.mainMenuFrame and S.mainMenuFrame.Parent
    if menuRoot then table.insert(roots, menuRoot) end
    if S.floatingPanelGui then table.insert(roots, S.floatingPanelGui) end
    if S.stealHudCard and S.stealHudCard.Parent then table.insert(roots, S.stealHudCard.Parent) end
    for _, root in ipairs(roots) do
        for _, object in ipairs(root:GetDescendants()) do
            if object:IsA("GuiObject") then
                object.BackgroundColor3 = recolor(object.BackgroundColor3)
                if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                    object.TextColor3 = recolor(object.TextColor3)
                end
                if object:IsA("ScrollingFrame") then
                    object.ScrollBarImageColor3 = recolor(object.ScrollBarImageColor3)
                end
                -- Keep background photos and thumbnails in their original colors.
            elseif object:IsA("UIStroke") then
                object.Color = recolor(object.Color)
            elseif object:IsA("UIGradient") then
                local points = {}
                for _, point in ipairs(object.Color.Keypoints) do
                    table.insert(points, ColorSequenceKeypoint.new(point.Time, recolor(point.Value)))
                end
                object.Color = ColorSequence.new(points)
            end
        end
    end
    PLAYER_ESP_COLOR = DaHubThemeRGB(255, 255, 255)
    local cache = S.espPlayerCache
    for _, data in pairs(cache and cache.players or {}) do
        if data.box and data.box.Parent then
            data.box.BackgroundColor3 = PLAYER_ESP_COLOR
            local stroke = data.box:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = PLAYER_ESP_COLOR end
        end
        if data.tracer and data.tracer.Parent then data.tracer.BackgroundColor3 = PLAYER_ESP_COLOR end
        if data.speedLabel and data.speedLabel.Parent then data.speedLabel.TextColor3 = PLAYER_ESP_COLOR end
        if data.nameLabel and data.nameLabel.Parent then data.nameLabel.TextColor3 = PLAYER_ESP_COLOR end
        if data.highlight and data.highlight.Parent then
            data.highlight.FillColor = PLAYER_ESP_COLOR
            data.highlight.OutlineColor = PLAYER_ESP_COLOR
        end
    end
    if S.refreshMobileTheme then S.refreshMobileTheme() end
    if S.refreshHubColorSelection then S.refreshHubColorSelection() end
    return true
end

-- ── Palette (Premium Glassmorphism) ──────────────────────────────────────
C_BG       = DaHubThemeRGB(8, 8, 8)
C_HEADER   = DaHubThemeRGB(12, 12, 12)
C_CARD     = DaHubThemeRGB(16, 16, 16)
C_CARD_HOV = DaHubThemeRGB(28, 28, 28)
C_BORDER   = DaHubThemeRGB(40, 40, 40)
C_HIGHLIGHT      = DaHubThemeRGB(196, 196, 196)
C_SHADE  = DaHubThemeRGB(83, 83, 83)
C_HIGHLIGHT_BRIGHT = DaHubThemeRGB(248, 248, 248)
C_WHITE    = DaHubThemeRGB(245, 245, 245)
C_GREY     = DaHubThemeRGB(160, 160, 160)
C_DIM      = DaHubThemeRGB(72, 72, 72)
C_ACCENT   = DaHubThemeRGB(166, 166, 166)
C_SEPARATOR_GRAY = DaHubThemeRGB(128, 128, 128)
C_CARD_ACTIVE_BG = DaHubThemeRGB(25, 25, 25)
DaHubPaletteBases = {
    C_BG = C_BG,
    C_HEADER = C_HEADER,
    C_CARD = C_CARD,
    C_CARD_HOV = C_CARD_HOV,
    C_BORDER = C_BORDER,
    C_HIGHLIGHT = C_HIGHLIGHT,
    C_SHADE = C_SHADE,
    C_HIGHLIGHT_BRIGHT = C_HIGHLIGHT_BRIGHT,
    C_WHITE = C_WHITE,
    C_GREY = C_GREY,
    C_DIM = C_DIM,
    C_ACCENT = C_ACCENT,
    C_SEPARATOR_GRAY = C_SEPARATOR_GRAY,
    C_CARD_ACTIVE_BG = C_CARD_ACTIVE_BG
}

PANEL_W  = 290
PANEL_H  = 520
HEADER_H = 72
TABBAR_H = 42

-- ── Scrolling page factory ────────────────────────────────────────────────
local DAHUB_NUM_KEYS = {Zero="0",One="1",Two="2",Three="3",Four="4",Five="5",Six="6",Seven="7",Eight="8",Nine="9",
    KeypadZero="Num0",KeypadOne="Num1",KeypadTwo="Num2",KeypadThree="Num3",KeypadFour="Num4",KeypadFive="Num5",KeypadSix="Num6",KeypadSeven="Num7",KeypadEight="Num8",KeypadNine="Num9"}
function DaHubKeyName(k) if not k then return "None" end local n = k.Name; return DAHUB_NUM_KEYS[n] or n end

-- Shared keybinding capture: one listener, no action while assigning a key.
DaHubBindings = {buttons = setmetatable({}, {__mode = "k"}), active = nil, blockedUntil = 0}
function DaHubBindings.refresh()
    for button, entry in pairs(DaHubBindings.buttons) do
        if button.Parent then
            button.Text = DaHubKeyName(entry.kb) .. " / " .. DaHubKeyName(entry.gp)
        end
    end
end
function DaHubBindings.assign(entry, key, isGamepad)
    if not entry or not key or key == Enum.KeyCode.Unknown or key == Enum.KeyCode.Escape then return false end
    local field = isGamepad and "gp" or "kb"
    local previous = entry[field]
    -- Swap occupied keys rather than allowing two actions on the same input.
    for _, other in pairs(S.KB) do
        if other ~= entry and other[field] == key then other[field] = previous end
    end
    entry[field] = key
    DaHubBindings.refresh()
    return true
end
function DaHubBindings.suppressed()
    return DaHubBindings.active ~= nil or tick() < DaHubBindings.blockedUntil
        or UIS:GetFocusedTextBox() ~= nil
end
function DaHubBindings.capture(button, entry)
    local current = DaHubBindings.active
    if current then
        if current.conn then current.conn:Disconnect() end
        DaHubBindings.active = nil
        DaHubBindings.refresh()
        if current.button == button then return end
    end
    local capture = {button = button}
    DaHubBindings.active = capture
    button.Text = "..."
    capture.conn = UIS.InputBegan:Connect(function(input)
        local isGamepad = input.UserInputType == Enum.UserInputType.Gamepad1
        if input.UserInputType ~= Enum.UserInputType.Keyboard and not isGamepad then return end
        if input.KeyCode == Enum.KeyCode.Unknown then return end
        -- Remain blocked for this entire event, regardless of listener order.
        DaHubBindings.blockedUntil = tick() + 0.2
        if input.KeyCode ~= Enum.KeyCode.Escape then
            DaHubBindings.assign(entry, input.KeyCode, isGamepad)
            saveConfig()
        end
        if capture.conn then capture.conn:Disconnect() end
        DaHubBindings.active = nil
        DaHubBindings.refresh()
    end)
    task.delay(10, function()
        if DaHubBindings.active == capture then
            if capture.conn then capture.conn:Disconnect() end
            DaHubBindings.active = nil
            DaHubBindings.refresh()
        end
    end)
end
function DaHubBindings.register(button, entry)
    DaHubBindings.buttons[button] = entry
    button.TextSize = 9
    button.TextScaled = true
    local limit = Instance.new("UITextSizeConstraint", button)
    limit.MinTextSize = 8
    limit.MaxTextSize = 10
    button.Activated:Connect(function() DaHubBindings.capture(button, entry) end)
    DaHubBindings.refresh()
end
-- End shared keybinding capture.

function DaHubSetUserScale(kind, v, persist)
    if kind ~= "menu" and kind ~= "mobile" then return end
    v = tonumber(v)
    if not v or v ~= v or v == math.huge or v == -math.huge then return end
    v = math.clamp(v, 0.5, 2)
    if kind == "menu" then S.userMenuScale = v else S.userMobileScale = v end
    local target
    if kind == "menu" then
        target = S.mainMenuFrame and S.mainMenuFrame:FindFirstChild("Main")
    else
        target = S.floatingPanelFrame
    end
    if target then
        local sc = target:FindFirstChild("DaHubUserScale")
        if not sc then sc = Instance.new("UIScale"); sc.Name = "DaHubUserScale"; sc.Parent = target end
        sc.Scale = v
        if kind == "mobile" and S.refreshMobileBackgroundLayout then
            S.refreshMobileBackgroundLayout()
        end
    end
    if persist ~= false then saveConfig() end
end
local function buildGui_createScrollingPages(parent)
    local pages = {}
    for _, n in ipairs({"Speed","Main","Player","Visual","Move","Config","Keybinds"}) do
        local sf = Instance.new("ScrollingFrame", parent)
        sf.Size = UDim2.new(1,0,1,0)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.ScrollBarThickness = 3
        sf.ScrollBarImageColor3 = C_HIGHLIGHT
        sf.Visible = false
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.CanvasSize = UDim2.new(0,0,0,0)
        pcall(function() sf.ElasticBehavior = Enum.ElasticBehavior.Always end)
        pcall(function() sf.ScrollingDirection = Enum.ScrollingDirection.Y end)
        local ll = Instance.new("UIListLayout", sf)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Padding = UDim.new(0,6)
        ll.FillDirection = Enum.FillDirection.Vertical
        local pp = Instance.new("UIPadding", sf)
        pp.PaddingLeft  = UDim.new(0,10)
        pp.PaddingRight = UDim.new(0,10)
        pp.PaddingTop   = UDim.new(0,10)
        pp.PaddingBottom= UDim.new(0,18)
        pages[n] = sf
    end
    return pages
end

rowCounts = {Speed=0, Main=0, Player=0, Visual=0, Move=0, Config=0, Keybinds=0}

-- ── Card row ──────────────────────────────────────────────────────────────
local function mkCard(pg, pages, h)
    rowCounts[pg] = rowCounts[pg] + 1
    local f = Instance.new("Frame", pages[pg])
    f.Size = UDim2.new(1,0,0,h or 38)
    f.BackgroundColor3 = C_CARD
    f.BackgroundTransparency = 0.85
    f.BorderSizePixel = 0
    f.LayoutOrder = rowCounts[pg]
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke", f)
    stroke.Color = DaHubThemeRGB(68, 68, 74); stroke.Thickness = 1; stroke.Transparency = 0.55
    -- Subtle inner glow gradient
    local cardGrad = Instance.new("UIGradient", f)
    cardGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DaHubThemeRGB(34, 34, 39)),
        ColorSequenceKeypoint.new(0.5, DaHubThemeRGB(24, 24, 28)),
        ColorSequenceKeypoint.new(1, DaHubThemeRGB(20, 20, 24)),
    })
    cardGrad.Rotation = 90
    return f
end

-- ── Section divider ───────────────────────────────────────────────────────
local function mkSection(pg, pages, text)
    rowCounts[pg] = rowCounts[pg] + 1
    local f = Instance.new("Frame", pages[pg])
    f.Size = UDim2.new(1,0,0,20)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.LayoutOrder = rowCounts[pg]
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1,-10,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text:upper()
    lbl.TextColor3 = C_HIGHLIGHT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1,-10,0,1)
    line.Position = UDim2.new(0,10,1,-1)
    line.BackgroundColor3 = C_SEPARATOR_GRAY
    line.BackgroundTransparency = 0.72
    line.BorderSizePixel = 0
end

-- ── Toggle row ────────────────────────────────────────────────────────────
local function mkToggle(pg, pages, label, defKey, defOn, onToggle, onKeyChanged)
    local card = mkCard(pg, pages, 36)
    local cardStroke = card:FindFirstChildOfClass("UIStroke")

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = defKey and UDim2.new(1,-172,1,0) or UDim2.new(1,-74,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C_WHITE
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local keyBtn = nil
    if defKey then
        keyBtn = Instance.new("TextButton", card)
        keyBtn.Size = UDim2.new(0,96,0,28)
        keyBtn.Position = UDim2.new(1,-156,0.5,-14)
        keyBtn.BackgroundColor3 = DaHubThemeRGB(0, 0, 0)
        keyBtn.BackgroundTransparency = 0
        keyBtn.BorderSizePixel = 0
        keyBtn.ZIndex = 10
        keyBtn.Text = DaHubKeyName(defKey or Enum.KeyCode.Unknown)
        keyBtn.TextColor3 = C_GREY
        keyBtn.Font = Enum.Font.GothamBold; keyBtn.TextSize = 9
        Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0,8)
        local ks = Instance.new("UIStroke", keyBtn)
        ks.Color = DaHubThemeRGB(34, 34, 40)
        ks.Thickness = 1
        ks.Transparency = 0.52
        ks.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        for _, entry in pairs(S.KB) do
            if entry.kb == defKey or entry.gp == defKey then
                DaHubBindings.register(keyBtn, entry)
                break
            end
        end
    end

    -- Interruptor estilo DaHub Leaked: perilla centrada gris apagada y morada encendida.
    local pillBg = Instance.new("Frame", card)
    pillBg.Size = UDim2.new(0,42,0,22)
    pillBg.AnchorPoint = Vector2.new(1,0.5)
    pillBg.Position = UDim2.new(1,-12,0.5,0)
    pillBg.BackgroundColor3 = DaHubThemeRGB(40,40,40)
    pillBg.BackgroundTransparency = 0
    pillBg.BorderSizePixel = 0
    pillBg.ZIndex = 6
    pillBg.ClipsDescendants = false
    Instance.new("UICorner", pillBg).CornerRadius = UDim.new(1,0)
    local pillStroke = Instance.new("UIStroke", pillBg)
    pillStroke.Name = "TrackStroke"
    pillStroke.Color = DaHubThemeRGB(225, 225, 225)
    pillStroke.Thickness = 1.2
    pillStroke.Transparency = 0.4
    local pillGradient = Instance.new("UIGradient", pillBg)
    pillGradient.Name = "TrackGradient"
    pillGradient.Rotation = 90
    pillGradient.Enabled = true
    pillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DaHubThemeRGB(44,44,54)),
        ColorSequenceKeypoint.new(0.55, DaHubThemeRGB(26, 26, 26)),
        ColorSequenceKeypoint.new(1, DaHubThemeRGB(12,12,16)),
    })
    local dotBack = Instance.new("Frame", pillBg)
    dotBack.Name = "DotBack"
    dotBack.AnchorPoint = Vector2.new(0.5,0.5)
    dotBack.Position = UDim2.new(0.5,0,0.5,1)
    dotBack.Size = UDim2.new(0,15,0,15)
    dotBack.BackgroundColor3 = DaHubThemeRGB(0,0,0)
    dotBack.BackgroundTransparency = 0.55
    dotBack.BorderSizePixel = 0
    dotBack.ZIndex = 6
    Instance.new("UICorner", dotBack).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame", pillBg)
    dot.Name = "Knob"
    dot.AnchorPoint = Vector2.new(0.5,0.5)
    dot.Position = UDim2.new(0.5,0,0.5,0)
    dot.Size = UDim2.new(0,13,0,13)
    dot.BackgroundColor3 = DaHubThemeRGB(92,92,104)
    dot.BorderSizePixel = 0
    dot.ZIndex = 7
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local dotGradient = Instance.new("UIGradient", dot)
    dotGradient.Name = "DaHubDotGradient"
    dotGradient.Rotation = 90
    dotGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DaHubThemeRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, DaHubThemeRGB(170,170,180)),
    })
    local dotGloss = Instance.new("Frame", dot)
    dotGloss.Name = "DaHubPurpleGloss"
    dotGloss.Size = UDim2.new(0.46,0,0.24,0)
    dotGloss.Position = UDim2.new(0.22,0,0.11,0)
    dotGloss.BackgroundColor3 = DaHubThemeRGB(255,255,255)
    dotGloss.BackgroundTransparency = 0.62
    dotGloss.BorderSizePixel = 0
    dotGloss.ZIndex = 8
    Instance.new("UICorner", dotGloss).CornerRadius = UDim.new(1,0)
    local dotScale = Instance.new("UIScale", dot)
    dotScale.Scale = 1

    local isOn = defOn or false
    local function setV(on)
        isOn = on
        local fadeInfo = TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        TS_G:Create(dot, fadeInfo, {
            BackgroundColor3 = on and C_BG or C_WHITE,
            Position = on and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0),
            Size = UDim2.fromOffset(16,16),
        }):Play()
        dotGradient.Enabled = not on
        dotGloss.BackgroundTransparency = on and 0.8 or 0.38
        pillGradient.Enabled = true
        pillGradient.Color = on and ColorSequence.new({
            ColorSequenceKeypoint.new(0, DaHubThemeRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, DaHubThemeRGB(190,190,204)),
        }) or ColorSequence.new({
            ColorSequenceKeypoint.new(0, DaHubThemeRGB(72,72,84)),
            ColorSequenceKeypoint.new(1, DaHubThemeRGB(28,28,36)),
        })
        TS_G:Create(pillBg, fadeInfo, {BackgroundColor3 = on and C_WHITE or C_GREY}):Play()
        TS_G:Create(pillStroke, fadeInfo, {
            Color = on and C_HIGHLIGHT_BRIGHT or C_BORDER,
            Transparency = on and 0.1 or 0.38,
        }):Play()
        TS_G:Create(dotBack, fadeInfo, {
            Position = on and UDim2.new(1,-11,0.5,1) or UDim2.new(0,11,0.5,1),
            BackgroundTransparency = on and 0.78 or 0.55,
        }):Play()
        if cardStroke then
            TS_G:Create(cardStroke, fadeInfo, {
                Color = on and C_HIGHLIGHT or C_BORDER,
                Transparency = on and 0.28 or 0.55,
            }):Play()
        end
    end

    local clickArea = Instance.new("TextButton", card)
    clickArea.Size = defKey and UDim2.new(1,-172,1,0) or UDim2.new(1,0,1,0)
    clickArea.BackgroundTransparency = 1; clickArea.Text = ""; clickArea.ZIndex = 8
    local function toggleRow()
        if DaHubBindings.active then return end
        isOn = not isOn; setV(isOn)
        if onToggle then onToggle(isOn) end
    end
    clickArea.Activated:Connect(toggleRow)
    if defKey then
        local switchTap = Instance.new("TextButton", card)
        switchTap.Size = UDim2.new(0,54,1,0)
        switchTap.Position = UDim2.new(1,-58,0,0)
        switchTap.BackgroundTransparency = 1
        switchTap.Text = ""
        switchTap.ZIndex = 9
        switchTap.Activated:Connect(toggleRow)
    end
    clickArea.MouseEnter:Connect(function()
        TS_G:Create(card, TweenInfo.new(0.12), {BackgroundColor3 = C_CARD_HOV}):Play()
    end)
    clickArea.MouseLeave:Connect(function()
        TS_G:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = C_CARD}):Play()
    end)

    setV(isOn)
    return setV, keyBtn
end

-- ── Number input row ──────────────────────────────────────────────────────
local function mkInput(pg, pages, label, default, onChange, speedKey)
    local card = mkCard(pg, pages, 36)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.55,-8,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = C_WHITE; lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("TextBox", card)
    box.Size = UDim2.new(0,66,0,26); box.Position = UDim2.new(1,-74,0.5,-13)
    box.BackgroundColor3 = DaHubThemeRGB(18, 18, 18); box.BorderSizePixel = 0
    box.Text = tostring(default); box.TextColor3 = C_WHITE
    box.Font = Enum.Font.GothamBlack; box.TextSize = 11
    box.ClearTextOnFocus = false; box.MultiLine = false
    pcall(function() box.ReturnKeyType = Enum.ReturnKeyType.Done end)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = C_BORDER; boxStroke.Thickness = 0.8
    local lastVal = tostring(default); local isFocused = false
    if speedKey then
        lbl.Size = UDim2.new(1, -144, 1, 0)
        lbl.TextWrapped = true
        box.Size = UDim2.fromOffset(48, 26)
        box.Position = UDim2.new(1, -94, 0.5, -13)
        local function addSpeedButton(text, offset, delta)
            local button = Instance.new("TextButton", card)
            button.Name = delta > 0 and "SpeedPlus" or "SpeedMinus"
            button.Size = UDim2.fromOffset(28, 26)
            button.Position = UDim2.new(1, offset, 0.5, -13)
            button.Text = text
            button.TextColor3 = C_WHITE
            button.BackgroundColor3 = box.BackgroundColor3
            button.BorderSizePixel = 0
            button.Font = Enum.Font.GothamBold
            button.TextSize = 18
            Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", button)
            stroke.Color = C_BORDER
            stroke.Thickness = 0.8
            button.Activated:Connect(function()
                -- Read the applied speed, not an uncommitted or stale text value.
                local current = tonumber(S[speedKey])
                if not current then return end
                local nextValue = current + delta
                if nextValue <= 0 or nextValue > 500 then return end
                isFocused = false
                pcall(function() box:ReleaseFocus(false) end)
                onChange(nextValue)
                lastVal = tostring(S[speedKey])
                box.Text = lastVal
                TS_G:Create(boxStroke, TweenInfo.new(0.15), {Color = C_BORDER}):Play()
            end)
        end
        addSpeedButton("-", -126, -0.5)
        addSpeedButton("+", -40, 0.5)
    end
    box.Focused:Connect(function()
        isFocused = true
        TS_G:Create(boxStroke, TweenInfo.new(0.15), {Color = C_HIGHLIGHT}):Play()
    end)
    local function applyVal()
        if not isFocused then return end
        isFocused = false
        TS_G:Create(boxStroke, TweenInfo.new(0.15), {Color = C_BORDER}):Play()
        local n = tonumber(box.Text)
        if n then lastVal = tostring(n); box.Text = lastVal; onChange(n)
        else box.Text = lastVal end
        pcall(function() box:ReleaseFocus(false) end)
    end
    box.FocusLost:Connect(function()
        if isFocused then
            isFocused = false
            TS_G:Create(boxStroke, TweenInfo.new(0.15), {Color = C_BORDER}):Play()
            local n = tonumber(box.Text)
            if n then lastVal = tostring(n); box.Text = lastVal; onChange(n)
            else box.Text = lastVal end
        end
    end)
    pcall(function() box.ReturnPressedFromOnScreenKeyboard:Connect(applyVal) end)
    UIS.TouchTap:Connect(function(positions)
        if not isFocused then return end
        pcall(function()
            local abs = box.AbsolutePosition; local sz = box.AbsoluteSize; local tp = positions[1]
            if tp and not (tp.X>=abs.X and tp.X<=abs.X+sz.X and tp.Y>=abs.Y and tp.Y<=abs.Y+sz.Y) then
                applyVal()
            end
        end)
    end)
    return box
end

-- ── Action / keybind row ──────────────────────────────────────────────────
local function mkActionRow(pg, pages, labelText, keyEntry, onRun)
    local card = mkCard(pg, pages, 36)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1,-142,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = labelText
    lbl.TextColor3 = C_WHITE; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Toda la fila ejecuta la acción al tocarla; el botón de tecla sigue permitiendo reasignarla.
    if onRun then
        local actionTap = Instance.new("TextButton", card)
        actionTap.Name = "ActionTapArea"
        actionTap.Size = keyEntry and UDim2.new(1, -132, 1, 0) or UDim2.new(1, 0, 1, 0)
        actionTap.BackgroundTransparency = 1
        actionTap.Text = ""
        actionTap.AutoButtonColor = false
        actionTap.Active = true
        actionTap.ZIndex = 2
        actionTap.Activated:Connect(function()
            task.spawn(onRun)
        end)
    end

    if keyEntry then
        local keyBtn = Instance.new("TextButton", card)
        keyBtn.Size = UDim2.new(0,112,0,24); keyBtn.Position = UDim2.new(1,-122,0.5,-12)
        keyBtn.BackgroundColor3 = DaHubThemeRGB(18, 18, 18); keyBtn.BorderSizePixel = 0; keyBtn.ZIndex = 10
        keyBtn.Text = DaHubKeyName(keyEntry.kb or keyEntry.gp or Enum.KeyCode.Unknown)
        keyBtn.TextColor3 = C_GREY; keyBtn.Font = Enum.Font.GothamBold; keyBtn.TextSize = 9
        Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0,7)
        local ks = Instance.new("UIStroke", keyBtn); ks.Color = C_BORDER; ks.Thickness = 0.8
        DaHubBindings.register(keyBtn, keyEntry)
    end
    return function(newLabel)
        if lbl and lbl.Parent then lbl.Text = newLabel end
    end
end

-- ── Mini toggle (minimised button) ────────────────────────────────────────
local function buildGui_createMiniToggle(gui, showGuiFn)
    local btn = Instance.new("TextButton", gui)
    btn.Name = "MiniToggle"
    btn.Size = UDim2.new(0,152,0,40)
    btn.Position = UDim2.new(0,18,0,60)
    btn.BackgroundColor3 = DaHubThemeRGB(12, 12, 16)
    btn.BackgroundTransparency = 0.02
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 20
    btn.Visible = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,16)
    local ms = Instance.new("UIStroke", btn)
    ms.Color = C_HIGHLIGHT
    ms.Thickness = 1
    ms.Transparency = 0.45
    local titleIcon = Instance.new("TextLabel", btn)
    titleIcon.Name = "MiniTitleImage"
    titleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    titleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    titleIcon.Size = UDim2.new(1, 0, 1, 0)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = DaHubBrandStyle.text
    titleIcon.Font = Enum.Font.GothamBlack
    titleIcon.TextSize = 20
    titleIcon.TextColor3 = DaHubThemeRGB(255, 255, 255)
    titleIcon.ZIndex = 21
    DaHubBrandStyle.apply(titleIcon)
    makeDraggable(btn, false)
    btn.MouseButton1Click:Connect(showGuiFn)
    return btn
end

-- ── Kroblox (ported from Ace Duels) ────────────────────────────────────────
_G._DaHubKrobloxMode = _G._DaHubKrobloxMode or "Off"
DAHUB_KROBLOX_ASSETS = {
    ["Left Leg"] = {
        id = "rbxassetid://139607673", targetBodyPart = "LeftUpperLeg",
        partsToHide = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
        scale = Vector3.new(1, 1, 1), audio = "rbxassetid://87998522263554",
        offset = CFrame.new(0, 0, 0) * CFrame.Angles(1.2, 0, 0),
    },
    ["Right Leg"] = {
        id = "rbxassetid://139607718", targetBodyPart = "RightUpperLeg",
        partsToHide = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
        scale = Vector3.new(1, 1, 1), audio = "rbxassetid://135315310485417",
        offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, 1.2, 0),
    },
}
local function clearDaHubKroblox()
    local character = LP.Character
    if not character then return end
    for _, name in ipairs({"Korblox_LeftLeg", "Korblox_RightLeg", "DaHubKroblox_LeftLeg", "DaHubKroblox_RightLeg"}) do
        local object = character:FindFirstChild(name)
        if object then pcall(function() object:Destroy() end) end
    end
    for _, name in ipairs({"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            part.Transparency = 0
            part.LocalTransparencyModifier = 0
        end
    end
end

local function attachDaHubKroblox(whichLeg)
    local data = DAHUB_KROBLOX_ASSETS[whichLeg]
    local character = LP.Character
    if not data or not character then return false end
    local target = character:FindFirstChild(data.targetBodyPart)
    if not target then return false end
    local old = character:FindFirstChild("Korblox_" .. whichLeg:gsub("%s+", ""))
    if old then old:Destroy() end
    for _, name in ipairs(data.partsToHide) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then part.Transparency = 1 end
    end
    local ok, objects = pcall(function() return game:GetObjects(data.id) end)
    if not ok or not objects or #objects == 0 then return false end
    local object = objects[1]
    object.Name = "Korblox_" .. whichLeg:gsub("%s+", "")
    local meshPart = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart", true)
    if not meshPart then pcall(function() object:Destroy() end); return false end
    meshPart.Size = meshPart.Size * data.scale
    meshPart.CanCollide = false
    meshPart.CanTouch = false
    meshPart.CanQuery = false
    meshPart.Massless = true
    meshPart.CFrame = target.CFrame * data.offset
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = target
    weld.Part1 = meshPart
    weld.Parent = meshPart
    object.Parent = character
    return true
end

_G._DaHubApplyKroblox = function(mode)
    mode = ({Off=true, Left=true, Right=true, Both=true})[mode] and mode or "Off"
    clearDaHubKroblox()
    S.krobloxMode = mode
    _G._DaHubKrobloxMode = mode
    if mode == "Left" or mode == "Both" then pcall(attachDaHubKroblox, "Left Leg") end
    if mode == "Right" or mode == "Both" then pcall(attachDaHubKroblox, "Right Leg") end
end

LP.CharacterAdded:Connect(function()
    task.wait(0.6)
    if _G._DaHubKrobloxMode ~= "Off" then
        pcall(_G._DaHubApplyKroblox, _G._DaHubKrobloxMode)
    end
end)

-- ── Tab content builders ──────────────────────────────────────────────────
local function buildSpeedTab(pages)
    mkSection("Speed", pages, "Speed Values")
    S.normalBox  = mkInput("Speed", pages, "Normal Speed",   S.NS, function(v)
        if v>0 and v<=500 then S.NS=v; S.applySpeedVelocityNow(); S.restartMovement(); saveConfig() end end, "NS")
    S.carryBox   = mkInput("Speed", pages, "Carry Speed",    S.CS, function(v)
        if v>0 and v<=500 then S.CS=v; S.applySpeedVelocityNow(); S.restartMovement(); saveConfig() end end, "CS")
    S.laggerBox  = mkInput("Speed", pages, "Lagger Normal Speed", S.LS, function(v)
        if v>0 and v<=500 then S.LS=v; S.applySpeedVelocityNow(); S.restartMovement(); saveConfig() end end, "LS")
    S.laggerCarryBox = mkInput("Speed", pages, "Lagger Carry Speed", S.LCS, function(v)
        if v>0 and v<=500 then S.LCS=v; S.applySpeedVelocityNow(); S.restartMovement(); saveConfig() end end, "LCS")
    mkSection("Speed", pages, "Modes")
    S.speedClk, _ = mkToggle("Speed", pages, "Carry Mode", S.KB.SpeedToggle.kb, S.speedMode, function(on)
        if on and S.laggerMode~=0 then S.laggerMode=0; if S.setLaggerVisual then S.setLaggerVisual(false) end; updateLaggerButtonVisual() end
        S.speedMode = on
        if on then S.setCarrySpeedMode() else S.setNormalSpeedMode() end
        S.restartMovement(); updateFloatingButtons(); saveConfig()
    end, function(k,isGp)
        if isGp then S.KB.SpeedToggle.gp=k; S.KB.SpeedToggle.kb=nil
        else S.KB.SpeedToggle.kb=k; S.KB.SpeedToggle.gp=nil end; saveConfig()
    end)
    S.setLaggerVisual, _ = mkToggle("Speed", pages, "Lagger Mode", S.KB.LaggerToggle.kb, S.laggerMode ~= 0, function(on)
        if on then
            if S.speedClk then S.speedClk(false) end
            S.setLaggerNormalMode()
        else
            S.setLaggerOffMode()
        end
        updateLaggerButtonVisual(); S.restartMovement(); updateFloatingButtons(); saveConfig()
    end, function(k,isGp)
        if isGp then S.KB.LaggerToggle.gp=k; S.KB.LaggerToggle.kb=nil
        else S.KB.LaggerToggle.kb=k; S.KB.LaggerToggle.gp=nil end; saveConfig()
    end)
end

-- ==================== DAHUB BAT SKINS ====================
do
-- Complete Bat catalog from the supplied Prime.vs, including original orientation and slash sounds.
DaHubBatSkin = {}
DAHUB_BAT_SKINS = {
    {name = "Off"},
    {
        name = "Epic Katana",
        id = "rbxassetid://14052995337",
        soundId = "rbxassetid://111808555599832",
        c0 = CFrame.new(),
    },
    {
        name = "Bloody Katana",
        id = "rbxassetid://126653333198410",
        soundId = "rbxassetid://111808555599832",
        c0 = CFrame.new(),
    },
}
DaHubBatSkin.cache = {}
DaHubBatSkin.originals = setmetatable({}, {__mode = "k"})
DaHubBatSkin.soundConnections = setmetatable({}, {__mode = "k"})
DaHubBatSkin.watched = setmetatable({}, {__mode = "k"})

function DaHubBatSkin.daHubLoadBatSkin(id)
    if DaHubBatSkin.cache[id] then return DaHubBatSkin.cache[id] end
    local ok, objects = pcall(function() return game:GetObjects(id) end)
    if not ok or type(objects) ~= "table" or #objects == 0 then return nil end
    DaHubBatSkin.cache[id] = objects[1]
    return objects[1]
end

function DaHubBatSkin.daHubIsBat(tool)
    return tool and tool:IsA("Tool") and tool.Name:lower() == "bat"
end

function DaHubBatSkin.daHubSetBatSlashSound(tool, soundId)
    if not tool then return end
    for _, sound in ipairs(tool:GetDescendants()) do
        if sound:IsA("Sound") and sound.Name == "Slash" then
            local original = sound:GetAttribute("DaHubOriginalSlashSound")
            if soundId then
                if original == nil then sound:SetAttribute("DaHubOriginalSlashSound", sound.SoundId) end
                sound.SoundId = soundId
            elseif original ~= nil then
                sound.SoundId = original
                sound:SetAttribute("DaHubOriginalSlashSound", nil)
            end
        end
    end
end

function DaHubBatSkin.daHubRestoreBatSkin(tool, clearOriginal)
    if not DaHubBatSkin.daHubIsBat(tool) then return end
    local handle = tool:FindFirstChild("Handle")
    local original = DaHubBatSkin.originals[tool]
    if handle then
        -- En Off no debe quedar visible ningún modelo, weld o parte de la skin.
        for _, child in ipairs(handle:GetChildren()) do
            if not child:IsA("Sound") then
                pcall(function() child:Destroy() end)
            end
        end
    end
    if handle and original then
        handle.Transparency = original.transparency
        handle.CanCollide = original.canCollide
        handle.CanTouch = original.canTouch
        handle.CanQuery = original.canQuery
        handle.Size = original.size
    elseif handle then
        handle.Transparency = 0
    end
    if original and original.grip then tool.Grip = original.grip end
    DaHubBatSkin.daHubSetBatSlashSound(tool, nil)
    local soundConnection = DaHubBatSkin.soundConnections[tool]
    if clearOriginal ~= false and soundConnection then
        pcall(function() soundConnection:Disconnect() end)
        DaHubBatSkin.soundConnections[tool] = nil
    end
    if clearOriginal ~= false then DaHubBatSkin.originals[tool] = nil end
end

function DaHubBatSkin.daHubPrepareBatSkin(tool, entry)
    if not DaHubBatSkin.daHubIsBat(tool) or not entry or not entry.id then return end
    local toolHandle = tool:FindFirstChild("Handle")
    if not toolHandle then return end

    if not DaHubBatSkin.originals[tool] then
        DaHubBatSkin.originals[tool] = {
            grip = tool.Grip,
            transparency = toolHandle.Transparency,
            canCollide = toolHandle.CanCollide,
            canTouch = toolHandle.CanTouch,
            canQuery = toolHandle.CanQuery,
            size = toolHandle.Size,
        }
    end

    DaHubBatSkin.daHubRestoreBatSkin(tool, false)
    for _, child in ipairs(toolHandle:GetChildren()) do
        if not child:IsA("Sound") then pcall(function() child:Destroy() end) end
    end

    local katanaRoot = DaHubBatSkin.daHubLoadBatSkin(entry.id)
    if not katanaRoot then return end
    local modelClone = katanaRoot:Clone()
    modelClone.Name = "DaHubBatSkinModel"
    modelClone.Parent = toolHandle

    local srcHandle = modelClone:IsA("BasePart") and modelClone
        or modelClone:FindFirstChild("Handle", true)
        or modelClone:FindFirstChildWhichIsA("BasePart", true)
    if not srcHandle then modelClone:Destroy(); return end
    local parts = {}
    if modelClone:IsA("BasePart") then parts[#parts + 1] = modelClone end
    for _, inst in ipairs(modelClone:GetDescendants()) do
        if inst:IsA("BasePart") then parts[#parts + 1] = inst end
    end
    local pivot = srcHandle.CFrame
    local orientFix = entry.c0 or CFrame.new()
    for _, part in ipairs(parts) do
        local relative = pivot:ToObjectSpace(part.CFrame)
        part.Anchored = false
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Massless = true
        part.CFrame = toolHandle.CFrame * orientFix * relative
        local weld = Instance.new("Weld", part)
        weld.Name = "DaHubBatSkinWeld"
        weld.Part0 = toolHandle
        weld.Part1 = part
        weld.C0 = orientFix * relative
        weld.C1 = CFrame.new()
    end
    toolHandle.Transparency = 1

    local previousSoundConnection = DaHubBatSkin.soundConnections[tool]
    if previousSoundConnection then
        pcall(function() previousSoundConnection:Disconnect() end)
        DaHubBatSkin.soundConnections[tool] = nil
    end
    DaHubBatSkin.daHubSetBatSlashSound(tool, entry.soundId)
    DaHubBatSkin.soundConnections[tool] = tool.DescendantAdded:Connect(function(obj)
        if S.batSkinMode == entry.name and obj:IsA("Sound") and obj.Name == "Slash" then
            if obj:GetAttribute("DaHubOriginalSlashSound") == nil then
                obj:SetAttribute("DaHubOriginalSlashSound", obj.SoundId)
            end
            obj.SoundId = entry.soundId
        end
    end)
end

function DaHubBatSkin.daHubApplyBatSkin(tool)
    if not DaHubBatSkin.daHubIsBat(tool) then return end
    if S.batSkinMode == "Off" then
        DaHubBatSkin.daHubRestoreBatSkin(tool)
        return
    end
    local entry
    for _, candidate in ipairs(DAHUB_BAT_SKINS) do
        if candidate.name == S.batSkinMode then entry = candidate; break end
    end
    if entry then DaHubBatSkin.daHubPrepareBatSkin(tool, entry) end
end

function DaHubBatSkin.daHubScanBatSkins(parent)
    if not parent then return end
    for _, child in ipairs(parent:GetChildren()) do
        if DaHubBatSkin.daHubIsBat(child) then task.spawn(DaHubBatSkin.daHubApplyBatSkin, child) end
    end
end

function DaHubBatSkin.daHubWatchBatSkinContainer(parent)
    if not parent or DaHubBatSkin.watched[parent] then return end
    DaHubBatSkin.watched[parent] = true
    table.insert(S.batSkinConnections, parent.ChildAdded:Connect(function(child)
        task.wait(0.1)
        if DaHubBatSkin.daHubIsBat(child) then DaHubBatSkin.daHubApplyBatSkin(child) end
    end))
    DaHubBatSkin.daHubScanBatSkins(parent)
end

function DaHubBatSkin.daHubWatchBatSkinCharacter(character)
    DaHubBatSkin.daHubWatchBatSkinContainer(character)
    DaHubBatSkin.daHubWatchBatSkinContainer(LP:FindFirstChildOfClass("Backpack"))
    if S.batSkinMode ~= "Off" then
        task.delay(0.35, function()
            if LP.Character == character then
                DaHubBatSkin.daHubScanBatSkins(character)
                DaHubBatSkin.daHubScanBatSkins(LP:FindFirstChildOfClass("Backpack"))
            end
        end)
    end
end

function DaHubBatSkin.daHubSetBatSkin(mode, shouldSave)
    local valid = false
    for _, entry in ipairs(DAHUB_BAT_SKINS) do
        if entry.name == mode then valid = true; break end
    end
    S.batSkinMode = valid and mode or "Off"
    DaHubBatSkin.daHubScanBatSkins(LP.Character)
    DaHubBatSkin.daHubScanBatSkins(LP:FindFirstChildOfClass("Backpack"))
    if S.batSkinSelectorLabel then S.batSkinSelectorLabel.Text = S.batSkinMode end
    if shouldSave then saveConfig() end
end

function DaHubBatSkin.daHubCycleBatSkin(direction)
    local index = 1
    for i, entry in ipairs(DAHUB_BAT_SKINS) do
        if entry.name == S.batSkinMode then index = i; break end
    end
    index = index + (direction or 1)
    if index < 1 then index = #DAHUB_BAT_SKINS end
    if index > #DAHUB_BAT_SKINS then index = 1 end
    DaHubBatSkin.daHubSetBatSkin(DAHUB_BAT_SKINS[index].name, true)
end

S.setBatSkin = DaHubBatSkin.daHubSetBatSkin
S.cycleBatSkin = DaHubBatSkin.daHubCycleBatSkin

LP.CharacterAdded:Connect(function(character)
    task.wait(0.2)
    DaHubBatSkin.daHubWatchBatSkinCharacter(character)
end)
LP.ChildAdded:Connect(function(child)
    if child:IsA("Backpack") then DaHubBatSkin.daHubWatchBatSkinContainer(child) end
end)
DaHubBatSkin.daHubWatchBatSkinCharacter(LP.Character)
end

-- ==================== PRIME.VS MEDUSA COSMETIC ====================
do
DaHubMedusaSkin = {watched = setmetatable({}, {__mode="k"})}
function DaHubMedusaSkin.load(assetId)
    local ok, objects = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(assetId)) end)
    if ok and type(objects)=="table" and #objects>0 then return objects end
    local loaded
    pcall(function() loaded=game:GetService("InsertService"):LoadAsset(tonumber(assetId)) end)
    return loaded and {loaded} or nil
end
local function DaHubClearMedusaVisual(tool)
if not tool then return end
pcall(function()
local folder = tool:FindFirstChild("Hub073GearVisual")
if folder then folder:Destroy() end
local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
if handle then
for _, ch in ipairs(handle:GetChildren()) do
if ch.Name == "Hub073GearMesh" or (ch:IsA("SpecialMesh") and ch:GetAttribute("Hub073")) then
ch:Destroy()
end
end
local orig = tool:GetAttribute("Hub073OrigHandleTrans")
if orig ~= nil then
handle.Transparency = orig
elseif handle.Transparency >= 0.99 then
handle.Transparency = 0
end
end
end)
end
local function DaHubApplyMedusaAsset(tool, assetId)
if not tool or not assetId then return false end
if tool:GetAttribute("Hub073Applying") then return false end
tool:SetAttribute("Hub073Applying", true)
assetId = tonumber(tostring(assetId):match("%d+")) or assetId
local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
if not handle then
tool:SetAttribute("Hub073Applying", nil)
return false
end
local success = false
pcall(function()
DaHubClearMedusaVisual(tool)
if tool:GetAttribute("Hub073OrigHandleTrans") == nil then
tool:SetAttribute("Hub073OrigHandleTrans", handle.Transparency)
end
local objs = DaHubMedusaSkin.load(assetId)
if not objs or #objs == 0 then return end
local folder = Instance.new("Folder")
folder.Name = "Hub073GearVisual"
folder.Parent = tool
local srcTool, srcHandle
for _, o in ipairs(objs) do
if o:IsA("Tool") then
srcTool = o
srcHandle = o:FindFirstChild("Handle") or o:FindFirstChildWhichIsA("BasePart")
break
end
local t = o:FindFirstChildOfClass("Tool") or o:FindFirstChildWhichIsA("Tool", true)
if t then
srcTool = t
srcHandle = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
break
end
end
if not srcHandle then
for _, o in ipairs(objs) do
if o:IsA("BasePart") then srcHandle = o; break end
local p = o:FindFirstChildWhichIsA("BasePart", true)
if p then srcHandle = p; break end
end
end
local skinConfig = nil
local orientFix = skinConfig and skinConfig.c0 or CFrame.new()
local parts = {}
local root = srcTool or objs[1]
if root then
if root:IsA("BasePart") then table.insert(parts, root) end
if root:IsA("Accessory") then
local ah = root:FindFirstChild("Handle")
if ah then table.insert(parts, ah) end
end
for _, d in ipairs(root:GetDescendants()) do
if d:IsA("BasePart") then table.insert(parts, d) end
end
end
if #parts == 0 and srcHandle then
table.insert(parts, srcHandle)
end
local seen = {}
local unique = {}
for _, p in ipairs(parts) do
if not seen[p] then
seen[p] = true
table.insert(unique, p)
end
end
parts = unique
if #parts > 0 then
handle.Transparency = 1
local pivot = srcHandle or parts[1]
for _, src in ipairs(parts) do
local okc, clone = pcall(function() return src:Clone() end)
if okc and clone then
for _, child in ipairs(clone:GetDescendants()) do
if child:IsA("LuaSourceContainer") or child:IsA("Sound") then child:Destroy() end
end
clone.Name = "GV_" .. tostring(src.Name)
clone.Anchored = false
clone.CanCollide = false
clone.Massless = true
pcall(function()
clone.CanQuery = false
clone.CanTouch = false
end)
local rel = pivot.CFrame:ToObjectSpace(src.CFrame)
clone.CFrame = handle.CFrame * orientFix * rel
clone.Parent = folder
local w = Instance.new("Weld")
w.Name = "Hub073GearWeld"
w.Part0 = handle
w.Part1 = clone
w.C0 = orientFix * rel
w.C1 = CFrame.new()
w.Parent = clone
success = true
end
end
elseif srcHandle then
local mesh = srcHandle:FindFirstChildOfClass("SpecialMesh")
if mesh then
local m = mesh:Clone()
m.Name = "Hub073GearMesh"
m:SetAttribute("Hub073", true)
m.Parent = handle
success = true
end
for _, d in ipairs(srcHandle:GetChildren()) do
if d:IsA("Decal") or d:IsA("Texture") then
pcall(function() d:Clone().Parent = handle end)
end
end
pcall(function()
handle.Color = srcHandle.Color
handle.Material = srcHandle.Material
handle.Reflectance = srcHandle.Reflectance
end)
end
for _, o in ipairs(objs) do
pcall(function() o:Destroy() end)
end
end)
tool:SetAttribute("Hub073Applying", nil)
-- Original Medusa sounds are untouched, exactly as in Prime.vs.
return success
end

function DaHubMedusaSkin.apply(tool)
    if not tool or not tool:IsA("Tool") or not tool.Name:lower():find("medusa",1,true) then return end
    if S.medusaSkinMode == "Medusa 1" then
        DaHubApplyMedusaAsset(tool,11563251)
    else
        DaHubClearMedusaVisual(tool)
    end
end
function DaHubMedusaSkin.scan(parent)
    if not parent then return end
    for _, tool in ipairs(parent:GetChildren()) do task.spawn(DaHubMedusaSkin.apply,tool) end
end
function DaHubMedusaSkin.watch(parent)
    if not parent or DaHubMedusaSkin.watched[parent] then return end
    DaHubMedusaSkin.watched[parent]=true
    parent.ChildAdded:Connect(function(tool) task.wait(0.15); DaHubMedusaSkin.apply(tool) end)
    DaHubMedusaSkin.scan(parent)
end
function DaHubMedusaSkin.set(mode,shouldSave)
    S.medusaSkinMode=mode=="Medusa 1" and "Medusa 1" or "Off"
    DaHubMedusaSkin.scan(LP.Character)
    DaHubMedusaSkin.scan(LP:FindFirstChildOfClass("Backpack"))
    if S.medusaSkinSelectorLabel then S.medusaSkinSelectorLabel.Text=S.medusaSkinMode end
    if shouldSave then saveConfig() end
end
S.setMedusaSkin=DaHubMedusaSkin.set
LP.CharacterAdded:Connect(function(character) DaHubMedusaSkin.watch(character) end)
LP.ChildAdded:Connect(function(child) if child:IsA("Backpack") then DaHubMedusaSkin.watch(child) end end)
DaHubMedusaSkin.watch(LP.Character)
DaHubMedusaSkin.watch(LP:FindFirstChildOfClass("Backpack"))
end

-- ==================== DAHUB DISPLAY MODE / COMPLETE SKINS ====================
do
DaHubDisplaySkin = {}
DAHUB_SKIN_ORDER = {"Off", "PURPLE", "BLUE", "RED", "BLACK", "GREEN", "WHITE", "BLEED 1", "BLEED 2", "BLEED 3", "BLEED 4", "BLEED 5"}
DAHUB_SKIN_SETS = {
    ["BLEED 1"] = {accessories={306969564}, headless=false, korblox="Right", shirtTemplate="rbxassetid://10632503795", pantsTemplate="rbxassetid://123161592384863", headMesh="rbxassetid://134079402", headTexture="rbxassetid://133940918", color=Color3.fromRGB(255,255,255)},
    ["BLEED 2"] = {accessories={1744060292}, headless=false, korblox="Right", shirtTemplate="rbxassetid://11526718530", pantsTemplate="rbxassetid://93710523210027", headMesh="rbxassetid://134079402", headTexture="rbxassetid://133940918", color=Color3.fromRGB(255,255,255)},
    ["BLEED 3"] = {accessories={112564966849233}, headless=false, korblox="Right", shirtTemplate="rbxassetid://11849088376", pantsTemplate="rbxassetid://16534673928", headMesh="rbxassetid://134079402", headTexture="rbxassetid://133940918", color=Color3.fromRGB(255,255,255)},
    ["BLEED 4"] = {accessories={10159600649}, headless=false, korblox="Off", shirtTemplate="rbxassetid://9683332638", pantsTemplate="rbxassetid://93182020184041", headMesh="rbxassetid://134079402", headTexture="rbxassetid://133940918", color=Color3.fromRGB(255,255,255)},
    ["BLEED 5"] = {accessories={8349240186}, headless=false, korblox="Off", shirtTemplate="rbxassetid://11926549070", pantsTemplate="rbxassetid://13189494471", headMesh="rbxassetid://16673245747", headTexture=nil, color=Color3.fromRGB(255,255,255)},
    PURPLE = {hats="1744060292,439945661,1125510,1029025", hair="", headless=true, korblox="Right", accessories={1744060292,439945661,1125510,1029025,11748356,8465506143,11444217173}, clothing={7424637509,7689651773}, color=DaHubThemeRGB(200, 200, 200)},
    BLUE = {hats="74891470", hair="16630147,6346833550,6594911228,6594919952,6823338112,7097747842", headless=true, korblox="Right", accessories={74891470,16630147,6346833550,6594911228,6594919952,6823338112,7097747842}, clothing={18423061209,18423154566}, color=DaHubThemeRGB(55,145,255)},
    RED = {hats="215718515,439945661", hair="7183785281", headless=true, korblox="Right", accessories={215718515,439945661,7183785281}, clothing={15998365201,7689651773}, color=DaHubThemeRGB(235,62,72)},
    BLACK = {hats="10159600649,439946249,17798262442,92482095662016", hair="139101716417676", headless=true, korblox="Right", accessories={10159600649,439946249,17798262442,92482095662016,139101716417676,12490213797}, clothing={18766106994,13925390578}, color=DaHubThemeRGB(24,24,30)},
    GREEN = {hats="553970961,1744060292", hair="93268856876777", headless=true, korblox="Right", accessories={553970961,1744060292,93268856876777}, clothing={9478068776,6348682339}, color=DaHubThemeRGB(62,210,112)},
    WHITE = {hats="74891470,215718515,439945661,1016143686,1744060292,10159600649,89012651581593,88365652378427", hair="126447390530523", headless=true, korblox="Right", accessories={74891470,215718515,439945661,1016143686,1744060292,10159600649,89012651581593,126447390530523}, clothing={88032876921227,108259950755140}, color=DaHubThemeRGB(238,238,244)},
}
DAHUB_ASSET_PROPERTIES = {
    [1744060292]="HatAccessory", [439945661]="HatAccessory", [1125510]="HatAccessory", [1029025]="HatAccessory", [8465506143]="HatAccessory", [74891470]="HatAccessory", [215718515]="HatAccessory", [10159600649]="HatAccessory", [439946249]="HatAccessory", [17798262442]="HatAccessory", [92482095662016]="HatAccessory", [553970961]="HatAccessory", [1016143686]="HatAccessory", [89012651581593]="HatAccessory", [88365652378427]="HatAccessory",
    [16630147]="HairAccessory", [6346833550]="HairAccessory", [6594911228]="HairAccessory", [6594919952]="HairAccessory", [6823338112]="HairAccessory", [7097747842]="HairAccessory", [7183785281]="HairAccessory", [139101716417676]="HairAccessory", [93268856876777]="HairAccessory", [126447390530523]="HairAccessory",
    [11748356]="FaceAccessory", [12490213797]="FaceAccessory", [11444217173]="NeckAccessory",
    [7424637509]="Shirt", [18423061209]="Shirt", [15998365201]="Shirt", [18766106994]="Shirt", [9478068776]="Shirt", [88032876921227]="Shirt",
    [7689651773]="Pants", [18423154566]="Pants", [13925390578]="Pants", [6348682339]="Pants", [108259950755140]="Pants",
}
DaHubOriginalDescriptions = setmetatable({}, {__mode="k"})
DaHubOriginalOutfits = setmetatable({}, {__mode="k"})

function DaHubDisplaySkin.assetInSet(id, setData)
    id=tonumber(id); if not id or not setData then return false end
    for _,v in ipairs(setData.accessories or {}) do if id==v then return true end end
    for _,v in ipairs(setData.clothing or {}) do if id==v then return true end end
    return false
end
function DaHubDisplaySkin.appendDescriptionAsset(description, id)
    local property=DAHUB_ASSET_PROPERTIES[tonumber(id)]
    if not property then return end
    if property=="Shirt" or property=="Pants" then description[property]=tonumber(id); return end
    local old=tostring(description[property] or "")
    if not old:find(tostring(id),1,true) then description[property]=(old=="" and tostring(id) or old..","..tostring(id)) end
end
function DaHubDisplaySkin.buildDescription(setName, character)
    local setData=DAHUB_SKIN_SETS[setName]; if not setData then return nil end
    local humanoid=character and character:FindFirstChildOfClass("Humanoid"); if not humanoid then return nil end
    local description
    pcall(function() description=humanoid:GetAppliedDescription():Clone() end)
    if not description then pcall(function() description=Players:GetHumanoidDescriptionFromUserId(LP.UserId) end) end
    if not description then description=Instance.new("HumanoidDescription") end
    for _,property in ipairs({"HatAccessory","HairAccessory","FaceAccessory","NeckAccessory","ShouldersAccessory","FrontAccessory","BackAccessory","WaistAccessory","ShirtAccessory","PantsAccessory","JacketAccessory","SweaterAccessory","ShortsAccessory","TShirtAccessory","DressSkirtAccessory"}) do pcall(function() description[property]="" end) end
    pcall(function() description.Shirt=0; description.Pants=0; description.GraphicTShirt=0; description.HatAccessory=setData.hats or ""; description.HairAccessory=setData.hair or "" end)
    for _,id in ipairs(setData.accessories or {}) do DaHubDisplaySkin.appendDescriptionAsset(description,id) end
    for _,id in ipairs(setData.clothing or {}) do DaHubDisplaySkin.appendDescriptionAsset(description,id) end
    return description
end
function DaHubDisplaySkin.applyDescription(humanoid, description)
    if not humanoid or not description then return false end
    for _,methodName in ipairs({"ApplyDescriptionClientServer","ApplyDescriptionReset","ApplyDescription"}) do
        local method
        pcall(function() method=humanoid[methodName] end)
        if type(method)=="function" then
            local copy=description:Clone(); local ok=pcall(method,humanoid,copy); copy:Destroy(); if ok then return true end
        end
    end
    return false
end
function DaHubDisplaySkin.captureOriginalOutfit(character)
    if DaHubOriginalOutfits[character] then return end
    local saved={}
    for _,child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Accoutrement") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
            local ok,clone=pcall(function() return child:Clone() end)
            if ok and clone then saved[#saved+1]=clone end
        end
    end
    DaHubOriginalOutfits[character]=saved
end
function DaHubDisplaySkin.restoreOriginalOutfit(character)
    local saved=DaHubOriginalOutfits[character]
    if not saved then return end
    for _,child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Accoutrement") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then pcall(function() child:Destroy() end) end
    end
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    for _,clone in ipairs(saved) do
        local copy=clone:Clone()
        if copy:IsA("Accessory") and humanoid then DaHubDisplaySkin.attachAccessory(character,humanoid,copy) else copy.Parent=character end
    end
end

function DaHubDisplaySkin.clearMarked(character)
    for _,child in ipairs(character:GetChildren()) do
        if child:GetAttribute("DaHubCompleteSkin") then pcall(function() child:Destroy() end) end
    end
end
function DaHubDisplaySkin.markAndColor(character, setData)
    for _,child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Accoutrement") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
            local id
            pcall(function() id=tonumber(child.SourceAssetId) end)
            if DaHubDisplaySkin.assetInSet(id,setData) then child:SetAttribute("DaHubCompleteSkin",true) end
        end
    end
    for _,descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            local parent=descendant
            while parent and parent~=character do
                if parent:GetAttribute("DaHubCompleteSkin") then descendant.Color=setData.color; break end
                parent=parent.Parent
            end
        end
    end
end
function DaHubDisplaySkin.setHeadless(character, enabled)
    local head=character and character:FindFirstChild("Head"); if not head then return end
    local transparency=enabled and 1 or 0; head.Transparency=transparency; head.LocalTransparencyModifier=transparency
    for _,child in ipairs(head:GetChildren()) do if child:IsA("Decal") or child:IsA("Texture") then child.Transparency=transparency end end
end
function DaHubDisplaySkin.attachAccessory(character, humanoid, accessory)
    local handle=accessory:FindFirstChild("Handle",true)
    pcall(function() humanoid:AddAccessory(accessory) end)
    if not accessory.Parent then accessory.Parent=character end
    if not handle or not handle:IsA("BasePart") then return accessory.Parent==character end
    local handleAttachment=handle:FindFirstChildWhichIsA("Attachment")
    if not handleAttachment then return accessory.Parent==character end
    local targetAttachment
    for _,descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("Attachment") and descendant.Name==handleAttachment.Name and not descendant:IsDescendantOf(accessory) then targetAttachment=descendant; break end
    end
    if targetAttachment and targetAttachment.Parent:IsA("BasePart") then
        handle.Anchored=false; handle.CanCollide=false; handle.CanTouch=false; handle.CanQuery=false; handle.Massless=true
        handle.CFrame=targetAttachment.Parent.CFrame*targetAttachment.CFrame*handleAttachment.CFrame:Inverse()
        if not handle:FindFirstChild("DaHubAccessoryWeld") then
            local weld=Instance.new("WeldConstraint"); weld.Name="DaHubAccessoryWeld"; weld.Part0=targetAttachment.Parent; weld.Part1=handle; weld.Parent=handle
        end
    end
    return accessory.Parent==character
end
function DaHubDisplaySkin.hasAsset(character, assetId)
    assetId=tonumber(assetId)
    for _,child in ipairs(character:GetChildren()) do
        local sourceId
        pcall(function() sourceId=tonumber(child.SourceAssetId) end)
        if assetId and assetId>0 then
            if sourceId==assetId or tonumber(child:GetAttribute("DaHubSkinAssetId"))==assetId then return true end
        end
    end
    return false
end
function DaHubDisplaySkin.addAsset(character, humanoid, assetId)
    if DaHubDisplaySkin.hasAsset(character,assetId) then return true end
    local ok, objects=pcall(function() return game:GetObjects("rbxassetid://"..tostring(assetId)) end)
    if not ok or type(objects)~="table" or #objects==0 then
        local loaded
        pcall(function() loaded=game:GetService("InsertService"):LoadAsset(tonumber(assetId)) end)
        objects=loaded and {loaded} or {}
    end
    local added=false
    for _,root in ipairs(objects) do
        local candidates={}
        if root:IsA("Accessory") or root:IsA("Shirt") or root:IsA("Pants") or root:IsA("ShirtGraphic") then table.insert(candidates,root) end
        for _,descendant in ipairs(root:GetDescendants()) do
            if descendant:IsA("Accessory") or descendant:IsA("Shirt") or descendant:IsA("Pants") or descendant:IsA("ShirtGraphic") then table.insert(candidates,descendant) end
        end
        for _,source in ipairs(candidates) do
            local clone=source:Clone(); clone:SetAttribute("DaHubCompleteSkin",true); clone:SetAttribute("DaHubSkinAssetId",tonumber(assetId))
            if clone:IsA("Accessory") then
                if DaHubDisplaySkin.attachAccessory(character,humanoid,clone) then added=true end
            else
                for _,old in ipairs(character:GetChildren()) do if old.ClassName==clone.ClassName and old:GetAttribute("DaHubCompleteSkin") then old:Destroy() end end
                clone.Parent=character; added=true
            end
        end
        pcall(function() root:Destroy() end)
    end
    return added
end

function DaHubDisplaySkin.applyAccessories(character, humanoid, description, setData)
    local source
    pcall(function() source=Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15) end)
    if not source then pcall(function() source=Players:CreateHumanoidModelFromDescription(description,Enum.HumanoidRigType.R15) end) end
    if not source then return end
    for _,child in ipairs(source:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
            if child:IsA("Accessory") then
                local sourceId; pcall(function() sourceId=tonumber(child.SourceAssetId) end)
                if not DaHubDisplaySkin.hasAsset(character,sourceId) then
                    local clone=child:Clone(); clone:SetAttribute("DaHubCompleteSkin",true); clone:SetAttribute("DaHubSkinAssetId",sourceId)
                    DaHubDisplaySkin.attachAccessory(character,humanoid,clone)
                end
            else
                for _,current in ipairs(character:GetChildren()) do if current.ClassName==child.ClassName then pcall(function() current:Destroy() end) end end
                local clone=child:Clone(); clone:SetAttribute("DaHubCompleteSkin",true); clone.Parent=character
            end
        end
    end
    source:Destroy(); DaHubDisplaySkin.markAndColor(character,setData)
end

function DaHubDisplaySkin.apply(token)
    token=token or S._skinApplyToken
    local character=LP.Character; local setName=S.displaySkin
    if token~=S._skinApplyToken or not character or setName=="Off" or not S.customSkinEnabled then return end
    local humanoid=character:FindFirstChildOfClass("Humanoid"); local setData=DAHUB_SKIN_SETS[setName]
    if not humanoid or not setData then return end
    if not DaHubOriginalDescriptions[character] then pcall(function() DaHubOriginalDescriptions[character]=humanoid:GetAppliedDescription():Clone() end) end
    DaHubDisplaySkin.captureOriginalOutfit(character)
    local originalHead=character:FindFirstChild("Head")
    local originalMesh=originalHead and originalHead:FindFirstChildOfClass("SpecialMesh")
    if originalMesh and originalHead:GetAttribute("DaHubOriginalHeadMesh")~=nil then
        originalMesh.MeshId=originalHead:GetAttribute("DaHubOriginalHeadMesh")
        originalMesh.TextureId=originalHead:GetAttribute("DaHubOriginalHeadTexture") or ""
    end

    -- Vanta quita los accesorios actuales y aplica la descripción completa primero.
    for _,child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Accoutrement") then pcall(function() child:Destroy() end) end
    end
    local description=DaHubDisplaySkin.buildDescription(setName,character)
    if description then DaHubDisplaySkin.applyDescription(humanoid,description) end
    task.wait(0.18)
    if token~=S._skinApplyToken then if description then description:Destroy() end; return end

    -- Fallback directo: añade cada asset de la skin aunque ApplyDescription no lo adjunte.
    for _,id in ipairs(setData.accessories or {}) do DaHubDisplaySkin.addAsset(character,humanoid,id) end
    for _,id in ipairs(setData.clothing or {}) do DaHubDisplaySkin.addAsset(character,humanoid,id) end
    task.wait(0.35)
    if token~=S._skinApplyToken then if description then description:Destroy() end; return end
    for _,id in ipairs(setData.accessories or {}) do DaHubDisplaySkin.addAsset(character,humanoid,id) end
    for _,id in ipairs(setData.clothing or {}) do DaHubDisplaySkin.addAsset(character,humanoid,id) end
    if description then DaHubDisplaySkin.applyAccessories(character,humanoid,description,setData) end
    if description then description:Destroy() end
    DaHubDisplaySkin.markAndColor(character,setData)
    if setData.shirtTemplate then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") then item:Destroy() end
        end
        local shirt=Instance.new("Shirt",character); shirt.ShirtTemplate=setData.shirtTemplate; shirt:SetAttribute("DaHubCompleteSkin",true)
        local pants=Instance.new("Pants",character); pants.PantsTemplate=setData.pantsTemplate; pants:SetAttribute("DaHubCompleteSkin",true)
    end
    local head=character:FindFirstChild("Head")
    if setData.headMesh and head then
        local mesh=head:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            if head:GetAttribute("DaHubOriginalHeadMesh")==nil then
                head:SetAttribute("DaHubOriginalHeadMesh",mesh.MeshId)
                head:SetAttribute("DaHubOriginalHeadTexture",mesh.TextureId)
            end
            mesh.MeshId=setData.headMesh
            mesh.TextureId=setData.headTexture or ""
        end
    end
    DaHubDisplaySkin.setHeadless(character,setData.headless==true)
    if type(_G._DaHubApplyKroblox)=="function" then pcall(_G._DaHubApplyKroblox,setData.korblox or "Off") end
end

function DaHubDisplaySkin.off()
    local character=LP.Character; if not character then return end
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    local head=character:FindFirstChild("Head")
    local mesh=head and head:FindFirstChildOfClass("SpecialMesh")
    if mesh and head:GetAttribute("DaHubOriginalHeadMesh")~=nil then
        mesh.MeshId=head:GetAttribute("DaHubOriginalHeadMesh")
        mesh.TextureId=head:GetAttribute("DaHubOriginalHeadTexture") or ""
        head:SetAttribute("DaHubOriginalHeadMesh",nil); head:SetAttribute("DaHubOriginalHeadTexture",nil)
    end
    DaHubDisplaySkin.clearMarked(character)
    if humanoid and DaHubOriginalDescriptions[character] then
        DaHubDisplaySkin.applyDescription(humanoid,DaHubOriginalDescriptions[character]:Clone())
        task.wait(0.2)
    end
    DaHubDisplaySkin.restoreOriginalOutfit(character)
    DaHubDisplaySkin.setHeadless(character,false)
    if type(_G._DaHubApplyKroblox)=="function" then pcall(_G._DaHubApplyKroblox,"Off") end
end
function DaHubDisplaySkin.setSkin(name,save)
    S._skinApplyToken=S._skinApplyToken+1
    local myToken=S._skinApplyToken
    local valid=false; for _,v in ipairs(DAHUB_SKIN_ORDER) do if v==name then valid=true end end
    S.displaySkin=valid and name or "Off"
    if S.displaySkin=="Off" then S.customSkinEnabled=false; DaHubDisplaySkin.off() else S.customSkinEnabled=true; task.spawn(function() pcall(DaHubDisplaySkin.apply,myToken) end) end
    if S.displaySkinSelectorLabel then S.displaySkinSelectorLabel.Text=S.displaySkin end
    if S.customSkinVisual then S.customSkinVisual(S.customSkinEnabled) end
    if save then saveConfig() end
end
function DaHubDisplaySkin.cycleSkin(direction)
    local index=1; for i,v in ipairs(DAHUB_SKIN_ORDER) do if v==S.displaySkin then index=i end end
    index=index+(direction or 1); if index<1 then index=#DAHUB_SKIN_ORDER end; if index>#DAHUB_SKIN_ORDER then index=1 end
    DaHubDisplaySkin.setSkin(DAHUB_SKIN_ORDER[index],true)
end
function DaHubDisplaySkin.setCustom(on)
    S._skinApplyToken=S._skinApplyToken+1
    local myToken=S._skinApplyToken
    S.customSkinEnabled=on==true
    if S.customSkinEnabled then if S.displaySkin=="Off" then S.displaySkin="PURPLE" end; task.spawn(function() DaHubDisplaySkin.apply(myToken) end) else DaHubDisplaySkin.off() end
    if S.customSkinVisual then S.customSkinVisual(S.customSkinEnabled) end
    if S.displaySkinSelectorLabel then S.displaySkinSelectorLabel.Text=S.displaySkin end
    saveConfig()
end
S.setDisplaySkin=DaHubDisplaySkin.setSkin; S.cycleDisplaySkin=DaHubDisplaySkin.cycleSkin; S.setCustomSkin=DaHubDisplaySkin.setCustom
S.applyDisplaySkin=function(token) return DaHubDisplaySkin.apply(token) end
LP.CharacterAdded:Connect(function(character) task.wait(0.4); DaHubOriginalDescriptions[character]=nil; DaHubOriginalOutfits[character]=nil; if S.customSkinEnabled and S.displaySkin~="Off" then task.spawn(DaHubDisplaySkin.apply) end end)
end

-- ==================== MYSTERY INFORMATION E01 ====================
do
    local running = true
    if type(_G._DaHubInformationE01Cleanup) == "function" then
        pcall(_G._DaHubInformationE01Cleanup)
    end
    local introGeneration = 0
    local wasHoldingBrainrot = false
    local activeIntroGui = nil
    local activeCameraConn = nil
    local function clearIntro()
        introGeneration = introGeneration + 1
        if activeIntroGui then pcall(function() activeIntroGui:Destroy() end); activeIntroGui = nil end
        if activeCameraConn then activeCameraConn:Disconnect(); activeCameraConn = nil end
    end
    S.setInformationE01 = function(on, persist)
        S.informationE01Enabled = on == true
        if not S.informationE01Enabled then clearIntro(); wasHoldingBrainrot = false end
        if S.setInformationE01Visual then S.setInformationE01Visual(S.informationE01Enabled) end
        if persist ~= false then saveConfig() end
    end
    _G._DaHubInformationE01Cleanup = function()
        running = false
        clearIntro()
    end

    local function isHoldingBrainrot()
        if _G.AceSafeModeHoldingBrainrot then
            local ok, carrying = pcall(_G.AceSafeModeHoldingBrainrot)
            if ok and carrying then return true end
        end

        local char = LP and LP.Character
        if not char then return false end
        for _, child in ipairs(char:GetChildren()) do
            local name = tostring(child.Name or ""):lower()
            if (child:IsA("Tool") or child:IsA("Model")) and
               (name:find("brainrot", 1, true) or name:find("animal", 1, true) or
                name:find("carry", 1, true) or name:find("grab", 1, true) or
                name:find("steal", 1, true) or name:find("hold", 1, true)) then
                return true
            end
        end
        return false
    end

    local function playBrainrotIntro(myGeneration)
        -- O aviso não altera a visibilidade nem o estado do menu.
        if activeIntroGui then pcall(function() activeIntroGui:Destroy() end) end

        local playerGui = LP and (LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 5))
        if not playerGui or myGeneration ~= introGeneration or not isHoldingBrainrot()
           or (S and S.informationE01Enabled == false) then return end

        local introGui = Instance.new("ScreenGui")
        introGui.Name = "BrainrotEnterIntro"
        introGui.ResetOnSpawn = false
        introGui.IgnoreGuiInset = true
        introGui.DisplayOrder = 1000000
        introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        introGui.Parent = playerGui
        activeIntroGui = introGui

        local strip = Instance.new("Frame")
        strip.Name = "EnterStrip"
        strip.AnchorPoint = Vector2.new(0.5, 0.5)
        strip.Position = UDim2.new(0.5, 0, -0.18, 0)
        strip.BackgroundColor3 = Color3.fromRGB(176, 24, 45)
        strip.BackgroundTransparency = 0
        strip.BorderSizePixel = 0
        strip.ClipsDescendants = false
        strip.ZIndex = 2
        strip.Parent = introGui
        Instance.new("UICorner", strip).CornerRadius = UDim.new(1, 0)
        local completeBorder = Instance.new("UIStroke", strip)
        completeBorder.Name = "CompleteLoadingBorder"
        completeBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        completeBorder.Color = Color3.fromRGB(22, 112, 62)
        completeBorder.Thickness = 3
        completeBorder.Transparency = 1
        completeBorder.ZIndex = 6

        local scale = Instance.new("UIScale", strip)
        scale.Scale = 0.9

        local stripHeight = 46
        local cornerRadius = 23
        local lineThickness = 3
        local inset = 3

        local function fitStrip()
            local camera = workspace.CurrentCamera
            if not camera or not strip.Parent then return end
            local width = math.min(math.max(150, math.floor(camera.ViewportSize.X * 0.33)), math.max(1, camera.ViewportSize.X - 24))
            strip.Size = UDim2.fromOffset(width, stripHeight)
        end
        fitStrip()

        local cameraConn
        local function bindCamera(camera)
            if cameraConn then cameraConn:Disconnect(); cameraConn = nil end
            if camera then cameraConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitStrip) end
            activeCameraConn = cameraConn
        end
        bindCamera(workspace.CurrentCamera)

        local label = Instance.new("TextLabel")
        label.Name = "EnterLabel"
        label.Size = UDim2.new(1, -32, 1, -16)
        label.Position = UDim2.fromOffset(16, 8)
        label.BackgroundTransparency = 1
        label.Text = "DON'T ENTER"
        label.TextColor3 = Color3.fromRGB(255, 228, 142)
        label.TextTransparency = 0
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.TextWrapped = true
        label.ZIndex = 5
        label.Parent = strip
        local textLimit = Instance.new("UITextSizeConstraint", label)
        textLimit.MinTextSize = 10
        textLimit.MaxTextSize = 16


        local function stillValid()
            return running and myGeneration == introGeneration and introGui.Parent ~= nil and isHoldingBrainrot()
                and not (S and S.informationE01Enabled == false)
        end
        local function abortIfReleased()
            if stillValid() then return false end
            if cameraConn then cameraConn:Disconnect(); cameraConn = nil end
            if introGui.Parent then introGui:Destroy() end
            if activeIntroGui == introGui then activeIntroGui = nil end
            return true
        end

        local arrival = TS_G:Create(strip, TweenInfo.new(0.52, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.fromScale(0.5, 0.12)
        })
        TS_G:Create(scale, TweenInfo.new(0.52, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        arrival:Play()
        arrival.Completed:Wait()
        if abortIfReleased() then return end

        -- Linha continua de carregamento, preenchida da esquerda para a direita.
        local revealTime = 1.9
        local DARK_CYAN = Color3.fromRGB(22, 112, 62)
        local track = Instance.new("Frame", strip)
        track.Name = "LoadingTrack"
        track.AnchorPoint = Vector2.new(0.5, 1)
        track.Position = UDim2.new(0.5, 0, 1, -6)
        track.Size = UDim2.new(1, -26, 0, lineThickness)
        track.BackgroundColor3 = Color3.fromRGB(255, 228, 142)
        track.BackgroundTransparency = 0.2
        track.BorderSizePixel = 0
        track.ClipsDescendants = true
        track.ZIndex = 6
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local lineFill = Instance.new("Frame", track)
        lineFill.Name = "LoadingLine"
        lineFill.Size = UDim2.new(0, 0, 1, 0)
        lineFill.BackgroundColor3 = DARK_CYAN
        lineFill.BorderSizePixel = 0
        lineFill.ZIndex = 7
        Instance.new("UICorner", lineFill).CornerRadius = UDim.new(1, 0)

        local elapsed = 0
        while elapsed < revealTime do
            lineFill.Size = UDim2.new(math.clamp(elapsed / revealTime, 0, 1), 0, 1, 0)
            elapsed = elapsed + task.wait()
            if abortIfReleased() then return end
        end
        lineFill.Size = UDim2.new(1, 0, 1, 0)
        completeBorder.Transparency = 0



        label.Text = "ENTER"
        label.TextTransparency = 1
        TS_G:Create(label, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        task.wait(0.3)
        if abortIfReleased() then return end

        TS_G:Create(scale, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 1.35}):Play()
        TS_G:Create(strip, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TS_G:Create(label, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        TS_G:Create(completeBorder, TweenInfo.new(0.25), {Transparency = 1}):Play()
        task.wait(0.4)

        if cameraConn then cameraConn:Disconnect(); cameraConn = nil end
        if introGui.Parent then introGui:Destroy() end
        if activeIntroGui == introGui then activeIntroGui = nil end
    end

    -- Only starts on the transition from not holding to holding the pet.
    task.spawn(function()
        while running do
            local holding = isHoldingBrainrot()
            local shouldShow = holding and not (S and S.informationE01Enabled == false)
            if shouldShow and not wasHoldingBrainrot then
                introGeneration = introGeneration + 1
                local thisGeneration = introGeneration
                task.spawn(function() playBrainrotIntro(thisGeneration) end)
            elseif not shouldShow and wasHoldingBrainrot then
                introGeneration = introGeneration + 1
                if activeIntroGui then
                    pcall(function() activeIntroGui:Destroy() end)
                    activeIntroGui = nil
                end
                if activeCameraConn then activeCameraConn:Disconnect(); activeCameraConn = nil end
            end
            wasHoldingBrainrot = shouldShow
            task.wait(0.1)
        end
    end)
end

local function buildMainTab(pages)
    mkSection("Main", pages, "Information")
    S.setInformationE01Visual, _ = mkToggle("Main", pages, "Information E01", nil,
        S.informationE01Enabled, function(on) S.setInformationE01(on, true) end, nil)
    mkSection("Main", pages, "Counters")
    local batVis, _ = mkToggle("Main", pages, "Bat Aimbot", S.KB.AutoBat.kb, S.batAimbotEnabled, function(on)
        if on then
            if S.autoLeftEnabled then S.autoLeftEnabled=false; if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end; stopAutoLeft() end
            if S.autoRightEnabled then S.autoRightEnabled=false; if S.autoRightSetVisual then S.autoRightSetVisual(false) end; stopAutoRight() end
        end
        setBatAimbot(on); updateFloatingButtons()
    end, function(k,isGp)
        if isGp then S.KB.AutoBat.gp=k; S.KB.AutoBat.kb=nil
        else S.KB.AutoBat.kb=k; S.KB.AutoBat.gp=nil end; saveConfig()
    end)
    S.batAimbotSetVisual = batVis
    mkSection("Main", pages, "Bat Bypass")
    S.setBatBypassRowVisual = mkToggle("Main", pages, "Bat Bypass", nil, S.batBypassEnabled,
        function(on) S.setBatBypass(on) end, nil)
    do
        local card = mkCard("Main", pages, 68)
        local label = Instance.new("TextLabel", card)
        label.Position = UDim2.fromOffset(12, 5)
        label.Size = UDim2.new(1, -24, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = "V1–V4 EMBER  ·  V5 FALLS4K"
        label.TextColor3 = C_GREY
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        local pill = Instance.new("Frame", card)
        pill.Name = "BatBypassVersionsPill"
        pill.Position = UDim2.fromOffset(8, 25)
        pill.Size = UDim2.new(1, -16, 0, 34)
        pill.BackgroundColor3 = C_BG
        pill.BorderSizePixel = 0
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        local border = Instance.new("UIStroke", pill)
        border.Color = C_BORDER; border.Transparency = 0.25
        local buttons = {}
        for index = 1, 5 do
            local version = "v" .. index
            local choice = Instance.new("TextButton", pill)
            choice.Name = "Bypass_" .. version
            choice.Size = UDim2.new(0.2, -6, 1, -6)
            choice.Position = UDim2.new((index - 1) * 0.2, 3, 0, 3)
            choice.Text = "V" .. index
            choice.Font = Enum.Font.GothamBold
            choice.TextSize = 12
            choice.AutoButtonColor = false
            choice.BorderSizePixel = 0
            Instance.new("UICorner", choice).CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new("UIStroke", choice)
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            buttons[version] = {button = choice, stroke = stroke}
            choice.Activated:Connect(function() S.selectBatBypassVersion(version, true) end)
        end
        S.refreshBatBypassVersions = function()
            for version, ref in pairs(buttons) do
                local selected = version == S.batBypassVersion
                TS_G:Create(ref.button, TweenInfo.new(0.18), {
                    BackgroundColor3 = selected and C_WHITE or C_CARD,
                    BackgroundTransparency = selected and 0.04 or 0.24,
                    TextColor3 = selected and C_BG or C_GREY,
                }):Play()
                TS_G:Create(ref.stroke, TweenInfo.new(0.18), {
                    Color = selected and C_HIGHLIGHT_BRIGHT or C_BORDER,
                    Transparency = selected and 0.15 or 0.65,
                }):Play()
            end
        end
        S.refreshBatBypassVersions()
    end
    mkInput("Main", pages, "Bypass Speed", S.batBypassSpeed or 58,
        function(n) S.batBypassSpeed = math.clamp(n, 1, 500); saveConfig() end)
    S.setBatCounterVisual, _ = mkToggle("Main", pages, "Bat Counter", nil, S.batCounterEnabled, function(on)
        S.batCounterEnabled = on
        if on then startBatCounter() else stopBatCounter() end
        saveConfig()
    end, nil)
    S.setMedusaVisual, _ = mkToggle("Main", pages, "Medusa Counter", nil, S.medusaCounterEnabled, function(on)
        S.medusaCounterEnabled=on
        if on then setupMedusaCounter(LP.Character) else stopMedusaCounter() end; saveConfig()
    end, nil)
    do
        local card = mkCard("Main", pages, 40)
        local label = Instance.new("TextLabel", card)
        label.Size = UDim2.new(0, 108, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "Bat Skins"
        label.TextColor3 = C_WHITE
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        local selector = Instance.new("Frame", card)
        selector.Size = UDim2.new(0, 142, 1, 0)
        selector.Position = UDim2.new(1, -152, 0, 0)
        selector.BackgroundTransparency = 1
        local function makeBatSkinButton(text, x)
            local button = Instance.new("TextButton", selector)
            button.Size = UDim2.new(0, 22, 0, 24)
            button.Position = UDim2.new(0, x, 0.5, -12)
            button.BackgroundTransparency = 1
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = C_WHITE
            button.Font = Enum.Font.GothamBold
            button.TextSize = 13
            button.AutoButtonColor = false
            button.ZIndex = 10
            return button
        end
        local left = makeBatSkinButton("<", 0)
        S.batSkinSelectorLabel = Instance.new("TextLabel", selector)
        S.batSkinSelectorLabel.Size = UDim2.new(0, 90, 0, 24)
        S.batSkinSelectorLabel.Position = UDim2.new(0, 26, 0.5, -12)
        S.batSkinSelectorLabel.BackgroundTransparency = 1
        S.batSkinSelectorLabel.Text = S.batSkinMode
        S.batSkinSelectorLabel.TextColor3 = C_WHITE
        S.batSkinSelectorLabel.Font = Enum.Font.GothamBold
        S.batSkinSelectorLabel.TextSize = 10
        S.batSkinSelectorLabel.TextXAlignment = Enum.TextXAlignment.Center
        S.batSkinSelectorLabel.TextTruncate = Enum.TextTruncate.AtEnd
        S.batSkinSelectorLabel.ZIndex = 9
        local right = makeBatSkinButton(">", 120)
        left.MouseButton1Click:Connect(function() S.cycleBatSkin(-1) end)
        right.MouseButton1Click:Connect(function() S.cycleBatSkin(1) end)
    end
    do
        local card=mkCard("Visual",pages,40)
        local label=Instance.new("TextLabel",card)
        label.Size=UDim2.new(0,108,1,0); label.Position=UDim2.fromOffset(12,0); label.BackgroundTransparency=1
        label.Text="Medusa Skin"; label.Font=Enum.Font.GothamBold; label.TextSize=11; label.TextColor3=C_WHITE; label.TextXAlignment=Enum.TextXAlignment.Left
        local selector=Instance.new("Frame",card); selector.Size=UDim2.new(0,142,1,0); selector.Position=UDim2.new(1,-152,0,0); selector.BackgroundTransparency=1
        S.medusaSkinSelectorLabel=Instance.new("TextLabel",selector)
        local value=S.medusaSkinSelectorLabel; value.Size=UDim2.fromOffset(90,24); value.Position=UDim2.new(0,26,0.5,-12); value.BackgroundTransparency=1
        value.Text=S.medusaSkinMode; value.Font=Enum.Font.GothamBold; value.TextSize=10; value.TextColor3=C_WHITE
        for i,text in ipairs({"<",">"}) do
            local arrow=Instance.new("TextButton",selector); arrow.Size=UDim2.fromOffset(22,24); arrow.Position=UDim2.new(0,(i-1)*120,0.5,-12)
            arrow.BackgroundTransparency=1; arrow.Text=text; arrow.Font=Enum.Font.GothamBold; arrow.TextSize=13; arrow.TextColor3=C_WHITE
            arrow.Activated:Connect(function() S.setMedusaSkin(S.medusaSkinMode=="Off" and "Medusa 1" or "Off",true) end)
        end
    end
    mkSection("Visual", pages, "Display Mode")
    do
        local card = mkCard("Visual", pages, 40)
        local label = Instance.new("TextLabel", card); label.Size=UDim2.new(0,108,1,0); label.Position=UDim2.new(0,12,0,0); label.BackgroundTransparency=1; label.Text="Skins"; label.TextColor3=C_WHITE; label.Font=Enum.Font.GothamBold; label.TextSize=11; label.TextXAlignment=Enum.TextXAlignment.Left
        local selector=Instance.new("Frame",card); selector.Size=UDim2.new(0,142,1,0); selector.Position=UDim2.new(1,-152,0,0); selector.BackgroundTransparency=1
        local left=Instance.new("TextButton",selector); left.Size=UDim2.fromOffset(22,24); left.Position=UDim2.new(0,0,0.5,-12); left.BackgroundTransparency=1; left.Text="<"; left.TextColor3=C_WHITE; left.Font=Enum.Font.GothamBold; left.TextSize=13; left.AutoButtonColor=false
        S.displaySkinSelectorLabel=Instance.new("TextLabel",selector); S.displaySkinSelectorLabel.Size=UDim2.fromOffset(90,24); S.displaySkinSelectorLabel.Position=UDim2.new(0,26,0.5,-12); S.displaySkinSelectorLabel.BackgroundTransparency=1; S.displaySkinSelectorLabel.Text=S.displaySkin; S.displaySkinSelectorLabel.TextColor3=C_WHITE; S.displaySkinSelectorLabel.Font=Enum.Font.GothamBold; S.displaySkinSelectorLabel.TextSize=10; S.displaySkinSelectorLabel.TextXAlignment=Enum.TextXAlignment.Center; S.displaySkinSelectorLabel.TextTruncate=Enum.TextTruncate.AtEnd
        local right=Instance.new("TextButton",selector); right.Size=UDim2.fromOffset(22,24); right.Position=UDim2.new(0,120,0.5,-12); right.BackgroundTransparency=1; right.Text=">"; right.TextColor3=C_WHITE; right.Font=Enum.Font.GothamBold; right.TextSize=13; right.AutoButtonColor=false
        left.MouseButton1Click:Connect(function() S.cycleDisplaySkin(-1) end); right.MouseButton1Click:Connect(function() S.cycleDisplaySkin(1) end)
    end
    S.customSkinVisual, _ = mkToggle("Visual", pages, "Custom Skin", nil, S.customSkinEnabled, function(on) S.setCustomSkin(on) end, nil)
    mkSection("Player", pages, "Player")
    S.setESPVisual, _ = mkToggle("Player", pages, "Player ESP", nil, S.espEnabled, function(on)
        toggleESP(on); saveConfig()
    end, nil)
    S.setFpsVisual, _ = mkToggle("Player", pages, "FPS Boost", nil, S.fpsBoostEnabled, function(on)
        S.fpsBoostEnabled=on; if on then applyFPSBoost() else stopFPSBoost() end; saveConfig()
    end, nil)
    S.setHoldJumpVisual, _ = mkToggle("Player", pages, "Infinity Jump", nil, S.holdJumpEnabled, function(on)
        S.holdJumpEnabled=on
        if on then startHoldJump() else stopHoldJump() end
        saveConfig()
    end, nil)
    mkSection("Player", pages, "Protection")
    S.setAntiFlingVisual, _ = mkToggle("Player", pages, "Anti Fling", nil, S.antiFlingEnabled, function(on)
        if on then YF.startAntiFling() else YF.stopAntiFling() end
        saveConfig()
    end, nil)
    S.bodyLockSetVisual, _ = mkToggle("Player", pages, "Lock Enemy", nil, S.bodyLockEnabled, function(on)
        if on then YF.startBodyLock() else YF.stopBodyLock() end
        saveConfig()
    end, nil)
    mkInput("Player", pages, "Lock Enemy Range", S.bodyLockRange, function(value)
        if value and value > 0 then
            S.bodyLockRange = math.clamp(math.floor(value), 5, 200)
            saveConfig()
        end
    end)
    mkSection("Visual", pages, "Visuals")
    S.setVividVisual, _ = mkToggle("Visual", pages, "Vivid Graphics", nil, S.vividGraphicsEnabled, function(on)
        toggleVividGraphics(on)
    end, nil)
    S.setStretchVisual, _ = mkToggle("Visual", pages, "Stretch Rez", nil, S.stretchEnabled, function(on)
        if on then enableStretch() else disableStretch() end
        S.stretchEnabled = on
        saveConfig()
    end, nil)
    do
        local card = mkCard("Visual", pages, 40)
        local label = Instance.new("TextLabel", card)
        label.Size = UDim2.new(0, 118, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "Kroblox Select"
        label.TextColor3 = C_WHITE
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        local selector = Instance.new("Frame", card)
        selector.Size = UDim2.new(0, 142, 1, 0)
        selector.Position = UDim2.new(1, -152, 0, 0)
        selector.BackgroundTransparency = 1
        local function makeKrobloxButton(text, x)
            local button = Instance.new("TextButton", selector)
            button.Size = UDim2.new(0, 22, 0, 24)
            button.Position = UDim2.new(0, x, 0.5, -12)
            button.BackgroundTransparency = 1
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = C_WHITE
            button.Font = Enum.Font.GothamBold
            button.TextSize = 13
            button.AutoButtonColor = false
            button.ZIndex = 10
            return button
        end
        local left = makeKrobloxButton("<", 0)
        S.krobloxSelectorLabel = Instance.new("TextLabel", selector)
        S.krobloxSelectorLabel.Size = UDim2.new(0, 90, 0, 24)
        S.krobloxSelectorLabel.Position = UDim2.new(0, 26, 0.5, -12)
        S.krobloxSelectorLabel.BackgroundTransparency = 1
        S.krobloxSelectorLabel.Text = S.krobloxMode
        S.krobloxSelectorLabel.TextColor3 = C_WHITE
        S.krobloxSelectorLabel.Font = Enum.Font.GothamBold
        S.krobloxSelectorLabel.TextSize = 10
        S.krobloxSelectorLabel.TextXAlignment = Enum.TextXAlignment.Center
        S.krobloxSelectorLabel.TextTruncate = Enum.TextTruncate.AtEnd
        S.krobloxSelectorLabel.ZIndex = 9
        local right = makeKrobloxButton(">", 120)
        local options = {"Off", "Left", "Right", "Both"}
        local function changeKroblox(direction)
            local index = 1
            for i, name in ipairs(options) do
                if name == S.krobloxMode then index = i; break end
            end
            index = index + direction
            if index < 1 then index = #options end
            if index > #options then index = 1 end
            local mode = options[index]
            pcall(_G._DaHubApplyKroblox, mode)
            S.krobloxSelectorLabel.Text = mode
            saveConfig()
        end
        left.MouseButton1Click:Connect(function()
            changeKroblox(-1)
        end)
        right.MouseButton1Click:Connect(function()
            changeKroblox(1)
        end)
    end
    do
        local card = mkCard("Visual", pages, 40)
        local label = Instance.new("TextLabel", card)
        label.Size = UDim2.new(0, 100, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "Sky Theme"
        label.TextColor3 = C_WHITE
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        local selector = Instance.new("Frame", card)
        selector.Size = UDim2.new(0, 142, 1, 0)
        selector.Position = UDim2.new(1, -152, 0, 0)
        selector.BackgroundTransparency = 1
        local function makeSkyButton(text, x)
            local button = Instance.new("TextButton", selector)
            button.Size = UDim2.new(0, 22, 0, 24)
            button.Position = UDim2.new(0, x, 0.5, -12)
            button.BackgroundTransparency = 1
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = C_WHITE
            button.Font = Enum.Font.GothamBold
            button.TextSize = 13
            button.AutoButtonColor = false
            button.ZIndex = 10
            return button
        end
        local left = makeSkyButton("<", 0)
        S.skySelectorLabel = Instance.new("TextLabel", selector)
        S.skySelectorLabel.Size = UDim2.new(0, 90, 0, 24)
        S.skySelectorLabel.Position = UDim2.new(0, 26, 0.5, -12)
        S.skySelectorLabel.BackgroundTransparency = 1
        S.skySelectorLabel.Text = S.skyTheme
        S.skySelectorLabel.TextColor3 = C_WHITE
        S.skySelectorLabel.Font = Enum.Font.GothamBold
        S.skySelectorLabel.TextSize = 10
        S.skySelectorLabel.TextXAlignment = Enum.TextXAlignment.Center
        S.skySelectorLabel.TextTruncate = Enum.TextTruncate.AtEnd
        S.skySelectorLabel.ZIndex = 9
        local right = makeSkyButton(">", 120)
        local function changeSky(direction)
            local index = 1
            for i, name in ipairs(SKY_PRESETS_LIST) do
                if name == S.skyTheme then index = i; break end
            end
            index = index + direction
            if index < 1 then index = #SKY_PRESETS_LIST end
            if index > #SKY_PRESETS_LIST then index = 1 end
            local name = SKY_PRESETS_LIST[index]
            pcall(applyCustomSky, name)
            S.skyTheme = name
            S.skySelectorLabel.Text = name
            saveConfig()
        end
        left.MouseButton1Click:Connect(function() changeSky(-1) end)
        right.MouseButton1Click:Connect(function() changeSky(1) end)
    end
    mkSection("Visual", pages, "Character / Performance")
    do
        local card = mkCard("Visual", pages, 40)
        local title = Instance.new("TextLabel", card)
        title.Size = UDim2.new(0, 100, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "Anim Pack"
        title.TextColor3 = C_WHITE
        title.Font = Enum.Font.GothamBold
        title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        local selector = Instance.new("Frame", card)
        selector.Size = UDim2.new(0, 142, 1, 0)
        selector.Position = UDim2.new(1, -152, 0, 0)
        selector.BackgroundTransparency = 1
        local function makeAnimButton(text, x)
            local button = Instance.new("TextButton", selector)
            button.Size = UDim2.new(0, 22, 0, 24)
            button.Position = UDim2.new(0, x, 0.5, -12)
            button.BackgroundTransparency = 1
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = C_WHITE
            button.Font = Enum.Font.GothamBold
            button.TextSize = 13
            button.AutoButtonColor = false
            button.ZIndex = 10
            return button
        end
        local left = makeAnimButton("<", 0)
        S.animSelectorLabel = Instance.new("TextLabel", selector)
        S.animSelectorLabel.Size = UDim2.new(0, 90, 0, 24)
        S.animSelectorLabel.Position = UDim2.new(0, 26, 0.5, -12)
        S.animSelectorLabel.BackgroundTransparency = 1
        S.animSelectorLabel.Text = S.currentAnimPack
        S.animSelectorLabel.TextColor3 = C_WHITE
        S.animSelectorLabel.Font = Enum.Font.GothamBold
        S.animSelectorLabel.TextSize = 10
        S.animSelectorLabel.TextXAlignment = Enum.TextXAlignment.Center
        S.animSelectorLabel.TextTruncate = Enum.TextTruncate.AtEnd
        S.animSelectorLabel.ZIndex = 9
        local right = makeAnimButton(">", 120)
        local function changeAnimPack(direction)
            local index = 1
            for i, entry in ipairs(YF.ANIM_PACK_ORDER) do
                if entry[2] == S.currentAnimPack then index = i; break end
            end
            index = index + direction
            if index < 1 then index = #YF.ANIM_PACK_ORDER end
            if index > #YF.ANIM_PACK_ORDER then index = 1 end
            local packName = YF.ANIM_PACK_ORDER[index][2]
            if packName == "Off" then YF.stopAnimPack() else YF.startAnimPack(packName) end
            if S.animSelectorLabel then S.animSelectorLabel.Text = packName end
            saveConfig()
        end
        left.MouseButton1Click:Connect(function() changeAnimPack(-1) end)
        right.MouseButton1Click:Connect(function() changeAnimPack(1) end)
    end
    mkSection("Visual", pages, "Otimização")
    S.setAntiLagVisual, _ = mkToggle("Visual", pages, "Anti Lag", nil,
        S.antiLagEnabled and S.optimizerMode == "standard", function(on)
        YF.setOptimizer("standard", on); saveConfig()
    end, nil)
    S.setTripaVisual, _ = mkToggle("Visual", pages, "Tropa Otimizador (TRIPA)", nil,
        S.antiLagEnabled and S.optimizerMode == "tripa", function(on)
        YF.setOptimizer("tripa", on); saveConfig()
    end, nil)
    do
        local card = mkCard("Visual", pages, 36)
        local off = Instance.new("TextButton", card)
        off.Name = "DisableOptimizer"
        off.Size = UDim2.fromScale(1, 1)
        off.BackgroundTransparency = 1
        off.BorderSizePixel = 0
        off.Text = "Desativar otimizador"
        off.TextColor3 = C_WHITE
        off.Font = Enum.Font.GothamBold
        off.TextSize = 11
        off.Activated:Connect(function() YF.setOptimizer(S.optimizerMode, false); saveConfig() end)
    end
    mkSection("Main", pages, "Utility")
    S.setUnwalkVisual, _ = mkToggle("Main", pages, "Unwalk", nil, S.unwalkEnabled, function(on)
        if on then startUnwalk() else stopUnwalk() end; saveConfig()
    end, nil)
    S.setAntiRagVisual, _ = mkToggle("Main", pages, "Anti Ragdoll", nil, S.antiRagdollEnabled, function(on)
        toggleAntiRag(on); saveConfig()
    end, nil)
end

local function buildMoveTab(pages)
    mkSection("Move", pages, "Auto Path")
    local setALVis, _ = mkToggle("Move", pages, "Auto Left", S.KB.AutoLeft.kb, false, function(on)
        S.autoLeftEnabled=on
        if on then
            if S.autoRightEnabled then S.autoRightEnabled=false; stopAutoRight(); if S.autoRightSetVisual then S.autoRightSetVisual(false) end end
            if S.batAimbotEnabled then setBatAimbot(false) end
            startAutoLeft()
        else stopAutoLeft() end
        if S.autoLeftSetVisual then S.autoLeftSetVisual(on) end
        S.restartMovement(); updateFloatingButtons(); saveConfig()
    end, function(k,isGp)
        if isGp then S.KB.AutoLeft.gp=k; S.KB.AutoLeft.kb=nil
        else S.KB.AutoLeft.kb=k; S.KB.AutoLeft.gp=nil end; saveConfig()
    end)
    S.autoLeftSetVisual = setALVis
    local setARVis, _ = mkToggle("Move", pages, "Auto Right", S.KB.AutoRight.kb, false, function(on)
        S.autoRightEnabled=on
        if on then
            if S.autoLeftEnabled then S.autoLeftEnabled=false; stopAutoLeft(); if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end end
            if S.batAimbotEnabled then setBatAimbot(false) end
            startAutoRight()
        else stopAutoRight() end
        if S.autoRightSetVisual then S.autoRightSetVisual(on) end
        S.restartMovement(); updateFloatingButtons(); saveConfig()
    end, function(k,isGp)
        if isGp then S.KB.AutoRight.gp=k; S.KB.AutoRight.kb=nil
        else S.KB.AutoRight.kb=k; S.KB.AutoRight.gp=nil end; saveConfig()
    end)
    S.autoRightSetVisual = setARVis
    mkSection("Move", pages, "Steal")
    local setStealVis, _ = mkToggle("Move", pages, "Auto Steal", nil, S.stealActive, function(on)
        S.stealActive = on
        if on then startAutoSteal() else stopAutoSteal() end
        saveConfig()
    end, nil)
    S.setInstaGrab = setStealVis
    S.radInput = mkInput("Move", pages, "Steal Radius", S.Steal.StealRadius, function(v)
        if v>=1 and v<=300 then S.Steal.StealRadius=math.floor(v) end; saveConfig()
    end)
    S.stealDurationBox = mkInput("Move", pages, "Steal Duration", S.Steal.StealDuration, function(v)
        if tonumber(v) then setStealDuration(v); saveConfig() end
    end)
    mkSection("Move", pages, "Actions")
    do
        local card = mkCard("Move", pages, 36)
        local label = Instance.new("TextLabel", card)
        label.Size = UDim2.new(0.5, -8, 1, 0)
        label.Position = UDim2.fromOffset(12, 0)
        label.BackgroundTransparency = 1
        label.Text = "Drop Mode"
        label.TextColor3 = C_WHITE
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        local selector = Instance.new("TextButton", card)
        selector.Size = UDim2.new(0, 108, 0, 26)
        selector.Position = UDim2.new(1, -116, 0.5, -13)
        selector.BackgroundColor3 = C_HEADER
        selector.TextColor3 = C_WHITE
        selector.Font = Enum.Font.GothamBold
        selector.TextSize = 11
        selector.BorderSizePixel = 0
        Instance.new("UICorner", selector).CornerRadius = UDim.new(0, 8)
        local function refresh()
            selector.Text = S.dropMode == 2 and "‹ Jump Drop ›" or "‹ Fling ›"
        end
        refresh()
        selector.Activated:Connect(function()
            stopDropBrainrot()
            S.dropMode = S.dropMode == 2 and 1 or 2
            refresh()
            saveConfig()
        end)
    end
    mkActionRow("Move", pages, "Drop Brainrot", S.KB.DropBrainrot, runDropBrainrot)
    mkActionRow("Move", pages, "TP Down",       S.KB.TPFlor,       runTPFloor)
end

local function buildKeybindsTab(pages)
    mkSection("Keybinds", pages, "Keybind")
    mkActionRow("Keybinds", pages, "Hide GUI",       S.KB.GuiHide,      nil)
    mkActionRow("Keybinds", pages, "Carry Mode",     S.KB.SpeedToggle,  function() S.toggleCarryMode(); S.restartMovement(); updateFloatingButtons(); saveConfig() end)
    mkActionRow("Keybinds", pages, "Lagger Mode",    S.KB.LaggerToggle, function() S.toggleLaggerMode(); S.restartMovement(); updateFloatingButtons(); saveConfig() end)
    mkActionRow("Keybinds", pages, "Bat Bypass", S.KB.BatBypass, function() S.toggleBatBypass(); saveConfig() end)
    mkActionRow("Keybinds", pages, "Bat Aimbot",     S.KB.AutoBat,      function() setBatAimbot(not S.batAimbotEnabled) end)
    mkActionRow("Keybinds", pages, "Auto Left",      S.KB.AutoLeft,     function()
        S.autoLeftEnabled=not S.autoLeftEnabled
        if S.autoLeftEnabled then if S.autoRightEnabled then S.autoRightEnabled=false; stopAutoRight(); if S.autoRightSetVisual then S.autoRightSetVisual(false) end end; startAutoLeft() else stopAutoLeft() end
        if S.autoLeftSetVisual then S.autoLeftSetVisual(S.autoLeftEnabled) end; updateFloatingButtons(); saveConfig()
    end)
    mkActionRow("Keybinds", pages, "Auto Right",     S.KB.AutoRight,    function()
        S.autoRightEnabled=not S.autoRightEnabled
        if S.autoRightEnabled then if S.autoLeftEnabled then S.autoLeftEnabled=false; stopAutoLeft(); if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end end; startAutoRight() else stopAutoRight() end
        if S.autoRightSetVisual then S.autoRightSetVisual(S.autoRightEnabled) end; updateFloatingButtons(); saveConfig()
    end)
    mkActionRow("Keybinds", pages, "Drop Brainrot",  S.KB.DropBrainrot, runDropBrainrot)
    mkActionRow("Keybinds", pages, "TP Down",        S.KB.TPFlor,       runTPFloor)
end

local function resetConfigToDefaults()
    if S.selectBatBypassVersion then S.selectBatBypassVersion("v5", false) end
    S.batBypassSpeed = 58
    if S.setBatBypass then S.setBatBypass(false) end
    pcall(stopAutoSteal)
    pcall(stopBatCounter)
    pcall(stopMedusaCounter)
    pcall(stopUnwalk)
    pcall(stopHoldJump)
    pcall(stopAutoLeft)
    pcall(stopAutoRight)
    pcall(stopBatAimbot)
    pcall(setTpBat, false)
    pcall(stopAntiRagdoll)
    pcall(stopFPSBoost)
    pcall(YF.stopAntiFling)
    pcall(YF.stopBodyLock)
    pcall(YF.disableAntiLag)
    pcall(YF.stopAnimPack)
    pcall(disableStretch)
    pcall(disableVividGraphics)
    pcall(toggleESP, false)

    S.NS, S.CS, S.LS, S.LCS = 70, 45, 22, 22
    S.speedMode, S.laggerMode = false, 0
    S.antiRagdollEnabled = false
    S.medusaCounterEnabled = false
    S.unwalkEnabled = false
    S.autoLeftEnabled, S.autoRightEnabled = false, false
    S.batAimbotEnabled, S.batCounterEnabled = false, false
    S.fpsBoostEnabled = false
    S.stealActive = false
    S.espEnabled = false
    S.antiFlingEnabled = false
    S.bodyLockEnabled, S.bodyLockRange = false, 20
    S.antiLagEnabled = false
    S.vividGraphicsEnabled = false
    S.stretchEnabled, S.stretchFOV = false, 120
    S.skyTheme, S.krobloxMode = "Off", "Off"
    if S.setBatSkin then pcall(S.setBatSkin, "Off", false) end
    S.batSkinMode = "Off"
    if S.setDisplaySkin then pcall(S.setDisplaySkin, "Off", false) else S.displaySkin="Off"; S.customSkinEnabled=false end
    S.currentAnimPack = "Off"
    S.hideOpiumButtonsEnabled = false
    S.lockUIEnabled = false
    S.Steal.StealRadius, S.Steal.StealDuration = 61, 1.3
    S.tpDownHeightTrigger = 20
    local function resetKey(name, kb, gp)
        if S.KB[name] then S.KB[name].kb, S.KB[name].gp = kb, gp end
    end
    resetKey("DropBrainrot", Enum.KeyCode.X, Enum.KeyCode.ButtonR2)
    resetKey("AutoLeft", Enum.KeyCode.Z, Enum.KeyCode.DPadLeft)
    resetKey("AutoRight", Enum.KeyCode.C, Enum.KeyCode.DPadRight)
    resetKey("AutoBat", Enum.KeyCode.E, Enum.KeyCode.ButtonY)
    resetKey("BatBypass", Enum.KeyCode.V, Enum.KeyCode.ButtonB)
    if S.setInformationE01 then S.setInformationE01(true, false) end
    resetKey("TPFlor", Enum.KeyCode.F, Enum.KeyCode.ButtonA)
    resetKey("GuiHide", Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonSelect)
    resetKey("SpeedToggle", Enum.KeyCode.Q, Enum.KeyCode.DPadUp)
    resetKey("LaggerToggle", Enum.KeyCode.R, Enum.KeyCode.DPadDown)
    S.hubColor = DEFAULT_HUB_COLOR
    S.optimizerMode = "standard"
    if S.setTripaVisual then S.setTripaVisual(false) end
    S.mobileButtonStyle = "original"
    DaHubBrandStyle.setFont("original",false)
    if S.setMedusaSkin then S.setMedusaSkin("Off",false) end
    if S.refreshMobileButtonStyleSelection then S.refreshMobileButtonStyleSelection() end
    if S.refreshMobileButtonShape then S.refreshMobileButtonShape() end
    DaHubApplyColorTheme(S.hubColor)
    S.mobileButtonPositions = {}
    S.floatingFreeButtonPositions = {}

    pcall(applyCustomSky, "Off")
    pcall(_G._DaHubApplyKroblox, "Off")
    if S.displaySkinSelectorLabel then S.displaySkinSelectorLabel.Text="Off" end
    if S.customSkinVisual then S.customSkinVisual(false) end
    pcall(setUILock, false)
    if S.floatingPanelGui then S.floatingPanelGui.Enabled = true end
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        local old = pg and pg:FindFirstChild("OpiumGGV5_2")
        if old then old.Enabled = true end
    end)
    DaHubBindings.refresh()
    if S.speedClk then S.speedClk(false) end
    if S.setLaggerVisual then S.setLaggerVisual(false) end
    if S.setAntiRagVisual then S.setAntiRagVisual(false) end
    if S.setFpsVisual then S.setFpsVisual(false) end
    if S.setBatCounterVisual then S.setBatCounterVisual(false) end
    if S.batAimbotSetVisual then S.batAimbotSetVisual(false) end
    if S.tpBatSetVisual then S.tpBatSetVisual(false) end
    if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
    if S.autoRightSetVisual then S.autoRightSetVisual(false) end
    if S.setAntiFlingVisual then S.setAntiFlingVisual(false) end
    if S.bodyLockSetVisual then S.bodyLockSetVisual(false) end
    if S.setVividVisual then S.setVividVisual(false) end
    if S.setStretchVisual then S.setStretchVisual(false) end
    if S.setMedusaVisual then S.setMedusaVisual(false) end
    if S.setUnwalkVisual then S.setUnwalkVisual(false) end
    if S.setAntiLagVisual then S.setAntiLagVisual(false) end
    if S.setHideOpiumButtons2 then S.setHideOpiumButtons2(false) end
    S.refreshSpeedModeLabel()
    resetFloatingPanel()
    if updateFloatingButtons then updateFloatingButtons() end
    saveConfig()
end

local function buildConfigTab(pages)
    mkSection("Config", pages, "General")
    mkInput("Config", pages, "UI Scale", S.userMenuScale or 1, function(v) DaHubSetUserScale("menu", v) end)
    mkInput("Config", pages, "Mobile Buttons Scale", S.userMobileScale or 1, function(v) DaHubSetUserScale("mobile", v) end)
    S.setLockUI_Visual2, _ = mkToggle("Config", pages, "Lock UI", nil, S.lockUIEnabled or false, function(on)
        S.lockUIEnabled=on; setUILock(on); saveConfig()
    end, nil)
    S.setEditMobileButtonsVisual, _ = mkToggle("Config", pages, "Edit Mobile Buttons", nil, false, function(on)
        S.editMobileButtons = on == true
        if on then
            S.lockUIEnabled = false
            setUILock(false)
            if S.setLockUI_Visual2 then S.setLockUI_Visual2(false) end
        end
        if S.refreshMobileEditMode then S.refreshMobileEditMode() end
        saveConfig()
    end, nil)
    do
        local card = mkCard("Config", pages, 44)
        local pill = Instance.new("Frame", card)
        pill.Name = "MobileButtonStylePill"
        local pillStroke = Instance.new("UIStroke", pill)
        pillStroke.Color = C_BORDER; pillStroke.Transparency = 0.3
        pill.Position = UDim2.fromOffset(8, 5)
        pill.Size = UDim2.new(1, -16, 1, -10)
        pill.BackgroundColor3 = C_BG
        pill.BorderSizePixel = 0
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0.5, 0)
        local options = {}
        for index, option in ipairs({{"original", "Da Button original"}, {"round", "Button redondo"}}) do
            local choice = Instance.new("TextButton", pill)
            choice.Name = "MobileButtonStyle_" .. option[1]
            choice.Position = UDim2.new((index - 1) * 0.5, 3, 0, 3)
            choice.Size = UDim2.new(0.5, -6, 1, -6)
            choice.BorderSizePixel = 0
            choice.AutoButtonColor = false
            choice.Font = Enum.Font.GothamBold
            choice.TextSize = 10
            choice.TextWrapped = true
            choice.Text = option[2]
            Instance.new("UICorner", choice).CornerRadius = UDim.new(0.5, 0)
            local stroke = Instance.new("UIStroke", choice)
            stroke.Color = C_BORDER; stroke.Transparency = 0.65
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            options[option[1]] = choice
            choice.Activated:Connect(function()
                S.mobileButtonStyle = option[1]
                S.refreshMobileButtonStyleSelection()
                if S.refreshMobileButtonShape then S.refreshMobileButtonShape() end
                saveConfig()
            end)
        end
        S.refreshMobileButtonStyleSelection = function()
            for id, choice in pairs(options) do
                local selected = S.mobileButtonStyle == id
                TS_G:Create(choice, TweenInfo.new(0.18), {
                    BackgroundColor3 = selected and C_WHITE or C_CARD,
                    TextColor3 = selected and C_BG or C_GREY,
                    BackgroundTransparency = selected and 0.04 or 0.24,
                }):Play()
            end
        end
        S.refreshMobileButtonStyleSelection()
    end
    mkSection("Config", pages, "Fonte do nome do hub")
    do
        local card=mkCard("Config",pages,44)
        local pill=Instance.new("Frame",card); pill.Name="HubTitleFontPill"; pill.Position=UDim2.fromOffset(8,5); pill.Size=UDim2.new(1,-16,1,-10)
        pill.BackgroundColor3=C_BG; pill.BorderSizePixel=0; Instance.new("UICorner",pill).CornerRadius=UDim.new(0.5,0)
        local border=Instance.new("UIStroke",pill); border.Color=C_BORDER; border.Transparency=0.3
        local choices={}
        for i,option in ipairs({{"original","Original",Enum.Font.GothamBlack},{"balloon","Balloon",Enum.Font.FredokaOne}}) do
            local choice=Instance.new("TextButton",pill); choice.Size=UDim2.new(0.5,-6,1,-6); choice.Position=UDim2.new((i-1)*0.5,3,0,3)
            choice.Name="HubTitleFont_"..option[1]; choice.Text=option[2]; choice.Font=option[3]; choice.TextSize=option[1]=="balloon" and 16 or 12
            choice.AutoButtonColor=false; choice.BorderSizePixel=0; Instance.new("UICorner",choice).CornerRadius=UDim.new(0.5,0)
            local stroke=Instance.new("UIStroke",choice); stroke.Color=C_BORDER; stroke.Transparency=0.65; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            choices[option[1]]=choice
            choice.Activated:Connect(function() DaHubBrandStyle.setFont(option[1],true) end)
        end
        S.refreshHubFontSelection=function()
            for id,choice in pairs(choices) do
                local selected=DaHubBrandStyle.fontMode==id
                TS_G:Create(choice,TweenInfo.new(0.18),{
                    BackgroundColor3=selected and C_WHITE or C_CARD,
                    TextColor3=selected and C_BG or C_GREY,
                    BackgroundTransparency=selected and 0.04 or 0.24,
                }):Play()
            end
        end
        S.refreshHubFontSelection()
    end
    S.setHideOpiumButtons2, _ = mkToggle("Config", pages, "Hide Buttons", nil, S.hideOpiumButtonsEnabled or false, function(on)
        S.hideOpiumButtonsEnabled=on
        if S.floatingPanelGui then S.floatingPanelGui.Enabled=not on end
        pcall(function()
            local pg=LP:FindFirstChild("PlayerGui")
            if pg then local og=pg:FindFirstChild("OpiumGGV5_2"); if og then og.Enabled=not on end end
        end)
        saveConfig()
    end, nil)
    mkSection("Config", pages, "Cor do hub")
    local colorCard = mkCard("Config", pages, 52)
    local choices = {}
    local labels = {"Original", "Dourado", "Violeta"}
    S.refreshHubColorSelection = function()
        for id, choice in pairs(choices) do
            local selected = S.hubColor == id
            choice.BackgroundColor3 = selected and C_WHITE or C_CARD
            choice.TextColor3 = selected and C_BG or C_GREY
        end
    end
    for index, colorId in ipairs(HUB_COLOR_OPTIONS) do
        local choice = Instance.new("TextButton", colorCard)
        choice.Name = "HubColor_" .. colorId
        choice.Position = UDim2.new((index - 1) / 3, 6, 0, 10)
        choice.Size = UDim2.new(1 / 3, -12, 0, 32)
        choice.BorderSizePixel = 0
        choice.AutoButtonColor = false
        choice.Text = labels[index]
        choice.Font = Enum.Font.GothamBold
        choice.TextSize = 11
        choice.TextWrapped = true
        Instance.new("UICorner", choice).CornerRadius = UDim.new(0, 6)
        choices[colorId] = choice
        choice.Activated:Connect(function()
            S.hubColor = colorId
            DaHubApplyColorTheme(colorId)
            saveConfig()
        end)
    end
    S.refreshHubColorSelection()

    mkSection("Config", pages, "Config")
    local function addConfigManagementButton(text, callback, mode)
        local card = mkCard("Config", pages, 44)
        local button = Instance.new("TextButton", card)
        button.Name = "ConfigManagement_" .. text:gsub("%s+", "")
        button.Size = UDim2.new(1, -20, 0.82, 0)
        button.Position = UDim2.new(0, 10, 0.09, 0)
        button.BackgroundColor3 = DaHubThemeRGB(255, 255, 255)
        button.BorderSizePixel = 0
        button.Text = ""
        button.AutoButtonColor = false
        button.ZIndex = 8
        Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)

        local gradient = Instance.new("UIGradient", button)
        gradient.Rotation = 90
        if mode == "save" then
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, DaHubThemeRGB(120, 120, 130)),
                ColorSequenceKeypoint.new(0.50, DaHubThemeRGB(60, 60, 70)),
                ColorSequenceKeypoint.new(1.00, DaHubThemeRGB(20, 20, 26)),
            })
        elseif mode == "reset" then
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, DaHubThemeRGB(80, 90, 110)),
                ColorSequenceKeypoint.new(0.50, DaHubThemeRGB(45, 55, 75)),
                ColorSequenceKeypoint.new(1.00, DaHubThemeRGB(18, 22, 32)),
            })
        else
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, DaHubThemeRGB(180, 45, 80)),
                ColorSequenceKeypoint.new(0.50, DaHubThemeRGB(120, 25, 55)),
                ColorSequenceKeypoint.new(1.00, DaHubThemeRGB(60, 10, 30)),
            })
        end

        local stroke = Instance.new("UIStroke", button)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.35
        stroke.Color = mode == "save" and DaHubThemeRGB(200, 200, 215)
            or mode == "reset" and DaHubThemeRGB(150, 175, 210)
            or DaHubThemeRGB(255, 130, 170)

        local label = Instance.new("TextLabel", button)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = DaHubThemeRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 13
        label.TextStrokeColor3 = DaHubThemeRGB(0, 0, 0)
        label.TextStrokeTransparency = 0.55
        label.ZIndex = 9

        button.MouseEnter:Connect(function()
            TS_G:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, -12, 0.92, 0),
                Position = UDim2.new(0, 6, 0.04, 0),
            }):Play()
            TS_G:Create(stroke, TweenInfo.new(0.14), {Transparency = 0.05}):Play()
        end)
        button.MouseLeave:Connect(function()
            TS_G:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, -20, 0.82, 0),
                Position = UDim2.new(0, 10, 0.09, 0),
            }):Play()
            TS_G:Create(stroke, TweenInfo.new(0.14), {Transparency = 0.35}):Play()
        end)

        if mode == "save" then
            button.MouseButton1Click:Connect(function()
                local ok = pcall(saveConfig)
                label.Text = ok and "SAVED ✓" or "ERROR"
                task.delay(1.2, function()
                    if label and label.Parent then label.Text = text end
                end)
            end)
        elseif mode == "reset" then
            local resetDebounce = false
            button.MouseButton1Click:Connect(function()
                if resetDebounce then return end
                resetDebounce = true
                pcall(resetFloatingPanel)
                label.Text = "RESET ✓"
                task.delay(1.2, function()
                    if label and label.Parent then
                        label.Text = text
                        resetDebounce = false
                    end
                end)
            end)
        else
            local deleteState = 0
            local deleteDebounce = false
            button.MouseButton1Click:Connect(function()
                if deleteDebounce then return end
                if deleteState == 0 then
                    deleteState = 1
                    label.Text = "CONFIRM?"
                    gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, DaHubThemeRGB(230, 70, 100)),
                        ColorSequenceKeypoint.new(0.50, DaHubThemeRGB(180, 40, 70)),
                        ColorSequenceKeypoint.new(1.00, DaHubThemeRGB(90, 15, 40)),
                    })
                    task.delay(2, function()
                        if button and button.Parent and deleteState == 1 then
                            deleteState = 0
                            label.Text = text
                            gradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0.00, DaHubThemeRGB(180, 45, 80)),
                                ColorSequenceKeypoint.new(0.50, DaHubThemeRGB(120, 25, 55)),
                                ColorSequenceKeypoint.new(1.00, DaHubThemeRGB(60, 10, 30)),
                            })
                        end
                    end)
                else
                    deleteDebounce = true
                    local ok = pcall(resetConfigToDefaults)
                    label.Text = ok and "DELETED ✓" or "ERROR"
                    deleteState = 0
                    task.delay(1.5, function()
                        if label and label.Parent then
                            label.Text = text
                            gradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0.00, DaHubThemeRGB(180, 45, 80)),
                                ColorSequenceKeypoint.new(0.50, DaHubThemeRGB(120, 25, 55)),
                                ColorSequenceKeypoint.new(1.00, DaHubThemeRGB(60, 10, 30)),
                            })
                            deleteDebounce = false
                        end
                    end)
                end
            end)
        end
        return button
    end
    addConfigManagementButton("SAVE CONFIG", saveConfig, "save")
    addConfigManagementButton("RESET POSITIONS", resetFloatingPanel, "reset")
    addConfigManagementButton("DELETE SETTINGS", resetConfigToDefaults, "delete")
end -- close buildConfigTab

-- Disable health bar
pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false) end)
LP.CharacterAdded:Connect(function()
    pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false) end)
end) -- close LP.CharacterAdded:Connect

local function buildGui()
    S.mainMenuFrame = nil
    S.refreshHubColorSelection = nil
    DaHubApplyColorTheme(S.hubColor or DEFAULT_HUB_COLOR)
    local old = game:GetService("CoreGui"):FindFirstChild("DaHub")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DaHub"; gui.ResetOnSpawn = false
    gui.DisplayOrder = 100; gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then
        gui.Parent = LP:WaitForChild("PlayerGui")
    end

    -- Outer drag frame
    local outer = Instance.new("Frame", gui)
    outer.Name = "Outer"
    outer.AnchorPoint = Vector2.new(0, 0.5)
    outer.Position = UDim2.new(0, 14, 0.5, 0)
    outer.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
    outer.BackgroundTransparency = 1; outer.BorderSizePixel = 0
    outer.ClipsDescendants = false
    outer.Visible = false
    S.mainMenuFrame = outer
    -- El panel no se arrastra desde toda su superficie: eso interfería con
    -- los gestos de toque y desplazamiento de las páginas/tabs.
    applyPhoneGuiScale(outer, S.phoneGuiScale, "mainGuiScaleObj")
    if S.IS_TOUCH_DEVICE then outer.Position = UDim2.new(0,8,0.5,0) end
    if S.menuOpenPosition then outer.Position = S.menuOpenPosition end
    S.menuOpenPosition = outer.Position

    -- Inner panel (glassmorphism)
    local main = Instance.new("Frame", outer)
    main.Name = "Main"; main.Size = UDim2.new(1,0,1,0)
    main.BackgroundColor3 = C_BG; main.BackgroundTransparency = 1
    main.BorderSizePixel = 0; main.ClipsDescendants = true; main.ZIndex = 1
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
    -- Banner integrado como fundo de todo o menu, sem uma janela separada.
    local menuBackground = Instance.new("ImageLabel", main)
    menuBackground.Name = "PurenDuelsMenuBackground"
    menuBackground.Size = UDim2.fromScale(1, 1)
    menuBackground.Position = UDim2.fromScale(0, 0)
    menuBackground.BackgroundColor3 = C_BG
    menuBackground.BackgroundTransparency = 0.08
    menuBackground.BorderSizePixel = 0
    menuBackground.ImageTransparency = 0.34
    menuBackground.ScaleType = Enum.ScaleType.Crop
    menuBackground.ZIndex = 0
    menuBackground.Active = false
    task.spawn(function()
        local asset = resolvePurenDuelsImage()
        if asset and menuBackground.Parent then menuBackground.Image = asset end
    end)
    local menuBackgroundShade = Instance.new("Frame", main)
    menuBackgroundShade.Name = "PurenDuelsMenuBackgroundShade"
    menuBackgroundShade.Size = UDim2.fromScale(1, 1)
    menuBackgroundShade.BackgroundColor3 = C_BG
    menuBackgroundShade.BackgroundTransparency = 0.42
    menuBackgroundShade.BorderSizePixel = 0
    menuBackgroundShade.ZIndex = 0
    menuBackgroundShade.Active = false
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = DaHubThemeRGB(160, 160, 172); mainStroke.Thickness = 1.2; mainStroke.Transparency = 0.34
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Painel de cor sólida, sem imagens de fundo.

    -- Header (premium gradient + glassmorphism)
    local header = Instance.new("Frame", main)
    header.Name = "Header"; header.Size = UDim2.new(1,0,0,HEADER_H)
    header.BackgroundColor3 = C_HEADER; header.BackgroundTransparency = 0.32
    header.BorderSizePixel = 0; header.ZIndex = 5; header.ClipsDescendants = true
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)
    -- Arrastrar solo desde el encabezado y mover el panel completo.
    makeDraggable(header, false, outer, function(target)
        S.menuOpenPosition = target.Position
    end)
    local headerGrad = Instance.new("UIGradient", header)
    headerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DaHubThemeRGB(65, 65, 74)),
        ColorSequenceKeypoint.new(0.5, DaHubThemeRGB(36, 36, 43)),
        ColorSequenceKeypoint.new(1, DaHubThemeRGB(19, 19, 24)),
    })
    headerGrad.Rotation = 90
    addPurenChristmasDecorations(header, true)

    local titleImage = Instance.new("TextLabel", header)
    titleImage.Name = "MenuTitleImage"
    titleImage.AnchorPoint = Vector2.new(0, 0.5)
    titleImage.Position = UDim2.fromOffset(4, 36)
    titleImage.Size = UDim2.fromOffset(240, 68)
    titleImage.BackgroundTransparency = 1
    titleImage.Text = DaHubBrandStyle.text
    titleImage.Font = Enum.Font.GothamBlack
    titleImage.TextSize = 32
    titleImage.TextColor3 = C_WHITE
    titleImage.ZIndex = 6
    DaHubBrandStyle.apply(titleImage)

    -- Papai Noel voando de ida e volta no cabeçalho do menu.
    local menuSanta = Instance.new("ImageLabel", header)
    menuSanta.Name = "ChristmasSantaSleighMenu"
    menuSanta.AnchorPoint = Vector2.new(0.5, 0.5)
    menuSanta.Position = UDim2.new(-0.35, 0, 0.5, 0)
    menuSanta.Size = UDim2.fromOffset(118, 79)
    menuSanta.BackgroundTransparency = 1
    menuSanta.BorderSizePixel = 0
    menuSanta.ScaleType = Enum.ScaleType.Fit
    menuSanta.ZIndex = 8
    task.spawn(function()
        local santaAsset = resolvePurenDuelsSantaAsset()
        if santaAsset and menuSanta.Parent then
            menuSanta.Image = santaAsset
            local santaTween = TS_G:Create(menuSanta, TweenInfo.new(4.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
                Position = UDim2.new(1.35, 0, 0.5, 0)
            })
            santaTween:Play()
        end
    end)

    titleImage.Position = UDim2.fromOffset(10, 36)
    titleImage.Size = UDim2.fromOffset(230, 68)

    -- Close button (premium style)
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.AnchorPoint = Vector2.new(1,0.5); closeBtn.Position = UDim2.fromOffset(PANEL_W-14,36)
    closeBtn.Size = UDim2.fromOffset(30,30); closeBtn.BackgroundColor3 = DaHubThemeRGB(28, 28, 28)
    closeBtn.BorderSizePixel = 0; closeBtn.Text = "−"; closeBtn.TextColor3 = DaHubThemeRGB(205, 205, 214)
    closeBtn.AutoButtonColor = false
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 18; closeBtn.ZIndex = 10
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)
    local closeBtnStroke = Instance.new("UIStroke", closeBtn)
    closeBtnStroke.Color = DaHubThemeRGB(59, 59, 59); closeBtnStroke.Thickness = 1; closeBtnStroke.Transparency = 0.3
    closeBtn.MouseEnter:Connect(function()
        TS_G:Create(closeBtn,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{BackgroundColor3=C_HIGHLIGHT,TextColor3=C_WHITE}):Play()
        TS_G:Create(closeBtnStroke,TweenInfo.new(0.15),{Color=C_HIGHLIGHT_BRIGHT,Transparency=0}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TS_G:Create(closeBtn,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=DaHubThemeRGB(28, 28, 28),TextColor3=DaHubThemeRGB(205, 205, 214)}):Play()
        TS_G:Create(closeBtnStroke,TweenInfo.new(0.2),{Color=DaHubThemeRGB(59, 59, 59),Transparency=0.3}):Play()
    end)

    -- Header separator (premium animated silver glow line)
    local hSep = Instance.new("Frame", main)
    hSep.Size = UDim2.new(1,-20,0,1); hSep.Position = UDim2.fromOffset(10,HEADER_H)
    hSep.BackgroundColor3 = DaHubThemeRGB(235, 235, 235); hSep.BackgroundTransparency = 0.45
    hSep.BorderSizePixel = 0; hSep.ZIndex = 4
    Instance.new("UICorner", hSep).CornerRadius = UDim.new(1,0)
    local hSepG = Instance.new("UIGradient", hSep)
    hSepG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DaHubThemeRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.46, DaHubThemeRGB(235, 235, 235)),
        ColorSequenceKeypoint.new(1, DaHubThemeRGB(170, 170, 170)),
    })
    hSepG.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.12,0.05),
        NumberSequenceKeypoint.new(0.5,0), NumberSequenceKeypoint.new(0.88,0.05), NumberSequenceKeypoint.new(1,1)
    })
    -- Glow line behind separator
    local hSepGlow = Instance.new("Frame", main)
    hSepGlow.Size = UDim2.new(1,-30,0,6); hSepGlow.Position = UDim2.fromOffset(15,HEADER_H-2)
    hSepGlow.BackgroundColor3 = DaHubThemeRGB(170, 170, 170); hSepGlow.BackgroundTransparency = 0.96
    hSepGlow.BorderSizePixel = 0; hSepGlow.ZIndex = 3
    Instance.new("UICorner", hSepGlow).CornerRadius = UDim.new(1,0)
    local hSepGlowG = Instance.new("UIGradient", hSepGlow)
    hSepGlowG.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.2,0.3),
        NumberSequenceKeypoint.new(0.5,0), NumberSequenceKeypoint.new(0.8,0.3), NumberSequenceKeypoint.new(1,1)
    })

    -- Drakon-style tabs sit below the header; horizontal scrolling keeps
    -- every label readable on the compact FALLS4K panel.
    local TAB_H = 44
    local contentY = HEADER_H + TAB_H + 8
    local contentArea = Instance.new("Frame", main)
    contentArea.Size = UDim2.new(1, 0, 1, -contentY)
    contentArea.Position = UDim2.fromOffset(0, contentY)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.ZIndex = 2
    contentArea.ClipsDescendants = true

    local pages = buildGui_createScrollingPages(contentArea)
    buildSpeedTab(pages); buildMainTab(pages); buildMoveTab(pages); buildConfigTab(pages); buildKeybindsTab(pages)

    -- Preserve all FALLS4K controls inside the five Drakon categories.
    -- Custom contains the former Main, Player and Move controls.
    local customPage = pages.Main
    local nextOrder = 0
    for _, child in ipairs(customPage:GetChildren()) do
        if child:IsA("GuiObject") then
            nextOrder = nextOrder + 1
            child.LayoutOrder = nextOrder
        end
    end
    for _, pageName in ipairs({"Player", "Move"}) do
        local sourcePage = pages[pageName]
        for _, child in ipairs(sourcePage:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Parent = customPage
                nextOrder = nextOrder + 1
                child.LayoutOrder = nextOrder
            end
        end
        sourcePage:Destroy()
        pages[pageName] = nil
    end

    local divider = Instance.new("Frame", main)
    divider.Name = "TabsDivider"
    divider.Size = UDim2.new(1, -32, 0, 1)
    divider.Position = UDim2.fromOffset(16, HEADER_H + 4)
    divider.BackgroundColor3 = C_GREY
    divider.BackgroundTransparency = 0.72
    divider.BorderSizePixel = 0
    divider.ZIndex = 4

    local tabScroll = Instance.new("ScrollingFrame", main)
    tabScroll.Name = "TabBar"
    tabScroll.Position = UDim2.fromOffset(8, HEADER_H + 8)
    tabScroll.Size = UDim2.new(1, -16, 0, TAB_H - 4)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 2
    tabScroll.ScrollBarImageColor3 = C_GREY
    tabScroll.ScrollBarImageTransparency = 0.45
    tabScroll.Active = true
    tabScroll.ScrollingEnabled = true
    tabScroll.ClipsDescendants = true
    tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabScroll.ElasticBehavior = Enum.ElasticBehavior.Never
    tabScroll.ZIndex = 4
    local tabLayout = Instance.new("UIListLayout", tabScroll)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 6)
    local tabPadding = Instance.new("UIPadding", tabScroll)
    tabPadding.PaddingLeft = UDim.new(0, 4)
    tabPadding.PaddingRight = UDim.new(0, 4)
    tabPadding.PaddingTop = UDim.new(0, 3)
    tabPadding.PaddingBottom = UDim.new(0, 5)

    local activePage = nil
    local activeTabName = nil
    local tabBtns = {}
    local tabDetails = {}
    local function switchTab(name)
        local selectedPage = pages[name]
        if not selectedPage then return end
        if activeTabName == name and activePage == selectedPage then return end
        for _, page in pairs(pages) do page.Visible = false end
        selectedPage.Visible = true
        selectedPage.CanvasPosition = Vector2.new(0, 0)
        activePage = selectedPage
        activeTabName = name
        for tabName, button in pairs(tabBtns) do
            local selected = tabName == name
            TS_G:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = selected and C_WHITE or C_CARD,
                TextColor3 = selected and C_DIM or C_GREY,
                BackgroundTransparency = selected and 0.06 or 0.18,
            }):Play()
            local details = tabDetails[tabName]
            if details then
                TS_G:Create(details.stroke, TweenInfo.new(0.18), {
                    Color = selected and C_WHITE or C_BORDER,
                    Transparency = selected and 0.12 or 0.45,
                }):Play()
                TS_G:Create(details.indicator, TweenInfo.new(0.18), {
                    BackgroundColor3 = C_DIM,
                    BackgroundTransparency = selected and 0.12 or 1,
                }):Play()
            end
        end
    end

    local tabs = {
        {key = "Speed", label = "Speed", width = 72},
        {key = "Main", label = "Custom", width = 78},
        {key = "Visual", label = "Visual", width = 72},
        {key = "Config", label = "Settings", width = 82},
        {key = "Keybinds", label = "Keybinds", width = 86},
    }
    for index, tab in ipairs(tabs) do
        local tabKey = tab.key
        local button = Instance.new("TextButton", tabScroll)
        button.Name = "Tab" .. tab.label
        button.Size = UDim2.fromOffset(tab.width, 30)
        button.LayoutOrder = index
        button.BackgroundColor3 = C_CARD
        button.BackgroundTransparency = 0.18
        button.BorderSizePixel = 0
        button.Text = tab.label
        button.TextColor3 = C_WHITE
        button.Font = Enum.Font.GothamBold
        button.TextSize = 12
        button.AutoButtonColor = false
        button.Active = true
        button.Selectable = true
        button.ZIndex = 5
        -- Full capsule rounding, softer than Drakon's 12px corners.
        Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke", button)
        stroke.Color = C_BORDER
        stroke.Thickness = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Transparency = 0.45
        -- Keep the original capsule shape and dimensions; refine only its finish.
        local indicator = Instance.new("Frame", button)
        indicator.Name = "SelectedIndicator"
        indicator.AnchorPoint = Vector2.new(0.5, 1)
        indicator.Position = UDim2.new(0.5, 0, 1, -3)
        indicator.Size = UDim2.fromOffset(16, 2)
        indicator.BackgroundColor3 = C_DIM
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.ZIndex = 6
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
        tabDetails[tabKey] = {stroke = stroke, indicator = indicator}
        tabBtns[tabKey] = button
        button.MouseEnter:Connect(function()
            if activeTabName == tabKey then return end
            TS_G:Create(button, TweenInfo.new(0.14), {
                BackgroundColor3 = C_CARD_HOV, TextColor3 = C_WHITE,
                BackgroundTransparency = 0.06,
            }):Play()
            TS_G:Create(stroke, TweenInfo.new(0.14), {Color = C_HIGHLIGHT, Transparency = 0.2}):Play()
        end)
        button.MouseLeave:Connect(function()
            if activeTabName == tabKey then return end
            TS_G:Create(button, TweenInfo.new(0.18), {
                BackgroundColor3 = C_CARD, TextColor3 = C_GREY,
                BackgroundTransparency = 0.18,
            }):Play()
            TS_G:Create(stroke, TweenInfo.new(0.18), {Color = C_BORDER, Transparency = 0.45}):Play()
        end)
        button.Activated:Connect(function() switchTab(tabKey) end)
    end
    switchTab("Speed")

    -- DaHub Leaked animation: scale in with a short Back easing and scale out
    -- with a compact Quart easing. No horizontal slide is used.
    local menuScale = S.mainGuiScaleObj
    local menuBaseScale = S.IS_TOUCH_DEVICE and S.phoneGuiScale or 1
    local menuClosedScale = menuBaseScale * 0.82
    S.menuTransitionToken = (S.menuTransitionToken or 0) + 1
    outer.Position = S.menuOpenPosition
    if menuScale then menuScale.Scale = menuClosedScale end
    outer.Visible = true
    S.menuTween = TS_G:Create(menuScale, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = menuBaseScale
    })
    S.menuTween:Play()

    local function showGui()
        S.menuTransitionToken = (S.menuTransitionToken or 0) + 1
        if S.menuTween then pcall(function() S.menuTween:Cancel() end) end
        outer.Visible = true
        if S.miniToggleButton then S.miniToggleButton.Visible = false end
        outer.Position = S.menuOpenPosition
        if menuScale then menuScale.Scale = menuClosedScale end
        S.menuTween = TS_G:Create(menuScale, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = menuBaseScale
        })
        S.menuTween:Play()
    end
    local function hideGui()
        -- Capture the current location before the scale-out animation.
        S.menuOpenPosition = outer.Position
        saveConfig()
        S.menuTransitionToken = (S.menuTransitionToken or 0) + 1
        local transitionToken = S.menuTransitionToken
        if S.menuTween then pcall(function() S.menuTween:Cancel() end) end
        S.menuTween = TS_G:Create(menuScale, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Scale = menuClosedScale
        })
        S.menuTween.Completed:Connect(function(playbackState)
            if transitionToken ~= S.menuTransitionToken or playbackState ~= Enum.PlaybackState.Completed then return end
            outer.Visible = false
            if menuScale then menuScale.Scale = menuBaseScale end
            if S.miniToggleButton then S.miniToggleButton.Visible = true end
        end)
        S.menuTween:Play()
    end
    closeBtn.MouseButton1Click:Connect(hideGui)
    S.miniToggleButton = buildGui_createMiniToggle(gui, showGui)
    S.miniToggleButton.Visible = false

    UIS.InputBegan:Connect(function(input, gpe)
        if input.UserInputType~=Enum.UserInputType.Keyboard and input.UserInputType~=Enum.UserInputType.Gamepad1 then return end
        if DaHubBindings.suppressed() then return end
        local kc=input.KeyCode
        if kc == Enum.KeyCode.Unknown then return end
        local field = input.UserInputType == Enum.UserInputType.Gamepad1 and "gp" or "kb"
        local function match(e) return e[field] ~= nil and kc == e[field] end
        if gpe then
            if match(S.KB.GuiHide) then if outer.Visible then hideGui() else showGui() end end
            return
        end
        if match(S.KB.DropBrainrot) then task.spawn(runDropBrainrot)
        elseif match(S.KB.TPFlor) then runTPFloor()
        elseif match(S.KB.AutoLeft) then
            S.autoLeftEnabled=not S.autoLeftEnabled
            if S.autoLeftEnabled then
                if S.autoRightEnabled then S.autoRightEnabled=false; stopAutoRight(); if S.autoRightSetVisual then S.autoRightSetVisual(false) end end
                if S.batAimbotEnabled then setBatAimbot(false) end
                startAutoLeft()
            else stopAutoLeft() end
            if S.autoLeftSetVisual then S.autoLeftSetVisual(S.autoLeftEnabled) end
            S.restartMovement(); updateFloatingButtons(); saveConfig()
        elseif match(S.KB.AutoRight) then
            S.autoRightEnabled=not S.autoRightEnabled
            if S.autoRightEnabled then
                if S.autoLeftEnabled then S.autoLeftEnabled=false; stopAutoLeft(); if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end end
                if S.batAimbotEnabled then setBatAimbot(false) end
                startAutoRight()
            else stopAutoRight() end
            if S.autoRightSetVisual then S.autoRightSetVisual(S.autoRightEnabled) end
            S.restartMovement(); updateFloatingButtons(); saveConfig()
        elseif match(S.KB.BatBypass) then S.toggleBatBypass(); saveConfig()
        elseif match(S.KB.AutoBat) then setBatAimbot(not S.batAimbotEnabled)
        elseif match(S.KB.GuiHide) then if outer.Visible then hideGui() else showGui() end
        elseif match(S.KB.SpeedToggle) then S.toggleCarryMode(); S.restartMovement(); updateFloatingButtons(); saveConfig()
        elseif match(S.KB.LaggerToggle) then S.toggleLaggerMode(); S.restartMovement(); updateFloatingButtons(); saveConfig()
        end
    end)
end


-- ===========================
-- FLOATING BUTTON PANEL (white / grey theme)
-- ===========================
local function createFloatingButtonPanel()
    local panelGui = Instance.new("ScreenGui")
    panelGui.Name = "FloatingModeMenu"
    panelGui.DisplayOrder = 50
    panelGui.IgnoreGuiInset = true
    panelGui.ResetOnSpawn = false
    panelGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    panelGui.Parent = LP:WaitForChild("PlayerGui")
    S.floatingPanelGui = panelGui

    local layoutFrame = Instance.new("Frame")
    layoutFrame.Name = "ButtonLayout"
    layoutFrame.AnchorPoint = Vector2.new(1, 0)
    layoutFrame.Position = UDim2.new(0.79, 0, 0, 0)
    layoutFrame.Size = UDim2.fromOffset(0, 0)
    layoutFrame.BackgroundTransparency = 1
    layoutFrame.BorderSizePixel = 0
    layoutFrame.ClipsDescendants = false
    layoutFrame.Active = false
    layoutFrame.Selectable = false
    layoutFrame.Parent = panelGui
    S.floatingPanelFrame = layoutFrame
    -- El panel principal mueve juntos sus botones; TP BAT y RESET van en una
    -- capa independiente para poder moverlos por separado.
    -- Solo esta franja superior captura el arrastre; el resto queda libre.
    local dragHandle = Instance.new("Frame")
    dragHandle.Name = "FloatingPanelDragHandle"
    dragHandle.Size = UDim2.fromOffset(0, 48)
    dragHandle.Position = UDim2.fromOffset(0, 0)
    dragHandle.BackgroundTransparency = 1
    dragHandle.BorderSizePixel = 0
    dragHandle.Active = true
    dragHandle.Parent = layoutFrame
    makeDraggable(dragHandle, true, layoutFrame)

    local freeButtonLayer = Instance.new("Frame")
    freeButtonLayer.Name = "IndependentButtonLayer"
    freeButtonLayer.AnchorPoint = Vector2.new(1, 0)
    freeButtonLayer.Position = UDim2.new(0.79, 0, 0, 0)
    freeButtonLayer.Size = UDim2.fromOffset(0, 0)
    freeButtonLayer.BackgroundTransparency = 1
    freeButtonLayer.BorderSizePixel = 0
    freeButtonLayer.ClipsDescendants = false
    freeButtonLayer.Active = false
    freeButtonLayer.Selectable = false
    freeButtonLayer.Parent = panelGui

    local selectedName = "CARRY SPD"
    local buttons = {}
    local BLACK = DaHubThemeRGB(1, 1, 4)
    local WHITE = DaHubThemeRGB(255, 255, 255)

    local buttonDefinitions = {
        {name = "DROP BR",       displayText = "DROP\nBR",       column = 2, row = 0},
        {name = "AUTO LEFT",     displayText = "AUTO\nLEFT",     column = 3, row = 0},
        {name = "BAT AIMBOT",    displayText = "BAT\nAIMBOT",   column = 2, row = 1},
        {name = "AUTO RIGHT",    displayText = "AUTO\nRIGHT",    column = 3, row = 1},
        {name = "TP DOWN",       displayText = "TP\nDOWN",       column = 2, row = 2},
        {name = "CARRY SPD",     displayText = "CARRY\nSPD",     column = 3, row = 2},
        {name = "NORMAL LAGGER", displayText = "NORMAL\nLAGGER", column = 2, row = 3},
        {name = "LAGGER CARRY SPEED", displayText = "LAGGER\nCARRY\nSPEED", column = 3, row = 3},
    }

    S.refreshMobileTheme = function()
        BLACK = DaHubThemeRGB(1, 1, 4)
        WHITE = DaHubThemeRGB(255, 255, 255)
    end
    local function applyButtonStyle(info, isSelected)
        if isSelected then
            info.button.BackgroundColor3 = WHITE
            info.button.TextColor3 = DaHubThemeRGB(18, 31, 28)
            info.gradient.Enabled = true
        else
            info.button.BackgroundColor3 = BLACK
            info.button.TextColor3 = WHITE
            info.gradient.Enabled = false
        end
    end

    local pressTweenInfo = TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local releaseTweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for _, definition in ipairs(buttonDefinitions) do
        local button = Instance.new("TextButton")
        button.Name = string.gsub(definition.name, "%s+", "")
        button.BackgroundColor3 = BLACK
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = definition.displayText or definition.name
        button.TextColor3 = WHITE
        button.TextScaled = true
        button.TextWrapped = true
        button.Font = Enum.Font.GothamBold
        button.ZIndex = 2
        button.Parent = layoutFrame

        local buttonScale = Instance.new("UIScale")
        buttonScale.Parent = button
        local activeScaleTween
        local function animateScale(target, info)
            if activeScaleTween then activeScaleTween:Cancel() end
            activeScaleTween = TS_G:Create(buttonScale, info, {Scale = target})
            activeScaleTween:Play()
        end
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                animateScale(0.92, pressTweenInfo)
            end
        end)
        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                animateScale(1, releaseTweenInfo)
            end
        end)

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.24, 0)
        corner.Parent = button
        local textLimit = Instance.new("UITextSizeConstraint")
        textLimit.MinTextSize = 10
        textLimit.MaxTextSize = 15
        textLimit.Parent = button
        local gradient = Instance.new("UIGradient")
        gradient.Name = "SelectedGradient"
        gradient.Enabled = false
        gradient.Rotation = 90
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DaHubThemeRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.56, DaHubThemeRGB(224, 226, 225)),
            ColorSequenceKeypoint.new(1, DaHubThemeRGB(76, 80, 80)),
        })
        gradient.Parent = button

        local isFreeButton = definition.name == "TP BAT" or definition.name == "Reset"
        local info = {button = button, gradient = gradient, name = definition.name, column = definition.column, row = definition.row, independent = isFreeButton, userMoved = false}
        table.insert(buttons, info)
        if isFreeButton then
            button.Parent = freeButtonLayer
            local saved = S.floatingFreeButtonPositions[definition.name]
            if type(saved) == "table" and type(saved.X) == "number" and type(saved.Y) == "number" then
                button.Position = UDim2.fromOffset(saved.X, saved.Y)
                info.userMoved = true
            end
            makeDraggable(button, true, button, function(target)
                info.userMoved = true
                S.floatingFreeButtonPositions[definition.name] = {X = target.Position.X.Offset, Y = target.Position.Y.Offset}
            end)
        end

        button.Activated:Connect(function()
            if info.name == "TP DOWN" then return end
            -- Los botones de velocidad controlan su propia luz después de cambiar
            -- el modo. No aplicar aquí el estilo genérico, porque este evento
            -- puede ejecutarse después del handler de acción y volver a encender
            -- Carry/Lagger al apagarlos con el segundo toque.
            local isModeButton = info.name == "CARRY SPD"
                or info.name == "NORMAL LAGGER"
                or info.name == "LAGGER CARRY SPEED"
                or info.name == "BAT AIMBOT"
                or info.name == "TP BAT"
            if isModeButton then return end
            selectedName = info.name
            for _, item in ipairs(buttons) do applyButtonStyle(item, item.name == selectedName) end
        end)
    end

    local function find(name)
        for _, info in ipairs(buttons) do
            if info.name == name then return info end
        end
    end
    local function flash(info, duration)
        if not info then return end
        applyButtonStyle(info, true)
        task.delay(duration or 0.35, function()
            if info.button and info.button.Parent then applyButtonStyle(info, false) end
        end)
    end
    local function canPress()
        -- Lock solo congela las posiciones; no bloquea las acciones.
        return not S._floatingPanelDragging
    end

    local drop = find("DROP BR")
    local autoLeft = find("AUTO LEFT")
    local bat = find("BAT AIMBOT")
    local autoRight = find("AUTO RIGHT")
    local tpDown = find("TP DOWN")
    local carry = find("CARRY SPD")
    local normalLagger = find("NORMAL LAGGER")
    local carryLagger = find("LAGGER CARRY SPEED")

    local function connectAction(info, action)
        info.button.Activated:Connect(function()
            if canPress() then action() end
        end)
    end
    connectAction(drop, function() flash(drop, 0.5); task.spawn(runDropBrainrot) end)
    connectAction(bat, function()
        local on = not S.batAimbotEnabled
        if on then
            if S.autoLeftEnabled then S.autoLeftEnabled = false; stopAutoLeft(); if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end end
            if S.autoRightEnabled then S.autoRightEnabled = false; stopAutoRight(); if S.autoRightSetVisual then S.autoRightSetVisual(false) end end
        end
        setBatAimbot(on)
        -- BAT AIMBOT controla su propia luz: primer toque ON, segundo toque OFF.
        applyButtonStyle(bat, on)
        updateFloatingButtons()
    end)
    connectAction(autoLeft, function()
        local on = not S.autoLeftEnabled
        if on then
            if S.autoRightEnabled then S.autoRightEnabled = false; stopAutoRight() end
            if S.batAimbotEnabled then setBatAimbot(false) end
            S.autoLeftEnabled = true; startAutoLeft()
        else S.autoLeftEnabled = false; stopAutoLeft() end
        if S.autoLeftSetVisual then S.autoLeftSetVisual(on) end
        S.restartMovement(); updateFloatingButtons(); saveConfig()
    end)
    connectAction(autoRight, function()
        local on = not S.autoRightEnabled
        if on then
            if S.autoLeftEnabled then S.autoLeftEnabled = false; stopAutoLeft() end
            if S.batAimbotEnabled then setBatAimbot(false) end
            S.autoRightEnabled = true; startAutoRight()
        else S.autoRightEnabled = false; stopAutoRight() end
        if S.autoRightSetVisual then S.autoRightSetVisual(on) end
        S.restartMovement(); updateFloatingButtons(); saveConfig()
    end)
    connectAction(tpDown, function()
        applyButtonStyle(tpDown, true)
        runTPFloor()
        task.delay(0.45, function()
            if tpDown and tpDown.button and tpDown.button.Parent then applyButtonStyle(tpDown, false) end
        end)
    end)
    local function refreshLaggerButtons()
        applyButtonStyle(normalLagger, S.laggerMode == 1 and not S.speedMode)
        applyButtonStyle(carryLagger, S.laggerMode == 2 and not S.speedMode)
    end

    -- Deja los tres botones de velocidad apagados y vuelve siempre a S.NS.
    -- Esto se usa al dar el segundo toque al botón que ya está activo.
    local function returnToNormalSpeed()
        S.setNormalSpeedMode()
        S.restartMovement()
        updateFloatingButtons()
        applyButtonStyle(carry, false)
        applyButtonStyle(normalLagger, false)
        applyButtonStyle(carryLagger, false)
        saveConfig()
    end

    connectAction(carry, function()
        -- Segundo toque en Carry: apagar Carry y volver a Normal Speed.
        if S.speedMode and S.laggerMode == 0 then
            returnToNormalSpeed()
            return
        end

        -- Primer toque (o cambio desde un modo Lagger): activar Carry.
        S.setCarrySpeedMode()
        S.restartMovement()
        updateFloatingButtons()
        refreshLaggerButtons()
        applyButtonStyle(normalLagger, false)
        applyButtonStyle(carryLagger, false)
        saveConfig()
    end)

    local function setLaggerSpeedMode(mode)
        -- Segundo toque en el mismo botón Lagger: apagarlo y volver a Normal.
        if S.laggerMode == mode and not S.speedMode then
            returnToNormalSpeed()
            return
        end

        -- Primer toque, o cambio entre Normal Lagger y Carry Lagger.
        S.speedMode = false
        S.laggerMode = mode
        S.refreshSpeedModeLabel()
        S.applySpeedVelocityNow()
        S.restartMovement()
        updateFloatingButtons()
        refreshLaggerButtons()
        saveConfig()
    end

    connectAction(normalLagger, function() setLaggerSpeedMode(1) end) -- S.LS: Lagger Normal Speed
    connectAction(carryLagger, function() setLaggerSpeedMode(2) end) -- S.LCS: Lagger Carry Speed

    S.dropBrainrotSetVisual = function(active) applyButtonStyle(drop, active) end
    S.dropBrainrotFloatVisual = S.dropBrainrotSetVisual
    -- Reset remains highlighted only while its action is running; respawn clears it.
    LP.CharacterAdded:Connect(function()
        task.defer(function()
            if reset and reset.button and reset.button.Parent then applyButtonStyle(reset, false) end
            if drop and drop.button and drop.button.Parent then applyButtonStyle(drop, false) end
        end)
    end)
    S._btnAAL, S._bsAAL, S._l1AAL, S._l2AAL = autoLeft.button, nil, nil, nil
    S._btnAAR, S._bsAAR, S._l1AAR, S._l2AAR = autoRight.button, nil, nil, nil
    S._btnBAT, S._bsBAT, S._l1BAT, S._l2BAT = bat.button, nil, nil, nil
    S._setPButtonActive = function(button, _, _, _, active)
        for _, info in ipairs(buttons) do
            if info.button == button then
                applyButtonStyle(info, active)
                return
            end
        end
    end
    S._floatingButtons = {
        lagger = normalLagger.button,
        l2Lagger = {Text = ""},
        carry = carry.button,
        autoLeft = autoLeft.button,
        autoRight = autoRight.button,
        bat = bat.button,
    }

    local function updateLayout()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        local isLandscape = viewport.X > viewport.Y
        local sizeFactor = isLandscape and 0.16 or 0.18
        local buttonSize = math.floor(math.min(viewport.Y * sizeFactor, viewport.X * 0.24))
        local gap = math.max(8, math.floor(buttonSize * 0.14))
        local pitch = buttonSize + gap
        -- No reposicionar aquí: el usuario puede haber guardado o movido el panel.
        local firstRowY = math.floor(viewport.Y * (isLandscape and 0.18 or 0.205))
        -- Las capas solo cubren el rectángulo de los botones; no toda la pantalla.
        local groupHeight = firstRowY + buttonSize * 4 + gap * 3 + gap
        local groupWidth = buttonSize * 4 + gap * 3
        layoutFrame.Size = UDim2.fromOffset(groupWidth, groupHeight)
        freeButtonLayer.Size = UDim2.fromOffset(groupWidth, groupHeight)
        dragHandle.Size = UDim2.fromOffset(groupWidth, math.max(48, firstRowY))
        for _, info in ipairs(buttons) do
            info.button.Size = UDim2.fromOffset(buttonSize, buttonSize)
            if not info.independent or not info.userMoved then
                info.button.Position = UDim2.fromOffset(info.column * pitch, firstRowY + info.row * pitch)
            end
        end
    end
    local cameraConnection
    local function bindCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        local camera = workspace.CurrentCamera
        if camera then
            cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayout)
            updateLayout()
        end
    end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
    bindCamera()
    S._floatingButtonInfos = buttons
    S._floatingFreeButtonLayer = freeButtonLayer
    S._floatingUpdateLayout = updateLayout
    if S._savedFloatingPanelPos then
        local pos = S._savedFloatingPanelPos
        layoutFrame.Position = UDim2.new(pos.XS or 0.79, pos.X or 0, pos.YS or 0, pos.Y or 0)
    end
    for _, info in ipairs(buttons) do applyButtonStyle(info, false) end
    applyButtonStyle(carry, S.speedMode and S.laggerMode == 0)
    applyButtonStyle(normalLagger, S.laggerMode == 1 and not S.speedMode)
    applyButtonStyle(carryLagger, S.laggerMode == 2 and not S.speedMode)
    applyButtonStyle(autoLeft, S.autoLeftEnabled)
    applyButtonStyle(autoRight, S.autoRightEnabled)
    applyButtonStyle(bat, S.batAimbotEnabled)
    applyButtonStyle(tpBat, S.tpBatEnabled)
end

-- Insta Reset do S2: HipHeight 1e30, até 40 tentativas / 0.05s,
-- depois Health=0. Mantém a câmera apenas durante a ação.
do
    local resetThread, cameraConnection
    local busy = false
    local generation = 0
    local savedCharacter, savedHumanoid, savedHipHeight, savedAutoRotate
    local collisions = {}
    local function release()
        if cameraConnection then cameraConnection:Disconnect(); cameraConnection = nil end
        if savedCharacter and savedCharacter.Parent and savedHumanoid then
            pcall(function()
                savedHumanoid.HipHeight = savedHipHeight
                savedHumanoid.AutoRotate = savedAutoRotate
            end)
            for part, value in pairs(collisions) do
                if part.Parent then pcall(function() part.CanCollide = value end) end
            end
        end
        savedCharacter, savedHumanoid = nil, nil
        collisions = {}
        busy = false
    end
    S.stopInstaReset = function()
        generation += 1
        if resetThread then pcall(task.cancel, resetThread); resetThread = nil end
        release()
    end
    S.instaReset = function()
        if busy then return end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or hum.Health <= 0 then return end
        busy = true
        generation += 1
        local token = generation
        savedCharacter, savedHumanoid = char, hum
        savedHipHeight, savedAutoRotate = hum.HipHeight, hum.AutoRotate
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then collisions[part] = part.CanCollide end
        end
        if S.setBatBypass and S.batBypassEnabled then S.setBatBypass(false) end
        local cam = workspace.CurrentCamera
        local locked = cam and cam.CFrame
        if locked then
            cameraConnection = RunService.Heartbeat:Connect(function()
                local current = workspace.CurrentCamera
                if current and busy and generation == token then current.CFrame = locked end
            end)
        end
        resetThread = task.defer(function()
            for attempt = 1, 40 do
                if generation ~= token or LP.Character ~= char or not char.Parent or hum.Health <= 0 then break end
                pcall(function()
                    hum.HipHeight = 1e30
                    hum.AutoRotate = true
                    for part in pairs(collisions) do if part.Parent then part.CanCollide = false end end
                end)
                task.wait(0.05)
            end
            if generation == token and LP.Character == char and char.Parent and hum.Health > 0 then
                pcall(function() hum.Health = 0 end)
                task.wait(0.1)
            end
            if generation == token then resetThread = nil; release() end
        end)
    end
    LP.CharacterRemoving:Connect(S.stopInstaReset)
end

-- ===========================
-- FLOATING BUTTON PANEL (FALLS4K layout, fully wired)
-- ===========================
createFloatingButtonPanel = function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FloatingModeMenu"
    gui.DisplayOrder = 50
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = LP:WaitForChild("PlayerGui")
    S.floatingPanelGui = gui

    local container = Instance.new("Frame")
    container.Name = "FloatingButtons"
    container.AnchorPoint = Vector2.new(1, 0)
    container.Position = UDim2.new(1, -58, 0, 95)
    container.Size = UDim2.fromOffset(132, 230)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = 10
    container.Parent = gui
    S.floatingPanelFrame = container
    container.Active = false
    local savedPanel = S._savedFloatingPanelPos
    if type(savedPanel) == "table" then
        local function finite(n)
            return type(n) == "number" and n == n and n > -math.huge and n < math.huge
        end
        if finite(savedPanel.XS) and finite(savedPanel.X) and finite(savedPanel.YS) and finite(savedPanel.Y) then
            container.Position = UDim2.new(savedPanel.XS, savedPanel.X, savedPanel.YS, savedPanel.Y)
        end
    end

    local DARK = DaHubThemeRGB(5, 5, 7)
    local TEXT = DaHubThemeRGB(255, 255, 255)
    local STROKE = DaHubThemeRGB(18, 18, 24)
    local ACTIVE_BASE = DaHubThemeRGB(235, 235, 235)
    local ACTIVE_TOP = DaHubThemeRGB(255, 255, 255)
    local ACTIVE_MIDDLE = DaHubThemeRGB(235, 235, 235)
    local ACTIVE_BOTTOM = DaHubThemeRGB(170, 170, 170)
    local ACTIVE_STROKE = DaHubThemeRGB(225, 225, 225)
    local byId, infos = {}, {}
    local positions = {
        {"Drop", "DROP\nBRAINROT", 0, 0}, {"AutoLeft", "AUTO\nLEFT", 72, 0},
        {"BatBypass", "BAT\nBYPASS", -72, 60},
        {"InstaReset", "INSTA\nRESET", -72, 120},
        {"AutoBat", "BAT\nAIMBOT", 0, 60},
        {"AutoRight", "AUTO\nRIGHT", 72, 60},
        {"TPDown", "TP\nDOWN", 0, 120}, {"CarrySpd", "CARRY\nSPD", 72, 120},
        {"LaggerCarry", "LAGGER\nCARRY\nSPEED", 0, 180}, {"LaggerNormal", "NORMAL\nLAGGER", 72, 180},
    }
    local function style(i, active)
        if not i or not i.button or not i.button.Parent then return end
        i.active = active == true
        i.button.BackgroundColor3 = i.active and ACTIVE_BASE or DARK
        i.gradient.Enabled = true
        i.gradient.Color = i.active and ColorSequence.new({
            ColorSequenceKeypoint.new(0, ACTIVE_TOP),
            ColorSequenceKeypoint.new(0.46, ACTIVE_MIDDLE),
            ColorSequenceKeypoint.new(1, ACTIVE_BOTTOM),
        }) or ColorSequence.new(DARK)
        i.stroke.Color = i.active and ACTIVE_STROKE or STROKE
        i.stroke.Transparency = i.active and 0 or 0.25
        i.stroke.Thickness = i.active and 2 or 1
        i.hit.TextColor3 = TEXT
    end
    S.refreshMobileTheme = function()
        DARK = DaHubThemeRGB(5, 5, 7)
        TEXT = DaHubThemeRGB(255, 255, 255)
        STROKE = DaHubThemeRGB(18, 18, 24)
        ACTIVE_BASE = DaHubThemeRGB(235, 235, 235)
        ACTIVE_TOP = DaHubThemeRGB(255, 255, 255)
        ACTIVE_MIDDLE = DaHubThemeRGB(235, 235, 235)
        ACTIVE_BOTTOM = DaHubThemeRGB(170, 170, 170)
        ACTIVE_STROKE = DaHubThemeRGB(225, 225, 225)
        for _, info in ipairs(infos) do style(info, info.active) end
    end
    S.refreshMobileButtonShape = function()
        local round = S.mobileButtonStyle == "round"
        for _, info in ipairs(infos) do
            -- Preserve grid centres and positions; only the visual changes shape.
            info.button.Size = round and UDim2.fromOffset(50, 50) or UDim2.fromScale(1, 1)
            info.corner.CornerRadius = round and UDim.new(0.5, 0) or UDim.new(0, 14)
        end
    end
    local function flash(i, duration)
        style(i, true)
        task.delay(duration or 0.45, function()
            if i and i.button and i.button.Parent then style(i, false) end
        end)
    end
    for _, p in ipairs(positions) do
        local button = Instance.new("Frame")
        button.Name = "VisualButton_" .. p[1]
        button.Position = UDim2.fromOffset(p[3], p[4])
        button.Size = UDim2.fromOffset(60, 50)
        button.BackgroundColor3 = DARK
        button.BorderSizePixel = 0
        button.ZIndex = 11
        button.Parent = container
        -- The touch target stays fixed; only this separate visual child animates.
        button.BackgroundTransparency = 1
        button.Active = false
        local visual = Instance.new("Frame")
        visual.Name = "AnimatedVisual"
        visual.AnchorPoint = Vector2.new(0.5, 0.5)
        visual.Position = UDim2.fromScale(0.5, 0.5)
        visual.Size = UDim2.fromScale(1, 1)
        visual.BackgroundColor3 = DARK
        visual.BorderSizePixel = 0
        visual.Active = false
        visual.ZIndex = 11
        visual.Parent = button
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 14)
        corner.Parent = visual
        local stroke = Instance.new("UIStroke")
        stroke.Name = "Border"
        stroke.Color = STROKE
        stroke.Transparency = 0.25
        stroke.Thickness = 1
        stroke.Parent = visual
        local gradient = Instance.new("UIGradient")
        gradient.Name = "SelectedGradient"
        gradient.Rotation = 90
        gradient.Parent = visual
        local hit = Instance.new("TextButton")
        hit.Name = "TextAndTouch"
        hit.Size = UDim2.fromScale(1, 1)
        hit.BackgroundTransparency = 1
        hit.BorderSizePixel = 0
        hit.AutoButtonColor = false
        hit.Active = true
        hit.Selectable = true
        hit.Text = p[2]
        hit.TextColor3 = TEXT
        hit.TextSize = 7
        hit.Font = Enum.Font.GothamBlack
        hit.TextWrapped = true
        hit.ZIndex = 13
        hit.Parent = button
        local buttonScale = Instance.new("UIScale")
        buttonScale.Name = "PressAnimationScale"
        buttonScale.Scale = 1
        buttonScale.Parent = visual
        local i = {id=p[1], button=visual, host=button, hit=hit, stroke=stroke, gradient=gradient, corner=corner,
            userMoved=false, defaultPosition=UDim2.fromOffset(p[3], p[4]), suppressUntil=0}
        local saved = S.mobileButtonPositions[p[1]]
        if type(saved) == "table" and type(saved.X) == "number" and type(saved.Y) == "number"
            and saved.X == saved.X and saved.Y == saved.Y
            and math.abs(saved.X) < 100000 and math.abs(saved.Y) < 100000 then
            button.Position = UDim2.fromOffset(saved.X, saved.Y)
            i.userMoved = true
        end
        local activeScaleTween
        local trackedInput, dragStart, startPosition, dragScale
        local editingGesture = false
        local function animateScale(target, duration)
            if activeScaleTween then activeScaleTween:Cancel() end
            activeScaleTween = TS_G:Create(buttonScale,
                TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=target})
            activeScaleTween:Play()
        end
        hit.InputBegan:Connect(function(input)
            if trackedInput then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
            trackedInput = input
            i.dragMoved = false
            editingGesture = S.editMobileButtons == true and not S.lockUIEnabled
            if editingGesture then
                dragStart = input.Position
                startPosition = button.Position
                dragScale = math.max(0.01, button.AbsoluteSize.X / button.Size.X.Offset)
                buttonScale.Scale = 1
            else
                animateScale(0.92, 0.07)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not trackedInput or not editingGesture or not S.editMobileButtons or S.lockUIEnabled then return end
            if trackedInput.UserInputType == Enum.UserInputType.Touch then
                if input ~= trackedInput then return end
            elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local delta = input.Position - dragStart
            if delta.Magnitude < 6 and not i.dragMoved then return end
            i.dragMoved = true
            local camera = workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize
            local dx, dy = delta.X, delta.Y
            if viewport then
                local origin = container.AbsolutePosition + Vector2.new(startPosition.X.Offset, startPosition.Y.Offset) * dragScale
                dx = math.clamp(dx, -origin.X, math.max(-origin.X, viewport.X - origin.X - button.AbsoluteSize.X))
                dy = math.clamp(dy, -origin.Y, math.max(-origin.Y, viewport.Y - origin.Y - button.AbsoluteSize.Y))
            end
            button.Position = UDim2.fromOffset(startPosition.X.Offset + dx / dragScale, startPosition.Y.Offset + dy / dragScale)
            i.userMoved = true
            S.mobileButtonPositions[i.id] = {X=button.Position.X.Offset, Y=button.Position.Y.Offset}
            -- Moving a button must not resize or reposition the shared backdrop.
        end)
        UIS.InputEnded:Connect(function(input)
            if input ~= trackedInput then return end
            trackedInput = nil
            if editingGesture then
                i.suppressUntil = os.clock() + 0.2
                if i.dragMoved then saveConfig() end
                i.dragMoved = false
            end
            animateScale(1, 0.12)
        end)
        hit.Destroying:Connect(function()
            if activeScaleTween then activeScaleTween:Cancel() end
            trackedInput = nil
        end)
        byId[p[1]], infos[#infos+1] = i, i
        style(i, false)
    end
    S.refreshMobileButtonShape()
    local dragHandle = Instance.new("Frame")
    dragHandle.Name = "FloatingPanelDragHandle"
    dragHandle.Size = UDim2.fromOffset(132, 50)
    dragHandle.BackgroundTransparency = 1
    dragHandle.Active = true
    dragHandle.ZIndex = 1
    dragHandle.Parent = container
    dragHandle.Active = false -- Reposition individual buttons only in edit mode.

    S._floatingButtonInfos = infos
    S._floatingFreeButtonLayer = container
    S._floatingUpdateLayout = function()
        container.Position = UDim2.new(1, -58, 0, 95)
        for _, info in ipairs(infos) do
            info.host.Position = info.defaultPosition
            info.userMoved = false
        end
    end
    S.refreshMobileEditMode = function()
        dragHandle.Active = false
        container.Active = false
        for _, info in ipairs(infos) do
            info.host.ZIndex = S.editMobileButtons and 20 or 11
            info.button.ZIndex = 11
            info.hit.ZIndex = 13
            info.hit.Active = true
            info.hit.Selectable = not S.editMobileButtons
        end
    end
    S.refreshMobileEditMode()
    local function get(id) return byId[id] end
    local function connect(id, fn)
        local info = get(id)
        info.hit.Activated:Connect(function()
            if S.editMobileButtons or os.clock() < info.suppressUntil then return end
            fn()
        end)
    end
    connect("Drop", function() flash(get("Drop"), 0.5); task.spawn(runDropBrainrot) end)
    connect("TPDown", function() flash(get("TPDown"), 0.45); runTPFloor() end)
    connect("BatBypass", function() S.toggleBatBypass() end)
    connect("InstaReset", function() flash(get("InstaReset"), 0.45); S.instaReset() end)
    S.setBatBypassVisual = function(active) style(get("BatBypass"), active) end
    gui.Destroying:Connect(function()
        if S.setBatBypass then S.setBatBypass(false) end
        if S.stopInstaReset then S.stopInstaReset() end
    end)
    connect("AutoBat", function()
        local on = not S.batAimbotEnabled
        if on then
            if S.autoLeftEnabled then S.autoLeftEnabled=false; stopAutoLeft() end
            if S.autoRightEnabled then S.autoRightEnabled=false; stopAutoRight() end
        end
        setBatAimbot(on); style(get("AutoBat"), on); updateFloatingButtons()
    end)
    connect("AutoLeft", function()
        local on = not S.autoLeftEnabled
        if on then
            if S.autoRightEnabled then S.autoRightEnabled=false; stopAutoRight() end
            if S.batAimbotEnabled then setBatAimbot(false) end
            S.autoLeftEnabled=true; startAutoLeft()
        else S.autoLeftEnabled=false; stopAutoLeft() end
        if S.autoLeftSetVisual then S.autoLeftSetVisual(on) end
        S.restartMovement(); updateFloatingButtons(); saveConfig()
    end)
    connect("AutoRight", function()
        local on = not S.autoRightEnabled
        if on then
            if S.autoLeftEnabled then S.autoLeftEnabled=false; stopAutoLeft() end
            if S.batAimbotEnabled then setBatAimbot(false) end
            S.autoRightEnabled=true; startAutoRight()
        else S.autoRightEnabled=false; stopAutoRight() end
        if S.autoRightSetVisual then S.autoRightSetVisual(on) end
        S.restartMovement(); updateFloatingButtons(); saveConfig()
    end)
    local function normalSpeed()
        S.setNormalSpeedMode(); S.restartMovement(); updateFloatingButtons()
        style(get("CarrySpd"), false); style(get("LaggerCarry"), false); style(get("LaggerNormal"), false); saveConfig()
    end
    connect("CarrySpd", function()
        if S.speedMode and S.laggerMode == 0 then
            normalSpeed()
        else
            S.setCarrySpeedMode()
            S.restartMovement()
            updateFloatingButtons()
            style(get("LaggerNormal"), false)
            style(get("LaggerCarry"), false)
            saveConfig()
        end
    end)
    local function lagger(mode)
        if S.laggerMode == mode and not S.speedMode then normalSpeed(); return end
        S.speedMode=false; S.laggerMode=mode; S.refreshSpeedModeLabel(); S.applySpeedVelocityNow(); S.restartMovement(); updateFloatingButtons()
        style(get("LaggerCarry"), mode == 2); style(get("LaggerNormal"), mode == 1); saveConfig()
    end
    connect("LaggerCarry", function() lagger(2) end)
    connect("LaggerNormal", function() lagger(1) end)

    S.dropBrainrotSetVisual = function(active) style(get("Drop"), active) end
    S.dropBrainrotFloatVisual = S.dropBrainrotSetVisual
    S._btnAAL, S._bsAAL, S._l1AAL, S._l2AAL = get("AutoLeft").button, nil, nil, nil
    S._btnAAR, S._bsAAR, S._l1AAR, S._l2AAR = get("AutoRight").button, nil, nil, nil
    S._btnBAT, S._bsBAT, S._l1BAT, S._l2BAT = get("AutoBat").button, nil, nil, nil
    S._setPButtonActive = function(button, _, _, _, active)
        for _, i in pairs(byId) do if i.button == button then style(i, active); return end end
    end
    S._floatingButtons = {
        lagger=get("LaggerNormal").button, l2Lagger={Text=""}, carry=get("CarrySpd").button,
        autoLeft=get("AutoLeft").button, autoRight=get("AutoRight").button, bat=get("AutoBat").button,
    }
    style(get("BatBypass"), S.batBypassEnabled)
    style(get("AutoBat"), S.batAimbotEnabled)
    style(get("AutoLeft"), S.autoLeftEnabled)
    style(get("AutoRight"), S.autoRightEnabled)
    style(get("CarrySpd"), S.speedMode and S.laggerMode == 0)
    style(get("LaggerNormal"), S.laggerMode == 1 and not S.speedMode)
    style(get("LaggerCarry"), S.laggerMode == 2 and not S.speedMode)
end

-- ── Load config then build UI ─────────────────────────────────────────────
pcall(function()
    local ok, data = pcall(function()
        if isfile and readfile and isfile(CONFIG_FILE) then return readfile(CONFIG_FILE) end
    end)
    if ok and data then
        local cfgOk, cfg = pcall(function() return HS:JSONDecode(data) end)
        if cfgOk and type(cfg)=="table" then
            DaHubSetUserScale("menu", cfg.userMenuScale or 1, false)
            DaHubSetUserScale("mobile", cfg.userMobileScale or 1, false)
            if type(cfg.normalSpeed)=="number" then S.NS=cfg.normalSpeed end
            if type(cfg.hubColor)=="string" then
                for _, optionId in ipairs(HUB_COLOR_OPTIONS) do
                    if cfg.hubColor == optionId then
                        S.hubColor = optionId
                        break
                    end
                end
            end
            S.optimizerMode = cfg.optimizerMode == "tripa" and "tripa" or "standard"
            S.mobileButtonStyle = cfg.mobileButtonStyle == "round" and "round" or "original"
            DaHubBrandStyle.setFont(cfg.hubTitleFont,false)
            if S.setMedusaSkin then S.setMedusaSkin(cfg.medusaSkin,false) end
            if type(cfg.carrySpeed)=="number" then S.CS=cfg.carrySpeed end
            if type(cfg.laggerSpeed)=="number" then S.LS=cfg.laggerSpeed end
            if type(cfg.laggerCarrySpeed)=="number" then S.LCS=cfg.laggerCarrySpeed end
            if type(cfg.grabRadius)=="number" then S.Steal.StealRadius=cfg.grabRadius end
            if cfg.stealDuration ~= nil then
                S.Steal.StealDuration = sanitizeStealDuration(cfg.stealDuration, S.Steal.StealDuration)
            end
            if type(cfg.mainMenuPos) == "table" then
                local pos = cfg.mainMenuPos
                local function finite(value)
                    return type(value) == "number" and value == value
                        and value > -math.huge and value < math.huge
                end
                if finite(pos.XS) and finite(pos.X) and finite(pos.YS) and finite(pos.Y) then
                    S.menuOpenPosition = UDim2.new(pos.XS, pos.X, pos.YS, pos.Y)
                    if S.mainMenuFrame then S.mainMenuFrame.Position = S.menuOpenPosition end
                end
            end
            S.dropMode = cfg.dropMode == 2 and 2 or 1
            if type(cfg.mobileButtonPositions)=="table" then S.mobileButtonPositions=cfg.mobileButtonPositions end
            if type(cfg.floatingFreeButtonPositions)=="table" then S.floatingFreeButtonPositions=cfg.floatingFreeButtonPositions end
            if type(cfg.lockMobileButtons)=="boolean" then S.lockMobileButtons=cfg.lockMobileButtons end
            local function rl(entry, saved)
                if type(saved) ~= "table" then return end
                for _, field in ipairs({"kb", "gp"}) do
                    if type(saved[field]) == "string" then
                        local ok, key = pcall(function() return Enum.KeyCode[saved[field]] end)
                        if ok and key then DaHubBindings.assign(entry, key, field == "gp") end
                    end
                end
            end
            -- Solo restaurar keybinds de configs ya migradas; las antiguas usaban teclas previas.
            if cfg.keybindVersion == 1 then
                rl(S.KB.DropBrainrot, cfg.dropBrainrotKey); rl(S.KB.AutoLeft, cfg.autoLeftKey)
                rl(S.KB.AutoRight, cfg.autoRightKey); rl(S.KB.AutoBat, cfg.autoBatKey)
                rl(S.KB.BatBypass, cfg.batBypassKey)
                rl(S.KB.TPFlor, cfg.tpFloorKey); rl(S.KB.GuiHide, cfg.guiHideKey)
                rl(S.KB.SpeedToggle, cfg.speedToggleKey); rl(S.KB.LaggerToggle, cfg.laggerToggleKey)
            end
            if cfg.batBypassVersion and S.selectBatBypassVersion then
                S.selectBatBypassVersion(cfg.batBypassVersion, false)
            end
            if tonumber(cfg.batBypassSpeed) then S.batBypassSpeed = math.clamp(tonumber(cfg.batBypassSpeed), 1, 500) end
            if S.setInformationE01 then S.setInformationE01(cfg.informationE01 ~= false, false) end
            if cfg.carryMode==true then S.speedMode=true; S.setCarrySpeedMode() end
            if cfg.laggerMode == 1 then
                S.setLaggerNormalMode()
            elseif cfg.laggerMode == 2 then
                S.setLaggerCarryMode()
            end
            if cfg.antiRagdoll==true then S.antiRagdollEnabled=true; startAntiRagdoll() end
            S.tpDownHeightTrigger = 20
            if type(cfg.tpDownHeightTrigger) == "number" then S.tpDownHeightTrigger = math.clamp(cfg.tpDownHeightTrigger, 1, 500) end
            -- Migrar el antiguo estado Infinite Jump a la única opción Hold Jump.
            if cfg.holdJumpEnabled==true or cfg["infiniteJump"]==true then S.holdJumpEnabled=true; startHoldJump() end
            if cfg.medusaCounter==true then
                S.medusaCounterEnabled=true
                if LP.Character then setupMedusaCounter(LP.Character) end
            end
            if cfg.batCounter==true then
                S.batCounterEnabled=true
                startBatCounter()
            end
            if cfg.autoStealEnabled==true then S.stealActive=true; startAutoSteal() end
            if cfg.batAimbot==true then S.batAimbotEnabled=true; startBatAimbot() end
            if type(cfg.batSkin) == "string" then S.setBatSkin(cfg.batSkin, false) end
            if type(cfg.displaySkin)=="string" then
                for _,name in ipairs(DAHUB_SKIN_ORDER) do if name==cfg.displaySkin then S.displaySkin=name; break end end
            end
            S.customSkinEnabled = cfg.customSkin == true and S.displaySkin ~= "Off"
            if S.customSkinEnabled and S.applyDisplaySkin then task.defer(function() pcall(S.applyDisplaySkin) end) end
            if cfg.espEnabled==true then
                S.espEnabled=true
                toggleESP(true)
                task.spawn(function()
                    task.wait(1)
                    if S.setESPVisual then S.setESPVisual(true) end
                end)
            end
            if type(cfg.stealHudPos)=="table" then
                S._savedStealHudPos = cfg.stealHudPos
                task.defer(function()
                    if S.stealHudCard and S._savedStealHudPos then
                        local pos = S._savedStealHudPos
                        S.stealHudCard.Position = UDim2.new(
                            pos.XS or 0.5, pos.X or 0,
                            pos.YS or 1, pos.Y or -106
                        )
                    end
                end)
            end
            if cfg.unwalkEnabled==true then S.unwalkEnabled=true; startUnwalk() end
            if cfg.lockUI==true then S.lockUIEnabled=true end
            if cfg.fpsBoost==true then S.fpsBoostEnabled=true; applyFPSBoost() end
            S.vividGraphicsEnabled = cfg.vividGraphics == true
            if S.vividGraphicsEnabled then pcall(enableVividGraphics) end
            if type(cfg.stretchFOV) == "number" then S.stretchFOV = math.clamp(cfg.stretchFOV, 70, 150) end
            S.stretchEnabled = cfg.stretchEnabled == true
            if S.stretchEnabled then pcall(enableStretch) end
            if type(cfg.skyTheme) == "string" and SKY_PRESETS[cfg.skyTheme] then
                S.skyTheme = cfg.skyTheme
                if S.skyTheme ~= "Off" then pcall(applyCustomSky, S.skyTheme) end
            else
                S.skyTheme = "Off"
            end
            if type(cfg.krobloxMode) == "string" and ({Off=true, Left=true, Right=true, Both=true})[cfg.krobloxMode] then
                S.krobloxMode = cfg.krobloxMode
                if S.krobloxMode ~= "Off" then pcall(_G._DaHubApplyKroblox, S.krobloxMode) end
            else
                S.krobloxMode = "Off"
            end
            S.antiFlingEnabled = cfg.antiFling == true
            if S.antiFlingEnabled then pcall(YF.startAntiFling) end
            if type(cfg.lockEnemyRange) == "number" then S.bodyLockRange = math.clamp(math.floor(cfg.lockEnemyRange), 5, 200) end
            S.bodyLockEnabled = cfg.lockEnemy == true
            if S.bodyLockEnabled then pcall(YF.startBodyLock) end
            if type(cfg.animPack) == "string" and (cfg.animPack == "Off" or YF.ANIM_PACKS[cfg.animPack]) then
                S.currentAnimPack = cfg.animPack
            else
                S.currentAnimPack = "Off"
            end
            if S.currentAnimPack ~= "Off" then pcall(YF.startAnimPack, S.currentAnimPack) end
            S.antiLagEnabled = cfg.antiLag == true
            if S.antiLagEnabled then pcall(YF.enableAntiLag) end
            if cfg.hideOpiumButtons==true then S.hideOpiumButtonsEnabled=true end
            if type(cfg.floatingPanelPos)=="table" then
                -- El panel todavía no existe aquí; createFloatingButtonPanel lo aplica después.
                S._savedFloatingPanelPos = cfg.floatingPanelPos
            end
        end
    end
end)


-- ── Nueva barra Steal (diseño adjunto) ───────────────────────────────────
local function buildStealHUD()
    local sg = Instance.new("ScreenGui")
    sg.Name = "StealBarMovableSmall"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 90 -- Main menu is 100; Auto Grab stays underneath.
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global

    -- Share the menu's GUI host so DisplayOrder is reliable across executors.
    local menuGui = S.mainMenuFrame and S.mainMenuFrame:FindFirstAncestorOfClass("ScreenGui")
    local parent = menuGui and menuGui.Parent or game:GetService("CoreGui")
    if not pcall(function() sg.Parent = parent end) or not sg.Parent then
        sg.Parent = LP:WaitForChild("PlayerGui")
    end

    local panel = Instance.new("Frame")
    panel.Name = "StealProgressBar"
    panel.Size = UDim2.new(0, 300, 0, 54)
    panel.Position = UDim2.new(0.5, -150, 1, -75)
    panel.BackgroundColor3 = Color3.fromRGB(20, 6, 10)
    panel.BackgroundTransparency = 0
    panel.BorderSizePixel = 0
    panel.Active = true
    panel.Selectable = true
    panel.ClipsDescendants = true
    panel.Visible = true
    panel.ZIndex = 100
    panel.Parent = sg
    addPurenChristmasDecorations(panel, true)

    -- Papai Noel atravessando o painel do Auto Grab.


    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 13)
    panelCorner.Parent = panel
    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = Color3.fromRGB(214, 40, 58)
    panelStroke.Thickness = 1.3
    panelStroke.Transparency = 0.15
    panelStroke.Parent = panel


    -- Sem brilho animado permanente no HUD.

    local fpsText = Instance.new("TextLabel")
    fpsText.Name = "FPS"
    fpsText.Size = UDim2.new(1, -24, 0, 17)
    fpsText.Position = UDim2.new(0, 12, 0, 6)
    fpsText.BackgroundTransparency = 1
    fpsText.Text = "AUTO GRAB · NATAL · 60FPS · 0ms"
    fpsText.TextColor3 = Color3.fromRGB(255, 221, 126)
    fpsText.Font = Enum.Font.Gotham
    fpsText.TextSize = 12
    fpsText.TextXAlignment = Enum.TextXAlignment.Left
    fpsText.TextYAlignment = Enum.TextYAlignment.Center
    fpsText.ZIndex = 103
    fpsText.Parent = panel

    local row = Instance.new("Frame")
    row.Name = "ProgressRow"
    row.Size = UDim2.new(1, -20, 0, 16)
    row.Position = UDim2.new(0, 10, 0, 30)
    row.BackgroundTransparency = 1
    row.ZIndex = 101
    row.Parent = panel

    local background = Instance.new("Frame")
    background.Name = "BarBackground"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(18, 74, 44)
    background.BorderSizePixel = 0
    background.ClipsDescendants = true
    background.ZIndex = 101
    background.Parent = row
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 8)
    backgroundCorner.Parent = background

    local fill = Instance.new("Frame")
    fill.Name = "ProgressFill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(214, 40, 58)
    fill.BorderSizePixel = 0
    fill.ZIndex = 102
    fill.Parent = background
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 8)
    fillCorner.Parent = fill
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(214, 40, 58)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 221, 126)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 112, 62)),
    })
    fillGradient.Parent = fill

    local percent = Instance.new("TextLabel")
    percent.Name = "Percent"
    percent.Size = UDim2.new(1, 0, 1, 0)
    percent.BackgroundTransparency = 1
    percent.Text = "0%"
    percent.TextColor3 = DaHubThemeRGB(255, 255, 255)
    percent.Font = Enum.Font.Gotham
    percent.TextSize = 11
    percent.TextXAlignment = Enum.TextXAlignment.Center
    percent.TextYAlignment = Enum.TextYAlignment.Center
    percent.TextStrokeColor3 = DaHubThemeRGB(245, 245, 250)
    percent.TextStrokeTransparency = 1
    percent.ZIndex = 104
    percent.Parent = background

    -- Lightning follows the rendered edge, including the smooth return.
    local lightning = Instance.new("Frame")
    lightning.Name = "AutoGrabLightning"
    lightning.Size = UDim2.fromOffset(24, 16)
    lightning.AnchorPoint = Vector2.new(0.5, 0.5)
    lightning.BackgroundTransparency = 1
    lightning.Active = false
    lightning.Selectable = false
    lightning.ZIndex = 103
    lightning.Visible = false
    lightning.Parent = background

    local segments = {}
    local points = {
        Vector2.new(16, 1), Vector2.new(8, 6),
        Vector2.new(14, 7), Vector2.new(7, 15),
    }
    for i = 1, #points - 1 do
        local a, b = points[i], points[i + 1]
        local delta = b - a
        local center = (a + b) * 0.5
        for layer = 1, 2 do
            local line = Instance.new("Frame")
            line.Name = layer == 1 and "LightningGlow" or "LightningCore"
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.Position = UDim2.fromOffset(center.X, center.Y)
            line.Size = UDim2.fromOffset(delta.Magnitude + 1, layer == 1 and 5 or 2)
            line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
            line.BackgroundColor3 = layer == 1
                and Color3.fromRGB(255, 190, 40) or Color3.fromRGB(255, 246, 220)
            line.BackgroundTransparency = layer == 1 and 0.55 or 0
            line.BorderSizePixel = 0
            line.ZIndex = 103
            line.Active = false
            line.Selectable = false
            line.Parent = lightning
            local corner = Instance.new("UICorner", line)
            corner.CornerRadius = UDim.new(0, 2)
            if layer == 1 then table.insert(segments, line) end
        end
    end

    -- Additional stationary bolt at the middle of the loading bar.
    local centralLightning = lightning:Clone()
    centralLightning.Name = "AutoGrabCentralLightning"
    centralLightning.Position = UDim2.fromScale(0.5, 0.5)
    centralLightning.Visible = false
    centralLightning.Parent = background
    for _, child in ipairs(centralLightning:GetChildren()) do
        if child.Name == "LightningGlow" then table.insert(segments, child) end
    end

    local trail = Instance.new("Frame")
    trail.Name = "LightningTrail"
    trail.AnchorPoint = Vector2.new(1, 0.5)
    trail.Size = UDim2.fromOffset(34, 6)
    trail.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
    trail.BackgroundTransparency = 0.45
    trail.BorderSizePixel = 0
    trail.ZIndex = 103
    trail.Visible = false
    trail.Parent = background
    local trailCorner = Instance.new("UICorner", trail)
    trailCorner.CornerRadius = UDim.new(0, 3)
    local trailGradient = Instance.new("UIGradient", trail)
    trailGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0.15),
    })

    local displayedProgress = 0
    local progressConnection
    local progressElapsed = 0
    progressConnection = RunService.Heartbeat:Connect(function(dt)
        progressElapsed += dt
        if progressElapsed < 1 / 30 then return end
        dt = progressElapsed
        progressElapsed = 0
        if not panel.Visible or not sg.Enabled then return end
        local now = os.clock()
        local target = S.progressVisualTarget or 0
        if now < (S.progressVisualCompleteUntil or 0) then target = 1 end
        if displayedProgress == target then return end
        -- Exponential smoothing remains consistent at different frame rates.
        local returning = target < displayedProgress
        local response = returning and 0.07 or 0.025
        displayedProgress += (target - displayedProgress) * (1 - math.exp(-dt / response))
        if math.abs(target - displayedProgress) < 0.001 then displayedProgress = target end
        fill.Size = UDim2.new(displayedProgress, 0, 1, 0)
        percent.Text = math.floor(displayedProgress * 100 + 0.5) .. "%"
        local width = background.AbsoluteSize.X
        local edge = displayedProgress * width
        lightning.Position = UDim2.new(0, math.clamp(edge, 12, math.max(12, width - 12)), 0.5, 0)
        lightning.Visible = displayedProgress > 0.003
        centralLightning.Visible = lightning.Visible
        -- Leave room for the central bolt beside the percentage, never over it.
        percent.Position = UDim2.fromOffset(centralLightning.Visible and 44 or 0, 0)
        percent.Size = UDim2.new(1, centralLightning.Visible and -44 or 0, 1, 0)
        trail.Position = UDim2.new(0, edge, 0.5, 0)
        trail.AnchorPoint = Vector2.new(returning and 0 or 1, 0.5)
        trailGradient.Rotation = returning and 180 or 0
        trail.Visible = lightning.Visible and math.abs(target - displayedProgress) > 0.002
        -- Raios estáticos: evita atualizar vários objetos a cada frame.
    end)
    sg.Destroying:Connect(function()
        if progressConnection then progressConnection:Disconnect() end
    end)

    -- Arrastre con mouse o toque.
    local dragging, dragInput, dragStart, startPosition = false, nil, nil, nil
    local moved = false
    local function updateDrag(input)
        if S.lockUIEnabled then return end
        if (input.Position - dragStart).Magnitude > 2 then moved = true end
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
    panel.InputBegan:Connect(function(input)
        if S.lockUIEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPosition = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if moved then saveConfig() end
                    dragging = false
                    moved = false
                end
            end)
        end
    end)
    panel.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if S.lockUIEnabled then
            dragging = false
            moved = false
            return
        end
        if input == dragInput and dragging then updateDrag(input) end
    end)

    S.progressBarFrame = background
    S.progressFill = fill
    S.progressPct = percent
    S.stealHudCard = panel
    if S._savedStealHudPos then
        local pos = S._savedStealHudPos
        panel.Position = UDim2.new(pos.XS or 0.5, pos.X or 0, pos.YS or 1, pos.Y or -106)
    end

    -- Actualización de FPS y ping del diseño adjunto.
    task.spawn(function()
        local lastTime, frameCount = os.clock(), 0
        while sg.Parent do
            RunService.RenderStepped:Wait()
            frameCount += 1
            local now = os.clock()
            if now - lastTime >= 0.5 then
                local fps = math.floor(frameCount / (now - lastTime) + 0.5)
                frameCount, lastTime = 0, now
                local ping = 0
                pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000 + 0.5) end)
                fpsText.Text = string.format("%dFPS · %dms", fps, ping)
            end
        end
    end)
end

interfaceLoaded = false
local function loadDaHubInterface()
    if interfaceLoaded then return end
    interfaceLoaded = true
    -- Cargar la interfaz local inmediatamente; la música se reproduce por separado.
    DaHubApplyColorTheme(S.hubColor or DEFAULT_HUB_COLOR)
    createFloatingButtonPanel()
    buildGui()
    DaHubSetUserScale("menu", S.userMenuScale or 1, false)
    DaHubSetUserScale("mobile", S.userMobileScale or 1, false)
    buildStealHUD()
    -- Luzes natalinas nos botões visíveis do menu, Auto Grab e painel flutuante.
    for _, root in ipairs({game:GetService("CoreGui"), LP:WaitForChild("PlayerGui")}) do
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextButton") then decoratePurenChristmasButton(obj) end
        end
    end
    local character = LP.Character
    if character then
        S.setupSpeedBillboard(character)
        setupDaHubRagdollTimer(character)
    end

    -- El cargador remoto es opcional y no debe bloquear la aparición del menú.
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if interfaceLoaded then
        S.setupSpeedBillboard(char)
        setupDaHubRagdollTimer(char)
    end
    if S.antiRagdollEnabled then startAntiRagdoll() end
    if S.medusaCounterEnabled then setupMedusaCounter(char) end
    if S.currentAnimPack ~= "Off" then
        task.spawn(function()
            local animate = char:WaitForChild("Animate", 5)
            if animate and LP.Character == char and S.currentAnimPack ~= "Off" then
                pcall(YF.saveOriginalAnims, char)
                pcall(YF.startAnimPack, S.currentAnimPack)
            end
        end)
    end
    if S.holdJumpEnabled and not S._youtResetInProgress then startHoldJump() end
    if S.unwalkEnabled then task.wait(1); startUnwalk() end
    S.restartMovement()
end)
if LP.Character then
    task.spawn(function()
        if interfaceLoaded then
            S.setupSpeedBillboard(LP.Character)
            setupDaHubRagdollTimer(LP.Character)
        end
        if S.antiRagdollEnabled then startAntiRagdoll() end
        if S.medusaCounterEnabled then setupMedusaCounter(LP.Character) end
    end)
end

showIntro(function()
    loadDaHubInterface()
end)

-- FALLS4K | by Davy...
-- [[ Hii! this file was cracked by SOURCE_CODE ]]
-- [[ TIMESTAMP: 10:10:26 ]]
