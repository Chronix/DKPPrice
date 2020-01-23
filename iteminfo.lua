local ItemInfo = {}


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