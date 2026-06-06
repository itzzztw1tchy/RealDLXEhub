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

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

local Window = Luna:CreateWindow({
    Name = "DLXE HUB",
    Subtitle = "by tw1tchy/DLXE/mentalplays",
    LogoID = nil,
    LoadingEnabled = true,
    LoadingTitle = "DLXE HUB",
    LoadingSubtitle = "99 Nights in the Forest",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "DLXEHUB"
    },
    KeySystem = false,
})

local TreeTab = Window:CreateTab({
    Name = "Trees",
    Icon = "forest",
    ImageSource = "Material",
    ShowTitle = true
})

local BringTab = Window:CreateTab({
    Name = "Bring",
    Icon = "inventory_2",
    ImageSource = "Material",
    ShowTitle = true
})

local DiscordTab = Window:CreateTab({
    Name = "Discord",
    Icon = "forum",
    ImageSource = "Material",
    ShowTitle = true
})

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

    Luna:Notification({
        Title = label,
        Icon = "inventory_2",
        ImageSource = "Material",
        Content = count > 0 and "Brought " .. count .. " item(s)!" or "No items found!"
    })
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

RunService.RenderStepped:Connect(function()
    if freecamEnabled then
        camera.CFrame = camCFrame
    end
end)

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
    btn.BackgroundColor3 = Color3.fromRGB(40, 0, 70)
    btn.TextColor3 = Color3.fromRGB(200, 100, 255)
    btn.Text = label
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.Parent = btnFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local held = false
    btn.MouseButton1Down:Connect(function() held = true end)
    btn.MouseButton1Up:Connect(function() held = false end)
    btn.TouchStarted:Connect(function() held = true end)
    btn.TouchEnded:Connect(function() held = false end)

    RunService.RenderStepped:Connect(function()
        if held and freecamEnabled then callback() end
    end)
end

makeBtn("W",  UDim2.new(0, 60,  0, 0),   function() camCFrame = camCFrame * CFrame.new(0, 0, -camSpeed) end)
makeBtn("S",  UDim2.new(0, 60,  0, 120), function() camCFrame = camCFrame * CFrame.new(0, 0, camSpeed) end)
makeBtn("A",  UDim2.new(0, 0,   0, 60),  function() camCFrame = camCFrame * CFrame.new(-camSpeed, 0, 0) end)
makeBtn("D",  UDim2.new(0, 120, 0, 60),  function() camCFrame = camCFrame * CFrame.new(camSpeed, 0, 0) end)
makeBtn("Up", UDim2.new(0, 60,  0, 60),  function() camCFrame = camCFrame * CFrame.new(0, camSpeed, 0) end)
makeBtn("Dn", UDim2.new(0, 0,   0, 0),   function() camCFrame = camCFrame * CFrame.new(0, -camSpeed, 0) end)

