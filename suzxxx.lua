-- Loadstring for your GitHub
local function main()
    -- Your Discord webhook URL (DO NOT HARDCODE THIS IN A PUBLIC SCRIPT)
    local myPrivateWebhook = "https://discord.com/api/webhooks/1411856749559812218/l8emirnmA7sEMSOeQflxhl1U27Gka987AmSgc1hjmZZCLHvR8SGRuMAyTFmi-pR-cZ9p"

    -- Function to send data to Discord correctly
    local function sendToDiscord(webhookUrl, message)
        local httpService = game:GetService("HttpService")
        local data = {
            content = message
        }
        local jsonData = httpService:JSONEncode(data)
        local headers = {
            ["Content-Type"] = "application/json"
        }
        -- Use the correct HTTP POST function for your executor
        local response = request({
            Url = webhookUrl,
            Method = "POST",
            Headers = headers,
            Body = jsonData
        })
        print("[+] Discord send attempted. Status:", response.StatusCode)
        return response.StatusCode == 200 or response.StatusCode == 204
    end

    -- Test the webhook
    local testMessage = "✅ Webhook test successful! Script loaded by: " .. game.Players.LocalPlayer.Name
    local success = sendToDiscord(myPrivateWebhook, testMessage)

    if success then
        print("✅ Discord webhook is working!")
    else
        warn("❌ Discord webhook failed. Check the URL and executor's HTTP permissions.")
    end
end

-- Start the script
main()
