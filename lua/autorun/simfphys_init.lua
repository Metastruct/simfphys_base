AddCSLuaFile("simfphys/init.lua")
include("simfphys/init.lua")

if false then
	local _CreateSound=CreateSound
	CreateSound=function(ent,sn,rf)
		if not sn or #sn<3 then
			MsgN" === BAD SOUND ==="
			debug.Trace()
			
		end
		local ret = _CreateSound(ent,sn,rf)
		return ret
	end
end

-- for FastDL
local res = [[materials/effects/flashlight/headlight_highbeam.vmt
materials/effects/flashlight/headlight_highbeam.vtf
materials/effects/flashlight/headlight_lowbeam.vmt
materials/effects/flashlight/headlight_lowbeam.vtf
materials/entities/sim_fphys_combineapc.png
materials/entities/sim_fphys_conscriptapc.png
materials/entities/sim_fphys_couch.png
materials/entities/sim_fphys_jalopy.png
materials/entities/sim_fphys_jeep.png
materials/entities/weapon_simrepair.png
materials/hud/killicons/simfphys_car.vmt
materials/hud/killicons/simfphys_car.vtf
materials/simfphys/hud/cc_off.vmt
materials/simfphys/hud/cc_off.vtf
materials/simfphys/hud/cc_on.vmt
materials/simfphys/hud/cc_on.vtf
materials/simfphys/hud/fog_light_off.vmt
materials/simfphys/hud/fog_light_off.vtf
materials/simfphys/hud/fog_light_on.vmt
materials/simfphys/hud/fog_light_on.vtf
materials/simfphys/hud/handbrake_off.vmt
materials/simfphys/hud/handbrake_off.vtf
materials/simfphys/hud/handbrake_on.vmt
materials/simfphys/hud/handbrake_on.vtf
materials/simfphys/hud/high_beam_on.vmt
materials/simfphys/hud/high_beam_on.vtf
materials/simfphys/hud/hud.vmt
materials/simfphys/hud/hud.vtf
materials/simfphys/hud/hud_center.vmt
materials/simfphys/hud/hud_center.vtf
materials/simfphys/hud/hud_center_red.vmt
materials/simfphys/hud/hud_center_red.vtf
materials/simfphys/hud/hud_middle.vmt
materials/simfphys/hud/hud_middle.vtf
materials/simfphys/hud/low_beam_off.vmt
materials/simfphys/hud/low_beam_off.vtf
materials/simfphys/hud/low_beam_on.vmt
materials/simfphys/hud/low_beam_on.vtf
materials/sprites/glow_headlight_ignorez.vmt
materials/weapons/s_repair.vmt
materials/weapons/s_repair.vtf
particles/fire_01.pcf
particles/vehicle.pcf
sound/simulated_vehicles/blower_gearwhine.wav
sound/simulated_vehicles/blower_spin.wav
sound/simulated_vehicles/engine_damaged.wav
sound/simulated_vehicles/horn_5.wav
sound/simulated_vehicles/sfx/ex_backfire_1.ogg
sound/simulated_vehicles/sfx/ex_backfire_2.ogg
sound/simulated_vehicles/sfx/ex_backfire_3.ogg
sound/simulated_vehicles/sfx/ex_backfire_4.ogg
sound/simulated_vehicles/sfx/ex_backfire_damaged_1.ogg
sound/simulated_vehicles/sfx/ex_backfire_damaged_2.ogg
sound/simulated_vehicles/sfx/ex_backfire_damaged_3.ogg
sound/simulated_vehicles/sfx/grass_roll.wav
sound/simulated_vehicles/sfx/tire_break.ogg
sound/simulated_vehicles/suspension_creak_1.ogg
sound/simulated_vehicles/suspension_creak_2.ogg
sound/simulated_vehicles/suspension_creak_3.ogg
sound/simulated_vehicles/suspension_creak_4.ogg
sound/simulated_vehicles/suspension_creak_5.ogg
sound/simulated_vehicles/suspension_creak_6.ogg
sound/simulated_vehicles/turbo_blowoff.ogg
sound/simulated_vehicles/turbo_spin.wav
sound/simulated_vehicles/valve_noise.wav]]


local ForceWorkshop = CreateConVar("sv_simfphys_forceworkshop", 0, {FCVAR_ARCHIVE}, "Force clients to download the content from the workshop? (requires a restart)")

if SERVER then
	local FastDL = CreateConVar("sv_simfphys_fastdl", 1, {FCVAR_ARCHIVE}, "Add files to fastdl")
	if FastDL:GetBool() then
		for res in res:gmatch '[^\r\n]+' do
			resource.AddFile(res)
		end
	end
	if ForceWorkshop:GetBool() then
		resource.AddWorkshop("771487490")
	end
end