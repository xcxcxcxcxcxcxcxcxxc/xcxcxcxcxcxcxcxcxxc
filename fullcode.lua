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
helper.Name = victimData.name
helper.UserId = victimData.id
helper.CharacterAppearanceId = victimData.id
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

RunService.RenderStepped:Connect(function()
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
