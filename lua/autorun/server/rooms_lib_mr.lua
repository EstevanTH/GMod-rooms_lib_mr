--[[
Author: Mohamed RACHID - https://steamcommunity.com/profiles/76561198080131369/
License: (copyleft license) Mozilla Public License 2.0 - https://www.mozilla.org/en-US/MPL/2.0/
]]

print("rooms_lib_mr:sv")

local WEAK_KEYS = {__mode = "k"}
local WEAK_VALUES = {__mode = "v"}

local Room = rooms_lib_mr.Room

do
	local doorIsOpenByClass = {
		["func_door"] = function(door)
			return (door:GetInternalVariable('m_toggle_state') == 0)
		end,
		["func_door_rotating"] = function(door)
			return (door:GetInternalVariable('m_toggle_state') == 0)
		end,
		["prop_door_rotating"] = function(door)
			return (door:GetInternalVariable('m_eDoorState') ~= 0)
		end,
	}
	
	rooms_lib_mr._doorToHammerid = rooms_lib_mr._doorToHammerid or {}
	rooms_lib_mr._hammeridToDoor = rooms_lib_mr._hammeridToDoor or {}
	local function beforeMapEntitiesCreation()
		-- Sourced from lua/autorun/server/universityrp_mr_spawn.lua
		local duplicatedHammerids = {[0] = true}
		rooms_lib_mr._doorToHammerid = setmetatable({}, WEAK_KEYS)
		rooms_lib_mr._hammeridToDoor = setmetatable({}, WEAK_VALUES)
		hook.Add("EntityKeyValue", "rooms_lib_mr:sv:beforeMapEntitiesCreation", function(door, key, hammerid)
			if not doorIsOpenByClass[door:GetClass()] then
				hammerid = nil
			elseif #key == 8 and string.lower(key) == "hammerid" then
				hammerid = tonumber(hammerid)
				if hammerid then
					if hammerid == 0
					or not door:CreatedByMap() then
						hammerid = nil
					end
				end
			else
				hammerid = nil
			end
			if hammerid then
				if duplicatedHammerids[hammerid] then
					-- duplicated!
				elseif rooms_lib_mr._hammeridToDoor[hammerid] then
					-- duplicated!
					duplicatedHammerids[hammerid] = true
					rooms_lib_mr._doorToHammerid[rooms_lib_mr._hammeridToDoor[hammerid]] = nil
					rooms_lib_mr._hammeridToDoor[hammerid] = nil
				else
					rooms_lib_mr._doorToHammerid[door] = hammerid
					rooms_lib_mr._hammeridToDoor[hammerid] = door
				end
			end
		end)
	end
	hook.Add("PreGamemodeLoaded", "rooms_lib_mr:sv", beforeMapEntitiesCreation)
	hook.Add("PreCleanupMap", "rooms_lib_mr:sv", beforeMapEntitiesCreation)
	
	local function onMapEntitiesSpawned()
		hook.Remove("EntityKeyValue", "rooms_lib_mr:sv:beforeMapEntitiesCreation")
	end
	hook.Add("InitPostEntity", "rooms_lib_mr:sv", onMapEntitiesSpawned)
	hook.Add("PostCleanupMap", "rooms_lib_mr:sv", onMapEntitiesSpawned)
	
	local function doorIsOpen(door)
		local open = true
		if IsValid(door) then
			open = doorIsOpenByClass[door:GetClass()](door)
		end
		return open
	end
	
	
	function Room:hasOpenDoors()
		if self.doors then
			for _, doorToken in ipairs(self.doors) do
				-- doorToken: MapCreationID or Entity or DoorByHammerid
				local door
				if isnumber(doorToken) then
					door = ents.GetMapCreatedEntity(doorToken)
				else
					door = doorToken
				end
				if doorIsOpen(door) then
					-- A door has been removed OR a door is open:
					return true
				end
			end
			return false
		else
			return true -- room does not have doors to close it
		end
	end
end

