-- Control Player Script for Delta Executor
-- Includes GUI for easy control

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local PlayerList = Instance.new("ScrollingFrame")
local ControlFrame = Instance.new("Frame")
local MoveButtons = {
    Forward = Instance.new("TextButton"),
    Backward = Instance.new("TextButton"),
    Left = Instance.new("TextButton"),
    Right = Instance.new("TextButton")
}
local TeleportBtn = Instance.new("TextButton")
local FreezeBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")

ScreenGui.Name = "ControlGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "PLAYER CONTROLLER"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 16

PlayerList.Name = "PlayerList"
PlayerList.Parent = MainFrame
PlayerList.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PlayerList.Position = UDim2.new(0, 5, 0, 35)
PlayerList.Size = UDim2.new(0.45, -10, 0.7, -5)
PlayerList.ScrollBarThickness = 5
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y

ControlFrame.Name = "ControlFrame"
ControlFrame.Parent = MainFrame
ControlFrame.BackgroundTransparency = 1
ControlFrame.Position = UDim2.new(0.5, 5, 0, 35)
ControlFrame.Size = UDim2.new(0.5, -10, 0.7, -5)

-- Movement Buttons
local buttonProps = {
    Forward = {Text = "↑", Position = UDim2.new(0.3, 0, 0.1, 0)},
    Backward = {Text = "↓", Position = UDim2.new(0.3, 0, 0.5, 0)},
    Left = {Text = "←", Position = UDim2.new(0.05, 0, 0.3, 0)},
    Right = {Text = "→", Position = UDim2.new(0.55, 0, 0.3, 0)}
}

for name, props in pairs(buttonProps) do
    local btn = MoveButtons[name]
    btn.Text = props.Text
    btn.Size = UDim2.new(0.4, 0, 0.2, 0)
    btn.Position = props.Position
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = ControlFrame
end

TeleportBtn.Name = "TeleportBtn"
TeleportBtn.Parent = MainFrame
TeleportBtn.Text = "TELEPORT TO ME"
TeleportBtn.Size = UDim2.new(0.45, -10, 0, 30)
TeleportBtn.Position = UDim2.new(0, 5, 0.75, 0)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

FreezeBtn.Name = "FreezeBtn"
FreezeBtn.Parent = MainFrame
FreezeBtn.Text = "FREEZE"
FreezeBtn.Size = UDim2.new(0.45, -10, 0, 30)
FreezeBtn.Position = UDim2.new(0.5, 5, 0.75, 0)
FreezeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
FreezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.Text = "CLOSE"
CloseBtn.Size = UDim2.new(0.9, 0, 0, 30)
CloseBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
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

-- Variables
local SelectedPlayer = nil
local FrozenPlayers = {}

-- Functions
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
                SelectedPlayer = player
                Title.Text = "CONTROLLING: " .. player.Name
            end)
        end
    end
end

local function MovePlayer(direction)
    if not SelectedPlayer or not SelectedPlayer.Character then return end
    
    local humanoid = SelectedPlayer.Character:FindFirstChild("Humanoid")
    local rootPart = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") or SelectedPlayer.Character:FindFirstChild("Torso")
    
    if humanoid and rootPart then
        local moveVector = Vector3.new(0, 0, 0)
        
        if direction == "Forward" then
            moveVector = rootPart.CFrame.LookVector * 5
        elseif direction == "Backward" then
            moveVector = -rootPart.CFrame.LookVector * 5
        elseif direction == "Left" then
            moveVector = -rootPart.CFrame.RightVector * 5
        elseif direction == "Right" then
            moveVector = rootPart.CFrame.RightVector * 5
        end
        
        rootPart.CFrame = rootPart.CFrame + moveVector
    end
end

local function TeleportToMe()
    if not SelectedPlayer or not SelectedPlayer.Character then return end
    
    local targetRoot = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") or SelectedPlayer.Character:FindFirstChild("Torso")
    local myRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
    
    if targetRoot and myRoot then
        targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
    end
end

local function ToggleFreeze()
    if not SelectedPlayer or not SelectedPlayer.Character then return end
    
    local humanoid = SelectedPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        if FrozenPlayers[SelectedPlayer] then
            humanoid.WalkSpeed = 16 -- Default speed
            FrozenPlayers[SelectedPlayer] = nil
            FreezeBtn.Text = "FREEZE"
        else
            humanoid.WalkSpeed = 0
            FrozenPlayers[SelectedPlayer] = true
            FreezeBtn.Text = "UNFREEZE"
        end
    end
end

-- Button Connections
MoveButtons.Forward.MouseButton1Click:Connect(function() MovePlayer("Forward") end)
MoveButtons.Backward.MouseButton1Click:Connect(function() MovePlayer("Backward") end)
MoveButtons.Left.MouseButton1Click:Connect(function() MovePlayer("Left") end)
MoveButtons.Right.MouseButton1Click:Connect(function() MovePlayer("Right") end)

TeleportBtn.MouseButton1Click:Connect(TeleportToMe)
FreezeBtn.MouseButton1Click:Connect(ToggleFreeze)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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
    Title = "Player Controller Loaded",
    Text = "Press RightShift to toggle GUI",
    Duration = 5
})
