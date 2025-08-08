local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateTeleporter"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "ULTIMATE TELEPORTER"
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 14
Title.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Text = "_"
MinimizeBtn.Size = UDim2.new(0, 25, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -25, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Parent = TitleBar

local PlayerInput = Instance.new("TextBox")
PlayerInput.PlaceholderText = "Player Name"
PlayerInput.Size = UDim2.new(1, -20, 0, 25)
PlayerInput.Position = UDim2.new(0, 10, 0, 30)
PlayerInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
PlayerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerInput.Parent = MainFrame

local TeleportToMeBtn = Instance.new("TextButton")
TeleportToMeBtn.Text = "TELEPORT TO ME"
TeleportToMeBtn.Size = UDim2.new(1, -20, 0, 30)
TeleportToMeBtn.Position = UDim2.new(0, 10, 0, 60)
TeleportToMeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
TeleportToMeBtn.Parent = MainFrame

local TeleportToMouseBtn = Instance.new("TextButton")
TeleportToMouseBtn.Text = "TELEPORT TO MOUSE"
TeleportToMouseBtn.Size = UDim2.new(1, -20, 0, 30)
TeleportToMouseBtn.Position = UDim2.new(0, 10, 0, 95)
TeleportToMouseBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 80)
TeleportToMouseBtn.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Status: Ready"
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 130)
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Minimize Functionality
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 250, 0, 25)
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 250, 0, 180)
        MinimizeBtn.Text = "_"
    end
end)

-- Core Functions
local function UpdateStatus(message)
    StatusLabel.Text = "Status: "..message
    print("[Teleporter] "..message)
end

local function GetMousePosition()
    local mouse = LocalPlayer:GetMouse()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)
    return raycastResult and raycastResult.Position or (mouse.UnitRay.Origin + (mouse.UnitRay.Direction * 100))
end

local function ForcePosition(targetRoot, cframe)
    -- Method 1: Standard teleport
    targetRoot.CFrame = cframe
    
    -- Method 2: Velocity cancellation
    targetRoot.Velocity = Vector3.new(0, 0, 0)
    targetRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    
    -- Method 3: Network ownership
    pcall(function()
        targetRoot:SetNetworkOwner(LocalPlayer)
    end)
    
    -- Method 4: Continuous enforcement
    local startTime = os.clock()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if os.clock() - startTime > 3 then
            connection:Disconnect()
            return
        end
        targetRoot.CFrame = cframe
        targetRoot.Velocity = Vector3.new(0, 0, 0)
    end)
end

local function MakePlayerJump(player)
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end

local function TeleportPlayer(targetName, positionGetter)
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer then
        UpdateStatus("Player not found!")
        return false
    end

    if not targetPlayer.Character then
        UpdateStatus(targetName.." has no character")
        return false
    end

    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso")
    if not targetRoot then
        UpdateStatus(targetName.." has no root part")
        return false
    end

    local success, position = pcall(positionGetter)
    if not success then
        UpdateStatus("Position error: "..tostring(position))
        return false
    end

    ForcePosition(targetRoot, CFrame.new(position))
    MakePlayerJump(targetPlayer)
    return true
end

-- Button Connections
TeleportToMeBtn.MouseButton1Click:Connect(function()
    if TeleportPlayer(PlayerInput.Text, function()
        if not LocalPlayer.Character then error("Your character not loaded") end
        local yourRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")
        if not yourRoot then error("You have no root part") end
        return (yourRoot.CFrame * CFrame.new(0, 0, -2)).Position
    end) then
        UpdateStatus("Teleported "..PlayerInput.Text.." to you!")
    end
end)

TeleportToMouseBtn.MouseButton1Click:Connect(function()
    if TeleportPlayer(PlayerInput.Text, function()
        return GetMousePosition() + Vector3.new(0, 3, 0)
    end) then
        UpdateStatus("Teleported "..PlayerInput.Text.." to cursor!")
    end
end)

-- Hotkey for mouse teleport (Ctrl+U)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.U and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if TeleportPlayer(PlayerInput.Text, function()
            return GetMousePosition() + Vector3.new(0, 3, 0)
        end) then
            UpdateStatus("Hotkey: Teleported "..PlayerInput.Text.." to cursor!")
        end
    end
end)

UpdateStatus("System ready - Enter player name")
