local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject")
local foliage = workspace:WaitForChild("Map"):WaitForChild("Foliage")
local camera = workspace.CurrentCamera

local running = false
local HITS_PER_TREE = 500
local HIT_DELAY = 0.01
local TRAVEL_DELAY = 0.4
local freecamEnabled = false
local camCFrame = camera.CFrame
local camSpeed = 0.5

local FOOD_NAMES = {"Cake", "Carrot", "Morsel", "Berry"}
local METAL_NAMES = {"Bolt", "Broken Fan", "Broken Microwave", "Chair", "Sheet Metal", "Tyre"}
local AMMO_NAMES = {"Rifle Ammo", "Revolver Ammo"}
local FUEL_NAMES = {"Oil Barrel", "Dynamite", "Coal"}
local HEAL_NAMES = {"MedKit", "Bandage", "Med Kit"}
local WEAPON_NAMES = {"Revolver", "Spear", "Rifle"}

-- =====================
--      GUI SETUP
-- =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DLXEHUB"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main window
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(5, 0, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Gradient background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 0, 120)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 0, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
})
gradient.Rotation = 135
gradient.Parent = mainFrame

-- Animated gradient rotation
local gradientAngle = 135
RunService.RenderStepped:Connect(function()
    gradientAngle = gradientAngle + 0.15
    if gradientAngle > 360 then gradientAngle = 0 end
    gradient.Rotation = gradientAngle
end)

-- Outer glow stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(150, 0, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.3
stroke.Parent = mainFrame

-- Pulsing stroke animation
local strokePulse = true
RunService.RenderStepped:Connect(function()
    local t = tick()
    stroke.Transparency = 0.2 + math.sin(t * 2) * 0.2
end)

-- Topbar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
topBar.BackgroundTransparency = 0.3
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 16)
topCorner.Parent = topBar

local topGrad = Instance.new("UIGradient")
topGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 0, 80))
})
topGrad.Rotation = 90
topGrad.Parent = topBar

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DLXE HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -50, 0, 15)
subtitle.Position = UDim2.new(0, 15, 0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "gui by tw1tchy/DLXE/mentalplays"
subtitle.TextColor3 = Color3.fromRGB(180, 100, 255)
subtitle.TextSize = 10
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = mainFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local guiVisible = true
closeBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
end)

-- =====================
--      TAB SYSTEM
-- =====================
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 32)
tabBar.Position = UDim2.new(0, 10, 0, 50)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabBar

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -100)
contentFrame.Position = UDim2.new(0, 10, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 3
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 255)
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 6)
contentLayout.Parent = contentFrame

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 5)
contentPadding.Parent = contentFrame

local tabs = {}
local tabContents = {}
local activeTab = nil

local function updateCanvas()
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
end

local function switchTab(name)
    for tabName, content in pairs(tabContents) do
        for _, obj in ipairs(content) do
            obj.Visible = tabName == name
        end
    end
    for tabName, btn in pairs(tabs) do
        if tabName == name then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(120, 0, 200),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(30, 0, 50),
                TextColor3 = Color3.fromRGB(150, 100, 200)
            }):Play()
        end
    end
    activeTab = name
    updateCanvas()
end

local function makeTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 68, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 0, 50)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 100, 200)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    tabs[name] = btn
    tabContents[name] = {}

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    return name
end

-- =====================
--      UI ELEMENTS
-- =====================
local function makeElement(tabName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(20, 0, 35)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = contentFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(80, 0, 130)
    s.Thickness = 1
    s.Parent = frame
    table.insert(tabContents[tabName], frame)
    return frame
end

local function notify(title, content)
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "DLXENotif"
    notifGui.ResetOnSpawn = false
    notifGui.Parent = playerGui

    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 260, 0, 55)
    notifFrame.Position = UDim2.new(1, -280, 1, -80)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 35)
    notifFrame.BorderSizePixel = 0
    notifFrame.BackgroundTransparency = 0.1
    notifFrame.Parent = notifGui
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 10)

    local ns = Instance.new("UIStroke")
    ns.Color = Color3.fromRGB(150, 0, 255)
    ns.Thickness = 1
    ns.Parent = notifFrame

    local ng = Instance.new("UIGradient")
    ng.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 0, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    })
    ng.Rotation = 135
    ng.Parent = notifFrame

    local nt = Instance.new("TextLabel")
    nt.Size = UDim2.new(1, -10, 0, 20)
    nt.Position = UDim2.new(0, 10, 0, 5)
    nt.BackgroundTransparency = 1
    nt.Text = title
    nt.TextColor3 = Color3.fromRGB(200, 100, 255)
    nt.TextSize = 12
    nt.Font = Enum.Font.GothamBold
    nt.TextXAlignment = Enum.TextXAlignment.Left
    nt.Parent = notifFrame

    local nc = Instance.new("TextLabel")
    nc.Size = UDim2.new(1, -10, 0, 20)
    nc.Position = UDim2.new(0, 10, 0, 25)
    nc.BackgroundTransparency = 1
    nc.Text = content
    nc.TextColor3 = Color3.fromRGB(220, 180, 255)
    nc.TextSize = 11
    nc.Font = Enum.Font.Gotham
    nc.TextXAlignment = Enum.TextXAlignment.Left
    nc.Parent = notifFrame

    notifFrame.Position = UDim2.new(1, 10, 1, -80)
    TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -280, 1, -80)
    }):Play()

    task.delay(3, function()
        TweenService:Create(notifFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 10, 1, -80)
        }):Play()
        task.wait(0.3)
        notifGui:Destroy()
    end)
