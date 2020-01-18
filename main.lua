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
