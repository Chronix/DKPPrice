SLASH_PRICE1 = "/price"

SlashCmdList["PRICE"] = function(lnk)
	if lnk then
		local itemString = string.match(lnk, "item[%-?%d:]+")
		local _, id = strsplit(":", itemString)
		local price = _G.DKPPrices[id]
		
		if price then print("Min bid for " .. lnk .. ": " .. price)
		else print("Price not found") end
	else
		print("Wrong item link specified")
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("LOOT_OPENED")
frame:SetScript("OnEvent", function(self, event, arg1)
	print("Minimal DKP values: ")
	
	for i=1,GetNumLootItems() do

		print(i)
		--if LootSlotHasItem(i) then

			local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i)			
			local hasItem = LootSlotHasItem(i)
			
			if hasItem then
				local itemLink = GetLootSlotLink(i)
				
				if itemLink then
					local linkstext = ""
					linkstext=linkstext .. itemLink
					SendChatMessage(linkstext, "SAY", nil, nil)
					local itemIdstr = string.match(linkstext, "item[%-?%d:]+")
					SendChatMessage(itemIdstr, "SAY", nil, nil)

					local _, id = strsplit(":", itemIdstr)
					SendChatMessage(id, "SAY", nil,nil)
				end
			end
			
		--end if
	end

end)