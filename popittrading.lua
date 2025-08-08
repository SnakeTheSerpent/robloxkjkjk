-- Teleport Players to Me GUI
-- Works with Delta Executor
-- Press RightShift to toggle GUI

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local PlayerList = Instance.new("ScrollingFrame")
local TeleportAllBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")

ScreenGui.Name = "TeleportGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "TELEPORT PLAYERS TO ME"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 16

PlayerList.Name = "PlayerList"
PlayerList.Parent = MainFrame
PlayerList.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PlayerList.Position = UDim2.new(0, 5, 0, 35)
PlayerList.Size = UDim2.new(1, -10, 1, -80)
PlayerList.ScrollBarThickness = 5
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)

TeleportAllBtn.Name = "TeleportAllBtn"
TeleportAllBtn.Parent = MainFrame
TeleportAllBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
TeleportAllBtn.Position = UDim2.new(0.5, -100, 1, -40)
TeleportAllBtn.Size = UDim2.new(0, 200, 0, 30)
TeleportAllBtn.Font = Enum.Font.GothamBold
TeleportAllBtn.Text = "TELEPORT ALL"
TeleportAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBtn.Position = UDim2.new(0.5, -25, 1, -80)
CloseBtn.Size = UDim2.new(0, 50, 0, 30)
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Player Button Template
local PlayerButton = Instance.new("TextButton")
PlayerButton.Name = "PlayerButtonTemplate"
PlayerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
PlayerButton.BorderSizePixel = 0
PlayerButton.Size = UDim2.new(1, -10, 0, 30)
PlayerButton.Font = Enum.Font.Gotham
PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerButton.TextSize = 14
PlayerButton.Visible = false
PlayerButton.Parent = PlayerList

-- Teleport Function
local function TeleportPlayer(player)
    if player == LocalPlayer then return end
    
    local targetChar = player.Character
    local myChar = LocalPlayer.Character
    
    if targetChar and myChar then
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
        local myHRP = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso")
        
        if targetHRP and myHRP then
            targetHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -2)
        end
    end
end

-- Update Player List
local function UpdatePlayerList()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") and child.Name ~= "PlayerButtonTemplate" then
            child:Destroy()
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local newButton = PlayerButton:Clone()
            newButton.Name = player.Name
            newButton.Text = player.Name
            newButton.Visible = true
            newButton.Parent = PlayerList
            
            newButton.MouseButton1Click:Connect(function()
                TeleportPlayer(player)
            end)
        end
    end
end

-- Teleport All Players
TeleportAllBtn.MouseButton1Click:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            TeleportPlayer(player)
            task.wait(0.1) -- Prevent crashing
        end
    end
end)

-- Close GUI
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Initial Setup
UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Teleport GUI Loaded",
    Text = "Press RightShift to toggle GUI",
    Duration = 5
})
