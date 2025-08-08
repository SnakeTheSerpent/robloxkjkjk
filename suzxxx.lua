local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup (same as before)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PersistentTeleporter"
ScreenGui.Parent = game.CoreGui

-- [Previous GUI creation code remains the same...]

-- Enhanced Teleport Functions
local function ForceNetworkOwnership(part)
    -- Try to force network ownership to prevent rubber-banding
    pcall(function()
        part:SetNetworkOwner(LocalPlayer)
    end)
end

local function PersistentTeleport(targetRoot, cframe)
    -- Set network ownership first
    ForceNetworkOwnership(targetRoot)
    
    -- Apply teleport in stages for better reliability
    targetRoot.CFrame = cframe
    task.wait(0.1)
    targetRoot.Velocity = Vector3.new(0, 0, 0)
    targetRoot.CFrame = cframe
    task.wait(0.1)
    targetRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    targetRoot.CFrame = cframe
end

local function MakePlayerJump(player)
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Force jump and reset state
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end

local function TeleportPlayerToMe(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer then
        UpdateStatus("Player not found!")
        return false
    end

    if not (LocalPlayer.Character and targetPlayer.Character) then
        UpdateStatus("Characters not loaded")
        return false
    end

    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso")
    local yourRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")

    if not (targetRoot and yourRoot) then
        UpdateStatus("Missing root parts")
        return false
    end

    -- Calculate position with slight offset
    local targetCFrame = yourRoot.CFrame * CFrame.new(0, 0, -2)
    
    -- Persistent teleport
    PersistentTeleport(targetRoot, targetCFrame)
    
    -- Force jump effect
    MakePlayerJump(targetPlayer)
    
    -- Continuous position enforcement (runs for 3 seconds)
    local startTime = os.time()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if os.time() - startTime > 3 then
            connection:Disconnect()
            return
        end
        targetRoot.CFrame = targetCFrame
        targetRoot.Velocity = Vector3.new(0, 0, 0)
    end)

    UpdateStatus("Teleported "..targetName.." persistently!")
    return true
end

-- [Rest of your existing code...]
