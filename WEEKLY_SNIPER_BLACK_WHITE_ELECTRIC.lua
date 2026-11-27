print("prince")

local success, err = pcall(function()
    local cloneref = cloneref or function(object) return object end
    local Players           = cloneref(game:GetService("Players"))
    local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
    local RunService        = cloneref(game:GetService("RunService"))
    local UserInputService  = cloneref(game:GetService("UserInputService"))
    local HttpService       = cloneref(game:GetService("HttpService"))
    local Stats             = cloneref(game:GetService("Stats"))
    local Lighting          = cloneref(game:GetService("Lighting"))
    local Workspace         = cloneref(game:GetService("Workspace"))
    local TweenService      = cloneref(game:GetService("TweenService"))
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    if getgenv and getgenv().StopAura then pcall(getgenv().StopAura) end

    local CONFIG_FILE = "ace_code_sniper_auto_redeem_test_config.json"
    local savedConfig = {
        codeSniper = true,
        autoSubmit = true,
        submitAfter = 1,
        spamRedeem = true,
        antiLag = false,
        antiRagdoll = false,
        removeAccessories = false,
        autoBuy = false,
        listenKeybind = "V",
    }
    pcall(function()
        if type(isfile) == "function" and type(readfile) == "function"
        and isfile(CONFIG_FILE) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(decoded) == "table" then
                if type(decoded.codeSniper) == "boolean" then savedConfig.codeSniper = decoded.codeSniper end
                if type(decoded.autoSubmit) == "boolean" then savedConfig.autoSubmit = decoded.autoSubmit end
                if type(decoded.submitAfter) == "number" then savedConfig.submitAfter = math.max(1, math.min(10, math.floor(decoded.submitAfter))) end
                if type(decoded.spamRedeem) == "boolean" then savedConfig.spamRedeem = decoded.spamRedeem end
                if type(decoded.antiLag) == "boolean" then savedConfig.antiLag = decoded.antiLag end
                if type(decoded.antiRagdoll) == "boolean" then savedConfig.antiRagdoll = decoded.antiRagdoll end
                if type(decoded.removeAccessories) == "boolean" then savedConfig.removeAccessories = decoded.removeAccessories end
                if type(decoded.autoBuy) == "boolean" then savedConfig.autoBuy = decoded.autoBuy end
                if type(decoded.listenKeybind) == "string" and #decoded.listenKeybind == 1 then
                    savedConfig.listenKeybind = decoded.listenKeybind:upper()
                end
            end
        end
    end)

    local function saveConfig()
        if type(writefile) ~= "function" then return end
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode({
                codeSniper = savedConfig.codeSniper,
                autoSubmit = savedConfig.autoSubmit,
                submitAfter = savedConfig.submitAfter,
                spamRedeem = savedConfig.spamRedeem,
                antiLag = savedConfig.antiLag,
                antiRagdoll = savedConfig.antiRagdoll,
                removeAccessories = savedConfig.removeAccessories,
                autoBuy = savedConfig.autoBuy,
                listenKeybind = savedConfig.listenKeybind,
            }))
        end)
    end

    local _enabled              = savedConfig.codeSniper
    local _seen                 = {}
    local _focused              = nil
    local _lastBox              = nil
    local _autoAccept           = savedConfig.autoSubmit
    local _submitAfter          = savedConfig.submitAfter
    local _capturedParts        = {}
    local _lastWatchedBox       = nil
    local _boxTextConn          = nil
    local _boxAncestryConn      = nil
    local _boxVisibilityConns   = {}
    local _spamRedeem           = savedConfig.spamRedeem
    local _lastNonBlankBoxText  = ""
    local ACE_CASE_MODE         = "EXACT"
    local ACE_WORD_COUNT        = 1

    local _programmaticChange = false
    local _manualSubmitDebounce = nil

    local _listenKeybind = savedConfig.listenKeybind or "V"
    local _listenInputConnection = nil
    local _capturingListenKey = false

    local _antiLagEnabled = savedConfig.antiLag
    local _antiLagDescendantConn = nil
    local _removeAccessoriesEnabled = savedConfig.removeAccessories
    local _accessoryConnection = nil

    local _antiRagdollEnabled = savedConfig.antiRagdoll
    local _ragdollConnection = nil
    local _ragdollCooldown = 0

    local _autoBuyEnabled = savedConfig.autoBuy
    local _autoBuyActive = false
    local _autoBuyRange = 17
    local _autoBuyKeybind = "K"
    local _autoBuyLockedTarget = nil
    local _autoBuyBodyPos = nil
    local _autoBuyCarpetConn = nil
    local _autoBuyRingPart = nil
    local _autoBuyPurchaseRemote = nil
    local _autoBuyConveyorCache = {}
    local _autoBuyBuyLoop = nil
    local _autoBuyScanLoop = nil
    local _autoBuyRingUpdateConn = nil

    local HOVER_HEIGHT = 5
    local BUY_INTERVAL = 0.08

    local function autoBuyCreateRing()
        if _autoBuyRingPart then _autoBuyRingPart:Destroy() end
        local r = Instance.new("Part")
        r.Name = "DZAutoBuyRing"
        r.Shape = Enum.PartType.Cylinder
        r.Anchored = true
        r.CanCollide = false
        r.CanTouch = false
        r.CanQuery = false
        r.CastShadow = false
        r.Material = Enum.Material.Neon
        r.Transparency = 0.5
        r.Color = Color3.fromRGB(255, 255, 255)
        r.Size = Vector3.new(0.5, _autoBuyRange * 2, _autoBuyRange * 2)
        r.Parent = Workspace
        _autoBuyRingPart = r
    end

    local function autoBuyDestroyRing()
        if _autoBuyRingPart then _autoBuyRingPart:Destroy(); _autoBuyRingPart = nil end
    end

    local function autoBuyEquipCarpet()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local toolName = "Flying Carpet"
        if not char:FindFirstChild(toolName) then
            local tool = player.Backpack:FindFirstChild(toolName)
            if tool then hum:EquipTool(tool) end
        end
    end

    local function autoBuyStartCarpetLock()
        if _autoBuyCarpetConn then _autoBuyCarpetConn:Disconnect() end
        _autoBuyCarpetConn = RunService.Heartbeat:Connect(function()
            if _autoBuyActive then autoBuyEquipCarpet() end
        end)
        autoBuyEquipCarpet()
    end

    local function autoBuyStopCarpetLock()
        if _autoBuyCarpetConn then _autoBuyCarpetConn:Disconnect(); _autoBuyCarpetConn = nil end
    end

    local function autoBuyEnsureBodyPos(hrp)
        if _autoBuyBodyPos and _autoBuyBodyPos.Parent == hrp then return _autoBuyBodyPos end
        if _autoBuyBodyPos then _autoBuyBodyPos:Destroy() end
        local bp = Instance.new("BodyPosition", hrp)
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 20000
        bp.D = 1000
        bp.Position = hrp.Position
        _autoBuyBodyPos = bp
        return bp
    end

    local function autoBuyDestroyBodyPos()
        if _autoBuyBodyPos then _autoBuyBodyPos:Destroy(); _autoBuyBodyPos = nil end
    end

    local function autoBuyResolveRemote()
        if _autoBuyPurchaseRemote and _autoBuyPurchaseRemote.Parent then return _autoBuyPurchaseRemote end
        pcall(function()
            local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net")
            if net then
                for _, v in ipairs(net:GetChildren()) do
                    local nl = (v.Name or ""):lower()
                    if nl:find("buy") or nl:find("purchase") or nl:find("acquire") then
                        _autoBuyPurchaseRemote = v; return
                    end
                end
            end
        end)
        return _autoBuyPurchaseRemote
    end

    local function autoBuyFirePurchase(prompt)
        if not prompt or not prompt.Parent or not prompt.Enabled then return end
        pcall(function()
            if fireproximityprompt then fireproximityprompt(prompt) end
        end)
        task.spawn(function()
            local remote = autoBuyResolveRemote()
            if remote then
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer(prompt.Parent)
                    elseif remote:IsA("RemoteEvent") then
                        remote:FireServer(prompt.Parent)
                    end
                end)
            end
        end)
    end

    local function autoBuyScanConveyor()
        local results = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local action = (obj.ActionText or ""):lower()
                if action:find("purchase") or action:find("buy") or action:find("comprar") then
                    local part = obj.Parent
                    if not part then continue end
                    local realPart = part:IsA("Attachment") and part.Parent or part
                    if not (realPart and realPart:IsA("BasePart")) then continue end
                    local model = nil
                    local cur = realPart
                    for _ = 1, 6 do
                        if cur and cur:IsA("Model") then model = cur; break end
                        cur = cur and cur.Parent
                    end
                    local name = "Brainrot"
                    if model then
                        for _, bb in ipairs(model:GetDescendants()) do
                            if bb:IsA("BillboardGui") then
                                for _, lbl in ipairs(bb:GetDescendants()) do
                                    if lbl:IsA("TextLabel") and lbl.Text and lbl.Text ~= "" then
                                        local t = lbl.Text:gsub("<[^>]+>", ""):match("^%s*(.-)%s*$")
                                        if t and #t > 1 and not t:match("^%$") and not t:match("/s$") and not t:match("^[%d%.]+") then
                                            name = t; break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    table.insert(results, {
                        prompt = obj,
                        part = realPart,
                        model = model,
                        name = name,
                    })
                end
            end
        end
        return results
    end

    local function autoBuyRefreshConveyor()
        local ok, found = pcall(autoBuyScanConveyor)
        if ok then _autoBuyConveyorCache = found end
    end

    local function autoBuyUpdate()
        if not _autoBuyActive then
            if _autoBuyLockedTarget then _autoBuyLockedTarget = nil end
            autoBuyDestroyBodyPos()
            autoBuyStopCarpetLock()
            return
        end

        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local radius = _autoBuyRange
        local best = nil
        local bestDist = math.huge
        for _, entry in ipairs(_autoBuyConveyorCache) do
            if entry.prompt and entry.prompt.Parent and entry.prompt.Enabled and entry.part and entry.part.Parent then
                local dist = (hrp.Position - entry.part.Position).Magnitude
                if dist <= radius and dist < bestDist then
                    bestDist = dist
                    best = entry
                end
            end
        end

        if best then
            if not _autoBuyLockedTarget or _autoBuyLockedTarget.prompt ~= best.prompt then
                _autoBuyLockedTarget = best
            end
            local targetPos = best.part.Position + Vector3.new(0, HOVER_HEIGHT, 0)
            local bp = autoBuyEnsureBodyPos(hrp)
            if bp then bp.Position = targetPos end
            autoBuyFirePurchase(best.prompt)
        else
            if _autoBuyLockedTarget then
                _autoBuyLockedTarget = nil
                autoBuyDestroyBodyPos()
            end
        end
    end

    local function autoBuyStart()
        if _autoBuyActive then return end
        _autoBuyActive = true
        savedConfig.autoBuy = true
        saveConfig()
        autoBuyCreateRing()
        autoBuyStartCarpetLock()
        autoBuyRefreshConveyor()
        if not _autoBuyBuyLoop then
            _autoBuyBuyLoop = task.spawn(function()
                while true do
                    task.wait(BUY_INTERVAL)
                    if _autoBuyActive then pcall(autoBuyUpdate) end
                end
            end)
        end
        if not _autoBuyScanLoop then
            _autoBuyScanLoop = task.spawn(function()
                while true do
                    task.wait(0.5)
                    if _autoBuyActive then pcall(autoBuyRefreshConveyor) end
                end
            end)
        end
        if not _autoBuyRingUpdateConn then
            _autoBuyRingUpdateConn = RunService.Heartbeat:Connect(function()
                if not _autoBuyActive then return end
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and _autoBuyRingPart then
                    _autoBuyRingPart.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90)) + Vector3.new(0, -2.5, 0)
                    local r = _autoBuyRange
                    if _autoBuyRingPart.Size.Y ~= r * 2 then
                        _autoBuyRingPart.Size = Vector3.new(0.5, r * 2, r * 2)
                    end
                end
            end)
        end
    end

    local function autoBuyStop()
        if not _autoBuyActive then return end
        _autoBuyActive = false
        savedConfig.autoBuy = false
        saveConfig()
        autoBuyDestroyRing()
        autoBuyStopCarpetLock()
        autoBuyDestroyBodyPos()
        _autoBuyLockedTarget = nil
        if _autoBuyBuyLoop then
            task.cancel(_autoBuyBuyLoop)
            _autoBuyBuyLoop = nil
        end
        if _autoBuyScanLoop then
            task.cancel(_autoBuyScanLoop)
            _autoBuyScanLoop = nil
        end
        if _autoBuyRingUpdateConn then
            _autoBuyRingUpdateConn:Disconnect()
            _autoBuyRingUpdateConn = nil
        end
    end

    local function toggleAutoBuy()
        if _autoBuyActive then
            autoBuyStop()
        else
            autoBuyStart()
        end
    end

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode[_autoBuyKeybind] then
            toggleAutoBuy()
        end
    end)

    player.CharacterAdded:Connect(function()
        if _autoBuyActive then
            task.wait(0.5)
            if _autoBuyActive then
                autoBuyStartCarpetLock()
                autoBuyCreateRing()
            end
        end
    end)


    local getupvalues = (debug and debug.getupvalues) or getupvalues
    local getconns    = getconnections or (debug and debug.getconnections)
    local setupv      = (debug and debug.setupvalue) or setupvalue

    local setStatus, flashCode, appendToBox
    local clearAceCapture
    local _lastStatusMsg = nil

    local function processDescendant(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") then
            obj.Enabled = false
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        end
        if _removeAccessoriesEnabled and (obj:IsA("Accessory") or obj:IsA("Hat")) then
            obj:Destroy()
        end
    end

    local function optimizeLighting()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9000000488
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end
        for _, obj in pairs(Workspace:GetDescendants()) do
            processDescendant(obj)
        end
    end

    local function removeAllAccessories()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                for _, obj in ipairs(plr.Character:GetDescendants()) do
                    if obj:IsA("Accessory") or obj:IsA("Hat") then
                        obj:Destroy()
                    end
                end
            end
        end
    end

    local function startAntiLag()
        if _antiLagEnabled then return end
        _antiLagEnabled = true
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        optimizeLighting()
        if _antiLagDescendantConn then _antiLagDescendantConn:Disconnect() end
        _antiLagDescendantConn = Workspace.DescendantAdded:Connect(processDescendant)
        if _removeAccessoriesEnabled then
            removeAllAccessories()
            if not _accessoryConnection then
                _accessoryConnection = Players.PlayerAdded:Connect(function(plr)
                    plr.CharacterAdded:Connect(function(char)
                        task.wait(0.5)
                        if _removeAccessoriesEnabled then
                            for _, obj in ipairs(char:GetDescendants()) do
                                if obj:IsA("Accessory") or obj:IsA("Hat") then
                                    obj:Destroy()
                                end
                            end
                        end
                    end)
                end)
            end
        end
    end

    local function stopAntiLag()
        _antiLagEnabled = false
        if _antiLagDescendantConn then
            _antiLagDescendantConn:Disconnect()
            _antiLagDescendantConn = nil
        end
    end

    local function startRemoveAccessories()
        if _removeAccessoriesEnabled then return end
        _removeAccessoriesEnabled = true
        removeAllAccessories()
        if not _accessoryConnection then
            _accessoryConnection = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if _removeAccessoriesEnabled then
                        for _, obj in ipairs(char:GetDescendants()) do
                            if obj:IsA("Accessory") or obj:IsA("Hat") then
                                obj:Destroy()
                            end
                        end
                    end
                end)
            end)
        end
        if not _antiLagEnabled then
            if _antiLagDescendantConn then _antiLagDescendantConn:Disconnect() end
            _antiLagDescendantConn = Workspace.DescendantAdded:Connect(processDescendant)
        end
    end

    local function stopRemoveAccessories()
        _removeAccessoriesEnabled = false
        if _accessoryConnection then
            _accessoryConnection:Disconnect()
            _accessoryConnection = nil
        end
        if not _antiLagEnabled and _antiLagDescendantConn then
            _antiLagDescendantConn:Disconnect()
            _antiLagDescendantConn = nil
        end
    end

    local function forceReset()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then return end

        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero

            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") then obj.Enabled = true end
                if obj:IsA("Constraint") then obj.Enabled = true end
            end

            workspace.CurrentCamera.CameraSubject = hum

            local PM = player.PlayerScripts:FindFirstChild("PlayerModule")
            if PM then
                local CM = require(PM:FindFirstChild("ControlModule"))
                if CM then CM:Enable() end
            end

            hum.AutoRotate = true
            hum.PlatformStand = false
            hum.Sit = false
        end)
    end

    local function startAntiRagdoll()
        if _ragdollConnection then return end
        _antiRagdollEnabled = true
        _ragdollConnection = RunService.Heartbeat:Connect(function()
            if not _antiRagdollEnabled then return end
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end

            local state = hum:GetState()
            local isRagdolled = (state == Enum.HumanoidStateType.Physics or
                                 state == Enum.HumanoidStateType.Ragdoll or
                                 state == Enum.HumanoidStateType.FallingDown)

            if isRagdolled then
                local now = tick()
                if now - _ragdollCooldown > 0.15 then
                    _ragdollCooldown = now
                    forceReset()
                end
            end
        end)
    end

    local function stopAntiRagdoll()
        _antiRagdollEnabled = false
        if _ragdollConnection then
            _ragdollConnection:Disconnect()
            _ragdollConnection = nil
        end
    end

    local function isOurGui(instance)
        local p = instance
        for _ = 1, 10 do
            if not p then break end
            if p.Name == "ACECodeSniperUI" or p.Name == "SourcesHubRedeemerGui" or p.Name == "ACESettingsUI" then return true end
            p = p.Parent
        end
        return false
    end

    local function isVisibleChain(inst)
        local current = inst
        while current do
            if current:IsA("GuiObject") and not current.Visible then return false end
            if current:IsA("ScreenGui") then return current.Enabled end
            current = current.Parent
        end
        return true
    end

    local function findAllTextBoxes(pg)
        local boxes = {}
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and not isOurGui(gui) then
                for _, d in ipairs(gui:GetDescendants()) do
                    if d:IsA("TextBox") and not isOurGui(d) then
                        boxes[#boxes+1] = d
                    end
                end
            end
        end
        return boxes
    end

    local function findCodeButtons(pg)
        local btns = {}
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and not isOurGui(gui) then
                for _, d in ipairs(gui:GetDescendants()) do
                    if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
                        local n  = d.Name:lower()
                        local pn = (d.Parent and d.Parent.Name or ""):lower()
                        if (n:find("code") or n:find("redeem") or pn:find("code") or pn:find("redeem"))
                            and isVisibleChain(d) then
                            btns[#btns+1] = d
                        end
                    end
                end
            end
        end
        return btns
    end

    local function clickButton(btn)
        if not btn then return false end
        local methods = {}
        
        methods[#methods+1] = function() btn.MouseButton1Click:Fire() end
        methods[#methods+1] = function() btn.Activated:Fire() end
        
        if typeof(firesignal) == "function" then
            methods[#methods+1] = function() firesignal(btn.MouseButton1Click) end
            methods[#methods+1] = function() firesignal(btn.Activated) end
        end
        
        if typeof(getconns) == "function" then
            methods[#methods+1] = function()
                local ok, cs = pcall(getconns, btn.MouseButton1Click)
                if ok and type(cs) == "table" then
                    for _, c in ipairs(cs) do pcall(function() c:Fire() end) end
                end
                local ok2, cs2 = pcall(getconns, btn.Activated)
                if ok2 and type(cs2) == "table" then
                    for _, c in ipairs(cs2) do pcall(function() c:Fire() end) end
                end
            end
        end
        
        if typeof(fireclick) == "function" then
            methods[#methods+1] = function() fireclick(btn) end
        end
        
        local anyOk = false
        for _, fn in ipairs(methods) do
            local ok = pcall(fn)
            anyOk = anyOk or ok
        end
        return anyOk
    end

    local function fireBoxFocusLost(box)
        if not box then return false end
        local anyFired = false
        
        if typeof(firesignal) == "function" then
            local ok = pcall(firesignal, box.FocusLost, true)
            anyFired = anyFired or ok
        end
        
        if typeof(getconns) == "function" then
            local ok, cs = pcall(getconns, box.FocusLost)
            if ok and type(cs) == "table" then
                for _, c in ipairs(cs) do
                    local fn
                    pcall(function() fn = c.Function end)
                    if fn and typeof(getupvalues) == "function" and typeof(setupv) == "function" then
                        local uOk, ups = pcall(getupvalues, fn)
                        if uOk and type(ups) == "table" then
                            for i, v in pairs(ups) do
                                if type(v) == "boolean" and v == true then
                                    pcall(setupv, fn, i, false)
                                end
                            end
                        end
                    end
                    local fOk = pcall(function()
                        if c.Enabled ~= false then c:Fire(true) end
                    end)
                    anyFired = anyFired or fOk
                end
            end
        end
        
        return anyFired
    end

    local function typeAndSubmitCode(code)
        local pg = playerGui or player:FindFirstChildOfClass("PlayerGui")
        if not pg then return false, "no PlayerGui" end

        local codesGui = pg:FindFirstChild("Codes")
        if codesGui then
            if codesGui:IsA("ScreenGui") then codesGui.Enabled = true end
            local codesFrame = codesGui:FindFirstChild("Codes") or codesGui
            if codesFrame then
                if codesFrame:IsA("GuiObject") then codesFrame.Visible = true end
                local cur = codesFrame
                while cur and cur ~= codesGui do
                    if cur:IsA("GuiObject") then cur.Visible = true end
                    cur = cur.Parent
                end

                local box = nil
                for _, d in ipairs(codesFrame:GetDescendants()) do
                    if d:IsA("TextBox") and not isOurGui(d) then
                        box = d
                        break
                    end
                end

                local submitBtn = nil
                for _, d in ipairs(codesFrame:GetDescendants()) do
                    if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
                        local n = d.Name:lower()
                        local txt = ""
                        pcall(function() txt = d.Text:lower() end)
                        if n:find("submit") or txt:find("submit") or n:find("redeem") or txt:find("redeem") or n:find("claim") or txt:find("confirm") or n:find("enter") then
                            submitBtn = d
                            break
                        end
                    end
                end
                if not submitBtn then
                    for _, d in ipairs(codesFrame:GetDescendants()) do
                        if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
                            local n = d.Name:lower()
                            if not n:find("close") and not n:find("x") and not n:find("toggle") then
                                submitBtn = d
                                break
                            end
                        end
                    end
                end

                if box then
                    pcall(function() box.Text = code end)
                    if submitBtn then
                        if _spamRedeem then
                            for i = 1, 20 do
                                clickButton(submitBtn)
                                task.wait(0.05)
                            end
                        else
                            clickButton(submitBtn)
                        end
                    end
                    fireBoxFocusLost(box)
                    return true, "submitted via PlayerGui.Codes"
                end
            end
        end

        local btns = findCodeButtons(pg)
        for _, btn in ipairs(btns) do
            clickButton(btn)
            task.wait(0)
        end

        local box = nil
        local deadline = tick() + 2
        while tick() < deadline do
            local allBoxes = findAllTextBoxes(pg)
            for _, d in ipairs(allBoxes) do
                if isVisibleChain(d) then
                    local n  = d.Name:lower()
                    local pn = (d.Parent and d.Parent.Name or ""):lower()
                    if n:find("code") or pn:find("code") or n:find("redeem") or pn:find("redeem") or n:find("input") or pn:find("textbox") or n:find("enter") then
                        box = d
                        break
                    end
                end
            end
            if not box then
                for _, d in ipairs(allBoxes) do
                    if isVisibleChain(d) then box = d; break end
                end
            end
            if box then break end
            task.wait()
        end

        if not box then return false, "no codebox visible" end

        pcall(function() box.Text = code end)
        local redeemBtn = nil
        local searchNames = {"submit","redeem","claim","confirm","enter","send","apply","ok","use","go","check"}
        local p = box.Parent
        for _ = 1, 8 do
            if not p then break end
            for _, d in ipairs(p:GetDescendants()) do
                if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) and d ~= box then
                    local n = d.Name:lower()
                    local txt = ""
                    pcall(function() txt = d.Text:lower() end)
                    for _, sn in ipairs(searchNames) do
                        if n:find(sn) or txt:find(sn) then
                            if isVisibleChain(d) then
                                redeemBtn = d
                                break
                            end
                        end
                    end
                    if redeemBtn then break end
                end
            end
            if redeemBtn then break end
            p = p.Parent
        end

        if redeemBtn then
            if _spamRedeem then
                for i = 1, 20 do
                    clickButton(redeemBtn)
                    task.wait(0.05)
                end
            else
                clickButton(redeemBtn)
            end
        end
        fireBoxFocusLost(box)

        return true, "submitted via dynamic search"
    end

    local function aceCodeBox()
        local pg = playerGui
        local allBoxes = findAllTextBoxes(pg)
        for _, box in ipairs(allBoxes) do
            if isVisibleChain(box) then return box end
        end
        return nil
    end

    local COLORS = {
        Window = Color3.fromRGB(3, 3, 4),
        Row = Color3.fromRGB(12, 12, 14),
        Control = Color3.fromRGB(34, 34, 38),
        Log = Color3.fromRGB(5, 5, 7),
        Border = Color3.fromRGB(150, 150, 155),
        White = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(225, 225, 230),
        Dim = Color3.fromRGB(145, 145, 152),
        Accent = Color3.fromRGB(235, 235, 240),
        Green = Color3.fromRGB(220, 220, 225),
        Red = Color3.fromRGB(125, 125, 132),
        Purple = Color3.fromRGB(205, 205, 212),
    }

    local function addCorner(parent, radius)
        local value = Instance.new("UICorner")
        value.CornerRadius = UDim.new(0, radius)
        value.Parent = parent
        return value
    end

    local ELECTRIC_GRADIENTS = {}
    local function addStroke(parent, color, thickness, transparency)
        local value = Instance.new("UIStroke")
        value.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        value.Color = Color3.fromRGB(255, 255, 255)
        value.Thickness = thickness or 1
        value.Transparency = transparency or 0
        value.Parent = parent

        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.22, Color3.fromRGB(95, 95, 102)),
            ColorSequenceKeypoint.new(0.48, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.72, Color3.fromRGB(75, 75, 82)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)),
        })
        gradient.Parent = value
        table.insert(ELECTRIC_GRADIENTS, gradient)
        return value
    end

    -- Movimiento eléctrico blanco/negro en los bordes, sin alterar funciones.
    RunService.RenderStepped:Connect(function(deltaTime)
        for i = #ELECTRIC_GRADIENTS, 1, -1 do
            local gradient = ELECTRIC_GRADIENTS[i]
            if gradient and gradient.Parent then
                gradient.Rotation = (gradient.Rotation + deltaTime * 105) % 360
            else
                table.remove(ELECTRIC_GRADIENTS, i)
            end
        end
    end)

    local function makeLabel(parent, name, text, size, position, textSize, color, font)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = size
        label.Position = position
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextSize = textSize
        label.TextColor3 = color
        label.Font = font or Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = parent
        return label
    end

    pcall(function()
        for _, name in ipairs({"ACECodeSniperUI", "ACESettingsUI", "AutoTypeCodesUI", "ACEPaste"}) do
            local previous = game.CoreGui:FindFirstChild(name)
            if previous then previous:Destroy() end
        end
    end)
    for _, name in ipairs({"ACECodeSniperUI", "ACESettingsUI", "AutoTypeCodesUI", "ACEPaste"}) do
        local previous = playerGui:FindFirstChild(name)
        if previous then previous:Destroy() end
    end

    local HeadBillboard = nil
    local function createHeadDisplay()
        if HeadBillboard then
            pcall(function() HeadBillboard:Destroy() end)
            HeadBillboard = nil
        end

        local char = player.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end

        local bill = Instance.new("BillboardGui")
        bill.Name = "ACECodeSniperHeadDisplay"
        bill.Adornee = head
        bill.Size = UDim2.new(0, 200, 0, 30)
        bill.StudsOffset = Vector3.new(0, 2.5, 0)
        bill.MaxDistance = 100
        bill.AlwaysOnTop = true
        bill.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "discord.gg/27x8UVAbQz"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 18
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = bill

        HeadBillboard = bill
    end

    local function updateHeadDisplay()
        if HeadBillboard then
            pcall(function() HeadBillboard:Destroy() end)
            HeadBillboard = nil
        end
        createHeadDisplay()
    end

    player.CharacterAdded:Connect(updateHeadDisplay)
    updateHeadDisplay()

    local GUI = Instance.new("ScreenGui")
    GUI.Name = "ACECodeSniperUI"
    GUI.ResetOnSpawn = false
    GUI.IgnoreGuiInset = true
    GUI.DisplayOrder = 999
    if not pcall(function() GUI.Parent = game.CoreGui end) then GUI.Parent = playerGui end

    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = UDim2.fromOffset(280, 280)   
    Window.AnchorPoint = Vector2.new(1, 0)
    Window.Position = UDim2.new(1, -8, 0, 8)
    Window.BackgroundColor3 = COLORS.Window
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent = GUI
    addCorner(Window, 14)
    addStroke(Window, COLORS.White, 2, 0)

    local InterfaceScale = Instance.new("UIScale")
    InterfaceScale.Name = "InterfaceScale"
    InterfaceScale.Scale = 0.92
    InterfaceScale.Parent = Window

    local viewportConnection
    local function updateInterfaceScale()
        local camera = workspace.CurrentCamera
        if not camera then InterfaceScale.Scale = 0.92; return end
        local viewport = camera.ViewportSize
        local fitScale = math.min((viewport.X - 16) / 280, (viewport.Y - 16) / 280)
        if UserInputService.TouchEnabled then
            local mobileTarget = 0.72
            InterfaceScale.Scale = math.max(0.45, math.min(mobileTarget, fitScale))
        else
            InterfaceScale.Scale = 0.92
        end
    end

    local function watchViewport()
        if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
        local camera = workspace.CurrentCamera
        if camera then viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateInterfaceScale) end
        updateInterfaceScale()
    end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchViewport)
    watchViewport()

    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Name = "ACEBackground"
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.Position = UDim2.fromOffset(0, 0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Image = "rbxassetid://97803827151139"
    BackgroundImage.ImageTransparency = 0
    BackgroundImage.ScaleType = Enum.ScaleType.Stretch
    BackgroundImage.ZIndex = 1
    BackgroundImage.Parent = Window
    addCorner(BackgroundImage, 14)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundTransparency = 1
    Header.Active = true
    Header.ZIndex = 3
    Header.Parent = Window

    local Console, ConsoleOutput, updateConsoleCanvas
    local CONSOLE_COLORS = {
        Dim = "rgb(145,145,152)",
        Amber = "rgb(220,220,225)",
        Green = "rgb(235,235,240)",
        Red = "rgb(125,125,132)",
        Cyan = "rgb(205,205,212)",
    }

    local function scrollConsoleToBottom()
        task.defer(function()
            task.wait()
            if not Console then return end
            if updateConsoleCanvas then updateConsoleCanvas() end
            local bottom = math.max(0, Console.AbsoluteCanvasSize.Y - Console.AbsoluteWindowSize.Y)
            Console.CanvasPosition = Vector2.new(0, bottom)
        end)
    end

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.Size = UDim2.fromOffset(36, 36)
    AvatarImage.Position = UDim2.fromOffset(8, 12)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.ZIndex = 3
    AvatarImage.Parent = Header
    addCorner(AvatarImage, 18)

    pcall(function()
        local thumb = player:GetUserThumbnailAsync(Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
        if thumb and thumb ~= "" then
            AvatarImage.Image = thumb
        end
    end)

    local Title = makeLabel(Header, "Title", "Weekly Sniper", UDim2.fromOffset(130, 30), UDim2.fromOffset(8, 8), 22, Color3.fromRGB(235, 235, 240), Enum.Font.GothamBold)
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local GearButton = Instance.new("TextButton")
    GearButton.Name = "GearButton"
    GearButton.Size = UDim2.fromOffset(28, 28)
    GearButton.Position = UDim2.fromOffset(190, 14)
    GearButton.BackgroundTransparency = 1
    GearButton.Text = "⚙️"
    GearButton.TextSize = 28                     
    GearButton.TextColor3 = Color3.fromRGB(255, 255, 255)  
    GearButton.Font = Enum.Font.GothamBold
    GearButton.ZIndex = 5
    GearButton.Parent = Header

    local StatusDot = Instance.new("Frame")
    StatusDot.Name = "StatusDot"
    StatusDot.Size = UDim2.fromOffset(10, 10)
    StatusDot.Position = UDim2.new(1, -45, 0, 24)
    StatusDot.BorderSizePixel = 0          
    StatusDot.BackgroundTransparency = 0   
    StatusDot.ZIndex = 4
    StatusDot.Parent = Header
    addCorner(StatusDot, 5)                

    local function updateStatusDot()
        if _enabled then
            StatusDot.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
        else
            StatusDot.BackgroundColor3 = Color3.fromRGB(105, 105, 112)
        end
    end
    updateStatusDot()

    Console = Instance.new("ScrollingFrame")
    Console.Name = "Console"
    Console.Size = UDim2.new(1, -20, 0, 45)
    Console.Position = UDim2.fromOffset(10, 70)
    Console.BackgroundColor3 = COLORS.Log
    Console.BorderSizePixel = 0
    Console.ClipsDescendants = true
    Console.Active = true
    Console.ScrollingEnabled = true
    Console.ScrollingDirection = Enum.ScrollingDirection.Y
    Console.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    Console.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    Console.CanvasSize = UDim2.new(0, 0, 0, 0)
    Console.AutomaticCanvasSize = Enum.AutomaticSize.None
    Console.ScrollBarThickness = 4
    Console.ScrollBarImageColor3 = COLORS.Dim
    Console.ZIndex = 3
    Console.Parent = Window
    addCorner(Console, 9)
    addStroke(Console, COLORS.Border, 1, 0.3)

    ConsoleOutput = Instance.new("TextLabel")
    ConsoleOutput.Name = "ConsoleOutput"
    ConsoleOutput.Size = UDim2.new(1, -18, 0, 90)
    ConsoleOutput.AutomaticSize = Enum.AutomaticSize.Y
    ConsoleOutput.Position = UDim2.fromOffset(9, 4)
    ConsoleOutput.BackgroundTransparency = 1
    ConsoleOutput.RichText = true
    if _enabled then
        ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Green .. '">Listening for codes</font>'
    else
        ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Red .. '">Off</font>'
    end
    ConsoleOutput.TextSize = 14
    ConsoleOutput.Font = Enum.Font.GothamMedium
    ConsoleOutput.TextColor3 = COLORS.Dim
    ConsoleOutput.TextXAlignment = Enum.TextXAlignment.Left
    ConsoleOutput.TextYAlignment = Enum.TextYAlignment.Top
    ConsoleOutput.TextWrapped = true
    ConsoleOutput.ZIndex = 4
    ConsoleOutput.Parent = Console

    local CONSOLE_BOTTOM_PADDING = 20
    updateConsoleCanvas = function()
        if not Console or not ConsoleOutput then return end
        local contentHeight = ConsoleOutput.Position.Y.Offset + ConsoleOutput.AbsoluteSize.Y + CONSOLE_BOTTOM_PADDING
        Console.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    end
    ConsoleOutput:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateConsoleCanvas)
    task.defer(updateConsoleCanvas)

    local function flashButtonPurple(button)
        local originalColor = button.BackgroundColor3
        button.BackgroundColor3 = COLORS.Purple
        task.delay(0.15, function()
            if button and button.Parent then
                button.BackgroundColor3 = originalColor
            end
        end)
    end

    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = "ButtonFrame"
    ButtonFrame.Size = UDim2.new(1, -20, 0, 36)
    ButtonFrame.Position = UDim2.fromOffset(10, 120)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = Window

    local buttonWidth = 80
    local buttonHeight = 28
    local rowY = 4

    local ClearLogsBtn = Instance.new("TextButton")
    ClearLogsBtn.Name = "ClearLogsBtn"
    ClearLogsBtn.Size = UDim2.fromOffset(buttonWidth, buttonHeight)
    ClearLogsBtn.Position = UDim2.fromOffset(0, rowY)
    ClearLogsBtn.BackgroundColor3 = COLORS.Control
    ClearLogsBtn.BorderSizePixel = 0
    ClearLogsBtn.AutoButtonColor = false
    ClearLogsBtn.Text = "Clear"
    ClearLogsBtn.TextSize = 13
    ClearLogsBtn.TextColor3 = COLORS.Text
    ClearLogsBtn.Font = Enum.Font.GothamBold
    ClearLogsBtn.ZIndex = 5
    ClearLogsBtn.Parent = ButtonFrame
    addCorner(ClearLogsBtn, 6)
    addStroke(ClearLogsBtn, COLORS.Border, 1, 0.5)
    ClearLogsBtn.Activated:Connect(function()
        flashButtonPurple(ClearLogsBtn)
        if _enabled then
            ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Green .. '">Listening for codes</font>'
        else
            ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Red .. '">Off</font>'
        end
    end)

    local RedeemBtn = Instance.new("TextButton")
    RedeemBtn.Name = "RedeemBtn"
    RedeemBtn.Size = UDim2.fromOffset(buttonWidth, buttonHeight)
    RedeemBtn.Position = UDim2.new(0.5, -buttonWidth/2, 0, rowY)
    RedeemBtn.BackgroundColor3 = COLORS.Accent
    RedeemBtn.BorderSizePixel = 0
    RedeemBtn.AutoButtonColor = false
    RedeemBtn.Text = "Redeem"
    RedeemBtn.TextSize = 13
    RedeemBtn.TextColor3 = COLORS.Window
    RedeemBtn.Font = Enum.Font.GothamBold
    RedeemBtn.ZIndex = 5
    RedeemBtn.Parent = ButtonFrame
    addCorner(RedeemBtn, 6)
    addStroke(RedeemBtn, COLORS.White, 1, 0.3)
    RedeemBtn.Activated:Connect(function()
        flashButtonPurple(RedeemBtn)
        local box = aceCodeBox()
        if box and box.Text ~= "" then
            local code = box.Text
            local ok, statusMsg = typeAndSubmitCode(code)
            if ok then
                setStatus("Code redeemed (" .. code .. ")", COLORS.Green)
            else
                setStatus("Failed: " .. tostring(statusMsg), COLORS.Red)
            end
        else
            setStatus("No code to redeem", COLORS.Red)
        end
    end)

    local CopyCodeBtn = Instance.new("TextButton")
    CopyCodeBtn.Name = "CopyCodeBtn"
    CopyCodeBtn.Size = UDim2.fromOffset(buttonWidth, buttonHeight)
    CopyCodeBtn.Position = UDim2.new(1, -buttonWidth, 0, rowY)
    CopyCodeBtn.BackgroundColor3 = COLORS.Control
    CopyCodeBtn.BorderSizePixel = 0
    CopyCodeBtn.AutoButtonColor = false
    CopyCodeBtn.Text = "Copy"
    CopyCodeBtn.TextSize = 13
    CopyCodeBtn.TextColor3 = COLORS.Text
    CopyCodeBtn.Font = Enum.Font.GothamBold
    CopyCodeBtn.ZIndex = 5
    CopyCodeBtn.Parent = ButtonFrame
    addCorner(CopyCodeBtn, 6)
    addStroke(CopyCodeBtn, COLORS.Border, 1, 0.5)
    CopyCodeBtn.Activated:Connect(function()
        flashButtonPurple(CopyCodeBtn)
        local box = aceCodeBox()
        if box and box.Text ~= "" then
            local code = box.Text
            if setclipboard then
                pcall(function() setclipboard(code) end)
                setStatus("Copied: " .. code, COLORS.Green)
            elseif toclipboard then
                pcall(function() toclipboard(code) end)
                setStatus("Copied: " .. code, COLORS.Green)
            else
                setStatus("Copy not supported", COLORS.Red)
            end
        else
            setStatus("No code to copy", COLORS.Red)
        end
    end)

    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.Size = UDim2.new(1, -20, 0, 112)
    SettingsFrame.Position = UDim2.fromOffset(10, 162)
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.BorderSizePixel = 0
    SettingsFrame.Parent = Window

    local autoCard = Instance.new("Frame")
    autoCard.Size = UDim2.new(1, 0, 0, 26)
    autoCard.Position = UDim2.fromOffset(0, 2)
    autoCard.BackgroundTransparency = 1
    autoCard.Parent = SettingsFrame
    makeLabel(autoCard, "Title", "Auto submit", UDim2.fromOffset(130, 26), UDim2.fromOffset(8, 0), 16, COLORS.White, Enum.Font.GothamBold)
    local autoSubmitBtn = Instance.new("TextButton")
    autoSubmitBtn.Name = "AutoSubmitBtn"
    autoSubmitBtn.Size = UDim2.fromOffset(50, 24)
    autoSubmitBtn.Position = UDim2.new(1, -56, 0.5, -12)
    autoSubmitBtn.BackgroundColor3 = _autoAccept and COLORS.Accent or COLORS.Control
    autoSubmitBtn.BorderSizePixel = 0
    autoSubmitBtn.AutoButtonColor = false
    autoSubmitBtn.Active = true
    autoSubmitBtn.Text = _autoAccept and "ON" or "OFF"
    autoSubmitBtn.TextSize = 12
    autoSubmitBtn.TextColor3 = _autoAccept and COLORS.Window or COLORS.Dim
    autoSubmitBtn.Font = Enum.Font.GothamBold
    autoSubmitBtn.ZIndex = 5
    autoSubmitBtn.Parent = autoCard
    addCorner(autoSubmitBtn, 6)
    local autoSubmitStroke = addStroke(autoSubmitBtn, COLORS.White, 1, _autoAccept and 0.62 or 0.88)
    autoSubmitBtn.Activated:Connect(function()
        _autoAccept = not _autoAccept
        savedConfig.autoSubmit = _autoAccept
        saveConfig()
        autoSubmitBtn.Text = _autoAccept and "ON" or "OFF"
        autoSubmitBtn.BackgroundColor3 = _autoAccept and COLORS.Accent or COLORS.Control
        autoSubmitBtn.TextColor3 = _autoAccept and COLORS.Window or COLORS.Dim
        autoSubmitStroke.Transparency = _autoAccept and 0.62 or 0.88
    end)

    local delayCard = Instance.new("Frame")
    delayCard.Size = UDim2.new(1, 0, 0, 26)
    delayCard.Position = UDim2.fromOffset(0, 30)
    delayCard.BackgroundTransparency = 1
    delayCard.Parent = SettingsFrame
    makeLabel(delayCard, "Title", "Submit after", UDim2.fromOffset(130, 26), UDim2.fromOffset(8, 0), 16, COLORS.White, Enum.Font.GothamBold)
    local CounterShell = Instance.new("Frame")
    CounterShell.Name = "Counter"
    CounterShell.Size = UDim2.fromOffset(90, 24)
    CounterShell.Position = UDim2.new(1, -100, 0.5, -12)
    CounterShell.BackgroundColor3 = COLORS.Window
    CounterShell.BackgroundTransparency = 0.05
    CounterShell.BorderSizePixel = 0
    CounterShell.Parent = delayCard
    CounterShell.ZIndex = 2
    addCorner(CounterShell, 6)
    addStroke(CounterShell, COLORS.Border, 1, 0.5)
    local Minus = Instance.new("TextButton")
    Minus.Name = "Minus"
    Minus.Size = UDim2.fromOffset(22, 22)
    Minus.Position = UDim2.fromOffset(2, 1)
    Minus.BackgroundColor3 = COLORS.Control
    Minus.BorderSizePixel = 0
    Minus.AutoButtonColor = false
    Minus.Active = true
    Minus.Text = "-"
    Minus.TextSize = 16
    Minus.TextColor3 = COLORS.Text
    Minus.Font = Enum.Font.GothamBold
    Minus.Parent = CounterShell
    Minus.ZIndex = 3
    addCorner(Minus, 4)
    local Count = makeLabel(CounterShell, "Count", tostring(_submitAfter), UDim2.fromOffset(24, 22), UDim2.fromOffset(34, 1), 16, COLORS.White, Enum.Font.GothamBold)
    Count.TextXAlignment = Enum.TextXAlignment.Center
    Count.ZIndex = 3
    local Plus = Instance.new("TextButton")
    Plus.Name = "Plus"
    Plus.Size = UDim2.fromOffset(22, 22)
    Plus.Position = UDim2.fromOffset(66, 1)
    Plus.BackgroundColor3 = COLORS.Control
    Plus.BorderSizePixel = 0
    Plus.AutoButtonColor = false
    Plus.Active = true
    Plus.Text = "+"
    Plus.TextSize = 16
    Plus.TextColor3 = COLORS.Text
    Plus.Font = Enum.Font.GothamBold
    Plus.Parent = CounterShell
    Plus.ZIndex = 3
    addCorner(Plus, 4)
    local lastStepTime = 0
    local function decr()
        local now = os.clock()
        if now - lastStepTime < 0.05 then return end
        lastStepTime = now
        _submitAfter = math.clamp(_submitAfter - 1, 1, 10)
        Count.Text = tostring(_submitAfter)
        savedConfig.submitAfter = _submitAfter
        clearAceCapture()
        saveConfig()
    end
    local function incr()
        local now = os.clock()
        if now - lastStepTime < 0.05 then return end
        lastStepTime = now
        _submitAfter = math.clamp(_submitAfter + 1, 1, 10)
        Count.Text = tostring(_submitAfter)
        savedConfig.submitAfter = _submitAfter
        clearAceCapture()
        saveConfig()
    end
    Minus.Activated:Connect(decr)
    Plus.Activated:Connect(incr)

    local listenCard = Instance.new("Frame")
    listenCard.Size = UDim2.new(1, 0, 0, 26)
    listenCard.Position = UDim2.fromOffset(0, 58)
    listenCard.BackgroundTransparency = 1
    listenCard.Parent = SettingsFrame
    makeLabel(listenCard, "Title", "Listen", UDim2.fromOffset(130, 26), UDim2.fromOffset(8, 0), 16, COLORS.White, Enum.Font.GothamBold)
    local listenBtn = Instance.new("TextButton")
    listenBtn.Name = "ListenBtn"
    listenBtn.Size = UDim2.fromOffset(50, 24)
    listenBtn.Position = UDim2.new(1, -56, 0.5, -12)
    listenBtn.BackgroundColor3 = _enabled and COLORS.Accent or COLORS.Control
    listenBtn.BorderSizePixel = 0
    listenBtn.AutoButtonColor = false
    listenBtn.Active = true
    listenBtn.Text = _enabled and "ON" or "OFF"
    listenBtn.TextSize = 12
    listenBtn.TextColor3 = _enabled and COLORS.Window or COLORS.Dim
    listenBtn.Font = Enum.Font.GothamBold
    listenBtn.ZIndex = 5
    listenBtn.Parent = listenCard
    addCorner(listenBtn, 6)
    local listenStroke = addStroke(listenBtn, COLORS.White, 1, _enabled and 0.62 or 0.88)
    listenBtn.Activated:Connect(function()
        _enabled = not _enabled
        savedConfig.codeSniper = _enabled
        saveConfig()
        listenBtn.Text = _enabled and "ON" or "OFF"
        listenBtn.BackgroundColor3 = _enabled and COLORS.Accent or COLORS.Control
        listenBtn.TextColor3 = _enabled and COLORS.Window or COLORS.Dim
        listenStroke.Transparency = _enabled and 0.62 or 0.88
        updateStatusDot()
        if _enabled then
            ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Green .. '">Listening for codes</font>'
        else
            ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Red .. '">Off</font>'
        end
        task.defer(updateConsoleCanvas)
    end)

    local spamCard = Instance.new("Frame")
    spamCard.Size = UDim2.new(1, 0, 0, 26)
    spamCard.Position = UDim2.fromOffset(0, 86)
    spamCard.BackgroundTransparency = 1
    spamCard.Parent = SettingsFrame
    makeLabel(spamCard, "Title", "Spam redeem", UDim2.fromOffset(130, 26), UDim2.fromOffset(8, 0), 16, COLORS.White, Enum.Font.GothamBold)
    local spamBtn = Instance.new("TextButton")
    spamBtn.Name = "SpamBtn"
    spamBtn.Size = UDim2.fromOffset(50, 24)
    spamBtn.Position = UDim2.new(1, -56, 0.5, -12)
    spamBtn.BackgroundColor3 = _spamRedeem and COLORS.Accent or COLORS.Control
    spamBtn.BorderSizePixel = 0
    spamBtn.AutoButtonColor = false
    spamBtn.Active = true
    spamBtn.Text = _spamRedeem and "ON" or "OFF"
    spamBtn.TextSize = 12
    spamBtn.TextColor3 = _spamRedeem and COLORS.Window or COLORS.Dim
    spamBtn.Font = Enum.Font.GothamBold
    spamBtn.ZIndex = 5
    spamBtn.Parent = spamCard
    addCorner(spamBtn, 6)
    local spamStroke = addStroke(spamBtn, COLORS.White, 1, _spamRedeem and 0.62 or 0.88)
    spamBtn.Activated:Connect(function()
        _spamRedeem = not _spamRedeem
        savedConfig.spamRedeem = _spamRedeem
        saveConfig()
        spamBtn.Text = _spamRedeem and "ON" or "OFF"
        spamBtn.BackgroundColor3 = _spamRedeem and COLORS.Accent or COLORS.Control
        spamBtn.TextColor3 = _spamRedeem and COLORS.Window or COLORS.Dim
        spamStroke.Transparency = _spamRedeem and 0.62 or 0.88
    end)

    do
        local dragging = false
        local activeDragInput
        local dragStart
        local startPosition
        local dragMoved = false
        local DRAG_THRESHOLD = UserInputService.TouchEnabled and 10 or 3

        local function isOverHeaderControl(position)
            local gearPos = GearButton.AbsolutePosition
            local gearSize = GearButton.AbsoluteSize
            return (position.X >= (gearPos.X - 10)
                and position.X <= (gearPos.X + gearSize.X + 10)
                and position.Y >= (gearPos.Y - 10)
                and position.Y <= (gearPos.Y + gearSize.Y + 10))
        end

        local function stopDragging(input)
            if input ~= activeDragInput then return end
            dragging = false
            activeDragInput = nil
            dragStart = nil
            startPosition = nil
        end

        Header.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if dragging or isOverHeaderControl(input.Position) then return end

            dragging = true
            activeDragInput = input
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPosition = Window.Position
            dragMoved = false

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                    stopDragging(input)
                end
            end)
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging or not activeDragInput then return end
            local isTrackedTouch = activeDragInput.UserInputType == Enum.UserInputType.Touch and input == activeDragInput
            local isTrackedMouse = activeDragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
            if not isTrackedTouch and not isTrackedMouse then return end

            local current = Vector2.new(input.Position.X, input.Position.Y)
            local delta = current - dragStart
            if not dragMoved then
                if delta.Magnitude < DRAG_THRESHOLD then return end
                dragMoved = true
            end

            Window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end)
    end

    local SettingsGUI = nil

    local function setupListenKeybind()
        if _listenInputConnection then
            _listenInputConnection:Disconnect()
            _listenInputConnection = nil
        end
        _listenInputConnection = UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if UserInputService:GetFocusedTextBox() then return end
            if inp.KeyCode == Enum.KeyCode[_listenKeybind] then
                _enabled = not _enabled
                savedConfig.codeSniper = _enabled
                saveConfig()
                listenBtn.Text = _enabled and "ON" or "OFF"
                listenBtn.BackgroundColor3 = _enabled and COLORS.Accent or COLORS.Control
                listenBtn.TextColor3 = _enabled and COLORS.Window or COLORS.Dim
                listenStroke.Transparency = _enabled and 0.62 or 0.88
                updateStatusDot()
            end
        end)
    end

    local function createSettingsUI()
        if SettingsGUI and SettingsGUI.Parent then
            SettingsGUI:Destroy()
            SettingsGUI = nil
            return
        end

        SettingsGUI = Instance.new("ScreenGui")
        SettingsGUI.Name = "ACESettingsUI"
        SettingsGUI.ResetOnSpawn = false
        SettingsGUI.IgnoreGuiInset = true
        SettingsGUI.DisplayOrder = 998
        if not pcall(function() SettingsGUI.Parent = game.CoreGui end) then SettingsGUI.Parent = playerGui end

        local SettingsWindow = Instance.new("Frame")
        SettingsWindow.Name = "SettingsWindow"
        SettingsWindow.Size = UDim2.fromOffset(240, 190)
        SettingsWindow.AnchorPoint = Vector2.new(0.5, 0.5)
        SettingsWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
        SettingsWindow.BackgroundColor3 = COLORS.Window
        SettingsWindow.BorderSizePixel = 0
        SettingsWindow.ClipsDescendants = true
        SettingsWindow.Parent = SettingsGUI
        addCorner(SettingsWindow, 14)
        addStroke(SettingsWindow, COLORS.Border, 1, 0.3)

        local SettingsBg = Instance.new("ImageLabel")
        SettingsBg.Name = "SettingsBackground"
        SettingsBg.Size = UDim2.new(1, 0, 1, 0)
        SettingsBg.Position = UDim2.fromOffset(0, 0)
        SettingsBg.BackgroundTransparency = 1
        SettingsBg.Image = "rbxassetid://97803827151139"
        SettingsBg.ImageTransparency = 0
        SettingsBg.ScaleType = Enum.ScaleType.Stretch
        SettingsBg.ZIndex = 1
        SettingsBg.Parent = SettingsWindow
        addCorner(SettingsBg, 14)

        local SettingsTitle = makeLabel(SettingsWindow, "Title", "⚙️", UDim2.new(1, -20, 0, 30), UDim2.fromOffset(10, 5), 16, COLORS.Text, Enum.Font.GothamBold)
        SettingsTitle.TextXAlignment = Enum.TextXAlignment.Center
        SettingsTitle.ZIndex = 2

        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseBtn"
        closeBtn.Size = UDim2.fromOffset(26, 26)
        closeBtn.Position = UDim2.new(1, -34, 0, 2)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Text = "X"
        closeBtn.TextSize = 16
        closeBtn.TextColor3 = COLORS.Dim
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.ZIndex = 2
        closeBtn.Parent = SettingsWindow
        closeBtn.Activated:Connect(function() if SettingsGUI then SettingsGUI:Destroy(); SettingsGUI = nil end end)

        local function createToggleRow(parent, y, labelText, initialState, onToggle, labelColor)
            labelColor = labelColor or COLORS.White
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -20, 0, 24)
            row.Position = UDim2.fromOffset(10, y)
            row.BackgroundTransparency = 1
            row.Parent = parent

            makeLabel(row, "Label", labelText, UDim2.fromOffset(120, 24), UDim2.fromOffset(6, 0), 13, labelColor, Enum.Font.GothamBold)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.fromOffset(44, 22)
            btn.Position = UDim2.new(1, -50, 0.5, -11)
            btn.BackgroundColor3 = initialState and COLORS.Accent or COLORS.Control
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Active = true
            btn.Text = initialState and "ON" or "OFF"
            btn.TextSize = 11
            btn.TextColor3 = initialState and COLORS.Window or COLORS.Dim
            btn.Font = Enum.Font.GothamBold
            btn.ZIndex = 5
            btn.Parent = row
            addCorner(btn, 5)
            local stroke = addStroke(btn, COLORS.White, 1, initialState and 0.62 or 0.88)

            local currentState = initialState

            btn.Activated:Connect(function()
                currentState = not currentState
                if onToggle then onToggle(currentState) end
                btn.Text = currentState and "ON" or "OFF"
                btn.BackgroundColor3 = currentState and COLORS.Accent or COLORS.Control
                btn.TextColor3 = currentState and COLORS.Window or COLORS.Dim
                stroke.Transparency = currentState and 0.62 or 0.88
            end)
            return btn
        end

        local darkerColor = Color3.fromRGB(105, 105, 112)

        createToggleRow(SettingsWindow, 42, "Anti Ragdoll", _antiRagdollEnabled, function(newState)
            if newState then startAntiRagdoll() else stopAntiRagdoll() end
            savedConfig.antiRagdoll = _antiRagdollEnabled
            saveConfig()
        end, darkerColor)

        createToggleRow(SettingsWindow, 72, "Anti Lag", _antiLagEnabled, function(newState)
            if newState then startAntiLag() else stopAntiLag() end
            savedConfig.antiLag = _antiLagEnabled
            saveConfig()
        end, darkerColor)

        createToggleRow(SettingsWindow, 102, "Remove Accessories", _removeAccessoriesEnabled, function(newState)
            if newState then startRemoveAccessories() else stopRemoveAccessories() end
            savedConfig.removeAccessories = _removeAccessoriesEnabled
            saveConfig()
        end, darkerColor)

        createToggleRow(SettingsWindow, 132, "Auto Buy", _autoBuyActive, function(newState)
            if newState then
                autoBuyStart()
            else
                autoBuyStop()
            end
        end, darkerColor)

        local keyRow = Instance.new("Frame")
        keyRow.Size = UDim2.new(1, -20, 0, 24)
        keyRow.Position = UDim2.fromOffset(10, 162)
        keyRow.BackgroundTransparency = 1
        keyRow.Parent = SettingsWindow

        makeLabel(keyRow, "Label", "Listen Key", UDim2.fromOffset(120, 24), UDim2.fromOffset(6, 0), 13, darkerColor, Enum.Font.GothamBold)

        local keyBtn = Instance.new("TextButton")
        keyBtn.Size = UDim2.fromOffset(44, 22)
        keyBtn.Position = UDim2.new(1, -50, 0.5, -11)
        keyBtn.BackgroundColor3 = COLORS.Control
        keyBtn.BorderSizePixel = 0
        keyBtn.AutoButtonColor = false
        keyBtn.Active = true
        keyBtn.Text = _listenKeybind
        keyBtn.TextSize = 12
        keyBtn.TextColor3 = COLORS.Text
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.ZIndex = 5
        keyBtn.Parent = keyRow
        addCorner(keyBtn, 5)
        addStroke(keyBtn, COLORS.Border, 1, 0.5)

        keyBtn.Activated:Connect(function()
            if _capturingListenKey then return end
            _capturingListenKey = true
            keyBtn.Text = "..."
            keyBtn.TextColor3 = COLORS.Dim
        end)

        do
            local drag, input, start, pos
            SettingsWindow.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag = true
                    input = i
                    start = Vector2.new(i.Position.X, i.Position.Y)
                    pos = SettingsWindow.Position
                    i.Changed:Connect(function()
                        if i.UserInputState == Enum.UserInputState.End or i.UserInputState == Enum.UserInputState.Cancel then
                            drag = false
                            input = nil
                        end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if drag and input then
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement) or
                       (input.UserInputType == Enum.UserInputType.Touch and i == input) then
                        local delta = Vector2.new(i.Position.X, i.Position.Y) - start
                        SettingsWindow.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
                    end
                end
            end)
        end

        local captureConnection
        captureConnection = UserInputService.InputBegan:Connect(function(inp, gp)
            if not _capturingListenKey then return end
            if gp then return end
            if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local key = inp.KeyCode
            if key == Enum.KeyCode.Unknown then return end
            local keyName = key.Name
            if #keyName == 1 then
                _listenKeybind = keyName:upper()
            else
                _listenKeybind = keyName
            end
            savedConfig.listenKeybind = _listenKeybind
            saveConfig()
            keyBtn.Text = _listenKeybind
            keyBtn.TextColor3 = COLORS.Text
            _capturingListenKey = false
            setupListenKeybind()
            if captureConnection then
                captureConnection:Disconnect()
                captureConnection = nil
            end
        end)
    end

    GearButton.Activated:Connect(createSettingsUI)
    GearButton.MouseButton1Click:Connect(createSettingsUI)
    GearButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            createSettingsUI()
        end
    end)

    local function col3ToRich(col)
        if col == COLORS.Green then return CONSOLE_COLORS.Green end
        if col == COLORS.Red then return CONSOLE_COLORS.Red end
        if col == COLORS.Text then return CONSOLE_COLORS.Amber end
        if col == COLORS.White then return CONSOLE_COLORS.Cyan end
        if col == COLORS.Dim then return CONSOLE_COLORS.Dim end
        return string.format("rgb(%d,%d,%d)", math.floor(col.R * 255 + 0.5), math.floor(col.G * 255 + 0.5), math.floor(col.B * 255 + 0.5))
    end

    function setStatus(msg, col)
        if not ConsoleOutput then return end
        col = col or COLORS.Dim
        local line = '<font color="' .. col3ToRich(col) .. '">' .. tostring(msg) .. "</font>"
        local lines = {}
        for line in ConsoleOutput.Text:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        if #lines == 0 then
            ConsoleOutput.Text = line
        else
            local newText = lines[1] .. "\n\n" .. line
            ConsoleOutput.Text = newText
        end
        scrollConsoleToBottom()
    end

    function flashCode(code, col)
        if not code or code == "" or code == "—" then return end
        setStatus("[code] -> " .. tostring(code), col or COLORS.White)
    end

    local function resetPasteCounter() _capturedParts = {} end
    clearAceCapture = function() _capturedParts = {} end

    local function clearBoxWatchers()
        if _boxTextConn then pcall(function() _boxTextConn:Disconnect() end) end
        if _boxAncestryConn then pcall(function() _boxAncestryConn:Disconnect() end) end
        for _, connection in ipairs(_boxVisibilityConns) do pcall(function() connection:Disconnect() end) end
        _boxTextConn = nil
        _boxAncestryConn = nil
        _boxVisibilityConns = {}
        _lastWatchedBox = nil
        if _manualSubmitDebounce then
            _manualSubmitDebounce:Disconnect()
            _manualSubmitDebounce = nil
        end
    end

    local function watchBoxForBlankReset(box)
        if not box or _lastWatchedBox == box then return end
        clearBoxWatchers()
        _lastWatchedBox = box
        if box.Text ~= "" then _lastNonBlankBoxText = box.Text end

        _boxTextConn = box:GetPropertyChangedSignal("Text"):Connect(function()
            if box.Text == "" then 
                resetPasteCounter()
                _lastNonBlankBoxText = ""
                if _manualSubmitDebounce then
                    _manualSubmitDebounce:Disconnect()
                    _manualSubmitDebounce = nil
                end
            else 
                _lastNonBlankBoxText = box.Text
                if not _programmaticChange and _autoAccept then
                    local words = {}
                    for w in box.Text:gmatch("%S+") do
                        table.insert(words, w)
                    end
                    if #words >= _submitAfter then
                        if _manualSubmitDebounce then
                            _manualSubmitDebounce:Disconnect()
                        end
                        _manualSubmitDebounce = task.delay(0.05, function()
                            _manualSubmitDebounce = nil
                            if _autoAccept and box and box.Parent and isVisibleChain(box) then
                                local code = box.Text
                                if code ~= "" then
                                    local ok, statusMsg = typeAndSubmitCode(code)
                                    if ok then
                                        setStatus("Code redeemed (" .. code .. ")", COLORS.Green)
                                    else
                                        setStatus("Failed: " .. tostring(statusMsg), COLORS.Red)
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end)

        _boxAncestryConn = box.AncestryChanged:Connect(function(_, parent)
            if not parent then resetPasteCounter(); clearBoxWatchers() end
        end)
    end

    UserInputService.TextBoxFocused:Connect(function(box)
        if box:IsDescendantOf(GUI) or (SettingsGUI and box:IsDescendantOf(SettingsGUI)) then return end
        if box ~= aceCodeBox() then return end
        _focused = box
        _lastBox = box
        watchBoxForBlankReset(box)
        if _enabled then setStatus("Ready", COLORS.Green) end
    end)

    UserInputService.TextBoxFocusReleased:Connect(function(box)
        if box:IsDescendantOf(GUI) or (SettingsGUI and box:IsDescendantOf(SettingsGUI)) then return end
        local codeBox = aceCodeBox()
        if box ~= codeBox and box ~= _lastBox then return end
        if _focused == box then
            _focused = nil
            if _enabled then
                setStatus((_lastBox and _lastBox.Parent) and "Ready" or "Click code box first", (_lastBox and _lastBox.Parent) and COLORS.Green or COLORS.Dim)
            end
        end
    end)

    function appendToBox(text)
        if not text or text == "" then return end
        if not _enabled then return end
        
        if _lastWatchedBox and not isVisibleChain(_lastWatchedBox) then
            resetPasteCounter()
            clearBoxWatchers()
        end
        local box = aceCodeBox()
        _capturedParts[#_capturedParts + 1] = text
        local combinedCode = table.concat(_capturedParts)
        local capturedCount = #_capturedParts

        if box then
            _lastBox = box
            watchBoxForBlankReset(box)
            local boxWasFocused = UserInputService:GetFocusedTextBox() == box
            _programmaticChange = true
            box.Text = combinedCode
            _programmaticChange = false
            if boxWasFocused then
                pcall(function()
                    local caretEnd = #combinedCode + 1
                    box.CursorPosition = caretEnd
                    box.SelectionStart = caretEnd
                end)
            end
        else
            setStatus("Captured; opening & searching UI...", COLORS.Text)
        end

        setStatus("Pasted " .. tostring(capturedCount) .. "/" .. tostring(_submitAfter), COLORS.Green)
        flashCode(combinedCode, COLORS.Green)

        if capturedCount >= _submitAfter then
            _capturedParts = {}
            if _autoAccept then
                local ok, statusMsg = typeAndSubmitCode(combinedCode)
                if ok then
                    setStatus("Code redeemed (" .. combinedCode .. ")", COLORS.Green)
                else
                    setStatus("Failed: " .. tostring(statusMsg), COLORS.Red)
                end
            end
        end
    end

    local function resolveNotifyRemote()
        if _G.PhiNotifyRemote then return _G.PhiNotifyRemote end
        local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
        local getinfo = debug and (debug.getinfo or debug.info)
        if getgc and getinfo and getconnections then
            for _, d in ipairs(Net:GetDescendants()) do
                if d:IsA("RemoteEvent") then
                    local ok, cs = pcall(getconnections, d.OnClientEvent)
                    if ok then
                        for _, c in ipairs(cs) do
                            local f, fn = pcall(function() return c.Function end)
                            if f and type(fn) == "function" then
                                local i, info = pcall(getinfo, fn)
                                if i and tostring(info.short_src or info.source or ""):find("NotificationController", 1, true) then
                                    return d
                                end
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    local function aceStripRich(text)
        if type(text) ~= "string" then return tostring(text) end
        return (text:gsub("<[^>]->", ""))
    end

    local function aceTokenize(text)
        local words = {}
        for word in text:gmatch("[%w_]+") do
            words[#words + 1] = word
        end
        return words
    end

    local aceCollectBuffer = {}
    local function onAceAnnouncement(...)
        if not _enabled then return end
        
        local text = aceStripRich(tostring((...) or ""))
        text = text:match("^%s*(.-)%s*$") or ""
        if text == "" then return end

        if text:find("%s") then return end

        for _, word in ipairs(aceTokenize(text)) do
            aceCollectBuffer[#aceCollectBuffer + 1] = word
        end
        
        local parts = {}
        for index = 1, math.min(#aceCollectBuffer, ACE_WORD_COUNT) do
            parts[index] = aceCollectBuffer[index]
        end
        if #aceCollectBuffer < ACE_WORD_COUNT then return end
        aceCollectBuffer = {}
        
        local captured = table.concat(parts)
        if captured == "" or _seen[captured] then return end
        _seen[captured] = true
        task.delay(1.25, function() _seen[captured] = nil end)
        appendToBox(captured)
    end

    local aceNotifyRemote = resolveNotifyRemote()
    local aceListenConnection
    if aceNotifyRemote then
        if getgenv then
            local previous = getgenv().ACECodeSniperNotifyConnection
            if previous then pcall(function() previous:Disconnect() end) end
        end
        aceListenConnection = aceNotifyRemote.OnClientEvent:Connect(function(...)
            pcall(onAceAnnouncement, ...)
        end)
        if getgenv then getgenv().ACECodeSniperNotifyConnection = aceListenConnection end
    end

    if getgenv then
        getgenv().StopAura = function()
            if aceListenConnection then
                pcall(function() aceListenConnection:Disconnect() end)
                aceListenConnection = nil
            end
            if getgenv().ACECodeSniperNotifyConnection then
                pcall(function() getgenv().ACECodeSniperNotifyConnection:Disconnect() end)
                getgenv().ACECodeSniperNotifyConnection = nil
            end
            if _listenInputConnection then
                _listenInputConnection:Disconnect()
                _listenInputConnection = nil
            end
            stopAntiLag()
            stopAntiRagdoll()
            stopRemoveAccessories()
            autoBuyStop()
            if GUI then GUI:Destroy() end
            if SettingsGUI then SettingsGUI:Destroy() end
            if HeadBillboard then pcall(function() HeadBillboard:Destroy() end) end
        end
    end

    if _antiLagEnabled then startAntiLag() end
    if _antiRagdollEnabled then startAntiRagdoll() end
    if _removeAccessoriesEnabled then startRemoveAccessories() end
    if savedConfig.autoBuy then
        autoBuyStart()
    end
    updateStatusDot()

    setupListenKeybind()

    if _enabled then
        ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Green .. '">Listening for codes</font>'
    else
        ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Red .. '">Off</font>'
    end
end)

if not success then
    warn("Weekly Sniper error: " .. tostring(err))
    print("Check the error above. The script may not work in this environment.")
end
