AddCSLuaFile("simfphys/init.lua")
include("simfphys/init.lua")

local ForceWorkshop = CreateConVar("sv_simfphys_forceworkshop", 1, {FCVAR_ARCHIVE}, "Force clients to download the content from the workshop? (requires a restart)")

if SERVER then
	if ForceWorkshop:GetBool() then
		resource.AddWorkshop("771487490")
	end
end