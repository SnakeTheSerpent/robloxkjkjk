-- Pop It Trading Script for Delta Executor
-- Auto-Accepts Trades & Detects Offers

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TradeService = game:GetService("ReplicatedStorage"):FindFirstChild("TradeService") or game:GetService("ReplicatedStorage"):FindFirstChild("TradeHandler")

if not TradeService then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "Trade system not found!",
        Duration = 5
    })
    return
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AutoAcceptToggle = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "PopItTradingGUI"

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0.5, -125, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "POP IT TRADING"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

AutoAcceptToggle.Parent = Frame
AutoAcceptToggle.Text = "AUTO-ACCEPT: OFF"
AutoAcceptToggle.Size = UDim2.new(0.8, 0, 0, 30)
AutoAcceptToggle.Position = UDim2.new(0.1, 0, 0.3, 0)
AutoAcceptToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AutoAcceptToggle.TextColor3 = Color3.fromRGB(255, 255, 255)

StatusLabel.Parent = Frame
StatusLabel.Text = "Waiting for trades..."
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.6, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

-- Trade Logic
local AutoAcceptEnabled = false

AutoAcceptToggle.MouseButton1Click:Connect(function()
    AutoAcceptEnabled = not AutoAcceptEnabled
    AutoAcceptToggle.Text = AutoAcceptEnabled and "AUTO-ACCEPT: ON ✅" or "AUTO-ACCEPT: OFF ❌"
    StatusLabel.Text = AutoAcceptEnabled and "Ready to auto-accept!" or "Auto-accept disabled."
end)

-- Detect incoming trades
TradeService.ChildAdded:Connect(function(tradeRequest)
    if AutoAcceptEnabled then
        StatusLabel.Text = "Trade detected! Accepting..."
        wait(1) -- Delay to prevent instant accept (optional)
        tradeRequest:InvokeServer("Accept")
        StatusLabel.Text = "Trade accepted!"
    end
end)

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Pop It Trading",
    Text = "Script loaded! Drag the GUI.",
    Duration = 5
})
