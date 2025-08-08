-- Player Controller with GUI Selection
-- [Ctrl+L] = Jump | Arrow Keys = Movement

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 250)
Frame.Position = UDim2.new(0.5, -100, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "PLAYER CONTROLLER"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Parent = Frame

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -10, 0.7, -10)
PlayerList.Position = UDim2.new(0, 5, 0, 35)
PlayerList.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
PlayerList.Parent = Frame

local TemplateButton = Instance.new("TextButton")
TemplateButton.Size = UDim2.new(1, -10, 0, 25)
TemplateButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
TemplateButton.Visible = false
TemplateButton.Parent = PlayerList

-- Variables
local TargetPlayer = nil
local IsControlling = false

-- Update Player List
local function UpdateList()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") and child ~= TemplateButton then
            child:Destroy()
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = TemplateButton:Clone()
            btn.Text = player.Name
            btn.Visible = true
            btn.Parent = PlayerList
            
            btn.MouseButton1Click:Connect(function()
                TargetPlayer = player
                Title.Text = "CONTROLLING: "..player.Name
            end)
        end
    end
end

-- Control Functions
local function ControlCharacter(action)
    if not TargetPlayer or not TargetPlayer.Character then return end
    
    local humanoid = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local root = TargetPlayer.Character:FindFirstChild("HumanoidRootPart") or TargetPlayer.Character:FindFirstChild("Torso")
    
    if not (humanoid and root) then return end
    
    if action == "Jump" then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    else
        local moveDir = Vector3.new(0,0,0)
        local speed = 8
        
        if action == "Forward" then moveDir = root.CFrame.LookVector * speed
        elseif action == "Backward" then moveDir = -root.CFrame.LookVector * speed
        elseif action == "Left" then moveDir = -root.CFrame.RightVector * speed
        elseif action == "Right" then moveDir = root.CFrame.RightVector * speed end
        
        root.Velocity = Vector3.new(moveDir.X, root.Velocity.Y, moveDir.Z)
    end
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle control mode with Ctrl+Space
    if input.KeyCode == Enum.KeyCode.Space and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        IsControlling = not IsControlling
        print("Control mode:", IsControlling)
    end
    
    if not IsControlling then return end
    
    -- Movement controls
    if input.KeyCode == Enum.KeyCode.Up then ControlCharacter("Forward")
    elseif input.KeyCode == Enum.KeyCode.Down then ControlCharacter("Backward")
    elseif input.KeyCode == Enum.KeyCode.Left then ControlCharacter("Left")
    elseif input.KeyCode == Enum.KeyCode.Right then ControlCharacter("Right")
    elseif input.KeyCode == Enum.KeyCode.L and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 
        ControlCharacter("Jump")
    end
end)

-- Initialize
UpdateList()
Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)

print([[
Player Controller Loaded!
• Click a name to select player
• Ctrl+Space = Toggle control mode
• Arrow Keys = Move player
• Ctrl+L = Make player jump
]])
