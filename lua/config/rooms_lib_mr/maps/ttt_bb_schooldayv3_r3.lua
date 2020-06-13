local hl = GetConVar("gmod_language"):GetString()
cvars.AddChangeCallback("gmod_language", function(convar, oldValue, newValue)
	hl = newValue
end, "rooms_lib_mr:maps")

local DoorByHammerid = rooms_lib_mr.DoorByHammerid

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Bâtiment 1" or "Building 1"); do
	building:setBuildingBounds(Vector(-1520, 80, 16), Vector(-208, 2096, 160))
	rooms_lib_mr.addForbiddenJumpLocation(building)
	local room = building:addRoom(hl == "fr" and "Salle 11" or "Room 11", true, nil, nil); do
		--room:setDoors({1394})
		room:setDoors({DoorByHammerid(468712)})
		room:addArea(Vector(-1520, 1444, 16), Vector(-1028, 2096, 160))
	end
	local room = building:addRoom(hl == "fr" and "Salle 12" or "Room 12", true, nil, nil); do
		--room:setDoors({1393})
		room:setDoors({DoorByHammerid(468665)})
		room:addArea(Vector(-1520, 580, 16), Vector(-1028, 1232, 160))
	end
	local room = building:addRoom(hl == "fr" and "Salle 13" or "Room 13", true, nil, nil); do
		--room:setDoors({1390, 1402})
		room:setDoors({DoorByHammerid(467875), DoorByHammerid(498545)})
		room:addArea(Vector(-1520, 80, 16), Vector(-868, 572, 160))
	end
	local room = building:addRoom(hl == "fr" and "Salle 14" or "Room 14", true, nil, nil); do
		--room:setDoors({1391, 1802})
		room:setDoors({DoorByHammerid(468513), DoorByHammerid(497469)})
		room:addArea(Vector(-860, 80, 16), Vector(-208, 572, 160))
	end
	local room = building:addRoom(hl == "fr" and "Salle 15" or "Room 15", true, nil, nil); do
		--room:setDoors({1392})
		room:setDoors({DoorByHammerid(468593)})
		room:addArea(Vector(-700, 580, 16), Vector(-208, 1232, 160))
	end
	local room = building:addRoom(hl == "fr" and "Salle Multimédia" or "Multimedia Room", false, nil, nil); do
		--room:setDoors({1395})
		room:setDoors({DoorByHammerid(468920)})
		room:addArea(Vector(-860, 1604, 16), Vector(-208, 2096, 160))
	end
	local room = building:addRoom(hl == "fr" and "Salle de détention" or "Detention Room", false, nil, nil); do
		--room:setDoors({1403})
		room:setDoors({DoorByHammerid(499586)})
		room:addArea(Vector(-1520, 1240, 16), Vector(-1028, 1436, 160))
	end
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Bâtiment 2" or "Building 2"); do
	building:setBuildingBounds(Vector(144, 80, 16), Vector(1456, 572, 320))
	rooms_lib_mr.addForbiddenJumpLocation(building)
	local room = building:addRoom(hl == "fr" and "Salle 21" or "Room 21", true, nil, nil); do
		--room:setDoors({1412, 1410})
		room:setDoors({DoorByHammerid(503944), DoorByHammerid(503896)})
		room:addArea(Vector(144, 80, 16), Vector(796, 572, 160))
	end
	local room = building:addRoom(hl == "fr" and "Salle 22" or "Room 22", true, nil, nil); do
		--room:setDoors({1665})
		room:setDoors({DoorByHammerid(732737)})
		room:addArea(Vector(804, 80, 176), Vector(1456, 572, 320))
	end
	local room = building:addRoom(hl == "fr" and "Stock" or "Stock", false, nil, nil); do
		--room:setDoors({1411, 1409})
		room:setDoors({DoorByHammerid(503912), DoorByHammerid(503659)})
		room:addArea(Vector(804, 80, 16), Vector(1456, 572, 160))
	end
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Piscine" or "Pool"); do
	building:setBuildingBounds(Vector(128, 704, -128), Vector(1152, 2392, 384))
	local room = building:addRoom(hl == "fr" and "Vestiaires" or "Changing Room", false, nil, nil); do
		--room:setDoors({1570, 1407, 1408, 1756})
		room:setDoors({DoorByHammerid(666491), DoorByHammerid(503482), DoorByHammerid(503547), DoorByHammerid(788170)})
		room:addArea(Vector(348, 2048, 0), Vector(1136, 2376, 144))
	end
	local room = building:addRoom(hl == "fr" and "Terrasse" or "Terrace", false, nil, nil); do
		rooms_lib_mr.addForbiddenJumpLocation(room)
		room:setDoors(nil)
		room:addArea(Vector( 136, 2048, 160), Vector(1464, 2384, 384))
		room:addArea(Vector(1152, 1416, 160), Vector(1464, 2384, 384))
	end
	local room = building:addRoom(hl == "fr" and "Salle d'eau" or "Water Room", false, nil, nil); do
		--room:setDoors({1568, 1569, 1406, 1407, 1408})
		room:setDoors({DoorByHammerid(504356), DoorByHammerid(504361), DoorByHammerid(501356), DoorByHammerid(503482), DoorByHammerid(503547)})
		room:addArea(Vector(144, 720, -128), Vector(1136, 2032, 320))
	end
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Resto'U" or "U'Resto"); do
	building:setBuildingBounds(Vector(512, -1472, 0), Vector(1472, -200, 320))
	local room = building:addRoom(hl == "fr" and "Cuisine" or "Kitchen", false, nil, nil); do
		--room:setDoors({1472})
		room:setDoors({DoorByHammerid(626354)})
		room:addArea(Vector(528, -1456, 0), Vector(1186, -1180, 160))
	end
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "WC Piscine" or "Pool Restroom"); do
	building:setBuildingBounds(Vector(1152, 1416, 0), Vector(1424, 1672, 128))
	local room = building:addRoom(hl == "fr" and "Femmes" or "Ladies", false, nil, nil); do
		--room:setDoors({2628})
		room:setDoors({DoorByHammerid(1394180)})
		room:addArea(Vector(1152, 1416, 0), Vector(1280, 1672, 128))
	end
	local room = building:addRoom(hl == "fr" and "Hommes" or "Men", false, nil, nil); do
		--room:setDoors({2629})
		room:setDoors({DoorByHammerid(1394227)})
		room:addArea(Vector(1296, 1416, 0), Vector(1424, 1672, 128))
	end
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "WC Garage" or "Garage Restroom"); do
	building:setBuildingBounds(Vector(-232, -640, -260), Vector(40, -384, -132))
	local room = building:addRoom(hl == "fr" and "Femmes" or "Ladies", false, nil, nil); do
		--room:setDoors({2631})
		room:setDoors({DoorByHammerid(1400358)})
		room:addArea(Vector(-88, -640, -260), Vector(40, -384, -132))
	end
	local room = building:addRoom(hl == "fr" and "Hommes" or "Men", false, nil, nil); do
		--room:setDoors({2630})
		room:setDoors({DoorByHammerid(1400353)})
		room:addArea(Vector(-232, -640, -260), Vector(-104, -384, -132))
	end
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Garage" or "Garage"); do
	building:setBuildingBounds(Vector(-416, -376, -264), Vector(864, 656, -88))
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Chaufferie" or "Boiler Room"); do
	building:setBuildingBounds(Vector(34, 2397, -264), Vector(1144, 2696, -72))
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Machines" or "Machines"); do
	building:setBuildingBounds(Vector(-1683, -1339, -224), Vector(-545, -821, -48))
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Résidence" or "Apartment block"); do
	-- This building is a prop created in Lua.
	building:setBuildingBounds(Vector(-640, -880, 26), Vector(-240, -208, 842))
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Stock extérieur" or "Outside Stock"); do
	-- This is an L-shaped area considered as a building.
	-- It does not have rooms, but because of its shape, an unnamed room must be created instead of setting its bounds.
	-- Because we have a Room object, we can also add the doors.
	rooms_lib_mr.addForbiddenJumpLocation(building)
	local room = building:addRoom(nil, false, nil, nil); do
		--room:setDoors({1590, 1589})
		room:setDoors({DoorByHammerid(685483), DoorByHammerid(683994)})
		room:addArea(Vector(-1800, 249, -8), Vector(-1536, 2376, 214))
		room:addArea(Vector(-1800, 2112, -8), Vector(-1198, 2376, 214))
	end
end

local building = rooms_lib_mr.addBuilding(hl == "fr" and "Bureaux" or "Offices"); do
	-- This building is a prop created in Lua.
	-- The doors are created in Lua, so Room:setDoors() must be called after their creation.
	building:setBuildingBounds(Vector(-1799, -763, 39), Vector(-1311, -274, 191))
	rooms_lib_mr.addForbiddenJumpLocation(building)
	local room = building:addRoom(hl == "fr" and "Salle des professeurs" or "Teachers' room", true, nil, nil); do
		room:addArea(Vector(-1509, -763, 39), Vector(-1311, -517, 191))
		room:addArea(Vector(-1597, -763, 39), Vector(-1509, -603, 191))
	end
	local room = building:addRoom(hl == "fr" and "Bureau du directeur" or "Head teacher's office", true, nil, nil); do
		room:addArea(Vector(-1799, -511, 39), Vector(-1603, -274, 191))
	end
	local room = building:addRoom(hl == "fr" and "Bureau de Noël" or "Christmas office", true, nil, nil); do
		room:addArea(Vector(-1799, -763, 39), Vector(-1603, -603, 191))
	end
end