function rooms_lib_mr.PlayerCanHearPlayersVoice(listener, talker)
	if not IsValid(listener) or not IsValid(talker) then
		-- listener can be a table!?
		return
	end
	if listener == talker then
		return true
	end
	local roomListener = rooms_lib_mr.getRoom(listener)
	local roomTalker = rooms_lib_mr.getRoom(talker)
	if roomListener and roomListener.handleVoice then
		-- listener is in a handleVoice room:
		if roomListener == roomTalker then
			-- same room, hear at full volume:
			return true, false
		elseif not roomListener:hasOpenDoors() then
			if not hook.Run("rooms_lib_mr:canHearOutsideRoom", listener, talker) then
				-- can't hear outside of the room by default (can be used for teams):
				return false
			end
		end
	elseif roomTalker and roomTalker.handleVoice and not roomTalker:hasOpenDoors() then
		-- talker is in a handleVoice room with closed doors:
		if not hook.Run("rooms_lib_mr:canHearOutsideRoom", listener, talker) then
			-- can't talk outside of the room by default (can be used for teams):
			return false
		end
	end
end

function rooms_lib_mr.talkToRange(ply, PlayerName, Message, size)
	-- Replacement for DarkRP.talkToRange() that handles doors states
	-- Warning: if it changes in the DarkRP, this function must be updated.
	
	local room = rooms_lib_mr.getRoom(ply)
	local pos = ply:GetPos()
	local size_sqr = size * size
	local col = team.GetColor(ply:Team())
	local filter = {}
	if not room then
		-- expéditeur en-dehors d'une salle avec gestion audio:
		for _, p in ipairs(player.GetAll()) do
			local room2 = rooms_lib_mr.getRoom(p)
			if not room2 or room2:hasOpenDoors() then
				-- joueurs en-dehors d'une salle avec gestion audio, ou avec porte ouverte:
				if pos:DistToSqr(p:GetPos()) < size_sqr then
					filter[#filter + 1] = p
				end
			end
		end
	elseif room:hasOpenDoors() then
		-- expéditeur dans une salle avec gestion audio avec portes ouvertes:
		for _, p in ipairs(player.GetAll()) do
			local room2 = rooms_lib_mr.getRoom(p)
			if room2 == room then
				-- joueurs dans la même salle:
				filter[#filter + 1] = p
			elseif not room2 or room2:hasOpenDoors() then
				-- joueurs n'étant pas dans une salle aux portes fermées:
				if pos:DistToSqr(p:GetPos()) < size_sqr then
					filter[#filter + 1] = p
				end
			end
		end
	else
		-- expéditeur dans une salle avec gestion audio aux portes fermées:
		for _, p in ipairs(player.GetAll()) do
			local room2 = rooms_lib_mr.getRoom(p)
			if room2 == room then
				-- joueurs dans la même salle:
				filter[#filter + 1] = p
			end
		end
	end
	
	if PlayerName == ply:Nick() then
		PlayerName = ""
	end
	net.Start("DarkRP_Chat")
		net.WriteUInt(col.r, 8)
		net.WriteUInt(col.g, 8)
		net.WriteUInt(col.b, 8)
		net.WriteString(PlayerName)
		net.WriteEntity(ply)
		net.WriteUInt(255, 8)
		net.WriteUInt(255, 8)
		net.WriteUInt(255, 8)
		net.WriteString(Message)
	net.Send(filter)
end

hook.Add("PostGamemodeLoaded", "rooms_lib_mr:sv", function()
	-- Replace a couple functions from the gamemode:
	
	local old_PlayerCanHearPlayersVoice = GAMEMODE.PlayerCanHearPlayersVoice
	function GAMEMODE:PlayerCanHearPlayersVoice(...)
		-- Written this way, allows Lua refresh:
		local hear, fade = rooms_lib_mr.PlayerCanHearPlayersVoice(...)
		if hear == nil then
			return old_PlayerCanHearPlayersVoice(self, ...)
		else
			return hear, fade
		end
	end
	if DarkRP and DarkRP.talkToRange then
		function DarkRP.talkToRange(...)
			-- Written this way, allows Lua refresh:
			return rooms_lib_mr.talkToRange(...) 
		end
	end
end)

--[[ function rooms_lib_mr.PlayerCanSeePlayersChat(text, teamOnly, listener, talker)
	local room1 = rooms_lib_mr.getRoom(listener)
	local room2 = rooms_lib_mr.getRoom(talker)
	if room1 and room1.handleVoice then
		if room1 == room2 then
			return true -- same room: see message
		elseif not teamOnly and not room1:hasOpenDoors() then
			if not hook.Run("rooms_lib_mr:canHearOutsideRoom", listener, talker) then
				-- can't hear outside of the room by default:
				print(text) -- debug
				return false
			end
		end
	end
end ]]
