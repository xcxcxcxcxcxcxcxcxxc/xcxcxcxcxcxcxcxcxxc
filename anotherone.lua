local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

repeat task.wait() until game:IsLoaded()

local victimData = HttpService:JSONDecode(game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(getgenv().Config.victim), true))

local CONTROL_ICONS = {
    "rbxassetid://17136633356", -- DESKTOP
    "rbxassetid://17136633510", -- MOBILE  
    "rbxassetid://17136633629", -- CONSOLE
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
helper.Name = victimData.name
helper.DisplayName = victimData.displayName

repeat task.wait() until helper.Character
helper.Character:WaitForChild("Humanoid")
helper.Character.Name = victimData.name
helper.Character.Humanoid.DisplayName = victimData.displayName

helper:SetAttribute("Level", tonumber(getgenv().Config.level))
helper:SetAttribute("StatisticDuelsWinStreak", tonumber(getgenv().Config.streak))
helper:WaitForChild("leaderstats").Level.Value = tonumber(getgenv().Config.level)
helper:WaitForChild("leaderstats"):FindFirstChild("Win Streak").Value = tonumber(getgenv().Config.streak)

if tonumber(getgenv().Config.elo) > 0 then
    helper:SetAttribute("DisplayELO", tonumber(getgenv().Config.elo))
end

-- Character appearance function
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

-- Event-based monitoring for efficiency (from second script)
Players.LocalPlayer:WaitForChild("PlayerGui").DescendantAdded:Connect(function(newElement)
    if newElement.Name == "Username" and newElement:IsA("TextLabel") and newElement.Text and newElement.Text:find("@" .. victimData.name) then
        -- Update controls in various locations
        local parent = newElement.Parent
        while parent do
            if parent:FindFirstChild("Controls") and parent.Controls:IsA("ImageLabel") then
                parent.Controls.Image = CONTROL_ICONS[platformType]
            end
            parent = parent.Parent
        end
    elseif newElement.Name == "Headshot" and newElement:IsA("ImageLabel") and newElement.Image and newElement.Image:find(tostring(victimId)) then
        if newElement.Parent and newElement.Parent:FindFirstChild("Controls") then
            newElement.Parent.Controls.Image = CONTROL_ICONS[platformType]
        end
    elseif newElement.Name == "Icon" and keyCount and newElement:IsA("ImageLabel") and newElement.Image == "rbxassetid://17860673529" then
        if newElement.Parent and newElement.Parent.Parent and newElement.Parent.Parent:FindFirstChild("Title") then
            newElement.Parent.Parent.Title.Text = keyCount
            -- Keep it updated
            newElement.Parent.Parent.Title:GetPropertyChangedSignal("Text"):Connect(function()
                if newElement.Parent.Parent.Title.Text ~= keyCount then
                    newElement.Parent.Parent.Title.Text = keyCount
                end
            end)
        end
    end
end)

-- Also use RenderStepped for maximum coverage (from first script)
RunService.RenderStepped:Connect(function()
    -- Update nametag controls every frame to be sure
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
        
        -- Also update any other controls in the character
        for _, descendant in ipairs(root:GetDescendants()) do
            if descendant.Name == "Controls" and descendant:IsA("ImageLabel") then
                descendant.Image = CONTROL_ICONS[platformType]
            end
        end
    end
end)

if getgenv().Config.unlockall then
    task.wait(15)
    loadstring(game:HttpGet("https://pastebin.com/raw/cm2q8rm0"))()
end
