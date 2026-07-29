local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject")
local foliage = workspace:WaitForChild("Map"):WaitForChild("Foliage")

local running = false
local HITS_PER_TREE = 500
local HIT_DELAY = 0.1
local TRAVEL_DELAY = 0.4

local FOOD_NAMES = {"Cake", "Carrot", "Morsel", "Berry"}
local METAL_NAMES = {"Bolt", "Broken Fan", "Broken Microwave", "Chair", "Sheet Metal", "Tyre"}
local AMMO_NAMES = {"Rifle Ammo", "Revolver Ammo"}
local FUEL_NAMES = {"Oil Barrel", "Dynamite", "Coal"}
local HEAL_NAMES = {"MedKit", "Bandage", "Med Kit"}
local WEAPON_NAMES = {"Revolver", "Spear", "Rifle"}

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "DLXEHUB",
    LoadingTitle = "99 Nights Script",
    LoadingSubtitle = "gui by tw1tchy/DLXE/mentalplays",
    Theme = "Amethyst",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local TreeTab = Window:CreateTab("Trees", 4483362458)
local BringTab = Window:CreateTab("Bring Items", 4483362458)

-- =====================
--      TREE TAB
-- =====================
TreeTab:CreateLabel("gui made by tw1tchy/DLXE/mentalplays")
TreeTab:CreateDivider()

local statusElement = TreeTab:CreateLabel("Status: Idle")
local treeElement = TreeTab:CreateLabel("")

local function setStatus(text)
    statusElement:Set("Status: " .. text)
end

local function setTreeLabel(text)
    treeElement:Set(text)
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

local function run()
    setStatus("Loading...")
    task.wait(1)

    local axe = getAxe()
    if not axe then
        setStatus("Old Axe not found!")
        running = false
        return
    end

    setStatus("Axe found ✓")
    task.wait(0.5)

    local trees = findSmallTrees()
    if #trees == 0 then
        setStatus("No Small Trees found!")
        running = false
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
                        setStatus("Tree broke! ✓")
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
        setStatus("Done! ✓")
        setTreeLabel("All trees chopped")
    else
        setStatus("Stopped")
        setTreeLabel("")
    end

    running = false
end

TreeTab:CreateToggle({
    Name = "Tree Farmer",
    CurrentValue = false,
    Flag = "TreeToggle",
    Callback = function(value)
        running = value
        if running then
            task.spawn(run)
        else
            setStatus("Stopped")
            setTreeLabel("")
        end
    end
})

TreeTab:CreateSlider({
    Name = "Hits Per Tree",
    Range = {1, 500},
    Increment = 1,
    CurrentValue = 500,
    Flag = "HitsSlider",
    Callback = function(value)
        HITS_PER_TREE = value
    end
})

TreeTab:CreateSlider({
    Name = "Hit Delay (ms)",
    Range = {1, 2000},
    Increment = 50,
    CurrentValue = 10,
    Flag = "DelaySlider",
    Callback = function(value)
        HIT_DELAY = value / 1000
    end
})

-- =====================
--      BRING TAB
-- =====================
local function bringItems(nameList, label)
    local character = player.Character
    if not character then return 0 end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return 0 end

    local items = workspace:FindFirstChild("Items")
    if not items then return 0 end

    local count = 0
    for _, obj in ipairs(items:GetChildren()) do
        for _, name in ipairs(nameList) do
            if obj.Name == name then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    obj:PivotTo(rootPart.CFrame * CFrame.new(0, 0, -3))
                    count = count + 1
                end
                break
            end
        end
    end

    Rayfield:Notify({
        Title = label,
        Content = count > 0 and "Brought " .. count .. " item(s) to you!" or "No items found on the ground!",
        Duration = 3
    })

    return count
end

BringTab:CreateLabel("gui made by tw1tchy/DLXE/mentalplays :3")
BringTab:CreateDivider()

BringTab:CreateButton({
    Name = "Wood/Logs",
    Callback = function()
        bringItems({"Log", "Small Log", "Wood"}, "Bring Wood")
    end
})

BringTab:CreateButton({
    Name = "Metal/Scraps",
    Callback = function()
        bringItems(METAL_NAMES, "Bring Metal")
    end
})

BringTab:CreateButton({
    Name = "Food",
    Callback = function()
        bringItems(FOOD_NAMES, "Bring Food")
    end
})

BringTab:CreateButton({
    Name = "Ammunition",
    Callback = function()
        bringItems(AMMO_NAMES, "Bring Ammo")
    end
})

BringTab:CreateButton({
    Name = "Weapons",
    Callback = function()
        bringItems(WEAPON_NAMES, "Bring Weapons")
    end
})

BringTab:CreateButton({
    Name = "Fuel",
    Callback = function()
        bringItems(FUEL_NAMES, "Bring Fuel")
    end
})

BringTab:CreateButton({
    Name = "Heals",
    Callback = function()
        bringItems(HEAL_NAMES, "Bring Heals")
    end
})

BringTab:CreateDivider()

BringTab:CreateButton({
    Name = "ALL ITEMS",
    Callback = function()
        local all = {}
        for _, t in ipairs({{"Log", "Small Log", "Wood"}, FOOD_NAMES, METAL_NAMES, AMMO_NAMES, FUEL_NAMES, HEAL_NAMES, WEAPON_NAMES}) do
            for _, n in ipairs(t) do table.insert(all, n) end
        end
        bringItems(all, "Bring Everything")
    end
})
