SLASH_PRICE1 = "/price"

local ItemInfo, NS = ...

-- have no idea, how to work with classess from separated files
StringExtension = {}
DKPPrices = {}
DKPMain = {}
ItemInfo = {}

function ItemInfo:new(itemId, itemName, itemLink)
	local item = {}

	item.id = itemId
	item.name = itemName
	item.link = itemLink
	item.minValue = 0

	function item:sayMinBid()
		local strout = string.format( "%s minBid: %d", item.link, item.minValue)
		SendChatMessage(strout, "SAY",nil,nil)
	end    

	return item
end

function ItemInfo:SayMinBid(item)
	local strout = string.format( "%s minBid: %d", item.link, item.minValue)
	print(strout)
	--SendChatMessage(strout, "SAY",nil,nil)
end

SlashCmdList["PRICE"] = function(lnk)
	lnk = StringExtension:trim(lnk)
	if lnk=="" then
		return
	end
	if lnk then
		
		local isEnabling = DKPMain:TryToMatchEnableDisable(lnk)
		if isEnabling then
			DKPMain:WriteEnableState()
			return
		end

		local split = DKPMain:TrySplitItems(lnk)
		if split then
			for key in pairs(split) do
				local s = string.format("split: %s %s", item, split[key])
				print(s)			
			end
			return
		else
		end
		local id = DKPMain:TryToMatchItem(lnk)
		if id then
			local item = DKPPrices[id]
			if item then 
				ItemInfo:SayMinBid(item)
			else 			
				local itemName, itemLink, itemRarity, itemLvl, itemMinLvl, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(id)
				print(string.format("itemId: %s | itemName: %s | itemLink: %s", id, itemName, itemLink))
				local iInfo = ItemInfo:new(id, itemName, itemLink)
				DKPPrices[id] = iInfo
			end	
		end

	else
		print("Wrong item link specified")
	end
end

function DKPMain:TrySplitItems(text)
	local t = StringExtension:split(text, ",")	
	return t
end

function DKPMain:TryToMatchItem(text)
	local itemString = string.match(text, "item[%-?%d:]+")
	if itemString then
		local _, id = strsplit(":", itemString)
		if id then
			return id
		end		
	end

	return nil
end

-- ## Try to Match Enable/Disable text
function DKPMain:TryToMatchEnableDisable(text)
	local isMatch = string.match(text, "enable")
	if isMatch then
		DKPPrices["enable"] = 1
		return 1			
	end
	local isMatch = string.match(text, "disable")
	if isMatch then
		DKPPrices["enable"] = 0
		return 1
	end
	return nil
end

-- ## Write state to console log
function DKPMain:WriteEnableState()
	local state = DKPMain:GetEnableState()
	local stateStr = string.format("DKP Prices: enable = %d", state)
	print(stateStr)
end

-- ## Return enabled state
function DKPMain:GetEnableState()
	local state = DKPPrices["enable"]
	if state then
		return state
	end

	return 1;
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("LOOT_OPENED")
frame:SetScript("OnEvent", function(self, event, arg1)
	local isEnabled = DKPMain:GetEnableState()
	if isEnabled==0 then
		return
	end	
	
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
					--SendChatMessage(linkstext, "SAY", nil, nil)
					local itemIdstr = string.match(linkstext, "item[%-?%d:]+")
					--SendChatMessage(itemIdstr, "SAY", nil, nil)

					local _, id = strsplit(":", itemIdstr)
					--SendChatMessage(id, "SAY", nil,nil)
				end
			end
			
		--end if
	end

end)

function StringExtension:split (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local count=0
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
			count=count+1			
	end
	t["count"]=count
	return t
end

function StringExtension:trim (s)	
	return s:match "^%s*(.-)%s*$"	
end