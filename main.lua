SLASH_PRICE1 = "/price"

local ItemInfo, StringExtension, NS = ...

-- have no idea, how to work with classess from separated files
DKPPrices = {}
DKPMain = {}
StringExtension = {}
ItemInfo = {}

DKPMain["debug"]=0
debug = DKPMain["debug"]

SlashCmdList["PRICE"] = function(lnk)
	print("DKP price")
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
				if debug==1 then
					print("key "..key)
				end
				if key~="count" then
					if debug==1 then
						local s = string.format("split: %s %s", key, split[key])
						print(s)			
					end
					DKPMain:TryAddItem(split[key])
				end
			end
			return
		else			
			DKPMain:TryAddItem(lnk)
		end
		
	else
		print("Wrong item link specified")
	end
end

function DKPMain:TryAddItem(text)
	if debug==1 then
		print("DKPMain:TryAddItem()"..text)
	end
	
	local trimmed = StringExtension:trim(text)
	local splitItem = StringExtension:splitItemDkp(trimmed)
	
	if splitItem then
		if debug==1 then
			print("s-item: "..splitItem["item"])
			print("s-dkp: "..splitItem["dkp"])
		end

		if splitItem["item"] and splitItem["dkp"] then
			DKPMain:AddOrWriteItem(splitItem["item"], splitItem["dkp"])
		else
			print("DKPPrice failed")
		end
	else
		if debug==1 then
			print("is-split-2 "..text)
		end
		DKPMain:AddOrWriteItem(text, 0)
	end
end

function DKPMain:AddOrWriteItem(lnk, minBid)
	if debug==1 then
		print("DKPMain:AddOrWriteItem "..lnk.." minBid "..minBid)
	end

	if lnk=="" then
		return
	end
	local id = DKPMain:GetItemId(lnk)
	if id then
		local item = DKPPrices[id]
		if item then 			
			if minBid~=0 then
				ItemInfo:setMinBid(item, minBid)
				DKPPrices[id] = item
			end

			ItemInfo:SayMinBid(item)			
		else 						
			local itemName, itemLink, itemRarity, itemLvl, itemMinLvl, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(id)
			if debug==1 then
				print(string.format("itemId: %s | itemName: %s | itemLink: %s", id, itemName, itemLink))
			end
			local iInfo = ItemInfo:new(id, itemName, itemLink)
			if minBid and minBid ~= 0 then
				ItemInfo:setMinBid(iInfo, minBid)
			end
			DKPPrices[id] = iInfo
			ItemInfo:SayMinBid(iInfo)
		end
	end	
end

function DKPMain:TrySplitItems(text)
	local t = StringExtension:split(text, ",")	
	return t
end

function DKPMain:GetItemId(text)
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

		if debug==1 then
			print(i)
		end

		local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i)			
		local hasItem = LootSlotHasItem(i)			
		if hasItem then
			local itemLink = GetLootSlotLink(i)
			
			if itemLink then
				DKPMain:AddOrWriteItem(itemLink, 0)
			end
		end			
	end
end)

function ItemInfo:new(itemId, itemName, itemLink)
	local item = {}

	item.id = itemId
	item.name = itemName
	item.link = itemLink
	item.minValue = 0

	return item
end

function ItemInfo:SayMinBid(item)
	local strout = string.format( "%s minBid: %d", item.link, item.minValue)
	if DKPPrices["enabled"]==1 then
		SendChatMessage(strout, "RAID",nil,nil)
	end
end

function ItemInfo:setMinBid(item, value)
	item.minValue = value
end


function StringExtension:split (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local count=0
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
			count=count+1
			
			if debug==1 then
				print("table "..count.."-"..str)
			end
	end
	t["count"]=count
	return t
end

function StringExtension:trim (s)	
	return string.match(s,"^%s*(.-)%s*$")
end

function StringExtension:splitItemDkp(text)	
	local index = string.find(text, "|h|r")
	if debug==1 then
		print ("splitItemDKP: "..index)
	end
	
	if index then
		local strint = string.sub(text, index+5)
		if strint==nil or strint=="" then
			return nil
		end
		split = {}
		split["dkp"] = tonumber(strint)
		split["item"] = string.sub(text, 1, index+4) 

		if debug==1 then
			print("dkp: "..split["dkp"])
			print("item: "..split["item"])
		end

		return split
	else
		return nil
	end
end
