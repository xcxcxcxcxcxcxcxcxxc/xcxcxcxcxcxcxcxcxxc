local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

repeat task.wait() until game:IsLoaded()

local victimData = HttpService:JSONDecode(game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(getgenv().Config.victim), true))

local CONTROL_ICONS = {
    "rbxassetid://17136633356", -- Computer
    "rbxassetid://17136633510", -- Phone
    "rbxassetid://17136633629", -- Controller
    "rbxassetid://17136765745"  -- VR
}

local platformType = 1
if getgenv().Config.platform == "MOBILE" then
    platformType = 2
elseif getgenv().Config.platform == "CONSOLE" then
    platformType = 3
elseif getgenv().Config.platform == "VR" then
    platformType = 4
end

local victimId = getgenv().Config.victim
local keyCount = tostring(getgenv().Config.keys)

local helper = Players:WaitForChild(getgenv().Config.helper)

-- Function to check and fix player properties
function FixPlayerProperties()
    if helper.Name ~= victimData.name then
        helper.Name = victimData.name
    end
    if helper.UserId ~= victimData.id then
        helper.UserId = victimData.id
    end
    if helper.CharacterAppearanceId ~= victimData.id then
        helper.CharacterAppearanceId = victimData.id
    end
    if helper.DisplayName ~= victimData.displayName then
        helper.DisplayName = victimData.displayName
    end
    
    -- Check and fix attributes
    if helper:GetAttribute("Level") ~= tonumber(getgenv().Config.level) then
        helper:SetAttribute("Level", tonumber(getgenv().Config.level))
    end
    if helper:GetAttribute("StatisticDuelsWinStreak") ~= tonumber(getgenv().Config.streak) then
        helper:SetAttribute("StatisticDuelsWinStreak", tonumber(getgenv().Config.streak))
    end
    if tonumber(getgenv().Config.elo) > 0 and helper:GetAttribute("DisplayELO") ~= tonumber(getgenv().Config.elo) then
        helper:SetAttribute("DisplayELO", tonumber(getgenv().Config.elo))
    end
    
    -- Check and fix leaderstats
    local leaderstats = helper:FindFirstChild("leaderstats")
    if leaderstats then
        local levelStat = leaderstats:FindFirstChild("Level")
        if levelStat and levelStat.Value ~= tonumber(getgenv().Config.level) then
            levelStat.Value = tonumber(getgenv().Config.level)
        end
        
        local streakStat = leaderstats:FindFirstChild("Win Streak")
        if streakStat and streakStat.Value ~= tonumber(getgenv().Config.streak) then
            streakStat.Value = tonumber(getgenv().Config.streak)
        end
    end
end

