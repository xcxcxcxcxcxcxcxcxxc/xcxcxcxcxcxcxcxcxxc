-- config things --
local cfg = getgenv().Config
local victim = cfg.victim
local helper = cfg.helper
local level = cfg.level
local streak = cfg.streak
local elo = cfg.elo
local keys = cfg.keys
local platform = tostring(cfg.platform):upper()
local showVictimName = cfg.showVictimName or false -- NEW: Option to show victim's username in GUI

-- waits for friend to be in the game --
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local friend = cfg.helper ~= "" and Players:WaitForChild(helper) or Players.LocalPlayer

-- sets user data --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = game:GetService("HttpService"):JSONDecode(UserData)

-- Only change the friend's name/display name if showVictimName is true
if showVictimName then
    friend.Name = decodedData.name
    friend.DisplayName = decodedData.displayName
    -- Store original names so we can revert GUI changes if needed
    friend:SetAttribute("OriginalName", friend.Name)
    friend:SetAttribute("OriginalDisplayName", friend.DisplayName)
end

repeat task.wait() until friend.Character
friend.Character:WaitForChild("Humanoid")

-- Apply stats regardless of name display
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
    task.wait(0.5) -- Small delay to ensure character is loaded
    Char()
end)

local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

game:GetService("RunService").RenderStepped:Connect(function()
    -- Update platform icons
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
                -- Check if this is our friend's username element
                if showVictimName then
                    -- Show victim's name
                    if v.Text:find("@" .. friend:GetAttribute("OriginalName") or friend.Name) then
                        v.Text = "@" .. decodedData.name
                    end
                else
                    -- Keep original name
                    if v.Text == "@" .. decodedData.name then
                        v.Text = "@" .. (friend:GetAttribute("OriginalName") or friend.Name)
                    end
                end
                
                -- Always update platform icon
                if v.Text:find("@" .. decodedData.name) or (not showVictimName and v.Text:find("@" .. (friend:GetAttribute("OriginalName") or friend.Name))) then
                    if v.Parent and v.Parent:FindFirstChild("Container") then
                        local container2 = v.Parent.Container
                        if container2:FindFirstChild("TeammateSlot") then
                            local slot = container2.TeammateSlot
                            if slot:FindFirstChild("Container") then
                                local innerContainer = slot.Container
                                if innerContainer:FindFirstChild("Controls") then
                                    innerContainer.Controls.Image = imagetable[platform]
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Update other GUI elements with platform icons
    for _,v in ipairs(
        Players.LocalPlayer
        and Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("Top")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top:FindFirstChild("Scores")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top.Scores:FindFirstChild("Teams")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top.Scores.Teams:GetDescendants()
        or {}
    ) do
        if v.Name == "Headshot" and string.find(v.Image, tostring(victim)) then
            v.Parent:FindFirstChild("Controls").Image = imagetable[platform]
        end
    end
    
    for _,v in ipairs(
        Players.LocalPlayer
        and Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("FinalResults")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults:FindFirstChild("Winners")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults.Winners:FindFirstChild("Players")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults.Winners.Players:GetDescendants()
        or {}
    ) do
        if v.Name == "Username" then
            if showVictimName then
                if v.Text:find("@" .. (friend:GetAttribute("OriginalName") or friend.Name)) then
                    v.Text = "@" .. decodedData.name
                end
            else
                if v.Text == "@" .. decodedData.name then
                    v.Text = "@" .. (friend:GetAttribute("OriginalName") or friend.Name)
                end
            end
            
            if v.Text:find("@" .. decodedData.name) or (not showVictimName and v.Text:find("@" .. (friend:GetAttribute("OriginalName") or friend.Name))) then
                local controls = v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChild("Controls")
                if controls then
                    controls.Image = imagetable[platform]
                end
            end
        end
    end
    
    -- Update keys display
    for _, v in ipairs(
        Players.LocalPlayer
        and Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("Lobby")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby:FindFirstChild("Currency")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency:FindFirstChild("Container")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency.Container:GetDescendants()
        or {}
    ) do
        if v.Name == "Icon" and keys and v.Image == "rbxassetid://17860673529" then
            v.Parent.Parent.Title.Text = keys
        end
    end
end)
