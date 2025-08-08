-- Sticky Player Dragger (Ctrl+Click to stick, Ctrl+U to drag)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Settings
local STICK_OFFSET = Vector3.new(0, 0, -2) -- How close you stick to them
local DRAG_SPEED = 30 -- Movement speed when dragging

-- Variables
local StuckToPlayer = nil
local Connection = nil

-- Get Mouse Position in 3D World
local function GetMousePosition()
    local mouse = LocalPlayer:GetMouse()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)
    return raycastResult and raycastResult.Position or (mouse.UnitRay.Origin + (mouse.UnitRay.Direction * 100))
end

-- Stick to Target Player
local function StickToPlayer(target)
    if not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso")
    local myRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
    
    if not (targetRoot and myRoot) then return end
    
    StuckToPlayer = target
    
    -- Disconnect previous connection if exists
    if Connection then Connection:Disconnect() end
    
    -- Create persistent connection to stick together
    Connection = RunService.Heartbeat:Connect(function()
        if not (StuckToPlayer and StuckToPlayer.Character and LocalPlayer.Character) then
            Connection:Disconnect()
            return
        end
        
        targetRoot = StuckToPlayer.Character:FindFirstChild("HumanoidRootPart") or StuckToPlayer.Character:FindFirstChild("Torso")
        myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")
        
        if targetRoot and myRoot then
            -- Force both positions to stay locked
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(STICK_OFFSET)
            targetRoot.Velocity = Vector3.new(0, 0, 0)
            myRoot.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    print("Stuck to:", target.Name)
end

-- Drag Both Players to Mouse
local function DragToMouse()
    if not StuckToPlayer then
        print("Not stuck to anyone!")
        return
    end
    
    local targetRoot = StuckToPlayer.Character and (StuckToPlayer.Character:FindFirstChild("HumanoidRootPart") or StuckToPlayer.Character:FindFirstChild("Torso"))
    local myRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
    
    if not (targetRoot and myRoot) then return end
    
    local mousePos = GetMousePosition()
    local direction = (mousePos - targetRoot.Position).Unit
    
    -- Smooth movement toward cursor
    for i = 1, DRAG_SPEED do
        if not (StuckToPlayer and StuckToPlayer.Character and LocalPlayer.Character) then break end
        
        targetRoot = StuckToPlayer.Character:FindFirstChild("HumanoidRootPart") or StuckToPlayer.Character:FindFirstChild("Torso")
        myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")
        
        if targetRoot and myRoot then
            local newPos = targetRoot.Position + (direction * 2)
            targetRoot.CFrame = CFrame.new(newPos)
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(STICK_OFFSET)
        end
        
        RunService.Heartbeat:Wait()
    end
    
    print("Dragged to cursor!")
end

-- Input Bindings
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Ctrl + Click to stick to player
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local target = LocalPlayer:GetMouse().Target
        if target and target.Parent then
            local player = Players:GetPlayerFromCharacter(target.Parent)
            if player then
                StickToPlayer(player)
            end
        end
    end
    
    -- Ctrl + U to drag to mouse
    if input.KeyCode == Enum.KeyCode.U and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        DragToMouse()
    end
    
    -- Ctrl + R to release
    if input.KeyCode == Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if Connection then Connection:Disconnect() end
        StuckToPlayer = nil
        print("Released from player!")
    end
end)

print([[
Sticky Player Controller Loaded!
• Ctrl + Click = Stick to player
• Ctrl + U = Drag both to cursor
• Ctrl + R = Release
]])
