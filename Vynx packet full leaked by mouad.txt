local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local CONFIG_FILE = "VynxPacket_Config.json"

local SETTINGS_IMAGES = {
	"rbxassetid://117506604414812",
	"rbxassetid://100339467909522",
	"rbxassetid://121717047689997",
	"rbxassetid://129336046876977",
}

-- Colors (Vynx)
local ACCENT  = Color3.fromRGB(70, 110, 230)
local NAVY    = Color3.fromRGB(10, 14, 28)
local PANEL   = Color3.fromRGB(16, 22, 42)
local INPUT   = Color3.fromRGB(26, 34, 60)
local BTN     = Color3.fromRGB(28, 40, 78)
local WHITE   = Color3.fromRGB(255, 255, 255)
local DIM     = Color3.fromRGB(140, 150, 175)

local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = o
	return c
end
local function stroke(o, col, th, tr)
	local s = Instance.new("UIStroke")
	s.Color = col
	s.Thickness = th or 1
	s.Transparency = tr or 0.2
	s.Parent = o
	return s
end
local function label(parent, text, x, y, w, size, color, font)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Position = UDim2.fromOffset(x, y)
	l.Size = w
	l.Text = text
	l.Font = font or Enum.Font.GothamBold
	l.TextSize = size
	l.TextColor3 = color
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 3
	l.Parent = parent
	return l
end
local function smallBtn(parent, text, pos, size)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.fromOffset(22, 22)
	b.Position = pos
	b.BackgroundColor3 = INPUT
	b.BackgroundTransparency = 0.3
	b.Text = text
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 13
	b.TextColor3 = WHITE
	b.AutoButtonColor = false
	b.ZIndex = 4
	b.Parent = parent
	corner(b, 6)
	return b
end

