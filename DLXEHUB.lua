local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject")
local foliage = workspace:WaitForChild("Map"):WaitForChild("Foliage")
local camera = workspace.CurrentCamera

local running = false
local HITS_PER_TREE = 500
local HIT_DELAY = 0.1
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

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "DLXEHUB",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "DLXEHUB",
    IntroEnabled = true,
    IntroText = "DLXEHUB",
})

-- =====================
--      TREE TAB
-- =====================
local TreeTab = Window:MakeTab({
    Name = "Trees",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

TreeTab:AddLabel("gui made by tw1tchy/DLXE/mentalplays")

local statusLabel = TreeTab:AddLabel("Status: Idle")
local treeLabel = TreeTab:AddLabel("")

local function setStatus(text)
    statusLabel:Set("Status: " .. text)
end

local function setTreeLabel(text)
    treeLabel:Set(text)
end

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
    camera.CameraType = Enum.CameraType.Custom
    local character = player.Character
    if character then
        camera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
    end
end

local lastTouchPos = nil

UserInputService.TouchStarted:Connect(function(touch)
    lastTouchPos = touch.Position
end)

UserInputService.TouchEnded:Connect(function()
    lastTouchPos = nil
end)

UserInputService.TouchMoved:Connect(function(touch)
    if freecamEnabled and lastTouchPos then
        local delta = touch.Position - lastTouchPos
        lastTouchPos = touch.Position
        camCFrame = camCFrame * CFrame.Angles(0, -delta.X * 0.005, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    if freecamEnabled then
        camera.CFrame = camCFrame
    end
end)

-- Freecam movement buttons
local freecamGui = Instance.new("ScreenGui")
freecamGui.Name = "FreecamControls"
freecamGui.ResetOnSpawn = false
freecamGui.Parent = player.PlayerGui

local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(0, 170, 0, 170)
btnFrame.Position = UDim2.new(1, -190, 1, -190)
btnFrame.BackgroundTransparency = 1
btnFrame.Visible = false
btnFrame.Parent = freecamGui

local function makeBtn(label, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    btn.TextColor3 = Color3.fromRGB(220, 0, 0)
    btn.Text = label
    btn.Font = Enum.Font.Antique
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.Parent = btnFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local held = false
    btn.MouseButton1Down:Connect(function() held = true end)
    btn.MouseButton1Up:Connect(function() held = false end)
    btn.TouchStarted:Connect(function() held = true end)
    btn.TouchEnded:Connect(function() held = false end)

    RunService.RenderStepped:Connect(function()
        if held and freecamEnabled then
            callback()
        end
    end)
end

makeBtn("W", UDim2.new(0, 60, 0, 0), function()
    camCFrame = camCFrame * CFrame.new(0, 0, -camSpeed)
end)
makeBtn("S", UDim2.new(0, 60, 0, 120), function()
    camCFrame = camCFrame * CFrame.new(0, 0, camSpeed)
end)
makeBtn("A", UDim2.new(0, 0, 0, 60), function()
    camCFrame = camCFrame * CFrame.new(-camSpeed, 0, 0)
end)
makeBtn("D", UDim2.new(0, 120, 0, 60), function()
    camCFrame = camCFrame * CFrame.new(camSpeed, 0, 0)
end)
makeBtn("Up", UDim2.new(0, 60, 0, 60), function()
    camCFrame = camCFrame * CFrame.new(0, camSpeed, 0)
end)
makeBtn("Dn", UDim2.new(0, 0, 0, 0), function()
    camCFrame = camCFrame * CFrame.new(0, -camSpeed, 0)
end)

-- =====================
--      RUN FUNCTION
-- =====================
local function run()
    enableFreecam()
    btnFrame.Visible = true
    setStatus("Loading...")
    task.wait(1)

    local axe = getAxe()
    if not axe then
        setStatus("Old Axe not found!")
        running = false
        disableFreecam()
        btnFrame.Visible = false
        return
    end

    setStatus("Axe found")
    task.wait(0.5)

    local trees = findSmallTrees()
    if #trees == 0 then
        setStatus("No Small Trees found!")
        running = false
        disableFreecam()
        btnFrame.Visible = false
        return
    end

    setStatus("Running")
    setTreeLabel("Found " .. #trees .. " trees")

    for i, tree in ipairs(trees) do
        if not running then break end

        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        axe = getAxe()

        if not axe then
            setStatus("Axe lost or not found! Stopping.")
            running = false
            break
        end

        if tree and tree.Parent then
            local primary = tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart")
            if primary then
                rootPart.CFrame = primary.CFrame * CFrame.new(0, 3, 3)
                task.wait(TRAVEL_DELAY)

                setTreeLabel("Tree " .. i .. "/" .. #trees)
                setStatus("Chopping...")

                for hit = 1, HITS_PER_TREE do
                    if not running then break end
                    if not tree or not tree.Parent then
                        setStatus("Tree broke!")
                        break
                    end

                    axe = getAxe()
                    if not axe then break end

                    remote:InvokeServer(
                        tree,
                        axe,
                        "9999_1076307479",
                        rootPart.CFrame,
                        true
                    )

                    task.wait(HIT_DELAY)
                end
            end
        end

        task.wait(0.2)
    end

    if running then
        setStatus("Done!")
        setTreeLabel("All trees chopped")
    else
        setStatus("Stopped")
        setTreeLabel("")
    end

    running = false
    disableFreecam()
    btnFrame.Visible = false
end

-- =====================
--      TREE TAB ELEMENTS
-- =====================
TreeTab:AddToggle({
    Name = "Tree Farmer",
    Default = false,
    Callback = function(value)
        running = value
        if running then
            task.spawn(run)
        else
            setStatus("Stopped")
            setTreeLabel("")
            disableFreecam()
            btnFrame.Visible = false
        end
    end
})

TreeTab:AddToggle({
    Name = "Freecam",
    Default = false,
    Callback = function(value)
        if value then
            enableFreecam()
            btnFrame.Visible = true
        else
            disableFreecam()
            btnFrame.Visible = false
        end
    end
})

TreeTab:AddSlider({
    Name = "Freecam Speed",
    Min = 1,
    Max = 20,
    Default = 5,
    Color = Color3.fromRGB(200, 0, 0),
    Increment = 1,
    ValueName = "speed",
    Callback = function(value)
        camSpeed = value * 0.1
    end
})

TreeTab:AddSlider({
    Name = "Hits Per Tree",
    Min = 1,
    Max = 500,
    Default = 500,
    Color = Color3.fromRGB(200, 0, 0),
    Increment = 1,
    ValueName = "hits",
    Callback = function(value)
        HITS_PER_TREE = value
    end
})

TreeTab:AddSlider({
    Name = "Hit Delay (ms)",
    Min = 1,
    Max = 2000,
    Default = 10,
    Color = Color3.fromRGB(200, 0, 0),
    Increment = 50,
    ValueName = "ms",
    Callback = function(value)
        HIT_DELAY = value / 1000
    end
})

-- =====================
--      BRING TAB
-- =====================
local BringTab = Window:MakeTab({
    Name = "Bring Items",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

BringTab:AddLabel("gui made by tw1tchy/DLXE/mentalplays :3")

local function bringItems(nameList, label)
    local character = player.Character
    if not character then return 0 end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return 0 end

    local items = workspace:FindFirstChild("Items")
    if not items then return 0 end

    local count = 0
    local radius = 5

    for _, obj in ipairs(items:GetChildren()) do
        for _, name in ipairs(nameList) do
            if obj.Name == name then
                local angle = (count * (2 * math.pi / 8))
                local offsetX = math.cos(angle) * radius
                local offsetZ = math.sin(angle) * radius
                local spawnCFrame = CFrame.new(
                    rootPart.Position.X + offsetX,
                    rootPart.Position.Y + 5,
                    rootPart.Position.Z + offsetZ
                )

                obj:PivotTo(spawnCFrame)

                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end

                count = count + 1
                task.wait(0.05)
                break
            end
        end
    end

    OrionLib:MakeNotification({
        Name = label,
        Content = count > 0 and "Brought " .. count .. " item(s) to you!" or "No items found!",
        Image = "rbxassetid://4483362458",
        Time = 3
    })

    return count
end

BringTab:AddButton({
    Name = "Wood/Logs",
    Callback = function()
        bringItems({"Log", "Small Log", "Wood"}, "Bring Wood")
    end
})

BringTab:AddButton({
    Name = "Metal/Scraps",
    Callback = function()
        bringItems(METAL_NAMES, "Bring Metal")
    end
})

BringTab:AddButton({
    Name = "Food",
    Callback = function()
        bringItems(FOOD_NAMES, "Bring Food")
    end
})

BringTab:AddButton({
    Name = "Ammunition",
    Callback = function()
        bringItems(AMMO_NAMES, "Bring Ammo")
    end
})

BringTab:AddButton({
    Name = "Weapons",
    Callback = function()
        bringItems(WEAPON_NAMES, "Bring Weapons")
    end
})

BringTab:AddButton({
    Name = "Fuel",
    Callback = function()
        bringItems(FUEL_NAMES, "Bring Fuel")
    end
})

BringTab:AddButton({
    Name = "Heals",
    Callback = function()
        bringItems(HEAL_NAMES, "Bring Heals")
    end
})

BringTab:AddButton({
    Name = "ALL ITEMS",
    Callback = function()
        local all = {}
        for _, t in ipairs({{"Log", "Small Log", "Wood"}, FOOD_NAMES, METAL_NAMES, AMMO_NAMES, FUEL_NAMES, HEAL_NAMES, WEAPON_NAMES}) do
            for _, n in ipairs(t) do table.insert(all, n) end
        end
        bringItems(all, "Bring Everything")
    end
})

-- =====================
--      DISCORD TAB
-- =====================
local DiscordTab = Window:MakeTab({
    Name = "Discord",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

DiscordTab:AddLabel("Join our Discord!")
DiscordTab:AddLabel("discord.gg/6egUXcwmdc")
DiscordTab:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("discord.gg/6egUXcwmdc")
        OrionLib:MakeNotification({
            Name = "Discord",
            Content = "Link copied to clipboard!",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    end
})

OrionLib:Init()

-- =====================
--      APPLY THEME
-- =====================
task.wait(1)

local function applyTheme(gui)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
            if obj.BackgroundTransparency < 1 then
                obj.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
            end
        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = Color3.fromRGB(220, 0, 0)
            obj.Font = Enum.Font.Antique
            if obj.BackgroundTransparency < 1 then
                obj.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
            end
        elseif obj:IsA("ImageButton") then
            if obj.BackgroundTransparency < 1 then
                obj.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
            end
        elseif obj:IsA("UIStroke") then
            obj.Color = Color3.fromRGB(180, 0, 0)
        end
    end
end

local playerGui = player:WaitForChild("PlayerGui")
for _, gui in ipairs(playerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        applyTheme(gui)
    end
end
