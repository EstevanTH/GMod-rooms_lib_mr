--[[
Author: Mohamed RACHID - https://steamcommunity.com/profiles/76561198080131369/
License: (copyleft license) Mozilla Public License 2.0 - https://www.mozilla.org/en-US/MPL/2.0/
]]

TOOL.Category = "Rooms"
TOOL.Command = nil
TOOL.ConfigName = ""


local hl = GetConVar("gmod_language"):GetString()
TOOL.Name = (
	hl == "fr" and
	"Zones de Salles" or
	"Rooms Areas"
)
if CLIENT then
	language.Add("tool.rooms_lib_mr.name", TOOL.Name)
	if hl == "fr" then
		language.Add("tool.rooms_lib_mr.desc", "Obtient facilement les coordonnées d'une zone de salle")
		language.Add("tool.rooms_lib_mr.0", "Attaquez les 4 murs, le sol et le plafond !")
		language.Add("tool.rooms_lib_mr.1", "Recharger : RAZ - Attaque2 : Copier résultat")
	else
		language.Add("tool.rooms_lib_mr.desc", "Easily get the coordinates of a room area")
		language.Add("tool.rooms_lib_mr.0", "Attack the 4 walls, the ground and the ceiling!")
		language.Add("tool.rooms_lib_mr.1", "Reload: Reset - Attack2: Copy result")
	end
end



	local hl = GetConVar("gmod_language"):GetString()


function TOOL:LeftClick(trace)
	if SERVER then
		local stage = self:GetStage()
		if stage == 1 then
			local areaMin = Vector(self.areaMin)
			local areaMax = Vector(self.areaMax)
			self.areaMin.x = math.min(areaMin.x, trace.HitPos.x)
			self.areaMin.y = math.min(areaMin.y, trace.HitPos.y)
			self.areaMin.z = math.min(areaMin.z, trace.HitPos.z)
			self.areaMax.x = math.max(areaMax.x, trace.HitPos.x)
			self.areaMax.y = math.max(areaMax.y, trace.HitPos.y)
			self.areaMax.z = math.max(areaMax.z, trace.HitPos.z)
		else
			-- Both vectors must be copies because self.areaMin and self.areaMax will not be identical.
			self.areaMin = Vector(trace.HitPos)
			self.areaMax = Vector(trace.HitPos)
			self:SetStage(1)
		end
	end
	return true
end


function TOOL:Reload(trace)
	if SERVER then
		self.areaMin = nil
		self.areaMax = nil
		self:SetStage(0)
	end
	return true
end


if SERVER then
	util.AddNetworkString("tool.rooms_lib_mr")
else
	net.Receive("tool.rooms_lib_mr", function()
		local actionId = net.ReadUInt(8)
		if actionId == 0 then
			chat.AddText("No traces yet!")
		elseif actionId == 1 then
			local luaCode = table.concat({
				"room:addArea(Vector(",
				net.ReadInt(24),
				", ",
				net.ReadInt(24),
				", ",
				net.ReadInt(24),
				"), Vector(",
				net.ReadInt(24),
				", ",
				net.ReadInt(24),
				", ",
				net.ReadInt(24),
				"))"
			}, "")
			SetClipboardText(luaCode)
			print(luaCode)
		else
			ErrorNoHalt("Unknown actionId\n")
		end
	end)
end


function TOOL:RightClick(trace)
	if SERVER then
		local ply = self:GetOwner()
		local stage = self:GetStage()
		if stage == 1 then
			net.Start("tool.rooms_lib_mr"); do
				net.WriteUInt(1, 8) -- actionId
				net.WriteInt(math.Round(self.areaMin.x), 24)
				net.WriteInt(math.Round(self.areaMin.y), 24)
				net.WriteInt(math.Round(self.areaMin.z), 24)
				net.WriteInt(math.Round(self.areaMax.x), 24)
				net.WriteInt(math.Round(self.areaMax.y), 24)
				net.WriteInt(math.Round(self.areaMax.z), 24)
			end; net.Send(ply)
		else
			net.Start("tool.rooms_lib_mr"); do
				net.WriteUInt(0, 8) -- actionId
			end; net.Send(ply)
		end
	end
	return true
end


function TOOL:Think()
	-- nothing
end


if CLIENT then
	function TOOL.BuildCPanel(panel)
		panel:Help(language.GetPhrase("tool.rooms_lib_mr.desc"))
	end
end