-- Cleanup old instances
pcall(function()
	local pg = LP:FindFirstChild("PlayerGui")
	if pg then
		for _, n in ipairs({"VynxPacketLagger", "ViolettePacketLagger", "BlindPacketLagger"}) do
			local old = pg:FindFirstChild(n)
			if old then old:Destroy() end
		end
	end
	if gethui then
		for _, g in ipairs(gethui():GetChildren()) do
			if g.Name == "VynxPacketLagger" or g.Name == "ViolettePacketLagger" then g:Destroy() end
		end
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "VynxPacketLagger"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
pcall(function() if gethui then gui.Parent = gethui() end end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

-- Dimensions (adjustable from settings)
local W = 230
local H = 240
local collapsedH = 108

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(W, H)
Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = NAVY
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Parent = gui
corner(Main, 14)
stroke(Main, ACCENT, 1.2, 0.55)

-- Background
local bgImg = Instance.new("ImageLabel")
bgImg.Size = UDim2.new(1, 0, 1, 0)
bgImg.BackgroundTransparency = 1
bgImg.Image = SETTINGS_IMAGES[1]
bgImg.ImageTransparency = 0.3
bgImg.ScaleType = Enum.ScaleType.Crop
bgImg.ZIndex = 0
bgImg.Parent = Main
corner(bgImg, 14)

local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = NAVY
overlay.BackgroundTransparency = 0.35
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Parent = Main
corner(overlay, 14)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundTransparency = 1
header.ZIndex = 2
header.Parent = Main

-- Avatar (click -> settings menu)
local Avatar = Instance.new("TextButton")
Avatar.Size = UDim2.fromOffset(32, 32)
Avatar.Position = UDim2.fromOffset(12, 9)
Avatar.BackgroundColor3 = BTN
Avatar.Text = "V"
Avatar.Font = Enum.Font.GothamBlack
Avatar.TextSize = 15
Avatar.TextColor3 = WHITE
Avatar.AutoButtonColor = false
Avatar.ZIndex = 3
Avatar.Parent = header
corner(Avatar, 16)
stroke(Avatar, ACCENT, 1.5, 0.2)

local Title = label(header, "VYNX PACKET", 52, 10, UDim2.new(1, -130, 0, 16), 14, WHITE, Enum.Font.GothamBlack)
local SubTitle = label(header, "discord.gg/vynxduel", 52, 27, UDim2.new(1, -130, 0, 13), 10, DIM, Enum.Font.GothamMedium)

local gearBtn  = smallBtn(header, "⚙", UDim2.new(1, -82, 0, 14))
local minBtn   = smallBtn(header, "−", UDim2.new(1, -56, 0, 14))
local closeBtn = smallBtn(header, "×", UDim2.new(1, -30, 0, 14))
for _, b in ipairs({gearBtn, minBtn, closeBtn}) do b.BackgroundTransparency = 1 end

-- Activate (main button)
local StartBtn = Instance.new("TextButton")
StartBtn.Position = UDim2.fromOffset(12, 56)
StartBtn.Size = UDim2.new(1, -24, 0, 40)
StartBtn.BackgroundColor3 = BTN
StartBtn.Text = "ACTIVATE"
StartBtn.Font = Enum.Font.GothamBlack
StartBtn.TextSize = 15
StartBtn.TextColor3 = WHITE
StartBtn.AutoButtonColor = false
StartBtn.ZIndex = 3
StartBtn.Parent = Main
corner(StartBtn, 10)
stroke(StartBtn, ACCENT, 1, 0.4)

-- Power row
local powerLbl = label(Main, "Power", 14, 112, UDim2.fromOffset(80, 24), 12, WHITE)

local powerRow = Instance.new("Frame")
powerRow.Size = UDim2.fromOffset(110, 26)
powerRow.Position = UDim2.new(1, -122, 0, 111)
powerRow.BackgroundColor3 = INPUT
powerRow.BackgroundTransparency = 0.3
powerRow.ZIndex = 3
powerRow.Parent = Main
corner(powerRow, 7)

local minusBtn = smallBtn(powerRow, "-", UDim2.fromOffset(2, 2))
local plusBtn  = smallBtn(powerRow, "+", UDim2.new(1, -24, 0, 2))
minusBtn.BackgroundColor3 = BTN
plusBtn.BackgroundColor3 = BTN

local PowerBox = Instance.new("TextBox")
PowerBox.Position = UDim2.fromOffset(26, 0)
PowerBox.Size = UDim2.new(1, -52, 1, 0)
PowerBox.BackgroundTransparency = 1
PowerBox.Text = "15000"
PowerBox.Font = Enum.Font.GothamBlack
PowerBox.TextSize = 13
PowerBox.TextColor3 = WHITE
PowerBox.TextXAlignment = Enum.TextXAlignment.Center
PowerBox.ClearTextOnFocus = false
PowerBox.ZIndex = 4
PowerBox.Parent = powerRow

-- Keybind row
local keyLbl = label(Main, "Keybind", 14, 150, UDim2.fromOffset(80, 24), 12, WHITE)

local KeyBtn = Instance.new("TextButton")
KeyBtn.Position = UDim2.new(1, -86, 0, 149)
KeyBtn.Size = UDim2.fromOffset(46, 26)
KeyBtn.BackgroundColor3 = BTN
KeyBtn.Text = "V"
KeyBtn.Font = Enum.Font.GothamBlack
KeyBtn.TextSize = 13
KeyBtn.TextColor3 = WHITE
KeyBtn.AutoButtonColor = false
KeyBtn.ZIndex = 3
KeyBtn.Parent = Main
corner(KeyBtn, 7)

-- Divider
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.fromOffset(12, 188)
divider.BackgroundColor3 = DIM
divider.BackgroundTransparency = 0.75
divider.BorderSizePixel = 0
divider.ZIndex = 3
divider.Parent = Main

-- Active On Steal toggle
local stealLbl = label(Main, "Active On Steal", 14, 198, UDim2.fromOffset(140, 24), 11, DIM, Enum.Font.GothamMedium)
local activeOnSteal = false

local stealTrack = Instance.new("TextButton")
stealTrack.Size = UDim2.fromOffset(38, 20)
stealTrack.Position = UDim2.new(1, -52, 0, 200)
stealTrack.BackgroundColor3 = INPUT
stealTrack.Text = ""
stealTrack.AutoButtonColor = false
stealTrack.ZIndex = 3
stealTrack.Parent = Main
corner(stealTrack, 10)

local stealKnob = Instance.new("Frame")
stealKnob.Size = UDim2.fromOffset(16, 16)
stealKnob.Position = UDim2.fromOffset(2, 2)
stealKnob.BackgroundColor3 = WHITE
stealKnob.ZIndex = 4
stealKnob.Parent = stealTrack
corner(stealKnob, 8)

local function paintSteal()
	TweenService:Create(stealKnob, TweenInfo.new(0.15), {
		Position = activeOnSteal and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
	}):Play()
	stealTrack.BackgroundColor3 = activeOnSteal and ACCENT or INPUT
end

-- ===================== SETTINGS (2nd menu) =====================
local SW, SH = 230, 250
local Settings = Instance.new("Frame")
Settings.Name = "Settings"
Settings.Size = UDim2.fromOffset(SW, SH)
Settings.BackgroundColor3 = NAVY
Settings.BorderSizePixel = 0
Settings.Visible = false
Settings.Active = true
Settings.ZIndex = 10
Settings.Parent = gui
corner(Settings, 14)
stroke(Settings, ACCENT, 1.2, 0.55)

local sTitle = label(Settings, "SETTINGS", 14, 12, UDim2.new(1, -60, 0, 16), 13, WHITE, Enum.Font.GothamBlack)
sTitle.ZIndex = 11
local sClose = smallBtn(Settings, "×", UDim2.new(1, -30, 0, 10))
sClose.BackgroundTransparency = 1
sClose.ZIndex = 11

local bgLbl = label(Settings, "BACKGROUND", 14, 40, UDim2.new(1, -28, 0, 14), 10, DIM)
bgLbl.ZIndex = 11

local bgRow = Instance.new("Frame")
bgRow.Size = UDim2.new(1, -28, 0, 40)
bgRow.Position = UDim2.fromOffset(14, 58)
bgRow.BackgroundTransparency = 1
bgRow.ZIndex = 11
bgRow.Parent = Settings

local selectedImg = 1
local imgButtons = {}

local function createBgButton(index, asset, text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(36, 36)
	b.Position = UDim2.fromOffset((index - 1) * 41, 0)
	b.BackgroundColor3 = INPUT
	b.BackgroundTransparency = 0.25
	b.Text = text or ""
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = WHITE
	b.AutoButtonColor = false
	b.ZIndex = 12
	b.Parent = bgRow
	corner(b, 8)

	local st = stroke(b, (index == 1) and ACCENT or DIM, 1.6, (index == 1) and 0.05 or 0.4)

	if asset then
		local im = Instance.new("ImageLabel")
		im.Size = UDim2.new(1, -6, 1, -6)
		im.Position = UDim2.fromOffset(3, 3)
		im.BackgroundTransparency = 1
		im.Image = asset
		im.ScaleType = Enum.ScaleType.Crop
		im.ZIndex = 13
		im.Parent = b
		corner(im, 6)
	end

	imgButtons[index] = {btn = b, stroke = st, asset = asset}

	b.MouseButton1Click:Connect(function()
		selectedImg = index
		if asset then
			bgImg.Image = asset
			bgImg.Visible = true
		else
			bgImg.Visible = false
		end
		for j, info in ipairs(imgButtons) do
			info.stroke.Color = (j == index) and ACCENT or DIM
			info.stroke.Transparency = (j == index) and 0.1 or 0.5
		end
	end)
end

for i, asset in ipairs(SETTINGS_IMAGES) do
	createBgButton(i, asset)
end
createBgButton(#SETTINGS_IMAGES + 1, nil, "off")

-- Size adjusters
local isCollapsed = false
local function applySize()
	Main.Size = UDim2.fromOffset(W, isCollapsed and collapsedH or H)
end

local function sizeRow(y, name, get, set, minV, maxV)
	local l = label(Settings, name, 14, y, UDim2.fromOffset(100, 26), 12, WHITE)
	l.ZIndex = 11
	local row = Instance.new("Frame")
	row.Size = UDim2.fromOffset(110, 26)
	row.Position = UDim2.new(1, -122, 0, y)
	row.BackgroundColor3 = INPUT
	row.BackgroundTransparency = 0.3
	row.ZIndex = 11
	row.Parent = Settings
	corner(row, 7)
	local m = smallBtn(row, "-", UDim2.fromOffset(2, 2)); m.ZIndex = 12; m.BackgroundColor3 = BTN
	local p = smallBtn(row, "+", UDim2.new(1, -24, 0, 2)); p.ZIndex = 12; p.BackgroundColor3 = BTN
	local box = Instance.new("TextBox")
	box.Position = UDim2.fromOffset(26, 0)
	box.Size = UDim2.new(1, -52, 1, 0)
	box.BackgroundTransparency = 1
	box.Font = Enum.Font.GothamBlack
	box.TextSize = 13
	box.TextColor3 = WHITE
	box.ClearTextOnFocus = false
	box.ZIndex = 12
	box.Parent = row
	local function refresh() box.Text = tostring(get()) end
	local function setv(v)
		v = tonumber(v) or get()
		set(math.clamp(math.floor(v), minV, maxV))
		applySize()
		refresh()
	end
	m.MouseButton1Click:Connect(function() setv(get() - 10) end)
	p.MouseButton1Click:Connect(function() setv(get() + 10) end)
	box.FocusLost:Connect(function() setv(box.Text) end)
	refresh()
	return refresh
end

local refreshW = sizeRow(112, "Menu Width",  function() return W end, function(v) W = v end, 200, 500)
local refreshH = sizeRow(148, "Menu Height", function() return H end, function(v) H = v end, 230, 600)

local sInfo = label(Settings, "LEAK BY Y78 AND POCTRIX", 14, 200, UDim2.new(1, -28, 0, 20), 11, WHITE, Enum.Font.GothamBlack)
sInfo.TextXAlignment = Enum.TextXAlignment.Center
sInfo.ZIndex = 11

local function openSettings()
	Settings.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset + W + 10, Main.Position.Y.Scale, Main.Position.Y.Offset)
	Settings.Visible = not Settings.Visible
end
Avatar.MouseButton1Click:Connect(openSettings)
gearBtn.MouseButton1Click:Connect(openSettings)
sClose.MouseButton1Click:Connect(function() Settings.Visible = false end)

-- ===================== RAINBOW HEAD TAG =====================
local headTag
local function attachTag(char)
	local head = char:WaitForChild("Head", 10)
	if not head then return end
	if headTag then pcall(function() headTag:Destroy() end) end
	local bb = Instance.new("BillboardGui")
	bb.Name = "VynxLeakTag"
	bb.Size = UDim2.fromOffset(260, 34)
	bb.StudsOffset = Vector3.new(0, 2.6, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = head
	bb.Parent = head
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 1, 0)
	t.BackgroundTransparency = 1
	t.Text = "LEAK BY Y78 AND POCTRIX"
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = WHITE
	t.Parent = bb
	local s = Instance.new("UIStroke")
	s.Thickness = 1.5
	s.Color = Color3.new(0, 0, 0)
	s.Parent = t
	headTag = bb
end
if LP.Character then task.spawn(attachTag, LP.Character) end
LP.CharacterAdded:Connect(attachTag)

RunService.Heartbeat:Connect(function()
	local c = Color3.fromHSV((tick() * 0.25) % 1, 1, 1)
	if headTag and headTag.Parent then
		local t = headTag:FindFirstChildOfClass("TextLabel")
		if t then t.TextColor3 = c end
	end
	sInfo.TextColor3 = c
end)

-- State
local lagging = false
local lagThread = nil
local intensity = 15000
local toggleKey = Enum.KeyCode.V
local toggleKeyName = "V"
local listeningForKey = false
local Event

local function setElementsVisible(visible)
	local elements = {powerLbl, powerRow, keyLbl, KeyBtn, divider, stealLbl, stealTrack}
	for _, el in ipairs(elements) do
		el.Visible = visible
	end
end

local function clampPower(v)
	v = tonumber(v)
	if not v then return intensity end
	return math.clamp(math.floor(v), 1000, 1000000)
end

local function updatePower()
	intensity = clampPower(PowerBox.Text)
	PowerBox.Text = tostring(intensity)
end

local function applyKeybind(name)
	toggleKeyName = name or "V"
	local ok, key = pcall(function() return Enum.KeyCode[toggleKeyName] end)
	toggleKey = (ok and key) or Enum.KeyCode.V
	KeyBtn.Text = toggleKeyName
end

task.spawn(function()
	-- Metod 1: kids[6] (yeni logicin remote-u)
	local ok1, net1 = pcall(function()
		local pkgs = RS:WaitForChild("Packages", 5)
		return pkgs and pkgs:WaitForChild("Net", 5)
	end)
	if ok1 and net1 then
		local kids = net1:GetChildren()
		Event = kids[6]
		if Event then return end
	end

	-- Metod 2: kids[230] (kohne arab packet logici - fallback)
	local tries = 0
	local pkgs
	while tries < 10 do
		local ok, found = pcall(function()
			return RS:FindFirstChild("Packages")
		end)
		if ok and found then
			pkgs = found
			break
		end
		tries = tries + 1
		task.wait(0.5)
	end
	if not pkgs then return end
	local netObj = pkgs:FindFirstChild("Net")
	if not netObj then
		task.wait(5)
		netObj = pkgs:FindFirstChild("Net")
	end
	if not netObj then return end
	local ok2, found2 = pcall(function()
		return netObj:GetChildren()[230]
	end)
	if ok2 then
		Event = found2
	end
end)

local function paintActivate()
	if lagging then
		StartBtn.Text = "DEACTIVATE"
		StartBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
	else
		StartBtn.Text = "ACTIVATE"
		StartBtn.BackgroundColor3 = BTN
	end
end

local function startLagging()
	if lagging then return end
	updatePower()
	lagging = true
	paintActivate()
	
	local payload = table.create(intensity, function() end) 
	
	lagThread = task.spawn(function()
		while lagging do
			if Event then 
				pcall(function() Event:FireServer(payload) end) 
			end
			task.wait(0.05) 
		end
	end)
end

local function stopLagging()
	if not lagging then return end
	lagging = false
	if lagThread then pcall(task.cancel, lagThread); lagThread = nil end
	paintActivate()
end

local function saveConfig()
	updatePower()
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE, HttpService:JSONEncode({
				Power = intensity,
				Keybind = toggleKeyName,
				Image = selectedImg,
				Width = W,
				Height = H,
				ActiveOnSteal = activeOnSteal,
			}))
		end
	end)
end

local function loadConfig()
	if not (readfile and isfile and isfile(CONFIG_FILE)) then return end
	local ok, cfg = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
	if not (ok and type(cfg) == "table") then return end
	if tonumber(cfg.Power) then
		intensity = clampPower(cfg.Power)
		PowerBox.Text = tostring(intensity)
	end
	if type(cfg.Keybind) == "string" and cfg.Keybind ~= "" then
		applyKeybind(cfg.Keybind)
	end
	if type(cfg.Image) == "number" and imgButtons[cfg.Image] then
		imgButtons[cfg.Image].btn.MouseButton1Click:Fire()
	end
	if tonumber(cfg.Width) then W = math.clamp(cfg.Width, 200, 500) end
	if tonumber(cfg.Height) then H = math.clamp(cfg.Height, 230, 600) end
	refreshW(); refreshH(); applySize()
	if type(cfg.ActiveOnSteal) == "boolean" then
		activeOnSteal = cfg.ActiveOnSteal
		paintSteal()
	end
end

-- Connections
minusBtn.MouseButton1Click:Connect(function()
	intensity = clampPower(intensity - 1000)
	PowerBox.Text = tostring(intensity)
end)

plusBtn.MouseButton1Click:Connect(function()
	intensity = clampPower(intensity + 1000)
	PowerBox.Text = tostring(intensity)
end)

PowerBox.FocusLost:Connect(function() updatePower(); saveConfig() end)

StartBtn.MouseButton1Click:Connect(function()
	if lagging then stopLagging() else startLagging() end
end)

KeyBtn.MouseButton1Click:Connect(function()
	listeningForKey = true
	KeyBtn.Text = "..."
end)

stealTrack.MouseButton1Click:Connect(function()
	activeOnSteal = not activeOnSteal
	paintSteal()
	saveConfig()
end)

closeBtn.MouseButton1Click:Connect(function()
	saveConfig()
	stopLagging()
	if headTag then pcall(function() headTag:Destroy() end) end
	gui:Destroy()
end)

-- Minimize
minBtn.MouseButton1Click:Connect(function()
	isCollapsed = not isCollapsed
	if isCollapsed then
		minBtn.Text = "+"
		setElementsVisible(false)
		TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(W, collapsedH)
		}):Play()
	else
		minBtn.Text = "−"
		TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(W, H)
		}):Play()
		task.delay(0.15, function() setElementsVisible(true) end)
	end