-- =====================
--      RUN FUNCTION
-- =====================
local function run()
    enableFreecam()
    btnFrame.Visible = true

    Luna:Notification({
        Title = "Tree Farmer",
        Icon = "forest",
        ImageSource = "Material",
        Content = "Starting..."
    })

    task.wait(1)

    local axe = getAxe()
    if not axe then
        Luna:Notification({
            Title = "Tree Farmer",
            Icon = "warning",
            ImageSource = "Material",
            Content = "Old Axe not found!"
        })
        running = false
        disableFreecam()
        btnFrame.Visible = false
        return
    end

    local trees = findSmallTrees()
    if #trees == 0 then
        Luna:Notification({
            Title = "Tree Farmer",
            Icon = "warning",
            ImageSource = "Material",
            Content = "No Small Trees found!"
        })
        running = false
        disableFreecam()
        btnFrame.Visible = false
        return
    end

    Luna:Notification({
        Title = "Tree Farmer",
        Icon = "forest",
        ImageSource = "Material",
        Content = "Found " .. #trees .. " trees. Chopping!"
    })

    for i, tree in ipairs(trees) do
        if not running then break end

        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        axe = getAxe()

        if not axe then
            Luna:Notification({
                Title = "Tree Farmer",
                Icon = "warning",
                ImageSource = "Material",
                Content = "Axe lost! Stopping."
            })
            running = false
            break
        end

        if tree and tree.Parent then
            local primary = tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart")
            if primary then
                rootPart.CFrame = primary.CFrame * CFrame.new(0, 3, 3)
                task.wait(TRAVEL_DELAY)

                for hit = 1, HITS_PER_TREE do
                    if not running then break end
                    if not tree or not tree.Parent then break end
                    axe = getAxe()
                    if not axe then break end

                    remote:InvokeServer(
                        tree, axe,
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
        Luna:Notification({
            Title = "Tree Farmer",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = "Done! All trees chopped."
        })
    else
        Luna:Notification({
            Title = "Tree Farmer",
            Icon = "cancel",
            ImageSource = "Material",
            Content = "Stopped."
        })
    end

    running = false
    disableFreecam()
    btnFrame.Visible = false
end

-- =====================
--      TREES TAB
-- =====================
TreeTab:CreateSection("Farming")

TreeTab:CreateToggle({
    Name = "Tree Farmer",
    Description = "Auto chops all Small Trees",
    CurrentValue = false,
    Callback = function(value)
        running = value
        if running then
            task.spawn(run)
        else
            Luna:Notification({
                Title = "Tree Farmer",
                Icon = "cancel",
                ImageSource = "Material",
                Content = "Stopped."
            })
            disableFreecam()
            btnFrame.Visible = false
        end
    end
}, "TreeFarmer")

TreeTab:CreateSection("Freecam")

TreeTab:CreateToggle({
    Name = "Enable Freecam",
    Description = "Detaches camera while farming",
    CurrentValue = false,
    Callback = function(value)
        if value then
            enableFreecam()
            btnFrame.Visible = true
        else
            disableFreecam()
            btnFrame.Visible = false
        end
    end
}, "FreecamToggle")

TreeTab:CreateSlider({
    Name = "Freecam Speed",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        camSpeed = value * 0.1
    end
}, "FreecamSpeed")

TreeTab:CreateSection("Settings")

TreeTab:CreateSlider({
    Name = "Hits Per Tree",
    Range = {1, 500},
    Increment = 1,
    CurrentValue = 500,
    Callback = function(value)
        HITS_PER_TREE = value
    end
}, "HitsPerTree")

TreeTab:CreateSlider({
    Name = "Hit Delay (ms)",
    Range = {1, 2000},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(value)
        HIT_DELAY = value / 1000
    end
}, "HitDelay")

-- =====================
--      BRING TAB
-- =====================
BringTab:CreateSection("Items")

BringTab:CreateButton({
    Name = "Wood / Logs",
    Description = "Brings all logs to you",
    Callback = function()
        bringItems({"Log", "Small Log", "Wood"}, "Bring Wood")
    end
})

BringTab:CreateButton({
    Name = "Metal / Scraps",
    Description = "Brings all metal and scraps",
    Callback = function()
        bringItems(METAL_NAMES, "Bring Metal")
    end
})

BringTab:CreateButton({
    Name = "Food",
    Description = "Brings all food items",
    Callback = function()
        bringItems(FOOD_NAMES, "Bring Food")
    end
})

BringTab:CreateButton({
    Name = "Ammunition",
    Description = "Brings all ammo",
    Callback = function()
        bringItems(AMMO_NAMES, "Bring Ammo")
    end
})

BringTab:CreateButton({
    Name = "Weapons",
    Description = "Brings all weapons",
    Callback = function()
        bringItems(WEAPON_NAMES, "Bring Weapons")
    end
})

BringTab:CreateButton({
    Name = "Fuel",
    Description = "Brings all fuel items",
    Callback = function()
        bringItems(FUEL_NAMES, "Bring Fuel")
    end
})

BringTab:CreateButton({
    Name = "Heals",
    Description = "Brings all healing items",
    Callback = function()
        bringItems(HEAL_NAMES, "Bring Heals")
    end
})

BringTab:CreateSection("Bring All")

BringTab:CreateButton({
    Name = "ALL ITEMS",
    Description = "Brings every item to you",
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
DiscordTab:CreateSection("Community")

DiscordTab:CreateParagraph({
    Title = "Join the Discord",
    Text = "discord.gg/6egUXcwmdc"
})

DiscordTab:CreateButton({
    Name = "Copy Discord Link",
    Description = "Copies the invite to clipboard",
    Callback = function()
        setclipboard("discord.gg/6egUXcwmdc")
        Luna:Notification({
            Title = "Discord",
            Icon = "forum",
            ImageSource = "Material",
            Content = "Link copied to clipboard!"
        })
    end
})

Luna:LoadAutoloadConfig()
