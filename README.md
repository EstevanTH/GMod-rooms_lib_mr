# Rooms location management library

This add-on is a library that lets you configure building bounds and their room bounds.

It provides functions to :

- get the current building & room of any `Player` or `Entity`
- check if a room has all of its doors closed

The configured rooms can have:

- a full voice volume everywhere
- no voices heard from outside the room when all doors are closed
- disallowed jump

[This add-on on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2129489905)

## Compatibility

There is no gamemode requirement.

The voice range replacement feature should work on all gamemodes that do not do special things. There are a few things to know:

- The DarkRP mechanism is hacked in order to make the replacement fully operational.
- The DarkRP shows who can hear who, but clients do not know whether doors are open of closed!
    - I picked the safest display: you are the talker and the listener cannot hear you when the room's doors are closed. The listener will not be listed in the listeners list because your game does not know door states.

## Setting up

### Toolgun tool

To help you through the process of getting bounding boxes, there is a Sandbox toolgun tool under the **Rooms** category named **Rooms Areas**.

For a building or a room, you proceed by attacking the walls, the ceiling and the floor. If you cannot attack indoor surfaces, attack the corresponding outdoor surfaces. Every time you attack a surface, the bounding box is extended.

When you are done with a building or a room, the tool generates `room:addArea()` Lua instructions, which you can edit into `building:setBuildingBounds()` instructions.

### Configuration files

For every configured map, you need to make a Lua file in `lua/config/rooms_lib_mr/maps/`. Name it `MAP_NAME.lua` where `MAP_NAME` is the name of the map, as in `MAP_NAME.bsp`.

- [`lua/config/rooms_lib_mr/maps/`](../../tree/_config/lua/config/rooms_lib_mr/maps/)

## Public object methods

### Class `rooms_lib_mr.Building`

- *:black_heart: SHARED:* `no value` **`Building:addLightArea`**`(int areaId, Vector min, Vector max)`  
    (usage not recommended)
- *:black_heart: SHARED:* `Room` **`Building:addRoom`**`(string name, boolean handleVoice, table lights, any lightArea)`  
    Adds a `Room` to the building  
    Arguments:  
    - `name`: the name of the building
    - `handleVoice`: activate the voice range management
    - `lights`: (usage not recommended)
    - `lightArea`: (usage not recommended), allowed types: `int` & `table` of `int`
- *:black_heart: SHARED:* `table` **`Building:getBuildingBounds`**`()`  
    Returns a table of 2 values: `{Vector min, Vector max}`  
    The returned value is not a copy!
- *:black_heart: SHARED:* `int` **`Building:getId`**`()`  
    Returns the index of the building  
    The value is identical on the server and the client, so it can be used for networking.
- *:black_heart: SHARED:* `string` **`Building:getName`**`()`  
    Returns the name of the building
- *:black_heart: SHARED:* `no value` **`Building:setBuildingBounds`**`(Vector min, Vector max)`  
    Sets the bounding box of the building

### Class `rooms_lib_mr.Room`

- *:black_heart: SHARED:* `no value` **`Room:addArea`**`(Vector min, Vector max)`  
    Adds a bounding box to the room  
    Room bounding boxes is not required to be within the `Building` bounding box.  
    Usually a room only has 1 bounding box.  
    A room can have as many bounding boxes are necessary.
- *:black_heart: SHARED:* `Building` **`Room:getBuilding`**`()`  
    Returns the `Building` this room belongs to
- *:black_heart: SHARED:* `string` **`Room:getBuildingName`**`()`  
    Returns the name of the `Building` this room belongs to
- *:black_heart: SHARED:* `int` **`Room:getId`**`()`  
    Returns the index of the room  
    The value is identical on the server and the client, so it can be used for networking.
- *:black_heart: SHARED:* `string` **`Room:getName`**`()`  
    Returns the name of the room
- *:blue_heart: SERVER:* `boolean` **`Room:hasOpenDoors`**`()`  
    Returns `true` if at least 1 door is open or missing, otherwise `false`  
    Returns `true` if doors are undefined
- *:black_heart: SHARED:* `boolean` **`Room:isInRoom`**`(any arg)`  
    Returns if `arg` is located in the room  
    `arg` can be of the following types: `Player`, `Entity`, `Vector`.
- *:black_heart: SHARED:* `no value` **`Room:setDoors`**`(table doors)`  
    Sets the doors of the room  
    `doors` is a list of elements of the following type: `DoorByHammerid` (see below), `int` (MapCreationIDs), `Entity` (usually for doors created by Lua code).