end)

UIS.InputBegan:Connect(function(input, gpe)
	if listeningForKey then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			listeningForKey = false
			applyKeybind(input.KeyCode.Name)
			saveConfig()
		end
		return
	end
	if gpe then return end
	if input.KeyCode == toggleKey then
		if lagging then stopLagging() else startLagging() end
	end
end)

-- Drag System (main + settings)
local function makeDrag(handle, target)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
makeDrag(header, Main)
makeDrag(Settings, Settings)

-- auto-save background choice
for _, info in ipairs(imgButtons) do
	info.btn.MouseButton1Click:Connect(saveConfig)
end

task.defer(function()
	loadConfig()
	paintActivate()
	paintSteal()
end)

local CONFIG_FILE = "VynxPacket_Config.json"
local HttpService = game:GetService("HttpService")

local function saveConfig()
    pcall(function()
        if not writefile then return end

        local config = {
            Image = selectedImg,
            Width = W,
            Height = H,
            Collapsed = isCollapsed,
            MainPosition = {
                XScale = Main.Position.X.Scale,
                XOffset = Main.Position.X.Offset,
                YScale = Main.Position.Y.Scale,
                YOffset = Main.Position.Y.Offset
            },
            SettingsVisible = Settings.Visible
        }

        writefile(CONFIG_FILE, HttpService:JSONEncode(config))
    end)
