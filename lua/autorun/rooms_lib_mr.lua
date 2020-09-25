--[[
Author: Mohamed RACHID - https://steamcommunity.com/profiles/76561198080131369/
License: (copyleft license) Mozilla Public License 2.0 - https://www.mozilla.org/en-US/MPL/2.0/
]]

--[[
Translate MapCreationIDs into hammerids:
	lua_run for _,d in ipairs(ents.GetAll())do local i=d:MapCreationID()if i~=-1 then print(i,d:GetInternalVariable('hammerid'))end end
]]

print("rooms_lib_mr:sh")

rooms_lib_mr = rooms_lib_mr or {}

local hl = GetConVar("gmod_language"):GetString()
cvars.AddChangeCallback("gmod_language", function(convar, oldValue, newValue)
	hl = newValue
end, "rooms_lib_mr:sh")

local function genericArgToPos(arg)
	if arg == nil then
		if CLIENT then
			local ply = LocalPlayer()
			if ply:InVehicle() then
				arg = ply:EyePos() -- real eye pos
			else
				arg = EyePos()
			end
		else
			return false
		end
	elseif isentity(arg) then
		if arg:IsPlayer() then
			arg = arg:EyePos()
		else
			arg = arg:GetPos()
		end
	end
	return arg
end

local rooms_buildings_list = {}

-- For networking (needed for translated strings):
local building2id = {}
local building2name = {}
local id2building = {}
local room2id = {}
local room2name = {}
local room2building = {}
local room2buildingname = {}
local id2room = {}

local Building = rooms_lib_mr.Building or {}
rooms_lib_mr.Building = Building
Building.__index = Building
Building.new = function(cls)
	return setmetatable({}, cls)
end

local Room

function rooms_lib_mr.getBuildings()
	-- Return a copy of id2building
	-- You should cache the result if you often access the list.
	
	local id2building_ = {}
	for id = 1, #id2building do
		id2building_[id] = id2building[id]
	end
	return id2building_
end

function rooms_lib_mr.addBuilding(name)
	local building = Building:new()
	rooms_buildings_list[name] = building
	building2id[building] = table.insert(id2building, building)
	building2name[building] = name
	return building
end

function Building:addLightArea(areaId, min, max)
	-- (to be avoided)
	-- areaId may be a 0x<floor><id> integer.
	-- In general, min Z is previous floor's ceiling and max Z is current floor's ceiling.
	-- In general, X and Y are outer coordinates.
	-- Do not forget to adjust when you have 2 fullbright rooms next to each other, otherwise the screen will blink between them.
	-- Only 17 lights seem to be displayable at once.
	if not self.lightAreas then
		self.lightAreas = {} -- not to be listed with ipairs()!
	end
	self.lightAreas[areaId] = {min, max}
end

local buildingBounds = {}

function Building:setBuildingBounds(min, max)
	-- This is optional: a building can also be retrieved from its rooms only.
	
	buildingBounds[self] = {min, max}
end

function Building:getBuildingBounds()
	return buildingBounds[self]
end

function Building:getId()
	return building2id[self] or 0
end
rooms_lib_mr.getIdFromBuilding = Building.getId

function Building:getName()
	return building2name[self] or "<null Building>"
end
rooms_lib_mr.getNameFromBuilding = Building.getName

function rooms_lib_mr.getBuildingFromId(id)
	return id2building[id]
end

function rooms_lib_mr.getBuildingFromName(name)
	return rooms_buildings_list[name]
end

function rooms_lib_mr.getBuilding(arg)
	arg = genericArgToPos(arg)
	for building_name, building in pairs(rooms_buildings_list) do
		local bounds = building:getBuildingBounds()
		if bounds then
			if arg:WithinAABox(bounds[1], bounds[2]) then
				return building, building_name
			end
		end
	end
	return nil, nil
end

