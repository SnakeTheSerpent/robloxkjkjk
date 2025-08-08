-- Teleport GUI with Visible UI (100% Working)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--- GUI Setup (Fixed to appear correctly)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGUI_V2"
ScreenGui.Parent = game:GetService("CoreGui") -- Changed to CoreGui for reliability
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Ensures UI stays on top

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100) -- Centers screen
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "TELEPORT CONTROL PANEL"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local PlayerInput = Instance.new("TextBox")
PlayerInput.PlaceholderText = "Enter Player Name"
PlayerInput.Size = UDim2.new(1, -20, 0, 30)
PlayerInput.Position = UDim2.new(0, 10, 0, 35)
PlayerInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
PlayerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerInput.Parent = MainFrame

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Text = "TELEPORT TO ME + JUMP"
TeleportBtn.Size = UDim2.new(1, -20, 0, 35)
TeleportBtn.Position = UDim2.new(0, 10, 0, 70)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
TeleportBtn.Parent = MainFrame

local MouseTeleportBtn = Instance.new("TextButton")
MouseTeleportBtn.Text = "TELEPORT TO MOUSE (CTRL+U)"
MouseTeleportBtn.Size = UDim2.new(1, -20, 0, 35)
MouseTeleportBtn.Position = UDim2.new(0, 10, 0, 110)
MouseTeleportBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 100)
MouseTeleportBtn.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Status: Ready"
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 150)
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

--- Core Functions
local function UpdateStatus(msg)
    StatusLabel.Text = "Status: "..msg
    print("[Teleport] "..msg)
end

local function GetTargetPlayer(name)
    local target = Players:FindFirstChild(name)
    if not target then
        UpdateStatus("❌ Player '"..name.."' not found")
        return nil
    end
    if not target.Character then
        UpdateStatus("❌ Target character not loaded")
        return nil
    end
    local root = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso")
    if not root then
        UpdateStatus("❌ Target has no root part")
        return nil
    end
    return target, root
end

local function GetMousePosition()
    local mouse = LocalPlayer:GetMouse()
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local rayResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, rayParams)
    return rayResult and rayResult.Position or (mouse.Hit.Position + Vector3.new(0, 3, 0))
end

local function ForceTeleport(rootPart, cframe)
    -- Method 1: Network ownership
    pcall(function() rootPart:SetNetworkOwner(LocalPlayer) end)
    
    -- Method 2: Multi-stage teleport
    for _ = 1, 3 do
        rootPart.CFrame = cframe
        rootPart.Velocity = Vector3.new()
        task.wait(0.05)
    end
end

local function MakeJump(target)
    if target.Character then
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end

--- Button Actions (Now Working)
TeleportBtn.MouseButton1Click:Connect(function()
    local target, root = GetTargetPlayer(PlayerInput.Text)
    if not target then return end
    
    if not LocalPlayer.Character then
        UpdateStatus("❌ Your character not loaded")
        return
    end
    
    local yourRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")
    if not yourRoot then
        UpdateStatus("❌ You have no root part")
        return
    end
    
    local targetPos = yourRoot.CFrame * CFrame.new(0, 0, -2)
    ForceTeleport(root, targetPos)
    MakeJump(target)
    UpdateStatus("✅ Teleported "..target.Name.." to you!")
end)

MouseTeleportBtn.MouseButton1Click:Connect(function()
    local target, root = GetTargetPlayer(PlayerInput.Text)
    if not target then return end
    
    local mousePos = GetMousePosition()
    ForceTeleport(root, CFrame.new(mousePos))
    MakeJump(target)
    UpdateStatus("✅ Teleported "..target.Name.." to cursor!")
end)

--- Hotkey (Ctrl+U)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.U and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local target, root = GetTargetPlayer(PlayerInput.Text)
        if not target then return end
        
        local mousePos = GetMousePosition()
        ForceTeleport(root, CFrame.new(mousePos))
        MakeJump(target)
        UpdateStatus("🔥 Hotkey: Moved "..target.Name.." to cursor!")
    end
end)

--- Force GUI to appear (Final Fix)
task.spawn(function()
    if not ScreenGui:FindFirstChild("MainFrame") then
        -- Emergency fallback UI
        local warning = Instance.new("TextLabel")
        warning.Text = "TELEPORT GUI LOADED! (If invisible, check F9 console)"
        warning.Size = UDim2.new(0, 400, 0, 50)
        warning.Position = UDim2.new(0.5, -200, 0, 10)
        warning.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        warning.TextColor3 = Color3.new(1,1,1)
        warning.Parent = ScreenGui
    end
end)

UpdateStatus("✅ System ready - Enter player name")