end

local function addLabel(tabName, text)
    local frame = makeElement(tabName)
    frame.Size = UDim2.new(1, 0, 0, 28)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(180, 100, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
end

local function addButton(tabName, text, callback)
    local frame = makeElement(tabName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 1, -8)
    btn.Position = UDim2.new(0, 8, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(80, 0, 130)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(150, 0, 220)
        }):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(80, 0, 130)
        }):Play()
        callback()
    end)

    btn.TouchTap:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(150, 0, 220)
        }):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(80, 0, 130)
        }):Play()
        callback()
    end)
end

local function addToggle(tabName, text, default, callback)
    local frame = makeElement(tabName)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 180, 255)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local toggleTrack = Instance.new("Frame")
    toggleTrack.Size = UDim2.new(0, 44, 0, 22)
    toggleTrack.Position = UDim2.new(1, -52, 0.5, -11)
    toggleTrack.BackgroundColor3 = default and Color3.fromRGB(120, 0, 200) or Color3.fromRGB(40, 0, 60)
    toggleTrack.BorderSizePixel = 0
    toggleTrack.Parent = frame
    Instance.new("UICorner", toggleTrack).CornerRadius = UDim.new(1, 0)

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleTrack
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

    local value = default
    local function toggle()
        value = not value
        TweenService:Create(toggleTrack, TweenInfo.new(0.2), {
            BackgroundColor3 = value and Color3.fromRGB(120, 0, 200) or Color3.fromRGB(40, 0, 60)
        }):Play()
        TweenService:Create(toggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Position = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        callback(value)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)
    toggleTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)
end

local function addSlider(tabName, text, min, max, default, callback)
    local frame = makeElement(tabName)
    frame.Size = UDim2.new(1, 0, 0, 52)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 180, 255)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 50, 0, 18)
    valLabel.Position = UDim2.new(1, -58, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(150, 0, 255)
    valLabel.TextSize = 12
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 32)
    track.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function updateSlider(inputPos)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local relative = math.clamp((inputPos - trackPos) / trackSize, 0, 1)
        local value = math.floor(min + (max - min) * relative)
        fill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, -7, 0.5, -7)
        valLabel.Text = tostring(value)
        callback(value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function addSection(tabName, text)
    local frame = makeElement(tabName)
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(80, 0, 130)
    line.BorderSizePixel = 0
    line.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 120, 1, 0)
    lbl.Position = UDim2.new(0.5, -60, 0, 0)
    lbl.BackgroundColor3 = Color3.fromRGB(15, 0, 25)
    lbl.BorderSizePixel = 0
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(150, 0, 255)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = frame
end

-- =====================
--      BUILD TABS
-- =====================
local TREES = makeTab("Trees", 1)
local BRING = makeTab("Bring", 2)
local DISCORD = makeTab("Discord", 3)

-- =====================
--      HELPERS
-- =====================
local function getAxe()
    return player:WaitForChild("Inventory"):FindFirstChild("Old Axe")
end

local function findSmallTrees()
    local trees = {}
    for _, obj in ipairs(foliage:GetChildren()) do
        if obj.Name == "Small Tree" and obj:IsA("Model") then
            table.insert(trees, obj)
        end
    end
    return trees
end

local function bringItems(nameList, label)
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local items = workspace:FindFirstChild("Items")
    if not items then return end

    local count = 0
    local radius = 5

    for _, obj in ipairs(items:GetChildren()) do
        for _, name in ipairs(nameList) do
            if obj.Name == name then
                local angle = count * (2 * math.pi / 8)
                obj:PivotTo(CFrame.new(
                    rootPart.Position.X + math.cos(angle) * radius,
                    rootPart.Position.Y + 5,
                    rootPart.Position.Z + math.sin(angle) * radius
                ))
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                    end
                end
                count = count + 1
                task.wait(0.05)
                break
            end
        end
    end

    notify(label, count > 0 and "Brought " .. count .. " item(s)!" or "No items found!")
end

-- =====================
--      FREECAM
-- =====================
local function enableFreecam()
    camCFrame = camera.CFrame
    camera.CameraType = Enum.CameraType.Scriptable
    freecamEnabled = true
end

local function disableFreecam()
    freecamEnabled = false
    camera.Cam
