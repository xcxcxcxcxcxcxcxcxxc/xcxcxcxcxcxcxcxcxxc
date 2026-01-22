
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

repeat task.wait() until game:IsLoaded()

local victimData = HttpService:JSONDecode(game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(getgenv().Config.victim), true))

local helperName = getgenv().Config.helper ~= "" and getgenv().Config.helper or Players.LocalPlayer.Name
local helper = Players:WaitForChild(helperName)

repeat task.wait() until helper.Character
helper.Character:WaitForChild("Humanoid")

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

function UpdateGUIAvatars()
    local headshotUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. victimData.id .. "&width=150&height=150"
    
      for _, descendant in ipairs(CoreGui:GetDescendants()) do
        if descendant:IsA("ImageLabel") then
            if descendant.Name == "Headshot" or descendant.Name == "PlayerIcon" or 
               descendant.Name == "AvatarImage" or descendant.Name == "Icon" then
                
                
                local parent = descendant.Parent
                while parent do
                    if parent:IsA("Frame") or parent:IsA("TextLabel") then
                        
                        for _, child in ipairs(parent:GetChildren()) do
                            if child:IsA("TextLabel") or child:IsA("TextButton") then
                                if child.Text == helper.Name or 
                                   child.Text == "@" .. helper.Name or
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
    end
    

    local playerList = CoreGui:FindFirstChild("PlayerList")
    if playerList then
        for _, child in ipairs(playerList:GetDescendants()) do
            if child:IsA("ImageLabel") and (child.Name == "PlayerIcon" or child.Name == "Headshot") then
                local parent = child.Parent
                while parent do
                    for _, sibling in ipairs(parent:GetChildren()) do
                        if (sibling:IsA("TextLabel") or sibling:IsA("TextButton")) and 
                           sibling.Text == helper.Name then
                            child.Image = headshotUrl
                        end
                    end
                    parent = parent.Parent
                end
            end
        end
    end
    
    
    local localPlayer = Players.LocalPlayer
    if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
        for _, descendant in ipairs(localPlayer.PlayerGui:GetDescendants()) do
            if descendant:IsA("ImageLabel") then
                if descendant.Name == "Headshot" or descendant.Name == "PlayerIcon" or 
                   descendant.Name == "AvatarImage" then
                    
                    local parent = descendant.Parent
                    while parent do
                        if parent:IsA("Frame") or parent:IsA("TextLabel") then
                            for _, child in ipairs(parent:GetChildren()) do
                                if child:IsA("TextLabel") or child:IsA("TextButton") then
                                    if child.Text == helper.Name or 
                                       child.Text == "@" .. helper.Name or
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
        end
    end
end


RunService.RenderStepped:Connect(UpdateGUIAvatars)


Players.LocalPlayer.PlayerGui.DescendantAdded:Connect(function(newElement)
    task.wait(0.1) 
    UpdateGUIAvatars()
end)

CoreGui.DescendantAdded:Connect(function(newElement)
    task.wait(0.1)
    UpdateGUIAvatars()
end)

UpdateGUIAvatars()
