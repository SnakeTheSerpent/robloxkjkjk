-- Undetectable Player Mover (Ctrl+Click to Move Player)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Settings
local MOVE_SPEED = 25  -- Movement speed (lower = smoother but slower)
local JUMP_HEIGHT = 50 -- Jump force
local MAX_DISTANCE = 100 -- Max distance to move players (studs)

-- Variables
local TargetPlayer = nil
local IsMovingPlayer = false

-- Get Mouse Target Position
local function GetMousePosition()
    local mouse = LocalPlayer:GetMouse()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)
    return raycastResult and raycastResult.Position or (mouse.UnitRay.Origin + (mouse.UnitRay.Direction * 100))
end

-- Smoothly Move Player to Position
local function MovePlayerToPosition(player, targetPos)
    if not player.Character then return end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
    if not rootPart then return end
    
    -- Apply slight jump effect
    if player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    -- Smooth movement (avoids teleport detection)
    local startPos = rootPart.Position
    local direction = (targetPos - startPos).Unit
    local distance = (targetPos - startPos).Magnitude
    
    -- Limit distance
    if distance > MAX_DISTANCE then
        targetPos = startPos + (direction * MAX_DISTANCE)
        distance = MAX_DISTANCE
    end
    
    -- Gradual movement
    local steps = math.ceil(distance / MOVE_SPEED)
    for i = 1, steps do
        if not rootPart or not rootPart.Parent then break end
        
        local newPos = startPos + (direction * (distance * (i/steps)))
        rootPart.Velocity = direction * MOVE_SPEED * 2
        rootPart.CFrame = CFrame.new(newPos)
        
        RunService.Heartbeat:Wait()
    end
    
    -- Final position lock
    if rootPart and rootPart.Parent then
        rootPart.Velocity = Vector3.new(0, JUMP_HEIGHT, 0) -- Small jump
        rootPart.CFrame = CFrame.new(targetPos)
    end
end

-- Player Selection (Ctrl+Click)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Ctrl + Click to select player under mouse
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouseTarget = LocalPlayer:GetMouse().Target
        if mouseTarget and mouseTarget.Parent then
            local player = Players:GetPlayerFromCharacter(mouseTarget.Parent)
            if player then
                TargetPlayer = player
                print("Selected:", player.Name)
            end
        end
    end
    
    -- Ctrl + U to move selected player to mouse
    if input.KeyCode == Enum.KeyCode.U and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if TargetPlayer then
            local mousePos = GetMousePosition()
            MovePlayerToPosition(TargetPlayer, mousePos)
            print("Moved", TargetPlayer.Name, "to cursor")
        end
    end
end)

print([[
Undetectable Player Mover Loaded!
• Ctrl + Click = Select player
• Ctrl + U = Move player to cursor
]])
