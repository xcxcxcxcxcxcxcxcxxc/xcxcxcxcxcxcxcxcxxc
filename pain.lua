repeat
  task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local victimData = HttpService:JSONDecode(game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(getgenv().Config.victim), true))

local CONTROL_ICONS = {
    DESKTOP = "rbxassetid://17136633356",
    MOBILE = "rbxassetid://17136633510",
    CONSOLE = "rbxassetid://17136633629",
    VR = "rbxassetid://17136765745"
}

local platformType = getgenv().Config.platform and getgenv().Config.platform:upper() or "DESKTOP"
local victimId = getgenv().Config.victim
local keyCount = getgenv().Config.keys

-- Determine helper player
local helperName = getgenv().Config.helper ~= "" and getgenv().Config.helper or Players.LocalPlayer.Name
local helper = Players:WaitForChild(helperName)

-- Apply basic spoofing
helper.Name = victimData.name
helper.DisplayName = victimData.displayName

-- These might not work as they're server-side properties
-- helper.UserId = victimData.id
-- helper.CharacterAppearanceId = victimData.id

repeat
  task.wait()
until helper.Character

-- Set attributes and stats
helper:SetAttribute("Level", tonumber(getgenv().Config.level))
helper:SetAttribute("StatisticDuelsWinStreak", tonumber(getgenv().Config.streak))
helper:WaitForChild("leaderstats").Level.Value = tonumber(getgenv().Config.level)

if tonumber(getgenv().Config.streak) > 0 then
  if helper:WaitForChild("leaderstats"):FindFirstChild("Win Streak") then
    helper:WaitForChild("leaderstats"):FindFirstChild("Win Streak").Value = tonumber(getgenv().Config.streak)
  end
end

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
            char:WaitForChild("Humanoid")
            char.Humanoid:AddAccessory(item)
        end
    end
    
    if victimLook:FindFirstChild("face") then
        char:WaitForChild("Head").face:Destroy()
        victimLook.face.Parent = char.Head
    else
        char:WaitForChild("Head").face:Destroy()
        local face = Instance.new("Decal")
        face.Face = Enum.NormalId.Front
        face.Name = "face"
        face.Texture = "rbxasset://textures/face.png"
        face.Transparency = 0
        face.Parent = char.Head
    end
    
    -- Refresh character
    local currentParent = char.Parent
    char.Parent = nil
    char.Parent = currentParent
end

ChangeAppearance()
helper.CharacterAdded:Connect(ChangeAppearance)

