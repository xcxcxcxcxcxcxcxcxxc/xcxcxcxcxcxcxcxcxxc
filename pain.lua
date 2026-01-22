local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

repeat task.wait() until game:IsLoaded()

local victimData = HttpService:JSONDecode(game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(getgenv().Config.victim), true))

local helperName = getgenv().Config.helper ~= "" and getgenv().Config.helper or Players.LocalPlayer.Name
local helper = Players:WaitForChild(helperName)

repeat task.wait() until helper.Character
helper.Character:WaitForChild("Humanoid")

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