### Class `rooms_lib_mr.DoorByHammerid`

This class is a wrapper around the door `Entity`, so `Entity` methods can be used on it.

It is meant to be used in your configuration file.

Unlike the `MapCreationID`, the `hammerid` do not change when modifying a map.

- *:black_heart: SHARED:* `DoorByHammerid` **`DoorByHammerid`**`(int hammerid)`  
    Constructor
- *:blue_heart: SERVER:* `Entity` **`DoorByHammerid:getEntity`**`()`  
    Returns the door `Entity`

## Public functions

- *:black_heart: SHARED:* `Building` **`rooms_lib_mr.addBuilding`**`(string name)`  
    Creates a new building
- *:black_heart: SHARED:* `no value` **`rooms_lib_mr.addForbiddenJumpLocation`**`(any roomOrBuilding)`  
    Adds a room or a building into locations with forbidden jump  
    `roomOrBuilding` can be a `Building` or a `Room`.
- *:black_heart: SHARED:* `Building, string` **`rooms_lib_mr.getBuilding`**`(any arg)`  
    Returns the building and the building name of the location of `arg`  
    This function ignores room bounding boxes, so it is faster than `rooms_lib_mr.getRoom()`.  
    If a no building matches, all 2 returned values are `nil`.  
    `arg` can be of the following types: `Player`, `Entity`, `Vector`.
- *:black_heart: SHARED:* `Building` **`rooms_lib_mr.getBuildingFromId`**`(int id)`  
    Returns the building with the specified index
- *:black_heart: SHARED:* `Building` **`rooms_lib_mr.getBuildingFromName`**`(string name)`  
    Returns the building with the specified name
- *:black_heart: SHARED:* `Building` **`rooms_lib_mr.getBuildingFromRoom`**`(Room room)`  
    See `Room:getBuilding()`
- *:black_heart: SHARED:* `string` **`rooms_lib_mr.getBuildingNameFromRoom`**`(Room room)`  
    See `Room:getBuildingName()`
- *:black_heart: SHARED:* `int` **`rooms_lib_mr.getIdFromBuilding`**`()`  
    See `Building:getId()`
- *:black_heart: SHARED:* `int` **`rooms_lib_mr.getIdFromRoom`**`(Room room)`  
    See `Room:getId()`
- *:black_heart: SHARED:* `string` **`rooms_lib_mr.getFullRoomLabel`**`(string building_name, string room_name)`  
    Returns the concatenation of `building_name`, `" - "` and `room_name`, if all arguments are non-empty `string`s  
    Returns `building_name` or `room_name` if only 1 argument is non-empty `string`s  
    Returns `"Unknown location"` otherwise
- *:black_heart: SHARED:* `int, Building, string` **`rooms_lib_mr.getLightArea`**`(any arg)`  
    (usage not recommended)  
    `arg` can be of the following types: `Player`, `Entity`, `Vector`.
- *:black_heart: SHARED:* `string` **`rooms_lib_mr.getNameFromBuilding`**`()`  
    See `Building:getName()`
- *:black_heart: SHARED:* `string` **`rooms_lib_mr.getNameFromRoom`**`(Room room)`  
    See `Room:getName()`
- *:black_heart: SHARED:* `Room, string, Building, string` **`rooms_lib_mr.getRoom`**`(any arg)`  
    Returns the room, the room name, the building and the building name of the location of `arg`  
    If a no room matches, the 1st and the 2nd returned values are `nil`.  
    If a no building matches, all 4 returned values are `nil`.  
    `arg` can be of the following types: `Player`, `Entity`, `Vector`.
- *:black_heart: SHARED:* `Room` **`rooms_lib_mr.getRoomFromId`**`(int id)`  
    Returns the room with the specified index
- *:black_heart: SHARED:* `Room` **`rooms_lib_mr.getRoomFromName`**`(string name, Building building)`  
    Retrieves a room by its name, only if it belongs to `building`  
    `building` is optional.
- *:black_heart: SHARED:* `boolean` **`rooms_lib_mr.isInArea`**`(table area, any arg)`  
    Returns if `arg` is located within `area` bounds  
    `area` is a table with the keys `min` & `max` and with `Vector` values.  
    `arg` can be of the following types: `Player`, `Entity`, `Vector`.
- *:black_heart: SHARED:* `no value` **`rooms_lib_mr.removeForbiddenJumpLocation`**`(any roomOrBuilding)`  
    Removes a room or a building into locations with forbidden jump  
    `roomOrBuilding` can be a `Building` or a `Room`.