-- Initial scan for GUI elements
for _, element in ipairs(Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
    if element.Name == "Username" and element:IsA("TextLabel") and element.Text and element.Text:find("@" .. victimData.name) then
        if element.Parent and element.Parent:IsA("Frame") and element.Parent:FindFirstChild("Container") and 
           element.Parent.Container:FindFirstChild("TeammateSlot") and 
           element.Parent.Container.TeammateSlot:FindFirstChild("Container") and 
           element.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls") and 
           (element.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image == CONTROL_ICONS.DESKTOP or 
            element.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image == CONTROL_ICONS.MOBILE or 
            element.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image == CONTROL_ICONS.CONSOLE or 
            element.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image == CONTROL_ICONS.VR) then
            element.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image = CONTROL_ICONS[platformType]
        end
        
        if element.Parent and element.Parent.Parent and element.Parent.Parent:IsA("Frame") and 
           element.Parent.Parent:FindFirstChild("Controls") and 
           (element.Parent.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.DESKTOP or 
            element.Parent.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.MOBILE or 
            element.Parent.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.CONSOLE or 
            element.Parent.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.VR) then
            element.Parent.Parent:FindFirstChild("Controls").Image = CONTROL_ICONS[platformType]
        end
    elseif element.Name == "Headshot" and element:IsA("ImageLabel") and element.Image and element.Image:find(tostring(victimId)) then
        if element.Parent and element.Parent:IsA("Frame") and element.Parent:FindFirstChild("Controls") and 
           (element.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.DESKTOP or 
            element.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.MOBILE or 
            element.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.CONSOLE or 
            element.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.VR) then
            element.Parent:FindFirstChild("Controls").Image = CONTROL_ICONS[platformType]
        end
    elseif element.Name == "Icon" and keyCount > 0 and element:IsA("ImageLabel") and element.Image == "rbxassetid://17860673529" and 
           element.Parent and element.Parent.Parent and element.Parent.Parent:FindFirstChild("Title") then
        element.Parent.Parent.Title.Text = keyCount
        element.Parent.Parent.Title:GetPropertyChangedSignal("Text"):Connect(function()
            if element.Parent.Parent.Title.Text ~= tostring(keyCount) then
                element.Parent.Parent.Title.Text = keyCount
            end
        end)
    end
end

-- Monitor for new GUI elements
Players.LocalPlayer:WaitForChild("PlayerGui").DescendantAdded:Connect(function(newElement)
    if newElement.Name == "Username" and newElement:IsA("TextLabel") and newElement.Text and newElement.Text:find("@" .. victimData.name) then
        if newElement.Parent and newElement.Parent:IsA("Frame") and newElement.Parent:FindFirstChild("Container") and 
           newElement.Parent.Container:FindFirstChild("TeammateSlot") and 
           newElement.Parent.Container.TeammateSlot:FindFirstChild("Container") and 
           newElement.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls") and 
           (newElement.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image == CONTROL_ICONS.DESKTOP or 
            newElement.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image == CONTROL_ICONS.MOBILE or 
            newElement.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image == CONTROL_ICONS.CONSOLE or 
            newElement.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image == CONTROL_ICONS.VR) then
            newElement.Parent.Container.TeammateSlot.Container:FindFirstChild("Controls").Image = CONTROL_ICONS[platformType]
        end
        
        if newElement.Parent and newElement.Parent.Parent and newElement.Parent.Parent:IsA("Frame") and 
           newElement.Parent.Parent:FindFirstChild("Controls") and 
           (newElement.Parent.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.DESKTOP or 
            newElement.Parent.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.MOBILE or 
            newElement.Parent.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.CONSOLE or 
            newElement.Parent.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.VR) then
            newElement.Parent.Parent:FindFirstChild("Controls").Image = CONTROL_ICONS[platformType]
        end
    elseif newElement.Name == "Headshot" and newElement:IsA("ImageLabel") and newElement.Image and newElement.Image:find(tostring(victimId)) then
        if newElement.Parent and newElement.Parent:IsA("Frame") and newElement.Parent:FindFirstChild("Controls") and 
           (newElement.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.DESKTOP or 
            newElement.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.MOBILE or 
            newElement.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.CONSOLE or 
            newElement.Parent:FindFirstChild("Controls").Image == CONTROL_ICONS.VR) then
            newElement.Parent:FindFirstChild("Controls").Image = CONTROL_ICONS[platformType]
        end
    elseif newElement.Name == "Icon" and keyCount > 0 and newElement:IsA("ImageLabel") and newElement.Image == "rbxassetid://17860673529" and 
           newElement.Parent and newElement.Parent.Parent and newElement.Parent.Parent:FindFirstChild("Title") then
        newElement.Parent.Parent.Title.Text = keyCount
        newElement.Parent.Parent.Title:GetPropertyChangedSignal("Text"):Connect(function()
            if newElement.Parent.Parent.Title.Text ~= tostring(keyCount) then
                newElement.Parent.Parent.Title.Text = keyCount
            end
        end)
    end
end)

-- Update nametag controls
if helper.Character and helper.Character:FindFirstChild("HumanoidRootPart") then
    for _, element in ipairs(helper.Character:FindFirstChild("HumanoidRootPart"):GetDescendants()) do
        if element.Name == "Controls" and element:IsA("ImageLabel") and 
           (element.Image == CONTROL_ICONS.DESKTOP or element.Image == CONTROL_ICONS.MOBILE or 
            element.Image == CONTROL_ICONS.CONSOLE or element.Image == CONTROL_ICONS.VR) then
            element.Image = CONTROL_ICONS[platformType]
        end
    end
    
    helper.Character:FindFirstChild("HumanoidRootPart").DescendantAdded:Connect(function(newElement)
        if newElement.Name == "Controls" and newElement:IsA("ImageLabel") and 
           (newElement.Image == CONTROL_ICONS.DESKTOP or newElement.Image == CONTROL_ICONS.MOBILE or 
            newElement.Image == CONTROL_ICONS.CONSOLE or newElement.Image == CONTROL_ICONS.VR) then
            newElement.Image = CONTROL_ICONS[platformType]
        end
    end)
end

-- Handle character respawns
helper.CharacterAdded:Connect(function(newChar)
    if newChar:WaitForChild("HumanoidRootPart", 5) then
        for _, element in ipairs(newChar:WaitForChild("HumanoidRootPart", 5):GetDescendants()) do
            if element.Name == "Controls" and element:IsA("ImageLabel") and 
               (element.Image == CONTROL_ICONS.DESKTOP or element.Image == CONTROL_ICONS.MOBILE or 
                element.Image == CONTROL_ICONS.CONSOLE or element.Image == CONTROL_ICONS.VR) then
                element.Image = CONTROL_ICONS[platformType]
            end
        end
        
        newChar:WaitForChild("HumanoidRootPart", 5).DescendantAdded:Connect(function(newElement)
            if newElement.Name == "Controls" and newElement:IsA("ImageLabel") and 
               (newElement.Image == CONTROL_ICONS.DESKTOP or newElement.Image == CONTROL_ICONS.MOBILE or 
                newElement.Image == CONTROL_ICONS.CONSOLE or newElement.Image == CONTROL_ICONS.VR) then
                newElement.Image = CONTROL_ICONS[platformType]
            end
        end)
    end
end)

if getgenv().Config.unlockall then
    task.wait(15)
    loadstring(game:HttpGet("https://pastebin.com/raw/cm2q8rm0"))()
end
