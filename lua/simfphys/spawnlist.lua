-- Example script for vehicles WITH valves skeleton / animations / bones
-- if you want to use a model that doesnt have these then take a look at the simfphys_spawnlist_nobones.lua

-- DO NOT JUST ADD YOUR VEHICLE HERE, MAKE A NEW FILE IN  LUA/AUTORUN  WITH A DIFFERENT NAME! IF YOU EDIT THIS FILE YOU WILL  OVERWRITE THE ORIGINAL VEHICLES!

local V = {
	Name = "HL2 Jeep",
	Model = "models/buggy.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Half Life 2 / Synergy",
	--SpawnOffset = Vector(0,0,0),

	Members = {
		Mass = 1700,	-- total mass of the   vehicle + masscenter counterweight     excluding the wheels
		--FrontWheelMass = 50,
		--RearWheelMass = 50,
		
		--MaxHealth = 1000,    -- overrides max health
		--AirFriction = -250,
		LightsTable = "jeep",  --wich list we want to use for our light positions. You can comment this variable out if you dont want lights.  lights are defined in simfphys_lights.lua 
		
		FrontWheelRadius = 18,			--sadly, these cannot be measured from the model. you need to look in the vehicle script @ scripts/vehicles/XXX.txt and find "radius" for both front and rear axle
		RearWheelRadius = 20,
		
		CustomMassCenter = Vector(0,0,0),		-- custom masscenter offset. The script creates a counter weight to make the masscenter exactly in the center of the wheels. However you can add an offset to this to create more body roll if you really have to... 
										--If you set the masscenter too low it will roll in the wrong direction in corners
		
		SeatOffset = Vector(0,0,-2),	--driver seat offset
		SeatPitch = 0,
		
		SpeedoMax = 120,    -- in mph.  if your vehicle interior has an working speedometer you can adjust it here. Some vehicles are very inaccurate so if the speedo matches at slowspeed that doesnt mean it will match at high speeds
		
		--RPMGaugePP = "vehicle_guage",  -- pose parameter name for the RPM gauge. poseparameter 0 should be 0 RPM and poseparameter 1 should be the RPM defined in RPMGaugeMax
		--RPMGaugeMax = 6500,
		
		--[[
		ModelInfo = {
			Bodygroups = {0,2,1},   -- Sets first bodygroup to 0, second to 2 and third to 1
			Color = Color(0,31,127,255),
			Skin = 1,
			WheelColor = Color(100,255,255,50)
		},
		]]--
		
		PassengerSeats = {
		},
		
		--[[
		Attachments = {
			{
				model = "models/hunter/plates/plate075x105.mdl",
				material = "lights/white",
				useVehicleColor = true,
				pos = Vector(0.04,57.5,16.74),
				ang = Angle(90,-90,0)
			},
		}
		]]--
		
		--[[
		Backfire = true,
		ExhaustPositions = {
			{
				pos = Vector(-94.91,24.24,9.65),
				ang = Angle(90,180,0),
				OnBodyGroups = { [4] = {0,2} }   -- if bodygroup number 4 is set to 0 or 2 the exhaust effect will be used
			},
			{
				pos = Vector(-96.27,18.81,9.63),
				ang = Angle(90,180,0)
			},
			{
				pos = Vector(-94.91,-24.24,9.65),
				ang = Angle(90,180,0)
			},
			{
				pos = Vector(-96.27,-18.81,9.63),
				ang = Angle(90,180,0)
			}
		},
		]]--
		
		StrengthenSuspension = false, -- if set to true it will increase the constant limit to 10 0000 but double the amount of constraints used. Also the limiters of the physical wheel will be set tighter. You can make the physical wheelpos visible by typing cl_simfphys_debugwheels = 1 into the console
							  --If you are using vehicle models with bones/poseparameters and experience floating wheels or wheels clipping into the ground then this will probably fix it. 
							  --Keep in mind that this will make the suspension alot more responsive to bumps and stiffer. If your wheels are still leaving the ground in corners you will have to decrease the constant or lower the masscenter
		
		FrontHeight = 13.5,		--positive numbers only
		FrontConstant = 27000,		--max 50000 if StrengthenSuspension set to false     constant can be imagined as spring strength
		FrontDamping = 2800,		-- dont set damping/relative damping too high or it will spazz     damping is basically the shock absorbers
		FrontRelativeDamping = 2800,  -- the amount of energy the spring loses proportional to the relative velocity of the vehicle vs wheel 
		
		RearHeight = 13.5,
		RearConstant = 32000,
		RearDamping = 2900,
		RearRelativeDamping = 2900,
		
		FastSteeringAngle = 10,	--steering angle at high speeds.
		SteeringFadeFastSpeed = 535,	--at wich speed (gmod units per second) we want to fade from slow steer angle to fast steer angle
		
		TurnSpeed = 8,		--how fast the steering will move to its target angle
		
		MaxGrip = 44,	--max available grip
		Efficiency = 1.337,	--this defines how good the wheels can put the engine power to the ground. this also increases engine power and brake force.  Its a cheap way to make your car accelerate faster without having to deal with griploss
		GripOffset = 0,	-- a negative value will get more understeer, a positive value more oversteer. NOTE: this will not affect under/oversteer caused by engine power.   This value can be found as Tractionbias in the EDIT properties menu however it is divided by MaxGrip there
		BrakePower = 40,		--how strong the brakes are, NOTE: this can be higher than MaxGrip. Sorry folks but i couldnt stand how people fail to realize that braking while turning decreases grip and therefore causes understeer. So i excluded it from the grip calculations
		
		IdleRPM = 750,	-- must be smaller than powerbandstart
		LimitRPM = 6500,  -- should never be less than PowerbandStart and PowerbandEnd
		--Revlimiter = true,  -- LimitRPM MUST be greater than 2500 for this to work!
		PeakTorque = 100,
		PowerbandStart = 2200,  --must be greater than IdleRPM but dont set this too high because it will also be used as shifting point for the automatic transmission.
		PowerbandEnd = 6300, -- should never be greater but ideally 200rpm less than LimitRPM. Must be greater than powerbandstart

		Turbocharged = false,
		--snd_blowoff = "path/to/sound.wav",  -- replace turbo blowoff sound
		--snd_spool = "ambient/gas/steam2.wav",  -- replace the turbo spool sound
		
		Supercharged = false,
		--snd_bloweron = "simulated_vehicles/blower_gearwhine.wav",  -- played when the supercharger is on load
		--snd_bloweroff = "simulated_vehicles/blower_spin.wav",	 -- played all the time but gets louder when not on load
		
		--DoNotStall = true,  -- prevents the engine from stalling
		
		PowerBias = 0.5,	--how much power goes to the front and rear wheels,   1 = rear wheel drive    -1 = front wheel Drive     0 = all wheel drive with power distributed equally on front and rear wheels
		
		EngineSoundPreset = -1,-- available sound presets:   -1 = use custom sound preset with gearchange and revdown sounds  ,  0 = use simple custom sounds preset ,  1 = GTA 5 Dukes  ,  2 = Master Chris's 1969 charger   ,  3 = shelby  ,   4 = hl2 jeep  ,  5 = synergy elite jeep  ,  6 = 4banger  ,   7 = hl2 jalopy cruise ,   8 = alfa romeo diesel (thanks to salza for recording)
		
		
		-- preset -1
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/jeep/jeep_idle.wav",  --you have to have an idle sound or the script will fallback to preset 0
		
		snd_low = "simulated_vehicles/jeep/jeep_low.wav",  			--you have to have an low rpm sound or the script will fallback to preset 0.  This will be used as "continue" sound for  snd_low_revdown so it has to sound the same.
		snd_low_revdown = "simulated_vehicles/jeep/jeep_revdown.wav",	--you dont need this one. if you comment it out it will use snd_low instead. The only difference in this should be the "startup",  once it reaches the loop part it should be the same as snd_low
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/jeep/jeep_mid.wav",  			--you have to have an mid sound or the script will fallback to preset 0. This will be used as "continue" sound for  snd_mid_gearup so it has to sound the same.
		snd_mid_gearup = "simulated_vehicles/jeep/jeep_second.wav", 	--you dont need this one but it is highly recommended to have it since this is the point of this sound definition.  if you comment it out it will use snd_mid instead but will cause sound issues ingame.
													--The soundfile should basically be the same as snd_mid but it should include the "gearchange" sound. Also make sure you set the start_cue and end_cue correctly so it doesnt loop the gearchange.
													--I highly advice to use EngineSoundPreset 0 if you dont have an matching sound for this one. 
		
		--snd_mid_geardown = "simulated_vehicles/shelby/shelby_shiftdown.wav",	-- same for geardown
		snd_mid_pitch = 1,
		--
		
		-- make sure every sound is looped https://developer.valvesoftware.com/wiki/Looping_a_Sound
		
		--if you set EngineSoundPreset to 0 you will have to define the sounds down below.
		Sound_Idle = "simulated_vehicles/misc/nanjing_loop.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/misc/m50.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 58,		-- at wich percentage of limitrpm the sound fades out
		Sound_MidFadeOutRate = 0.476,                    --how fast it fades out   0 = instant       1 = never
		
		Sound_High = "simulated_vehicles/misc/v8high2.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 0.75,
		Sound_HighFadeInRPMpercent = 58,
		Sound_HighFadeInRate = 0.19,
		
		Sound_Throttle = "",		-- mutes the default throttle sound
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		--
		
		snd_horn = "simulated_vehicles/horn_1.wav",   -- wich sound to use as horn
		
		DifferentialGear = 0.3,
		Gears = {-0.15,0,0.15,0.25,0.35,0.45}	-- 0.15 means 1 revolution of the engine = 0.15 of the driveshaft
		-- First Gear should always be reverse, second neutral, third is the actual first gear.
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_jeep", V )


local V = {
	Name = "HL2 Combine APC",
	Model = "models/combine_apc.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Half Life 2 / Synergy",

	Members = {
		Mass = 3500,
		MaxHealth = 3000,
		
		FrontWheelRadius = 28,
		RearWheelRadius = 28,
		
		SeatOffset = Vector(-25,0,104),
		SeatPitch = 0,
		
		PassengerSeats = {
		},
		
		FrontHeight = 10,
		FrontConstant = 50000,
		FrontDamping = 3000,
		FrontRelativeDamping = 3000,
		
		RearHeight = 10,
		RearConstant = 50000,
		RearDamping = 3000,
		RearRelativeDamping = 3000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 70,
		Efficiency = 1.8,
		GripOffset = 0,
		BrakePower = 70,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 100,
		PowerbandStart = 1500,
		PowerbandEnd = 5800,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 0,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/c_apc/apc_idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/c_apc/apc_mid.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "",
		
		Sound_Throttle = "",
		
		snd_horn = "ambient/alarms/apc_alarm_pass1.wav",
		
		DifferentialGear = 0.3,
		Gears = {-0.1,0,0.1,0.2,0.3}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_combineapc", V )


local V = {
	Name = "HL2:EP2 Jalopy",
	Model = "models/vehicle.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Half Life 2 / Synergy",

	Members = {
		Mass = 1700,
		LightsTable = "jalopy",
		
		FrontWheelRadius = 18,
		RearWheelRadius = 20,
		
		SeatOffset = Vector(-1,0,5),
		SeatPitch = 3,
		
		PassengerSeats = {
			{
				pos = Vector(21,-22,21),
				ang = Angle(0,0,9)
			}
		},
		
		ExhaustPositions = {
			{
				pos = Vector(-21.63,-142.52,37.55),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(19.65,-144.09,38.03),
				ang = Angle(90,-90,0)
			}
		},
		
		FrontHeight = 11.5,
		FrontConstant = 27000,
		FrontDamping = 2800,
		FrontRelativeDamping = 2800,
		
		RearHeight = 8.5,
		RearConstant = 32000,
		RearDamping = 2900,
		RearRelativeDamping = 2900,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 45,
		Efficiency = 1.22,
		GripOffset = -0.5,
		BrakePower = 50,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 130,
		PowerbandStart = 2200,
		PowerbandEnd = 5800,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 0.9,
		snd_idle = "simulated_vehicles/jalopy/jalopy_idle.wav",
		
		snd_low = "simulated_vehicles/jalopy/jalopy_low.wav",
		snd_low_revdown = "simulated_vehicles/jalopy/jalopy_revdown.wav",
		snd_low_pitch = 0.95,
		
		snd_mid = "simulated_vehicles/jalopy/jalopy_mid.wav",
		snd_mid_gearup = "simulated_vehicles/jalopy/jalopy_second.wav",
		snd_mid_pitch = 1.1,
		
		Sound_Idle = "simulated_vehicles/jalopy/jalopy_idle.wav",
		Sound_IdlePitch = 0.95,
		
		Sound_Mid = "simulated_vehicles/jalopy/jalopy_mid.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 55,
		Sound_MidFadeOutRate = 0.25,
		
		Sound_High = "simulated_vehicles/jalopy/jalopy_high.wav",
		Sound_HighPitch = 0.75,
		Sound_HighVolume = 0.9,
		Sound_HighFadeInRPMpercent = 55,
		Sound_HighFadeInRate = 0.4,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		DifferentialGear = 0.3,
		Gears = {-0.15,0,0.15,0.25,0.35,0.45}
	}
}
if (file.Exists( "models/vehicle.mdl", "GAME" )) then
	list.Set( "simfphys_vehicles", "sim_fphys_jalopy", V )
end



local V = {
	Name = "Synergy Elite Jeep",
	Model = "models/vehicles/buggy_elite.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Half Life 2 / Synergy",

	Members = {
		Mass = 1200,
		
		LightsTable = "elitejeep",
		
		FrontWheelRadius = 18,
		RearWheelRadius = 20,
		
		SeatOffset = Vector(0,0,-3),
		SeatPitch = 0,
		
		PassengerSeats = {
			{
			pos = Vector(16,-35,21),
			ang = Angle(0,0,9)
			}
		},
		
		Backfire = true,
		ExhaustPositions = {
			{
				pos = Vector(-15.69,-105.94,14.94),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(16.78,-105.46,14.35),
				ang = Angle(90,-90,0)
			}
		},
		
		StrengthenSuspension = true,
		
		FrontHeight = 13.5,
		FrontConstant = 25000,
		FrontDamping = 1000,
		FrontRelativeDamping = 1000,
		
		RearHeight = 13.5,
		RearConstant = 25000,
		RearDamping = 1000,
		RearRelativeDamping = 1000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 44,
		Efficiency = 1.1,
		GripOffset = 0,
		BrakePower = 40,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 185,
		PowerbandStart = 2500,
		PowerbandEnd = 7300,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 0.6,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/v8elite/v8elite_idle.wav",
		
		snd_low = "simulated_vehicles/v8elite/v8elite_low.wav",
		snd_low_revdown = "simulated_vehicles/v8elite/v8elite_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/v8elite/v8elite_mid.wav",
		snd_mid_gearup = "simulated_vehicles/v8elite/v8elite_second.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_4.wav",
		
		DifferentialGear = 0.52,
		Gears = {-0.1,0,0.1,0.18,0.25,0.31,0.40}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_v8elite", V )

local V = {
	Name = "Synergy Van",
	Model = "models/vehicles/7seatvan.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Half Life 2 / Synergy",

	Members = {
		Mass = 2500,
		
		FrontWheelRadius = 15.5,
		RearWheelRadius = 15.5,
		
		SeatOffset = Vector(0,0,-5),
		SeatPitch = 6,
		
		PassengerSeats = {
			{
				pos = Vector(27,60,33),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(0,60,33),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(30,-25,37.5),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(-30,-25,37.5),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-30,-60,37.5),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(30,-60,37.5),
				ang = Angle(0,90,0)
			}
		},
		
		FrontHeight = 12,
		FrontConstant = 45000,
		FrontDamping = 2500,
		FrontRelativeDamping = 2500,
		
		RearHeight = 12,
		RearConstant = 45000,
		RearDamping = 2500,
		RearRelativeDamping = 2500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 350,
		
		TurnSpeed = 8,
		
		MaxGrip = 45,
		Efficiency = 1.8,
		GripOffset = 0,
		BrakePower = 55,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 80,
		PowerbandStart = 1000,
		PowerbandEnd = 5500,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/4banger/4banger_idle.wav",
		
		snd_low = "simulated_vehicles/4banger/4banger_low.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/4banger/4banger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/4banger/4banger_second.wav",
		snd_mid_pitch = 0.8,
		
		DifferentialGear = 0.52,
		Gears = {-0.1,0,0.1,0.2,0.3,0.4}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_van", V )


local V = {
	Name = "1969 Dodge Charger",
	Model = "models/vehicles/cars/69charger.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Base",
	Members = {
		Mass = 1700,
		
		LightsTable = "charger",
		
		FrontWheelRadius = 15,
		RearWheelRadius = 15,
		
		SeatOffset = Vector(0,0,-1),
		SeatPitch = 0,
		
		PassengerSeats = {
			{
				pos = Vector(20,0,20),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(20,-30,20),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(-20,-30,20),
				ang = Angle(0,0,9)
			}
		},
		
		ExhaustPositions = {
			{
				pos = Vector(17.7,-121,17.5),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(-17.7,-121,17.5),
				ang = Angle(90,-90,0)
			}
		},
		
		FrontHeight = 13,	
		FrontConstant = 28000,
		FrontDamping = 2800,
		FrontRelativeDamping = 2800,
		
		RearHeight = 12,
		RearConstant = 32000,
		RearDamping = 2900,
		RearRelativeDamping = 2900,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 43,
		Efficiency = 1.45,
		GripOffset = -2,
		BrakePower = 50,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 285,
		PowerbandStart = 2000,
		PowerbandEnd = 7000,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 0.95,
		snd_idle = "simulated_vehicles/master_chris_charger69/charger_idle.wav",
		
		snd_low = "simulated_vehicles/master_chris_charger69/charger_low.wav",
		snd_low_revdown = "simulated_vehicles/master_chris_charger69/charger_revdown.wav",
		snd_low_pitch = 0.75,
		
		snd_mid = "simulated_vehicles/master_chris_charger69/charger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/master_chris_charger69/charger_second.wav",
		snd_mid_geardown = "simulated_vehicles/master_chris_charger69/charger_shiftdown.wav",
		snd_mid_pitch = 0.9,
		
		snd_horn = "simulated_vehicles/horn_3.wav",
		
		DifferentialGear = 0.65, 
		Gears = {-0.12,0,0.12,0.21,0.32,0.42}
	}
}
if (file.Exists( "models/vehicles/cars/69charger.mdl", "GAME" )) then
	list.Set( "simfphys_vehicles", "sim_fphys_charger", V )
end



local V = {
	Name = "Mad Max Interceptor",
	Model = "models/vehicles/madmax/interceptordrive.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Base",

	Members = {
		Mass = 1385,
		AirFriction = -1500,
		
		LightsTable = "madmax",
		
		FrontWheelRadius = 14.6,
		RearWheelRadius = 15.6,
		
		SeatOffset = Vector(-4,0,-4),
		SeatPitch = 0,
		
		PassengerSeats = {
			{
				pos = Vector(21,0,20),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(21,-30,20),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(-21,-30,20),
				ang = Angle(0,0,9)
			}
		},
		
				
		ExhaustPositions = {
			{
				pos = Vector(49,-38,23.5),
				ang = Angle(30,0,0)
			},
			{
				pos = Vector(49,-34.5,23.5),
				ang = Angle(30,0,0)
			},
			{
				pos = Vector(49,-31,23.5),
				ang = Angle(30,0,0)
			},
			{
				pos = Vector(49,-27.5,23.5),
				ang = Angle(30,0,0)
			},
			{
				pos = Vector(-49,-38,23.5),
				ang = Angle(-30,0,0)
			},
			{
				pos = Vector(-49,-34.5,23.5),
				ang = Angle(-30,0,0)
			},
			{
				pos = Vector(-49,-31,23.5),
				ang = Angle(-30,0,0)
			},
			{
				pos = Vector(-49,-27.5,23.5),
				ang = Angle(-30,0,0)
			}
		},
		
		FrontHeight = 10,
		FrontConstant = 28000,
		FrontDamping = 2800,
		FrontRelativeDamping = 2800,
		
		RearHeight = 8,
		RearConstant = 32000,
		RearDamping = 2900,
		RearRelativeDamping = 2900,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 44,
		Efficiency = 1.2,
		GripOffset = -3.8,
		BrakePower = 60,
		
		IdleRPM = 800,
		LimitRPM = 7000,
		PeakTorque = 200,
		PowerbandStart = 2000,
		PowerbandEnd = 6500,
		Turbocharged = false,
		Supercharged = true,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 0.85,
		snd_idle = "simulated_vehicles/shelby/shelby_idle.wav",
		
		snd_low = "simulated_vehicles/shelby/shelby_low.wav",
		snd_low_revdown = "simulated_vehicles/shelby/shelby_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/shelby/shelby_mid.wav",
		snd_mid_gearup = "simulated_vehicles/shelby/shelby_second.wav",
		snd_mid_geardown = "simulated_vehicles/shelby/shelby_shiftdown.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_7.wav",
		
		DifferentialGear = 0.58,
		Gears = {-0.12,0,0.12,0.21,0.32,0.40,0.48}
	}
}
if (file.Exists( "models/vehicles/madmax/interceptordrive.mdl", "GAME" )) then
	list.Set( "simfphys_vehicles", "sim_fphys_interceptor", V )
end