function Building:getRooms()
	-- Return a new list of the rooms (of the specified building if specified), ordered by index
	-- You should cache the result if you often access the list.
	
	local rooms = {}
	if self then
		for id = 1, #id2room do
			local room = id2room[id]
			if room2building[room] == self then
				rooms[#rooms + 1] = id2room[id]
			end
		end
	else
		for id = 1, #id2room do
			rooms[id] = id2room[id]
		end
	end
	return rooms
end
rooms_lib_mr.getRooms = Building.getRooms

function Building:addRoom(name, handleVoice, lights, lightArea)
	-- The name is optional if a room is a building itself (the building should have no bounds then).
	-- The room's lightArea activates its lights if the player is in any of the list.
	-- If the room's lightArea is nil, lights will be displayed anywhere in the map.
	name = name or ""
	local room = Room:new()
	room.name = name
	room.handleVoice = handleVoice -- enable voice modification?
	room.lights = lights -- light positions
	if lightArea then -- restrict lights to the given lightArea
		if isnumber(lightArea) then
			room.lightAreas = {[lightArea] = true}
		else
			for _, lightArea in ipairs(lightArea) do
				room.lightAreas[lightArea] = true
			end
		end
	end
	room.doors = {}
	room.areas = {}
	self[name] = room
	room2id[room] = table.insert(id2room, room)
	room2name[room] = name
	room2building[room] = self
	for name1, building1 in pairs(rooms_buildings_list) do
		if building1 == self then
			room2buildingname[room] = name1
			break
		end
	end
	return room
end

Room = rooms_lib_mr.Room or {}
rooms_lib_mr.Room = Room
Room.__index = Room
Room.new = function(cls)
	return setmetatable({}, cls)
end

-- function Room:getAreas()
	-- return self.areas
-- end

function Room:addArea(min, max)
	local area = {}
	area.min = min
	area.max = max
	self.areas[#self.areas + 1] = area
end

function Room:setDoors(doors)
	-- doors: MapCreationIDs or entities or DoorByHammerids
	
	self.doors = doors
end

function Room:isInRoom(arg)
	for _, area in ipairs(self.areas) do
		if rooms_lib_mr.isInArea(area, arg) then
			return true
		end
	end
	return false
end

function rooms_lib_mr.getRoom(arg)
	for building_name, building in pairs(rooms_buildings_list) do
		for room_name, room in pairs(building) do
			if room:isInRoom(arg) then
				return
					room,
					#room_name ~= 0 and room_name or nil,
					building,
					building_name
			end
		end
	end
	return nil, nil, rooms_lib_mr.getBuilding(arg)
end

function rooms_lib_mr.getFullRoomLabel(building_name, room_name)
	-- Returns "Building name - room name"
	if building_name and room_name then
		if #room_name == 0 then
			return building_name
		elseif #building_name == 0 then
			return room_name
		else
			return building_name .. " - " .. room_name
		end
	elseif building_name then
		return building_name
	end
	return room_name or "Unknown location"
end

function Room:getId()
	return room2id[self] or 0
end
rooms_lib_mr.getIdFromRoom = Room.getId

function Room:getName()
	return room2name[self] or "<null Room>"
end
rooms_lib_mr.getNameFromRoom = Room.getName

function Room:getBuilding()
	return room2building[self]
end
rooms_lib_mr.getBuildingFromRoom = Room.getBuilding

function Room:getBuildingName()
	return room2buildingname[self] or "<null Building>"
end
rooms_lib_mr.getBuildingNameFromRoom = Room.getBuildingName

function rooms_lib_mr.getRoomFromId(id)
	return id2room[id]
end

function rooms_lib_mr.getRoomFromName(name, building)
	if building then
		return building[name]
	else
		for _, building in pairs(rooms_buildings_list) do
			if building[name] then
				return building[name]
			end
		end
	end
	return nil
end

function rooms_lib_mr.getLightArea(arg)
	arg = genericArgToPos(arg)
	for building_name, building in pairs(rooms_buildings_list) do
		if building.lightAreas then
			for areaId, lightArea in pairs(building.lightAreas) do
				if arg:WithinAABox(lightArea[1], lightArea[2]) then
					return areaId, building, building_name
				end
			end
		end
	end
	return nil, rooms_lib_mr.getBuilding(arg)
end

function rooms_lib_mr.isInArea(area, arg)
	arg = genericArgToPos(arg)
	return arg:WithinAABox(area.min, area.max)
end

do
	-- Locations with disallowed jump:
	
	local NOT_IN_JUMP = bit.bnot(IN_JUMP)
	local forbiddenJumpLocations = {}
	
	function rooms_lib_mr.addForbiddenJumpLocation(roomOrBuilding)
		forbiddenJumpLocations[roomOrBuilding] = true
	end
	
	function rooms_lib_mr.removeForbiddenJumpLocation(roomOrBuilding)
		forbiddenJumpLocations[roomOrBuilding] = nil
	end
	
	hook.Add("Move", "rooms_lib_mr:sh", function(ply, mv)
		if  mv:KeyDown(IN_JUMP)
		and ply:GetMoveType() == MOVETYPE_WALK
		and not ply:InVehicle()
		and ply:WaterLevel() < 2 then
			local room, room_name, building = rooms_lib_mr.getRoom(ply)
			if forbiddenJumpLocations[building]
			or forbiddenJumpLocations[room] then
				mv:SetButtons(bit.band(mv:GetButtons(), NOT_IN_JUMP))
			end
		end
	end)
end

do
	-- Wrapper class to designate a door by its hammerid:
	-- This actually does not work client-side because the hammerid is unavailable.
	
	rooms_lib_mr.DoorByHammerid = setmetatable(rooms_lib_mr.DoorByHammerid or {}, {
		__call = function(cls, hammerid) -- constructor
			local self = setmetatable({}, cls)
			self.hammerid = hammerid
			return self
		end,
	})
	if SERVER then
		rooms_lib_mr.DoorByHammerid.getEntity = function(self)
			return rooms_lib_mr._hammeridToDoor[self.hammerid]
		end
		rooms_lib_mr.DoorByHammerid.__index = function(self, key)
			local defaultValue = rooms_lib_mr.DoorByHammerid[key]
			if defaultValue ~= nil then
				return defaultValue
			end
			local door = rooms_lib_mr.DoorByHammerid.getEntity(self)
			if not door then
				return nil
			end
			local doorMember = door[key]
			if isfunction(doorMember) then
				return function(self, ...)
					return doorMember(door, ...)
				end
			else
				return doorMember
			end
		end
	end
	rooms_lib_mr.DoorByHammerid.__tostring = function(self)
		return "rooms_lib_mr.DoorByHammerid(" .. tostring(self.hammerid) .. ")"
	end
	rooms_lib_mr.DoorByHammerid.__eq = function(self, other)
		-- This will always return false (not called) when comparing an Entity.
		return self.hammerid == other.hammerid
	end
end

do
	local map = game.GetMap()
	local mapCases = {
		[map] = true,
		[string.lower(map)] = true,
	}
	local luaPath = SERVER and "lsv" or "lcl"
	local found = false
	for map in pairs(mapCases) do
		local luaFile = "config/rooms_lib_mr/maps/" .. map .. ".lua"
		if file.Exists(luaFile, luaPath) then
			AddCSLuaFile(luaFile)
			include(luaFile)
			found = true
			break
		end
	end
	if not found then
		ErrorNoHalt("There is no rooms_lib_mr config for the current map!\n")
	end
end