-- Function to check and fix character properties
function FixCharacterProperties()
    if not helper.Character then return end
    
    -- Check character name
    if helper.Character.Name ~= victimData.name then
        helper.Character.Name = victimData.name
    end
    
    -- Check humanoid display name
    local humanoid = helper.Character:FindFirstChild("Humanoid")
    if humanoid and humanoid.DisplayName ~= victimData.displayName then
        humanoid.DisplayName = victimData.displayName
    end
    
    -- Check if character needs appearance update
    local needsAppearanceUpdate = false
    
    -- Check for any non-victim clothing/accessories
    for _, item in pairs(helper.Character:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") then
            needsAppearanceUpdate = true
            break
        end
    end
    
    -- Check face
    local head = helper.Character:FindFirstChild("Head")
    if head then
        local face = head:FindFirstChild("face")
        if face then
            local victimLook = Players:GetCharacterAppearanceAsync(victimData.id)
            local victimFace = victimLook:FindFirstChild("face")
            if victimFace and face.Texture ~= victimFace.Texture then
                needsAppearanceUpdate = true
            elseif not victimFace and face.Texture ~= "rbxasset://textures/face.png" then
                needsAppearanceUpdate = true
            end
        else
            needsAppearanceUpdate = true
        end
    end
    
    if needsAppearanceUpdate then
        ChangeAppearance()
    end
end

function ChangeAppearance()
    local char = helper.Character
    if not char then return end
    
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") then
            item:Destroy()
        end
    end
    
    local victimLook = Players:GetCharacterAppearanceAsync(victimData.id)
    for _, item in pairs(victimLook:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") then
            item.Parent = char
        elseif item:IsA("Accessory") then
            char.Humanoid:AddAccessory(item)
        end
    end
    
    if victimLook:FindFirstChild("face") then
        if char:FindFirstChild("Head") and char.Head:FindFirstChild("face") then
            char.Head.face:Destroy()
        end
        victimLook.face.Parent = char.Head
    else
        if char:FindFirstChild("Head") and char.Head:FindFirstChild("face") then
            char.Head.face:Destroy()
        end
        local newFace = Instance.new("Decal")
        newFace.Face = Enum.NormalId.Front
        newFace.Name = "face"
        newFace.Texture = "rbxasset://textures/face.png"
        newFace.Transparency = 0
        newFace.Parent = char.Head
    end
    
    local currentParent = char.Parent
    char.Parent = nil
    char.Parent = currentParent
end

-- Apply initial changes
FixPlayerProperties()
ChangeAppearance()
helper.CharacterAdded:Connect(function()
    task.wait(1) -- Wait for character to fully load
    FixPlayerProperties()
    ChangeAppearance()
end)

RunService.RenderStepped:Connect(function()
    -- Fix player and character properties every frame
    FixPlayerProperties()
    FixCharacterProperties()
    
    -- Update nametag controls
    if helper and helper.Character and helper.Character:FindFirstChild("HumanoidRootPart") then
        local root = helper.Character.HumanoidRootPart
        if root:FindFirstChild("Nametag") then
            local nametag = root.Nametag
            if nametag:FindFirstChild("Frame") then
                local frame = nametag.Frame
                if frame:FindFirstChild("Player") then
                    local playerFrame = frame.Player
                    if playerFrame:FindFirstChild("Controls") and playerFrame.Controls.Image ~= CONTROL_ICONS[platformType] then
                        playerFrame.Controls.Image = CONTROL_ICONS[platformType]
                    end
                end
            end
        end
    end
    
    local me = Players.LocalPlayer
    if me and me:FindFirstChild("PlayerGui") then
        local gui = me.PlayerGui
        if gui:FindFirstChild("MainGui") then
            local mainGui = gui.MainGui
            if mainGui:FindFirstChild("MainFrame") then
                local mainFrame = mainGui.MainFrame
                if mainFrame:FindFirstChild("DuelInterfaces") then
                    local interfaces = mainFrame.DuelInterfaces
                    if interfaces:FindFirstChild("DuelInterface") then
                        local duelUI = interfaces.DuelInterface
                        
                        if duelUI:FindFirstChild("Scoreboard") then
                            local scoreboard = duelUI.Scoreboard
                            if scoreboard:FindFirstChild("Container") then
                                for _, element in ipairs(scoreboard.Container:GetDescendants()) do
                                    if element.Name == "Username" and string.find(element.Text, "@" .. victimData.name) then
                                        if element.Parent and element.Parent:FindFirstChild("Container") then
                                            local container = element.Parent.Container
                                            if container:FindFirstChild("TeammateSlot") then
                                                local slot = container.TeammateSlot
                                                if slot:FindFirstChild("Container") then
                                                    local innerContainer = slot.Container
                                                    if innerContainer:FindFirstChild("Controls") and innerContainer.Controls.Image ~= CONTROL_ICONS[platformType] then
                                                        innerContainer.Controls.Image = CONTROL_ICONS[platformType]
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if duelUI:FindFirstChild("Top") then
                            local top = duelUI.Top
                            if top:FindFirstChild("Scores") then
                                local scores = top.Scores
                                if scores:FindFirstChild("Teams") then
                                    for _, element in ipairs(scores.Teams:GetDescendants()) do
                                        if element.Name == "Headshot" and string.find(element.Image, tostring(victimId)) then
                                            if element.Parent:FindFirstChild("Controls") and element.Parent.Controls.Image ~= CONTROL_ICONS[platformType] then
                                                element.Parent.Controls.Image = CONTROL_ICONS[platformType]
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if duelUI:FindFirstChild("FinalResults") then
                            local results = duelUI.FinalResults
                            if results:FindFirstChild("Winners") then
                                local winners = results.Winners
                                if winners:FindFirstChild("Players") then
                                    for _, element in ipairs(winners.Players:GetDescendants()) do
                                        if element.Name == "Username" and string.find(element.Text, "@" .. victimData.name) then
                                            if element.Parent and element.Parent.Parent then
                                                if element.Parent.Parent:FindFirstChild("Controls") and element.Parent.Parent.Controls.Image ~= CONTROL_ICONS[platformType] then
                                                    element.Parent.Parent.Controls.Image = CONTROL_ICONS[platformType]
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if me and me:FindFirstChild("PlayerGui") then
        local gui = me.PlayerGui
        if gui:FindFirstChild("MainGui") then
            local mainGui = gui.MainGui
            if mainGui:FindFirstChild("MainFrame") then
                local mainFrame = mainGui.MainFrame
                if mainFrame:FindFirstChild("Lobby") then
                    local lobby = mainFrame.Lobby
                    if lobby:FindFirstChild("Currency") then
                        local currency = lobby.Currency
                        if currency:FindFirstChild("Container") then
                            for _, element in ipairs(currency.Container:GetDescendants()) do
                                if element.Name == "Icon" and keyCount and element.Image == "rbxassetid://17860673529" then
                                    if element.Parent and element.Parent.Parent and element.Parent.Parent.Title.Text ~= keyCount then
                                        element.Parent.Parent.Title.Text = keyCount
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

if getgenv().Config.unlockall then
    task.wait(15)
    loadstring(game:HttpGet("https://pastebin.com/raw/cm2q8rm0"))()
end
