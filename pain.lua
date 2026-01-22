getgenv().Config = {
    victim = 5441022436,
    helper = "onmypms",
    platform = "PC",
    level = 1000,
    streak = 500,
    elo = 6500,
    keys = 10000,
    showVictimName = false
}

-- config things --
local cfg = getgenv().Config
local victim = cfg.victim
local helper = cfg.helper
local level = cfg.level
local streak = cfg.streak
local elo = cfg.elo
local keys = cfg.keys
local platform = tostring(cfg.platform):upper()
local showVictimName = cfg.showVictimName

-- waits for friend to be in the game --
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local friend = cfg.helper ~= "" and Players:WaitForChild(helper) or Players.LocalPlayer

-- sets user data --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = game:GetService("HttpService"):JSONDecode(UserData)

-- Store original name for GUI updates
local originalName = friend.Name
local originalDisplayName = friend.DisplayName

-- Only change name if showVictimName is true
if showVictimName then
    friend.Name = decodedData.name
    friend.DisplayName = decodedData.displayName
    friend.CharacterAppearanceId = decodedData.id
end

repeat task.wait() until friend.Character
friend.Character:WaitForChild("Humanoid")

if showVictimName then
    friend.Character.Name = decodedData.name
    friend.Character.Humanoid.DisplayName = decodedData.displayName
end

-- Apply stats
friend:SetAttribute("Level", tonumber(level))
friend:SetAttribute("StatisticDuelsWinStreak", tonumber(streak))
friend:WaitForChild("leaderstats").Level.Value = tonumber(level)
friend:WaitForChild("leaderstats"):FindFirstChild("Win Streak").Value = tonumber(streak)
if tonumber(elo) > 0 then
    friend:SetAttribute("DisplayELO", tonumber(elo))
end

-- changes user character --
function Char()
    local plr = friend
    local appearance = Players:GetCharacterAppearanceAsync(decodedData.id)
    for i,v in pairs(plr.Character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end
    for i,v in pairs(appearance:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v.Parent = plr.Character
        elseif v:IsA("Accessory") then
            plr.Character.Humanoid:AddAccessory(v)
        end
    end
    if appearance:FindFirstChild("face") then
        if plr.Character:WaitForChild("Head"):FindFirstChild("face") then
            plr.Character.Head.face:Destroy()
        end
        appearance.face.Parent = plr.Character.Head
    else
        if plr.Character:WaitForChild("Head"):FindFirstChild("face") then
            plr.Character.Head.face:Destroy()
        end
        local face = Instance.new("Decal")
        face.Face = "Front"
        face.Name = "face"
        face.Texture = "rbxasset://textures/face.png"
        face.Transparency = 0
        face.Parent = plr.Character.Head
    end
    local parent = plr.Character.Parent
    plr.Character.Parent = nil
    plr.Character.Parent = parent
end
Char()
friend.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    Char()
end)

local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

-- Optimized version - only checks specific paths like the original script
game:GetService("RunService").RenderStepped:Connect(function()
    -- Only update platform icons, not avatar images (much lighter)
    local displayName = showVictimName and decodedData.name or originalName
    
    -- 1. Update nametag controls
    local ctrl =
        friend
        and friend.Character
        and friend.Character:FindFirstChild("HumanoidRootPart")
        and friend.Character.HumanoidRootPart:FindFirstChild("Nametag")
        and friend.Character.HumanoidRootPart.Nametag:FindFirstChild("Frame")
        and friend.Character.HumanoidRootPart.Nametag.Frame:FindFirstChild("Player")
        and friend.Character.HumanoidRootPart.Nametag.Frame.Player:FindFirstChild("Controls")

    if ctrl then
        ctrl.Image = imagetable[platform]
    end
    
    -- 2. Update scoreboard controls
    local container =
        Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("Scoreboard")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Scoreboard:FindFirstChild("Container")

    if container then
        for _, v in ipairs(container:GetDescendants()) do
            if v.Name == "Username" then
                local usernameText = showVictimName and "@" .. decodedData.name or "@" .. originalName
                if string.find(v.Text, usernameText) then
                    v.Parent.Container.TeammateSlot.Container.Controls.Image = imagetable[platform]
                end
            end
        end
    end
    
    -- 3. Update top scores controls
    local topScores =
        Players.LocalPlayer
        and Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("Top")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top:FindFirstChild("Scores")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top.Scores:FindFirstChild("Teams")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top.Scores.Teams
    
    if topScores then
        for _,v in ipairs(topScores:GetDescendants()) do
            if v.Name == "Headshot" and string.find(v.Image, tostring(victim)) then
                v.Parent:FindFirstChild("Controls").Image = imagetable[platform]
            end
        end
    end
    
    -- 4. Update final results controls
    local finalResults =
        Players.LocalPlayer
        and Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("FinalResults")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults:FindFirstChild("Winners")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults.Winners:FindFirstChild("Players")
    
    if finalResults then
        for _,v in ipairs(finalResults:GetDescendants()) do
            if v.Name == "Username" then
                local usernameText = showVictimName and "@" .. decodedData.name or "@" .. originalName
                if string.find(v.Text, usernameText) then
                    local controls = v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChild("Controls")
                    if controls then
                        controls.Image = imagetable[platform]
                    end
                end
            end
        end
    end
    
    -- 5. Update keys display
    local currencyContainer =
        Players.LocalPlayer
        and Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("Lobby")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby:FindFirstChild("Currency")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency:FindFirstChild("Container")
    
    if currencyContainer then
        for _, v in ipairs(currencyContainer:GetDescendants()) do
            if v.Name == "Icon" and keys and v.Image == "rbxassetid://17860673529" then
                v.Parent.Parent.Title.Text = keys
            end
        end
    end
end)
