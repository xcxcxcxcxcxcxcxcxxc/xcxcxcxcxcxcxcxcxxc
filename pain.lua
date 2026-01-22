-- Check if config exists
if not getgenv().Config then
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
end

-- config things --
local cfg = getgenv().Config
local victim = cfg.victim
local helper = cfg.helper
local level = cfg.level
local streak = cfg.streak
local elo = cfg.elo
local keys = cfg.keys
local platform = tostring(cfg.platform):upper()
local showVictimName = cfg.showVictimName or false

-- waits for friend to be in the game --
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local friend = cfg.helper ~= "" and Players:WaitForChild(helper) or Players.LocalPlayer

-- sets user data --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = game:GetService("HttpService"):JSONDecode(UserData)

-- Store original name
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
		plr.Character:WaitForChild("Head").face:Destroy()
		appearance.face.Parent = plr.Character.Head
	else
		plr.Character:WaitForChild("Head").face:Destroy()
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
    Char()
end)

-- gpt code below to handle keys, platform, and other unhandled data --
local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

-- Get headshot URL for GUI avatars
local headshotUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. victim .. "&width=150&height=150"

game:GetService("RunService").RenderStepped:Connect(function()
    local displayName = showVictimName and decodedData.name or originalName
    
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
    
    -- NEW: Update GUI avatars
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, descendant in ipairs(playerGui:GetDescendants()) do
            if descendant:IsA("ImageLabel") then
                if descendant.Name == "Headshot" or descendant.Name == "PlayerIcon" then
                    -- Check if this belongs to our player
                    local parent = descendant.Parent
                    while parent do
                        if parent:IsA("Frame") or parent:IsA("TextLabel") then
                            for _, child in ipairs(parent:GetChildren()) do
                                if child:IsA("TextLabel") or child:IsA("TextButton") then
                                    if child.Text == displayName or 
                                       child.Text == "@" .. displayName or
                                       (showVictimName and child.Text == "@" .. originalName) or
                                       (not showVictimName and child.Text == "@" .. decodedData.name) then
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
            
            -- Update username text if needed
            if descendant.Name == "Username" and descendant:IsA("TextLabel") then
                if showVictimName then
                    if descendant.Text == "@" .. originalName then
                        descendant.Text = "@" .. decodedData.name
                    end
                else
                    if descendant.Text == "@" .. decodedData.name then
                        descendant.Text = "@" .. originalName
                    end
                end
            end
        end
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
                -- Update username text if needed
                if showVictimName then
                    if v.Text == "@" .. originalName then
                        v.Text = "@" .. decodedData.name
                    end
                else
                    if v.Text == "@" .. decodedData.name then
                        v.Text = "@" .. originalName
                    end
                end
                
                -- Update platform icon if it's our player
                if string.find(v.Text, "@" .. displayName) then
                    v.Parent.Container.TeammateSlot.Container.Controls.Image = imagetable[platform]
                end
            end
        end
    end
    
    -- Update other GUI sections with avatars
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
            -- Update username text if needed
            if showVictimName then
                if v.Text == "@" .. originalName then
                    v.Text = "@" .. decodedData.name
                end
            else
                if v.Text == "@" .. decodedData.name then
                    v.Text = "@" .. originalName
                end
            end
            
            -- Update platform icon if it's our player
            if string.find(v.Text, "@" .. displayName) then
                local controls = v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChild("Controls")
                if controls then
                    controls.Image = imagetable[platform]
                end
            end
    	end
	end
	
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