end

local function loadConfig()
    pcall(function()
        if not (isfile and readfile and isfile(CONFIG_FILE)) then
            return
        end

        local config = HttpService:JSONDecode(readfile(CONFIG_FILE))

        if type(config.Image) == "number" then
            selectedImg = math.clamp(config.Image, 1, #SETTINGS_IMAGES + 1)

            if selectedImg <= #SETTINGS_IMAGES then
                bgImg.Image = SETTINGS_IMAGES[selectedImg]
                bgImg.Visible = true
            else
                bgImg.Visible = false
            end

            for i, info in ipairs(imgButtons) do
                info.stroke.Color = i == selectedImg and ACCENT or DIM
            end
        end

        W = math.clamp(tonumber(config.Width) or W, 200, 500)
        H = math.clamp(tonumber(config.Height) or H, 230, 600)

        if type(config.Collapsed) == "boolean" then
            isCollapsed = config.Collapsed
            setElementsVisible(not isCollapsed)
            minBtn.Text = isCollapsed and "+" or "−"
        end

        applySize()

        if type(config.MainPosition) == "table" then
            local p = config.MainPosition
            Main.Position = UDim2.new(
                p.XScale or 0.5,
                p.XOffset or -W/2,
                p.YScale or 0.5,
                p.YOffset or -H/2
            )
        end

        Settings.Visible = config.SettingsVisible == true

        refreshW()
        refreshH()
    end)
end

-- LOAD
loadConfig()

-- AUTO SAVE
local function autoSave()
    task.defer(saveConfig)
end

-- Background changes
for _, info in ipairs(imgButtons) do
    info.btn.MouseButton1Click:Connect(autoSave)
end

-- Save after resizing
task.spawn(function()
    while gui.Parent do
        task.wait(2)
        autoSave()
    end
end)

-- Save when closing
gui.Destroying:Connect(saveConfig)

-- Save after dragging
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        autoSave()
    end
end)

Print("by y78 and poctrix")
Print("by y78 and poctrix")
Print("by y78 and poctrix")
Print("by y78 and poctrix")
Print("by y78 and poctrix")
Print("by y78 and poctrix")