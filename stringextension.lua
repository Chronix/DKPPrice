StringExtension = {}

function StringExtension:split (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local count=0
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
			count=count+1
			
			if DKPMain["debug"]==1 then
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
	if index then
		split = {}
		split["dkp"] = string.sub(text, index+5)		
		split["item"] = string.sub(text, 1, index+4)

		print("dkp: "..split["dkp"])
		print("item: "..split["item"])
	else
		return nil
	end
end