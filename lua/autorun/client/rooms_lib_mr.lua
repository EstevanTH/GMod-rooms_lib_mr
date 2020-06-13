--[[
Author: Mohamed RACHID - https://steamcommunity.com/profiles/76561198080131369/
License: (copyleft license) Mozilla Public License 2.0 - https://www.mozilla.org/en-US/MPL/2.0/
]]

print("rooms_lib_mr:cl")

local Room = rooms_lib_mr.Room

do
	-- This is the system that adds lights in specific rooms:
	-- It uses DynamicLight().
	-- It is strongly advised to avoid this system.
	
	local dieTime = 0. -- to be refreshed every 10 seconds with 1 second security
	local lastAreaId
	hook.Add("Think", "rooms_lib_mr:lightAreas:cl", function()
		local areaId, building = rooms_lib_mr.getLightArea()
		if areaId ~= lastAreaId or RealTime() >= dieTime - 1. then -- refresh lights 1 second before they expire
			dieTime = RealTime() + 11. -- 10+1 seconds
			lastAreaId = areaId
			local i = 0
			
			if building and building.lightAreas then
				for _, room in pairs(building) do
					if room.lights and (not room.lightAreas or room.lightAreas[areaId]) then
						for k, lightInfo in ipairs(room.lights) do
							local light = DynamicLight(76667 + i) -- 76667 is "rooms" on phone keypads
							if lightInfo.brightness ~= nil then
								light.brightness = lightInfo.brightness
							end
							if lightInfo.decay ~= nil then
								light.decay = lightInfo.decay
							end
							light.dieTime = dieTime
							if lightInfo.dir ~= nil then
								light.dir = lightInfo.dir
							end
							if lightInfo.innerangle ~= nil then
								light.innerangle = lightInfo.innerangle
							end
							if lightInfo.outerangle ~= nil then
								light.outerangle = lightInfo.outerangle
							end
							if lightInfo.key ~= nil then
								light.key = lightInfo.key
							end
							if lightInfo.minlight ~= nil then
								light.minlight = lightInfo.minlight
							end
							if lightInfo.noworld ~= nil then
								light.noworld = lightInfo.noworld
							end
							if lightInfo.nomodel ~= nil then
								light.nomodel = lightInfo.nomodel
							end
							if lightInfo.pos ~= nil then
								light.pos = lightInfo.pos
							end
							if lightInfo.size ~= nil then
								light.size = lightInfo.size
							end
							if lightInfo.style ~= nil then
								light.style = lightInfo.style
							end
							if lightInfo.b ~= nil then
								light.b = lightInfo.b
							else
								light.b = 255
							end
							if lightInfo.g ~= nil then
								light.g = lightInfo.g
							else
								light.g = 255
							end
							if lightInfo.r ~= nil then
								light.r = lightInfo.r
							else
								light.r = 255
							end
							i = i + 1
						end
					end
				end
			end
		end
	end)
end

do
	-- This is the system that overrides the chat / voice recipient display:
	-- See https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/chat/cl_chatlisteners.lua
	
	local prefixesDefaultListeners = {
		["/ooc"] = true,
		["//"] = true,
		["/a"] = true,
		["/w"] = true,
		["/g"] = true,
		["/pm"] = true,
	}
	local forceDefaultListeners = false -- force default DarkRP listeners
	
	hook.Add("ChatTextChanged", "rooms_lib_mr:cl", function(text)
		local prefix = string.match(text, "^(/[^%s]+)")
		prefix = prefix and string.lower(prefix)
		forceDefaultListeners = prefixesDefaultListeners[prefix] or false
	end)
	
	local function drawChatReceivers()
		-- This is a modified copy from the DarkRP.
		
		-- mod:
		local allPlayers = player.GetAll() -- dirty!
		local ply = LocalPlayer()
		local room = rooms_lib_mr.getRoom(ply) -- always a valid room with audio because unused otherwise
		local receivers = {}
		for _, p in ipairs(allPlayers) do
			if p ~= ply and rooms_lib_mr.getRoom(p) == room then
				receivers[#receivers + 1] = p
			end
		end
		
		local x, y = chat.GetChatBoxPos()
		y = y - 21
		if #receivers == 0 then
			draw.WordBox(2, x, y, DarkRP.getPhrase("hear_noone", DarkRP.getPhrase("talk")), "DarkRPHUD1", Color(0, 0, 0, 160), Color(255, 0, 0, 255)) -- mod
		elseif #receivers == #allPlayers - 1 then
			draw.WordBox(2, x, y, DarkRP.getPhrase("hear_everyone"), "DarkRPHUD1", Color(0, 0, 0, 160), Color(0, 255, 0, 255))
		else
			draw.WordBox(2, x, y - (#receivers * 21), DarkRP.getPhrase("hear_certain_persons", DarkRP.getPhrase("talk")), "DarkRPHUD1", Color(0, 0, 0, 160), Color(0, 255, 0, 255)) -- mod
			for i = 1, #receivers do
				-- mod: no need to remove invalid players
				draw.WordBox(2, x, y - (i - 1) * 21, receivers[i]:Nick(), "DarkRPHUD1", Color(0, 0, 0, 160), Color(255, 255, 255, 255))
			end
		end
	end
	
	local DarkRP_DrawChatReceivers -- to restore DarkRP's variant
	hook.Add("Think", "rooms_lib_mr:drawChatReceivers:cl", function()
		if DarkRP then
			local ply = LocalPlayer()
			local HUDPaint = hook.GetTable()["HUDPaint"]
			if HUDPaint then
				if HUDPaint["DarkRP_DrawChatReceivers"] then
					if HUDPaint["DarkRP_DrawChatReceivers"] == drawChatReceivers then
						-- If needed, restore the DarkRP's hook:
						local switchToDefault = false
						if forceDefaultListeners then
							switchToDefault = true
						else
							local room = rooms_lib_mr.getRoom(ply)
							if not room or not room.handleVoice then
								switchToDefault = true
							end
						end
						if switchToDefault then
							hook.Add("HUDPaint", "DarkRP_DrawChatReceivers", DarkRP_DrawChatReceivers) -- restore DarkRP's DrawChatReceivers
						end
					else
						-- If needed, set our modified hook:
						if not forceDefaultListeners then
							local room = rooms_lib_mr.getRoom(ply)
							if room and room.handleVoice then
								DarkRP_DrawChatReceivers = HUDPaint["DarkRP_DrawChatReceivers"]
								hook.Add("HUDPaint", "DarkRP_DrawChatReceivers", drawChatReceivers) -- set rooms' DrawChatReceivers
							end
						end
					end
				else -- finished chat / voice
					forceDefaultListeners = false
				end
			else -- finished chat / voice
				forceDefaultListeners = false
			end
		end
	end)
end
