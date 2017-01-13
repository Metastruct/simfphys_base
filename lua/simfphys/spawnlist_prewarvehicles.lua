local Category = "Half Life 2 - Prewar"

-- DO NOT JUST ADD YOUR VEHICLE HERE, MAKE A NEW FILE IN  LUA/AUTORUN  WITH A DIFFERENT NAME! IF YOU EDIT THIS FILE YOU WILL  OVERWRITE THE ORIGINAL VEHICLES!

local V = {
	Name = "HL2 Golf",
	Model = "models/salza/hatchback/pw_hatchback.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 800,
		
		EnginePos = Vector(54.27,0,37.26),
		
		LightsTable = "golf",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/hatchback/hatchback_wheel.mdl",
		CustomWheelPosFL = Vector(44.5,28,12),
		CustomWheelPosFR = Vector(44.5,-28,12),
		CustomWheelPosRL = Vector(-46,29.5,12),
		CustomWheelPosRR = Vector(-46,-29.5,12),
		CustomWheelAngleOffset = Angle(0,90,0),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-8.5,-16,44),
		SeatPitch = 0,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(5,-16,14),
				ang = Angle(0,-90,20)
			},
			{
				pos = Vector(-24,-16,14),
				ang = Angle(0,-90,20)
			},
			{
				pos = Vector(-24,16,14),
				ang = Angle(0,-90,20)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 20000,
		FrontDamping = 1000,
		FrontRelativeDamping = 500,
		
		RearHeight = 6.5,
		RearConstant = 20000,
		RearDamping = 1000,
		RearRelativeDamping = 500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 23,
		Efficiency = 1,
		GripOffset = -0.7,
		BrakePower = 25,
		
		IdleRPM = 750,
		LimitRPM = 6200,
		PeakTorque = 75,
		PowerbandStart = 1750,
		PowerbandEnd = 5700,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = -1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/4banger/4banger_idle.wav",
		
		snd_low = "simulated_vehicles/4banger/4banger_low.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/4banger/4banger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/4banger/4banger_second.wav",
		snd_mid_pitch = 0.8,
		
		snd_horn = "simulated_vehicles/horn_3.wav",
		
		DifferentialGear = 0.78,
		Gears = {-0.08,0,0.08,0.18,0.26,0.33}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwhatchback", V )


local V = {
	Name = "HL2 Van",
	Model = "models/salza/van/pw_van.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,
	
	Members = {
		Mass = 2500,
		
		EnginePos = Vector(89.98,0,51.3),
		
		LightsTable = "van",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/van/van_wheel.mdl",
		CustomWheelPosFL = Vector(45,44,20),
		CustomWheelPosFR = Vector(45,-44,20),
		CustomWheelPosRL = Vector(-72,44,20),
		CustomWheelPosRR = Vector(-72,-44,20),
		CustomWheelAngleOffset = Angle(0,-90,0),
		
		CustomMassCenter = Vector(0,0,10),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(36,-23,72),
		SeatPitch = 8,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(45,-27,33),
				ang = Angle(0,-90,9)
			},
			{
				pos = Vector(45,0,33),
				ang = Angle(0,-90,9)
			},
			{
				pos = Vector(-38,-29,28),
				ang = Angle(0,0,0)
			}
		},
		
		FrontHeight = 12,
		FrontConstant = 45000,
		FrontDamping = 5000,
		FrontRelativeDamping = 5000,
		
		RearHeight = 12,
		RearConstant = 45000,
		RearDamping = 5000,
		RearRelativeDamping = 5000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 350,
		
		TurnSpeed = 8,
		
		MaxGrip = 45,
		Efficiency = 1.8,
		GripOffset = 0,
		BrakePower = 55,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 95,
		PowerbandStart = 1000,
		PowerbandEnd = 5500,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic3/generic3_idle.wav",
		
		snd_low = "simulated_vehicles/generic3/generic3_low.wav",
		snd_low_revdown = "simulated_vehicles/generic3/generic3_revdown.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/generic3/generic3_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic3/generic3_second.wav",
		snd_mid_pitch = 1,
		
		DifferentialGear = 0.52,
		Gears = {-0.1,0,0.1,0.2,0.3,0.4}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwvan", V )


local V = {
	Name = "HL2 Moskvich",
	Model = "models/salza/moskvich/moskvich.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1350,
		
		EnginePos = Vector(55.76,0,44.4),
		
		LightsTable = "moskvich",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/moskvich/moskvich_wheel.mdl",
		CustomWheelPosFL = Vector(52,32,12),
		CustomWheelPosFR = Vector(52,-32,12),
		CustomWheelPosRL = Vector(-55,29.5,12),
		CustomWheelPosRR = Vector(-55,-29.5,12),
		CustomWheelAngleOffset = Angle(0,0,0),
		
		CustomMassCenter = Vector(0,0,2.5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-12,-16,49),
		SeatPitch = 0,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(-4,-16,17.5),
				ang = Angle(0,-90,10)
			},
			{
				pos = Vector(-40,16,19),
				ang = Angle(0,-90,10)
			},
			{
				pos = Vector(-40,-16,19),
				ang = Angle(0,-90,10)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 25000,
		FrontDamping = 1500,
		FrontRelativeDamping = 1500,
		
		RearHeight = 6.5,
		RearConstant = 25000,
		RearDamping = 1500,
		RearRelativeDamping = 1500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 35,
		Efficiency = 1,
		GripOffset = -1.5,
		BrakePower = 38,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 100,
		PowerbandStart = 1500,
		PowerbandEnd = 5800,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic1/generic1_idle.wav",
		
		snd_low = "simulated_vehicles/generic1/generic1_low.wav",
		snd_low_revdown = "simulated_vehicles/generic1/generic1_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/generic1/generic1_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic1/generic1_second.wav",
		snd_mid_pitch = 1.1,
		
		snd_horn = "simulated_vehicles/horn_5.wav",
		
		DifferentialGear = 0.6,
		Gears = {-0.1,0,0.1,0.18,0.26,0.34,0.42}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwmoskvich", V )



local V = {
	Name = "HL2 Trabant",
	Model = "models/salza/trabant/trabant.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,

	Members = {
		Mass = 850,
		
		EnginePos = Vector(0.6,56.38,38.7),
		
		LightsTable = "trabbi",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/trabant/trabant_wheel.mdl",
		CustomWheelPosFL = Vector(-32,50,12),
		CustomWheelPosFR = Vector(32,50,12),
		CustomWheelPosRL = Vector(-32,-41.5,12),
		CustomWheelPosRR = Vector(32,-41.5,12),
		CustomWheelAngleOffset = Angle(0,0,0),
		
		CustomMassCenter = Vector(0,0,1),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-8.5,-16,44),
		SeatPitch = 0,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(16,-2,12.5),
				ang = Angle(0,0,8)
			},
			{
				pos = Vector(0,-2,12.5),
				ang = Angle(0,0,8)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 24000,
		FrontDamping = 1200,
		FrontRelativeDamping = 1200,
		
		RearHeight = 6.5,
		RearConstant = 24000,
		RearDamping = 1200,
		RearRelativeDamping = 1200,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 30,
		Efficiency = 1.1,
		GripOffset = -1,
		BrakePower = 30,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 85,
		PowerbandStart = 2000,
		PowerbandEnd = 7000,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = -1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic5/generic5_idle.wav",
		
		snd_low = "simulated_vehicles/generic5/generic5_low.wav",
		snd_low_revdown = "simulated_vehicles/generic5/generic5_revdown.wav",
		snd_low_pitch = 0.7,
		
		snd_mid = "simulated_vehicles/generic5/generic5_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic5/generic5_gear.wav",
		snd_mid_pitch = 0.7,
		
		DifferentialGear = 0.6,
		Gears = {-0.1,0,0.1,0.2,0.28}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwtrabant", V )



local V = {
	Name = "HL2 Trabant 2",
	Model = "models/salza/trabant/trabant02.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,

	Members = {
		Mass = 850,
		
		EnginePos = Vector(0,56.38,38.7),
		
		LightsTable = "trabbi",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/trabant/trabant02_wheel.mdl",
		CustomWheelPosFL = Vector(-32,50,12),
		CustomWheelPosFR = Vector(32,50,12),
		CustomWheelPosRL = Vector(-32,-41.5,12),
		CustomWheelPosRR = Vector(32,-41.5,12),
		CustomWheelAngleOffset = Angle(0,0,0),
		
		CustomMassCenter = Vector(0,0,1),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-8.5,-16,44),
		SeatPitch = 0,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(16,-2,12.5),
				ang = Angle(0,0,8)
			},
			{
				pos = Vector(0,-2,12.5),
				ang = Angle(0,0,8)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 24000,
		FrontDamping = 1200,
		FrontRelativeDamping = 1200,
		
		RearHeight = 6.5,
		RearConstant = 24000,
		RearDamping = 1200,
		RearRelativeDamping = 1200,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 30,
		Efficiency = 1.1,
		GripOffset = -1,
		BrakePower = 30,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 85,
		PowerbandStart = 2000,
		PowerbandEnd = 7000,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = -1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic5/generic5_idle.wav",
		
		snd_low = "simulated_vehicles/generic5/generic5_low.wav",
		snd_low_revdown = "simulated_vehicles/generic5/generic5_revdown.wav",
		snd_low_pitch = 0.7,
		
		snd_mid = "simulated_vehicles/generic5/generic5_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic5/generic5_gear.wav",
		snd_mid_pitch = 0.7,
		
		DifferentialGear = 0.6,
		Gears = {-0.1,0,0.1,0.2,0.28}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwtrabant02", V )


local V = {
	Name = "HL2 Volga",
	Model = "models/salza/volga/volga.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1350,
		
		EnginePos = Vector(65.39,0,44.84),
		
		LightsTable = "volga",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/volga/volga_wheel.mdl",
		CustomWheelPosFL = Vector(64,34,13),
		CustomWheelPosFR = Vector(64,-34,13),
		CustomWheelPosRL = Vector(-55,34,13),
		CustomWheelPosRR = Vector(-55,-34,13),
		CustomWheelAngleOffset = Angle(0,-90,0),
		
		CustomMassCenter = Vector(0,0,2.5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-4,-17.5,52),
		SeatPitch = 5,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(6,-17.5,18.5),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(6,0,18.5),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,-17.5,18.5),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,17.5,18.5),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,-0,18.5),
				ang = Angle(0,-90,12)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 25000,
		FrontDamping = 1500,
		FrontRelativeDamping = 1500,
		
		RearHeight = 6.5,
		RearConstant = 25000,
		RearDamping = 1500,
		RearRelativeDamping = 1500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 35,
		Efficiency = 1,
		GripOffset = -1.5,
		BrakePower = 38,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 100,
		PowerbandStart = 1500,
		PowerbandEnd = 5800,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic2/generic2_idle.wav",
		
		snd_low = "simulated_vehicles/generic2/generic2_low.wav",
		snd_low_revdown = "simulated_vehicles/generic2/generic2_revdown.wav",
		snd_low_pitch = 1,
		
		snd_mid = "simulated_vehicles/generic2/generic2_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic2/generic2_second.wav",
		snd_mid_pitch = 1.1,
		
		snd_horn = "simulated_vehicles/horn_5.wav",
		
		DifferentialGear = 0.62,
		Gears = {-0.1,0,0.1,0.18,0.26,0.31,0.38}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwvolga", V )


local V = {
	Name = "HL2 ZAZ",
	Model = "models/salza/zaz/zaz.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1150,
		
		EnginePos = Vector(63.64,0,47.96),
		
		LightsTable = "zaz",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/zaz/zaz_wheel.mdl",
		CustomWheelPosFL = Vector(61,32,17),
		CustomWheelPosFR = Vector(61,-34,17),
		CustomWheelPosRL = Vector(-53,32,17),
		CustomWheelPosRR = Vector(-53,-34,17),
		CustomWheelAngleOffset = Angle(0,90,0),
		
		CustomMassCenter = Vector(0,0,2.5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-3,-17.5,54),
		SeatPitch = 5,
		SeatYaw = 90,
		
		--[[
		ModelInfo = {
			Skin = 1
		},
		]]--
		
		PassengerSeats = {
			{
				pos = Vector(6,-17.5,20),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,-17.5,24),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,17.5,24),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,0,24),
				ang = Angle(0,-90,12)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 25000,
		FrontDamping = 1500,
		FrontRelativeDamping = 1500,
		
		RearHeight = 6.5,
		RearConstant = 25000,
		RearDamping = 1500,
		RearRelativeDamping = 1500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 35,
		Efficiency = 1,
		GripOffset = -1.5,
		BrakePower = 38,
		
		IdleRPM = 750,
		LimitRPM = 7250,
		PeakTorque = 60,
		PowerbandStart = 2000,
		PowerbandEnd = 6950,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic3/generic3_idle.wav",
		
		snd_low = "simulated_vehicles/generic3/generic3_low.wav",
		snd_low_revdown = "simulated_vehicles/generic3/generic3_revdown.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/generic3/generic3_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic3/generic3_second.wav",
		snd_mid_pitch = 0.9,
		
		DifferentialGear = 0.42,
		Gears = {-0.1,0,0.1,0.17,0.24,0.3,0.37,0.41}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwzaz", V )


local V = {
	Name = "HL2 GAZ52",
	Model = "models/salza/gaz52/gaz52.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,

	Members = {
		Mass = 3000,
		
		EnginePos = Vector(0,61.23,76.81),
		
		LightsTable = "gaz",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/gaz52/gaz52_wheel.mdl",
		CustomWheelPosFL = Vector(-40,55,25),
		CustomWheelPosFR = Vector(40,55,25),
		CustomWheelPosRL = Vector(-45,-120,25),
		CustomWheelPosRR = Vector(45,-120,25),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,18),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-20,-23,85),
		SeatPitch = 10,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(23,-2,50),
				ang = Angle(0,0,5)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 38000,
		FrontDamping = 6000,
		FrontRelativeDamping = 6000,
		
		RearHeight = 12,
		RearConstant = 38000,
		RearDamping = 6000,
		RearRelativeDamping = 6000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 600,
		
		TurnSpeed = 8,
		
		MaxGrip = 85,
		Efficiency = 1.2,
		GripOffset = -12,
		BrakePower = 80,
		
		IdleRPM = 500,
		LimitRPM = 5000,
		PeakTorque = 150,
		PowerbandStart = 650,
		PowerbandEnd = 4700,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "vehicles/crane/crane_startengine1.wav",
		
		snd_low ="simulated_vehicles/alfaromeo/alfaromeo_low.wav",
		snd_low_pitch = 0.35,
		
		snd_mid = "simulated_vehicles/alfaromeo/alfaromeo_mid.wav",
		snd_mid_gearup = "simulated_vehicles/alfaromeo/alfaromeo_second.wav",
		snd_mid_pitch = 0.5,
		
		DifferentialGear = 0.25,
		Gears = {-0.1,0,0.1,0.19,0.29,0.37,0.44,0.5,0.57}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwgaz52", V )




local V = {
	Name = "HL2 Liaz",
	Model = "models/salza/skoda_liaz/skoda_liaz.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,

	Members = {
		Mass = 3000,
		
		EnginePos = Vector(-1.75,-0.56,51.17),
		
		LightsTable = "liaz",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/skoda_liaz/skoda_liaz_fwheel.mdl",
		CustomWheelModel_R = "models/salza/skoda_liaz/skoda_liaz_rwheel.mdl",
		CustomWheelPosFL = Vector(-44,57,25),
		CustomWheelPosFR = Vector(40,57,25),
		CustomWheelPosRL = Vector(-50,-98,25),
		CustomWheelPosRR = Vector(47,-98,25),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,30,10),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(40,-27,100),
		SeatPitch = 10,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(27,58,60),
				ang = Angle(0,0,5)
			}
		},
		
		StrengthenSuspension = false,
		
		FrontHeight = 16,
		FrontConstant = 32000,
		FrontDamping = 12000,
		FrontRelativeDamping = 12000,
		
		RearHeight = 12.5,
		RearConstant = 25000,
		RearDamping = 6000,
		RearRelativeDamping = 6000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 600,
		
		TurnSpeed = 8,
		
		MaxGrip = 75,
		Efficiency = 1,
		GripOffset = -1,
		BrakePower = 80,
		
		IdleRPM = 500,
		LimitRPM = 5500,
		PeakTorque = 125,
		PowerbandStart = 650,
		PowerbandEnd = 5300,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "vehicles/crane/crane_startengine1.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/alfaromeo/alfaromeo_low.wav",
		Sound_MidPitch = 0.5,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "",
		
		Sound_Throttle = "",
		
		DifferentialGear = 0.22,
		Gears = {-0.1,0,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.5}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwliaz", V )



local V = {
	Name = "HL2 avia",
	Model = "models/salza/avia/avia.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 2500,
		
		EnginePos = Vector(49.37,-2.41,44.13),
		
		LightsTable = "avia",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/avia/avia_wheel.mdl",
		CustomWheelPosFL = Vector(78,37,17),
		CustomWheelPosFR = Vector(78,-40,17),
		CustomWheelPosRL = Vector(-55,38.5,17),
		CustomWheelPosRR = Vector(-55,-37,17),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(55,-20,95),
		SeatPitch = 15,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(79,-21,45),
				ang = Angle(0,-90,0)
			}
		},
		
		FrontHeight = 8,
		FrontConstant = 40000,
		FrontDamping = 3500,
		FrontRelativeDamping = 3500,
		
		RearHeight = 8,
		RearConstant = 40000,
		RearDamping = 3500,
		RearRelativeDamping = 3500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 49,
		Efficiency = 1.1,
		GripOffset = -2,
		BrakePower = 45,	
		
		IdleRPM = 750,
		LimitRPM = 4200,
		PeakTorque = 160,
		PowerbandStart = 1500,
		PowerbandEnd = 3800,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/jeep/jeep_idle.wav",
		
		snd_low = "simulated_vehicles/jeep/jeep_low.wav",
		snd_low_revdown = "simulated_vehicles/jeep/jeep_revdown.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/jeep/jeep_mid.wav",
		snd_mid_gearup = "simulated_vehicles/jeep/jeep_second.wav", 
		snd_mid_pitch = 1,
		
		DifferentialGear = 0.45,
		Gears = {-0.15,0,0.15,0.25,0.35,0.45,0.52}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwavia", V )