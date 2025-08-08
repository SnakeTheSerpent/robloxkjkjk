-- Silent Player Controller with Minimal Alerts
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lastAlert = 0 -- Rate limiter

local function Alert(msg)
    if os.clock() - lastAlert < 1 then return end -- Throttle alerts
    lastAlert = os.clock()
    print("[CONTROL] "..msg)
end

local function GetNearestPlayer()
    if not LocalPlayer.Character then
        Alert("Your character not loaded")
        return nil
    end
    
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")
    if not myRoot then
        Alert("No root part found on you")
        return nil
    end

    local nearestPlayer, minDist = nil, 50 -- Max distance (studs)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
            if root then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearestPlayer = player
                end
            end
        end
    end
    
    if not nearestPlayer then
        Alert("No players nearby ("..math.floor(minDist).."++ studs)")
    end
    return nearestPlayer
end

local function ControlPlayer(action)
    local target = GetNearestPlayer()
    if not target then return false end
    
    if not target.Character then
        Alert(target.Name.." has no character")
        return false
    end

    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
    local root = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso")
    
    if not humanoid then
        Alert(target.Name.." has no humanoid")
        return false
    end
    
    if not root then
        Alert(target.Name.." has no root part")
        return false
    end

    -- Execute control
    if action == "Jump" then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        Alert("Made "..target.Name.." jump")
        return true
    else
        local moveDir = Vector3.new(0,0,0)
        local speed = 12
        
        if action == "Forward" then moveDir = root.CFrame.LookVector * speed
        elseif action == "Backward" then moveDir = -root.CFrame.LookVector * speed
        elseif action == "Left" then moveDir = -root.CFrame.RightVector * speed
        elseif action == "Right" then moveDir = root.CFrame.RightVector * speed end
        
        root.Velocity = Vector3.new(moveDir.X, root.Velocity.Y, moveDir.Z)
        Alert("Moved "..target.Name.." "..action:lower())
        return true
    end
end

-- Input handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Up then ControlPlayer("Forward")
    elseif input.KeyCode == Enum.KeyCode.Down then ControlPlayer("Backward")
    elseif input.KeyCode == Enum.KeyCode.Left then ControlPlayer("Left")
    elseif input.KeyCode == Enum.KeyCode.Right then ControlPlayer("Right")
    elseif input.KeyCode == Enum.KeyCode.L and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 
        ControlPlayer("Jump")
    end
end)

Alert("Controller ready - Arrow keys to move nearest player | Ctrl+L to jump")
