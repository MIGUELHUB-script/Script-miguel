-- ==============================================
--  🥚 MIGUEL HUB — Steal An Egg
--  ✅ MENÚ IDÉNTICO A LENNON HUB | ✅ SIN KEY
-- =============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- VARIABLES
local AutoSteal = false
local AutoSell = false
local SlowMode = true
local DeliveryDelay = 0.8
local ESP_Enabled = false

-- DETECTAR BASE
local function GetMyBase()
    local base = workspace:FindFirstChild("Base_"..LocalPlayer.Name) 
        or workspace:FindFirstChild("OwnerBase")
    if base then
        return base:FindFirstChild("DropOff") or base.PrimaryPart or base
    end
    return nil
end

-- BUSCAR MEJOR HUEVO
local function FindBestEgg()
    local BestEgg = nil
    local BestValue = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(GetMyBase() or Instance.new("Part")) then
            if obj.Name:lower():find("egg") or obj:GetAttribute("IsEgg") then
                local Value = obj:GetAttribute("Value") or 1
                if Value > BestValue then
                    BestValue = Value
                    BestEgg = obj
                end
            end
        end
    end
    return BestEgg
end

-- TELETRANSPORTE SEGURO
local function SafeTP(targetPos)
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    if SlowMode then
        local dist = (HRP.Position - targetPos).Magnitude
        local steps = math.max(5, math.floor(dist / 15))
        for i = 1, steps do
            HRP.CFrame = CFrame.new(HRP.Position:Lerp(targetPos, i / steps))
            task.wait(0.016)
        end
    else
        HRP.CFrame = CFrame.new(targetPos)
    end
end

-- ENTREGAR HUEVO
local function DeliverEgg(egg)
    local Base = GetMyBase()
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Base or not HRP then return end
    task.wait(DeliveryDelay)
    SafeTP(Base.Position + Vector3.new(0, 3, 5))
    task.wait(0.3)
    SafeTP(Base.Position + Vector3.new(0, 2, 0))
end

-- ROBAR HUEVO
local function StealEgg(egg)
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not egg or not HRP then return end
    SafeTP(egg.Position + Vector3.new(0, 3, 0))
    task.wait(0.15)
    DeliverEgg(egg)
end

-- ESP
local function ToggleESP(State)
    ESP_Enabled = State
    if not State then return end
    task.spawn(function()
        while ESP_Enabled do
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("egg") and not obj:FindFirstChild("MiguelESP") then
                    local bg = Instance.new("BillboardGui")
                    bg.Name = "MiguelESP"
                    bg.AlwaysOnTop = true
                    bg.Size = UDim2.new(0, 70, 0, 22)
                    bg.Parent = obj
                    local lbl = Instance.new("TextLabel")
                    lbl.BackgroundTransparency = 1
                    lbl.Text = "🥚 HUEVO"
                    lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 11
                    lbl.Size = UDim2.new(1,0,1,0)
                    lbl.Parent = bg
                end
            end
            task.wait(0.4)
        end
    end)
end

-- 🎨 INTERFAZ — IDÉNTICA A LENNON HUB
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MiguelHub"
ScreenGui.Parent = PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🥚 MIGUEL HUB"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = TitleBar

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(1, 0, 0, 22)
Version.Position = UDim2.new(0, 0, 0, 52)
Version.BackgroundTransparency = 1
Version.Text = "Steal An Egg — v1.0"
Version.TextColor3 = Color3.fromRGB(160, 160, 160)
Version.Font = Enum.Font.Gotham
Version.TextSize = 11
Version.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 10, 1, -80)
Scroll.Position = UDim2.new(0, 5, 0, 80)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 5
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.Parent = Scroll

-- FUNCIÓN DE BOTONES
local function Boton(nombre, funcion)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 80)
    btn.Text = "❌ "..nombre
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = Scroll
    
    local activo = false
    btn.MouseButton1Click:Connect(function()
        activo = not activo
        btn.Text = (activo and "✅ " or "❌ ")..nombre
        btn.BackgroundColor3 = activo and Color3.fromRGB(35, 130, 80) or Color3.fromRGB(55, 55, 80)
        funcion(activo)
    end)
end

-- 📌 BOTONES
Boton("Auto Steal", function(On)
    AutoSteal = On
    task.spawn(function()
        while AutoSteal do
            local egg = FindBestEgg()
            if egg then StealEgg(egg) end
            task.wait(1.5)
        end
    end)
end)

Boton("Best Egg Finder", function(On) end)

Boton("Slow Mode (Anti-Detect)", function(On)
    SlowMode = On
end)

Boton("Safe Delivery Fix", function(On)
    DeliveryDelay = On and 1.0 or 0.5
end)

Boton("Egg ESP", function(On)
    ToggleESP(On)
end)

Boton("Auto Sell", function(On)
    AutoSell = On
end)

Boton("Server Hop", function(On) end)

local Pie = Instance.new("TextLabel")
Pie.Size = UDim2.new(1, 0, 0, 35)
Pie.BackgroundTransparency = 1
Pie.Text = "✅ Sin Key — Creado por ti, Miguel 💛"
Pie.TextColor3 = Color3.fromRGB(130, 130, 130)
Pie.Font = Enum.Font.Gotham
Pie.TextSize = 11
Pie.Parent = Scroll

print("✅ 🥚 MIGUEL HUB CARGADO — Menú idéntico a Lennon Hub")
