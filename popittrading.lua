-- Enhanced Teleport Calculator with Advanced Features
-- Works with Delta/Synapse/Krnl

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Anti-detection variables
local ProtectedMode = true
local TeleportHistory = {}
local LastTeleportTime = 0

-- GUI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportPro"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 420)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "TELEPORT PRO v2.0"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 14
Title.Parent = TitleBar

-- Tab System
local Tabs = {"Calculator", "Waypoints", "Settings"}
local TabButtons = {}
local TabFrames = {}

for i, tabName in ipairs(Tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Text = tabName
    tabButton.Size = UDim2.new(0.33, -2, 0, 30)
    tabButton.Position = UDim2.new((i-1)*0.33, 0, 0, 30)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Parent = MainFrame
    
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 1, -60)
    tabFrame.Position = UDim2.new(0, 0, 0, 60)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = i == 1
    tabFrame.Parent = MainFrame
    
    TabButtons[tabName] = tabButton
    TabFrames[tabName] = tabFrame
    
    tabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        tabFrame.Visible = true
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
        tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)
end

-- Calculator Tab
local CalcFrame = TabFrames["Calculator"]

local function CreateInput(parent, name, yPos, defaultValue)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 25)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Text = name .. ":"
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.7, 0, 1, 0)
    input.Position = UDim2.new(0.3, 5, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    input.TextColor3 = Color3.white
    input.Text = tostring(defaultValue)
    input.PlaceholderText = name
    input.Parent = frame
    
    return input
end

local XInput = CreateInput(CalcFrame, "X", 10, 0)
local YInput = CreateInput(CalcFrame, "Y", 40, 0)
local ZInput = CreateInput(CalcFrame, "Z", 70, 0)
local DistanceInput = CreateInput(CalcFrame, "Distance", 100, 10)
local AngleInput = CreateInput(CalcFrame, "Angle (deg)", 130, 0)

local ResultLabel = Instance.new("TextLabel")
ResultLabel.Text = "Target Position: (0, 0, 0)"
ResultLabel.Size = UDim2.new(1, -20, 0, 20)
ResultLabel.Position = UDim2.new(0, 10, 0, 160)
ResultLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
ResultLabel.TextXAlignment = Enum.TextXAlignment.Left
ResultLabel.Parent = CalcFrame

local CalculateBtn = Instance.new("TextButton")
CalculateBtn.Text = "CALCULATE POSITION"
CalculateBtn.Size = UDim2.new(1, -20, 0, 25)
CalculateBtn.Position = UDim2.new(0, 10, 0, 190)
CalculateBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
CalculateBtn.Parent = CalcFrame

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Text = "TELEPORT"
TeleportBtn.Size = UDim2.new(1, -20, 0, 25)
TeleportBtn.Position = UDim2.new(0, 10, 0, 220)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 80)
TeleportBtn.Parent = CalcFrame

-- Waypoints System
local WaypointsFrame = TabFrames["Waypoints"]
local WaypointsList = Instance.new("ScrollingFrame")
WaypointsList.Size = UDim2.new(1, -20, 0.7, 0)
WaypointsList.Position = UDim2.new(0, 10, 0, 10)
WaypointsList.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
WaypointsList.Parent = WaypointsFrame

local WaypointTemplate = Instance.new("TextButton")
WaypointTemplate.Text = "Waypoint"
WaypointTemplate.Size = UDim2.new(1, -10, 0, 25)
WaypointTemplate.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
WaypointTemplate.Visible = false
WaypointTemplate.Parent = WaypointsList

local SaveCurrentBtn = Instance.new("TextButton")
SaveCurrentBtn.Text = "SAVE CURRENT POSITION"
SaveCurrentBtn.Size = UDim2.new(1, -20, 0, 25)
SaveCurrentBtn.Position = UDim2.new(0, 10, 0.8, 0)
SaveCurrentBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
SaveCurrentBtn.Parent = WaypointsFrame

-- Settings Tab
local SettingsFrame = TabFrames["Settings"]

local ProtectionToggle = Instance.new("TextButton")
ProtectionToggle.Text = "ANTI-CHEAT PROTECTION: ON"
ProtectionToggle.Size = UDim2.new(1, -20, 0, 25)
ProtectionToggle.Position = UDim2.new(0, 10, 0, 10)
ProtectionToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
ProtectionToggle.Parent = SettingsFrame

local TeleportMethod = Instance.new("TextLabel")
TeleportMethod.Text = "Teleport Method: CFrame"
TeleportMethod.Size = UDim2.new(1, -20, 0, 25)
TeleportMethod.Position = UDim2.new(0, 10, 0, 40)
TeleportMethod.TextXAlignment = Enum.TextXAlignment.Left
TeleportMethod.TextColor3 = Color3.fromRGB(200, 200, 200)
TeleportMethod.Parent = SettingsFrame

-- Core Functions
local function CalculatePosition()
    local distance = tonumber(DistanceInput.Text) or 0
    local angle = math.rad(tonumber(AngleInput.Text) or 0
    
    local xOffset = distance * math.cos(angle)
    local zOffset = distance * math.sin(angle)
    
    local x = (tonumber(XInput.Text) or 0) + xOffset
    local y = tonumber(YInput.Text) or 0
    local z = (tonumber(ZInput.Text) or 0) + zOffset
    
    return Vector3.new(x, y, z)
end

local function SafeTeleport(position)
    if not LocalPlayer.Character then return end
    
    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")
    if not humanoidRootPart then return end
    
    if ProtectedMode then
        -- Gradual teleport to avoid detection
        local startPos = humanoidRootPart.Position
        local steps = 10
        for i = 1, steps do
            humanoidRootPart.CFrame = CFrame.new(startPos:Lerp(position, i/steps))
            RunService.Heartbeat:Wait()
        end
    else
        -- Instant teleport
        humanoidRootPart.CFrame = CFrame.new(position)
    end
    
    -- Record teleport
    table.insert(TeleportHistory, 1, {
        position = position,
        time = os.time()
    })
    LastTeleportTime = os.time()
end

-- Button Connections
CalculateBtn.MouseButton1Click:Connect(function()
    local position = CalculatePosition()
    ResultLabel.Text = string.format("Target Position: (%.1f, %.1f, %.1f)", position.X, position.Y, position.Z)
end)

TeleportBtn.MouseButton1Click:Connect(function()
    local position = CalculatePosition()
    SafeTeleport(position)
end)

SaveCurrentBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")
        if rootPart then
            local waypoint = WaypointTemplate:Clone()
            waypoint.Text = string.format("Waypoint %d", #WaypointsList:GetChildren())
            waypoint.Position = rootPart.Position
            waypoint.Visible = true
            waypoint.Parent = WaypointsList
            
            waypoint.MouseButton1Click:Connect(function()
                SafeTeleport(waypoint.Position)
            end)
        end
    end
end)

ProtectionToggle.MouseButton1Click:Connect(function()
    ProtectedMode = not ProtectedMode
    ProtectionToggle.Text = "ANTI-CHEAT PROTECTION: " .. (ProtectedMode and "ON" or "OFF")
    ProtectionToggle.BackgroundColor3 = ProtectedMode and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
end)

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Initialization
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Teleport Pro Loaded",
    Text = "Press RightShift to toggle GUI",
    Duration = 5
})
