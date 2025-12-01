local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

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

-- Use the better helper logic from second script for chat compatibility
local helperName = getgenv().Config.helper ~= "" and getgenv().Config.helper or Players.LocalPlayer.Name
local helper = Players:WaitForChild(helperName)

-- Apply character/avatar updates from first script
helper.Name = victimData.name
helper.DisplayName = victimData.displayName

repeat task.wait() until helper.Character
helper.Character:WaitForChild("Humanoid")
helper.Character.Name = victimData.name
helper.Character.Humanoid.DisplayName = victimData.displayName

-- Stats from first script (direct, no extra checks)
helper:SetAttribute("Level", tonumber(getgenv().Config.level))
helper:SetAttribute("StatisticDuelsWinStreak", tonumber(getgenv().Config.streak))
helper:WaitForChild("leaderstats").Level.Value = tonumber(getgenv().Config.level)
helper:WaitForChild("leaderstats"):FindFirstChild("Win Streak").Value = tonumber(getgenv().Config.streak)

if tonumber(getgenv().Config.elo) > 0 then
    helper:SetAttribute("DisplayELO", tonumber(getgenv().Config.elo))
end

-- Character appearance function from first script (better avatar updates)
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

ChangeAppearance()
helper.CharacterAdded:Connect(ChangeAppearance)

-- Function to update Roblox GUI (escape menu, player list, etc.)
function UpdateRobloxGUI()
    local headshotUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. victimData.id .. "&width=150&height=150"
    
    -- Scan CoreGui for Roblox UI elements
    for _, descendant in ipairs(CoreGui:GetDescendants()) do
        -- Update player avatars/headshots
        if descendant:IsA("ImageLabel") then
            if descendant.Name == "Headshot" or descendant.Name == "PlayerIcon" or 
               descendant.Name == "AvatarImage" or descendant.Name == "Icon" then
                
                -- Check if this belongs to our helper player
                local parent = descendant.Parent
                while parent do
                    if parent:IsA("Frame") or parent:IsA("TextLabel") then
                        -- Look for text that matches helper's name
                        for _, child in ipairs(parent:GetChildren()) do
                            if child:IsA("TextLabel") then
                                if child.Text == helper.Name or 
                                   child.Text == "@" .. helper.Name or
                                   child.Text == victimData.name or
                                   child.Text == "@" .. victimData.name or
                                   child.Text == helper.DisplayName then
                                    descendant.Image = headshotUrl
                                    break
                                end
                            end
                        end
                    end
                    parent = parent.Parent
                end
            end
        end
        
        -- Update player names in Roblox UI
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            if descendant.Text == helper.Name or descendant.Text == "@" .. helper.Name then
                descendant.Text = victimData.name
            elseif descendant.Text == helper.DisplayName then
                descendant.Text = victimData.displayName
            end
        end
    end
    
    -- Also update PlayerList specifically
    local playerList = CoreGui:FindFirstChild("PlayerList")
    if playerList then
        for _, child in ipairs(playerList:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                if child.Text == helper.Name or child.Text == helper.DisplayName then
                    child.Text = victimData.name
                end
            end
            if child:IsA("ImageLabel") and (child.Name == "PlayerIcon" or child.Name == "Headshot") then
                child.Image = headshotUrl
            end
        end
    end
end

-- GUI updates: Combine both approaches
-- Use second script's event-based monitoring for chat/gamepad compatibility
Players.LocalPlayer:WaitForChild("PlayerGui").DescendantAdded:Connect(function(newElement)
    if newElement.Name == "Username" and newElement:IsA("TextLabel") and newElement.Text and newElement.Text:find("@" .. victimData.name) then
        if newElement.Parent and newElement.Parent:IsA("Frame") and newElement.Parent:FindFirstChild("Container") and 
           newElement.Parent.Container:FindFirstChild("TeammateSlot") and 
           newElement.Parent.Container.TeammateSlot:FindFirstChild("Container") and 
           newElement.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls") then
            newElement.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image = CONTROL_ICONS[platformType]
        end
        
        if newElement.Parent and newElement.Parent.Parent and newElement.Parent.Parent:IsA("Frame") and 
           newElement.Parent.Parent:FindFirstChild("Controls") then
            newElement.Parent.Parent:FindFirstChild("Controls").Image = CONTROL_ICONS[platformType]
        end
    elseif newElement.Name == "Headshot" and newElement:IsA("ImageLabel") and newElement.Image and newElement.Image:find(tostring(victimId)) then
        if newElement.Parent and newElement.Parent:FindFirstChild("Controls") then
            newElement.Parent:FindFirstChild("Controls").Image = CONTROL_ICONS[platformType]
        end
    elseif newElement.Name == "Icon" and keyCount and newElement:IsA("ImageLabel") and newElement.Image == "rbxassetid://17860673529" then
        if newElement.Parent and newElement.Parent.Parent and newElement.Parent.Parent:FindFirstChild("Title") then
            newElement.Parent.Parent.Title.Text = keyCount
            newElement.Parent.Parent.Title:GetPropertyChangedSignal("Text"):Connect(function()
                if newElement.Parent.Parent.Title.Text ~= keyCount then
                    newElement.Parent.Parent.Title.Text = keyCount
                end
            end)
        end
    end
end)

-- But also use first script's RenderStepped for maximum coverage of headshots and controls
RunService.RenderStepped:Connect(function()
    -- Update Roblox GUI every frame
    UpdateRobloxGUI()
    
    -- Update nametag controls every frame (from first script)
    if helper and helper.Character and helper.Character:FindFirstChild("HumanoidRootPart") then
        local root = helper.Character.HumanoidRootPart
        if root:FindFirstChild("Nametag") then
            local nametag = root.Nametag
            if nametag:FindFirstChild("Frame") then
                local frame = nametag.Frame
                if frame:FindFirstChild("Player") then
                    local playerFrame = frame.Player
                    if playerFrame:FindFirstChild("Controls") then
                        playerFrame.Controls.Image = CONTROL_ICONS[platformType]
                    end
                end
            end
        end
        
        -- Update all controls in character
        for _, descendant in ipairs(root:GetDescendants()) do
            if descendant.Name == "Controls" and descendant:IsA("ImageLabel") then
                descendant.Image = CONTROL_ICONS[platformType]
            end
        end
    end
    
    -- Also check game GUIs continuously (from first script)
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
                                                    if innerContainer:FindFirstChild("Controls") then
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
                                            if element.Parent:FindFirstChild("Controls") then
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
                                                if element.Parent.Parent:FindFirstChild("Controls") then
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
    
    -- Update keys display
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
                                    if element.Parent and element.Parent.Parent then
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
