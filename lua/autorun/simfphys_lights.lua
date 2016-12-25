-- DO NOT JUST ADD YOUR LIGHTS HERE, MAKE A NEW FILE IN  LUA/AUTORUN  WITH A DIFFERENT NAME! IF YOU EDIT THIS FILE YOU WILL  OVERWRITE THE ORIGINAL LIGHTS!

local light_table = {
	-- projected texture / lamp pos   - front
	L_HeadLampPos = Vector( 115, 20, 0 ),
	L_HeadLampAng = Angle(10,5,0),
	R_HeadLampPos = Vector( 115, -20, 0 ),
	R_HeadLampAng = Angle(10,-5,0),
	
	-- projected texture - rear
	L_RearLampPos = Vector(-115,20,5),
	L_RearLampAng = Angle(25,180,0),
	R_RearLampPos = Vector(-115,-20,5),
	R_RearLampAng = Angle(25,180,0),
	
	Headlight_sprites = {   -- lowbeam
		Vector(102,27.5,-1),Vector(102,-27.5,-1),Vector(102,21,-1),Vector(102,-21,-1),
	},
	--[[ --alternative and more detailed definition: (works for all except marker lights)
	Headlight_sprites = {   -- lowbeam
		{
			pos = Vector(102,27.5,-1),
			OnBodyGroups = { [3] = {1,2} } },   -- if bodygroup number 3 is set to 1 or 2 the sprite will be drawn
			material = "sprites/light_ignorez",
			size = 60,
			color = Color(0,0,250,255),
		}
	},
	]]--
	Headlamp_sprites = {   -- highbeam
		{pos = Vector(102,27.5,-1),size = 40},
		{pos = Vector(102,-27.5,-1),size = 40},
		{pos = Vector(102,21,-1),size = 40},
		{pos = Vector(102,-21,-1),size = 40},
	},
	Rearlight_sprites = {	--taillights
		Vector(-120,28,5),Vector(-120,27,5),Vector(-120,26,5),Vector(-120,25,5),Vector(-120,24,5),Vector(-120,23,5),Vector(-120,22,5),
		
		Vector(-120,-28,5),Vector(-120,-27,5),Vector(-120,-26,5),Vector(-120,-25,5),Vector(-120,-24,5),Vector(-120,-23,5),Vector(-120,-22,5)
	},
	Brakelight_sprites = {
		Vector(-120,17,5),Vector(-120,16,5),Vector(-120,15,5),Vector(-120,14,5),Vector(-120,13,5),Vector(-120,12,5),Vector(-120,11,5),Vector(-120,10,5),
		Vector(-120,-17,5),Vector(-120,-16,5),Vector(-120,-15,5),Vector(-120,-14,5),Vector(-120,-13,5),Vector(-120,-12,5),Vector(-120,-11,5),Vector(-120,-10,5)
	},
	Reverselight_sprites = {
		Vector(-120,18.5,5),Vector(-120,20.5,5),
		Vector(-120,-18.5,5),Vector(-120,-20.5,5)
	},
	
	DelayOn = 0.5,
	DelayOff = 0.25,
	BodyGroups = {
		On = {8,0},
		Off = {8,1}
	}
	--[[
	PoseParameters = {
		name = "headlight",
		min = 0,
		max = 1
	},
	
	Animation = {
		On = "lightcoveropenreal",
		Off = "lightcoverclosereal"
	},
	
	FogLight_sprites = {
		Vector(-29.06,109.39,15.74),Vector(-27.06,109.39,15.74),Vector(-31.06,109.39,15.74),
		Vector(29.06,109.39,15.74),Vector(27.06,109.39,15.74),Vector(31.06,109.39,15.74)
	},
	
	ems_sounds = {"simulated_vehicles/police/siren_1.wav","simulated_vehicles/police/siren_2.wav","simulated_vehicles/police/siren_3.wav"},
	ems_sprites = {
		{
			pos = Vector(15.89,20.46,55.79),
			material = "sprites/light_ignorez",
			size = 60,
			Colors = {Color(0,0,250,250),Color(0,0,255,255),Color(0,0,250,250),Color(0,0,200,200),Color(0,0,150,150),Color(0,0,100,100),Color(0,0,50,50),Color(0,0,0,0)}, -- the script will go from color to color
			Speed = 0.05, -- for how long each color will be drawn
		}
	}
	]]--
}
list.Set( "simfphys_lights", "dukes", light_table)


local light_table = {
	L_HeadLampPos = Vector( 28.5, 122, 31.5 ),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector( -28.5, 120, 31.5 ),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(23,-120,36),
	L_RearLampAng = Angle(25,-90,0),
	R_RearLampPos = Vector(-23,-120,36),
	R_RearLampAng = Angle(25,-90,0),

	Headlight_sprites = { 
		{pos = Vector(-33,121.5,31.5),material = "sprites/light_ignorez",size = 60},
		{pos = Vector(-33,121.5,31.5),size = 70},
		
		{pos = Vector(33,121.5,31.5),material = "sprites/light_ignorez",size = 60},
		{pos = Vector(33,121.5,31.5),size = 70}
	},
	Headlamp_sprites = { 
		{pos = Vector(-24,121.5,31.5),material = "sprites/light_ignorez",size = 60},
		{pos = Vector(-24,121.5,31.5),size = 70},
		
		{pos = Vector(24,121.5,31.5),material = "sprites/light_ignorez",size = 60},
		{pos = Vector(24,121.5,31.5),size = 70}
	},
	Rearlight_sprites = {
		Vector(33.5,-120,36),Vector(31.9,-120,36),Vector(30.3,-120,36),Vector(28.7,-120,36),Vector(27.1,-120,36),Vector(25.5,-120,36),Vector(23.9,-120,36),Vector(22.3,-120,36),Vector(20.7,-120,36),Vector(19.1,-120,36),Vector(17.5,-120,36),Vector(15.9,-120,36),Vector(14.3,-120,36),Vector(12.7,-120,36),Vector(11.1,-120,36),Vector(9.5,-120,36),Vector(7.9,-120,36),
		Vector(-33.5,-120,36),Vector(-31.9,-120,36),Vector(-30.3,-120,36),Vector(-28.7,-120,36),Vector(-27.1,-120,36),Vector(-25.5,-120,36),Vector(-23.9,-120,36),Vector(-22.3,-120,36),Vector(-20.7,-120,36),Vector(-19.1,-120,36),Vector(-17.5,-120,36),Vector(-15.9,-120,36),Vector(-14.3,-120,36),Vector(-12.7,-120,36),Vector(-11.1,-120,36),Vector(-9.5,-120,36),Vector(-7.9,-120,36)
	},
	Brakelight_sprites = {
		Vector(33.5,-120,36),Vector(31.9,-120,36),Vector(30.3,-120,36),Vector(28.7,-120,36),Vector(27.1,-120,36),Vector(25.5,-120,36),Vector(23.9,-120,36),Vector(22.3,-120,36),Vector(20.7,-120,36),Vector(19.1,-120,36),Vector(17.5,-120,36),Vector(15.9,-120,36),Vector(14.3,-120,36),Vector(12.7,-120,36),Vector(11.1,-120,36),Vector(9.5,-120,36),Vector(7.9,-120,36),
		Vector(-33.5,-120,36),Vector(-31.9,-120,36),Vector(-30.3,-120,36),Vector(-28.7,-120,36),Vector(-27.1,-120,36),Vector(-25.5,-120,36),Vector(-23.9,-120,36),Vector(-22.3,-120,36),Vector(-20.7,-120,36),Vector(-19.1,-120,36),Vector(-17.5,-120,36),Vector(-15.9,-120,36),Vector(-14.3,-120,36),Vector(-12.7,-120,36),Vector(-11.1,-120,36),Vector(-9.5,-120,36),Vector(-7.9,-120,36)
	},
	Reverselight_sprites = {
		Vector(-17.6,-121.1,23.1),
		Vector(17.6,-121.1,23.1)
	},
	FrontMarker_sprites = {
		Vector(-30,120.5,18),
		Vector(30,120.5,18),
		Vector(-42.5,110.3,24.4),
		Vector(42.5,110.3,24.4)
	},
	RearMarker_sprites = {
		Vector(-41.5,-113,28),
		Vector(41.5,-113,28)
	},
	
	DelayOn = 2.1,
	DelayOff = 2.1,
	Animation = {
		On = "lightcoveropenreal",
		Off = "lightcoverclosereal"
	}
}
list.Set( "simfphys_lights", "charger", light_table)


local light_table = {
	ModernLights = true,
	
	L_HeadLampPos = Vector(87.8,24.1,22.7),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(87.8,-24.1,22.7),
	R_HeadLampAng = Angle(15,0,0),
	
	L_RearLampPos = Vector(-88,24.5,31.2),
	L_RearLampAng = Angle(25,180,0),
	R_RearLampPos = Vector(-88,-24.5,31.2),
	R_RearLampAng = Angle(25,180,0),
	
	Headlight_sprites = { 
		Vector(84.2,29.4,22.3),
		Vector(84.2,-29.4,22.3),
		Vector(87.8,24.1,22.3),
		Vector(87.8,-24.1,22.3)
	},
	Headlamp_sprites = { 
		Vector(90,19,21.9),Vector(90,-19,21.9)
	},
	Rearlight_sprites = {
		Vector(-88,22.2,31.2),Vector(-86.2,26.9,30.9),
		Vector(-88,-22.2,31.2),Vector(-86.2,-26.9,30.9)
	},
	Brakelight_sprites = {
		Vector(-88,22.2,31.2),Vector(-86.2,26.9,30.9),
		Vector(-88,-22.2,31.2),Vector(-86.2,-26.9,30.9),
		
		Vector(-70,5.9,49.8),Vector(-70,4.425,49.85),Vector(-70,2.95,49.9),Vector(-70,1.475,49.95),Vector(-70,0,50),Vector(-70,-5.9,49.8),Vector(-70,-4.425,49.85),Vector(-70,-2.95,49.9),Vector(-70,-1.475,49.95),
	},
	Reverselight_sprites = {
		Vector(-90,16.6,30.9),
		Vector(-90,-16.6,30.9)
	},
	FogLight_sprites = {
		{pos = Vector(87.79,26.65,9.62),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(87.79,26.65,9.62),size = 24},
		
		{pos = Vector(87.79,-26.65,9.62),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(87.79,-26.65,9.62),size = 24},
	}
}
list.Set( "simfphys_lights", "alfons", light_table)


local light_table = {
	L_HeadLampPos = Vector(-42,148,21.1),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(42,148,21.1),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(45.6,-147,27.2),
	L_RearLampAng = Angle(40,-90,0),
	R_RearLampPos = Vector(-45.6,-147,27.2),
	R_RearLampAng = Angle(40,-90,0),
	
	Headlight_sprites = { 
		Vector(-46.3,145.6,21.1),
		Vector(46.3,145.6,21.1)
	},
	Headlamp_sprites = { 
		Vector(-37.6,145.7,21),
		Vector(37.6,145.7,21)
	},
	Rearlight_sprites = {
		Vector(45.6,-146.2,27.2),
		Vector(-45.6,-146.2,27.2)
	},
	Brakelight_sprites = {
		Vector(45.6,-146.2,27.2),
		Vector(-45.6,-146.2,27.2)
	}
}
list.Set( "simfphys_lights", "conapc", light_table)


local light_table = {
	L_HeadLampPos = Vector(118.8,30.5,41.8),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(118.8,-35,41.8),
	R_HeadLampAng = Angle(15,0,0),
	
	Headlight_sprites = { 
		Vector(118.8,30.5,41.8),
		Vector(118.8,-35,41.8)
	},
	Headlamp_sprites = {
		Vector(118.8,30.5,41.8),
		Vector(118.8,-35,41.8)
	},
}
list.Set( "simfphys_lights", "avia", light_table)

local light_table = {
	L_HeadLampPos = Vector(32.7,79.5,29.0),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(-30.75,79.5,28.9),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(15.9,-139.2,53),
	L_RearLampAng = Angle(40,-90,0),
	R_RearLampPos = Vector(-17.44,-139.2,53),
	R_RearLampAng = Angle(40,-90,0),
	
	Headlight_sprites = { 
		Vector(-34.5,77.5,29),
		Vector(36.4,77.5,29.5),
		Vector(-27.1,77.5,29),
		Vector(29,77.5,29.5)
	},
	Headlamp_sprites = { 
		{pos =Vector(-34.5,77.5,29),size = 60},
		{pos =Vector(36.4,77.5,29.5),size = 60},
		{pos =Vector(-27.1,77.5,29),size = 60},
		{pos =Vector(29,77.5,29.5),size = 60},
	},
	Rearlight_sprites = {
		Vector(25.8,-139.2,53),Vector(24.28,-139.2,53),Vector(22.76,-139.2,53),Vector(21.24,-139.2,53),Vector(19.72,-139.2,53),Vector(18.2,-139.2,53),Vector(16.68,-139.2,53),Vector(15.16,-139.2,53),Vector(13.64,-139.2,53),Vector(12.12,-139.2,53),Vector(10.6,-139.2,53),Vector(9.08,-139.2,53),Vector(7.56,-139.2,53),Vector(6.04,-139.2,53),
		Vector(-27.32,-139.2,53),Vector(-25.8,-139.2,53),Vector(-24.28,-139.2,53),Vector(-22.76,-139.2,53),Vector(-21.24,-139.2,53),Vector(-19.72,-139.2,53),Vector(-18.2,-139.2,53),Vector(-16.68,-139.2,53),Vector(-15.16,-139.2,53),Vector(-13.64,-139.2,53),Vector(-12.12,-139.2,53),Vector(-10.6,-139.2,53),Vector(-9.08,-139.2,53),Vector(-7.56,-139.2,53)
	},
	Brakelight_sprites = {
		Vector(25.8,-139.2,53),Vector(24.28,-139.2,53),Vector(22.76,-139.2,53),Vector(21.24,-139.2,53),Vector(19.72,-139.2,53),Vector(18.2,-139.2,53),Vector(16.68,-139.2,53),Vector(15.16,-139.2,53),Vector(13.64,-139.2,53),Vector(12.12,-139.2,53),Vector(10.6,-139.2,53),Vector(9.08,-139.2,53),Vector(7.56,-139.2,53),Vector(6.04,-139.2,53),
		Vector(-27.32,-139.2,53),Vector(-25.8,-139.2,53),Vector(-24.28,-139.2,53),Vector(-22.76,-139.2,53),Vector(-21.24,-139.2,53),Vector(-19.72,-139.2,53),Vector(-18.2,-139.2,53),Vector(-16.68,-139.2,53),Vector(-15.16,-139.2,53),Vector(-13.64,-139.2,53),Vector(-12.12,-139.2,53),Vector(-10.6,-139.2,53),Vector(-9.08,-139.2,53),Vector(-7.56,-139.2,53)
	},
}
list.Set( "simfphys_lights", "jalopy", light_table)


local light_table = {
	L_HeadLampPos = Vector(-11,55,35),
	L_HeadLampAng = Angle(20,90,0),
	R_HeadLampPos = Vector(11,55,35),
	R_HeadLampAng = Angle(20,90,0),
	
	L_RearLampPos = Vector(-14.9,-99.9,39.13),
	L_RearLampAng = Angle(40,-90,0),
	
	Headlight_sprites = { 
		Vector(-11,57,38.8),
		Vector(11,57,38.8)
	},
	Headlamp_sprites = { 
		Vector(-11,57,38.8),
		Vector(11,57,38.8)
	},
	Rearlight_sprites = {
		Vector(-14.9,-101,39.13)
	},
	Brakelight_sprites = {
		Vector(-14.9,-101,39.1)
	},
}
list.Set( "simfphys_lights", "jeep", light_table)


local light_table = {
	L_HeadLampPos = Vector(0,66.3,21.84),
	L_HeadLampAng = Angle(20,90,0),
	
	R_HeadLampPos = Vector(0,-58.01,70.71),
	R_HeadLampAng = Angle(0,90,0),

	L_RearLampPos = Vector(-14.9,-99.9,39.13),
	L_RearLampAng = Angle(40,-90,0),
	
	Headlight_sprites = { 
		Vector(-12.25,67.23,22.33),
		Vector(-3.91,67.03,22.14),
		Vector(4.63,66.33,21.96),
		Vector(13.4,66.72,22.16)
	},
	Headlamp_sprites = { 
		Vector(14.3,-59.87,70.12),
		Vector(7.34,-58.62,70.32),
		Vector(-7.79,-58.55,70.09),
		Vector(-14.97,-60.01,69.99)
	},
	Rearlight_sprites = {
		Vector(-14.9,-99.9,39.13)
	},
	Brakelight_sprites = {
		Vector(-14.9,-99.9,39.1)
	},
}
list.Set( "simfphys_lights", "elitejeep", light_table)


local light_table = {
	L_HeadLampPos = Vector(-26,106,30.3),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(26,106,30.3),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(-28.5,-109.63,49.5),
	L_RearLampAng = Angle(40,-90,0),
	R_RearLampPos = Vector(28.5,-109.63,49.5),
	R_RearLampAng = Angle(40,-90,0),
	
	Headlight_sprites = { 
		{pos = Vector(35,103.2,33.1),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(33.75,103.4,33.05),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(32.5,103.6,33),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(31.25,103.8,32.95),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(30,104,32.9),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(28.75,104.2,32.85),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(27.5,104.4,32.8),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(26.25,104.6,32.75),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(25,104.8,32.7),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(23.75,105,32.75),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(22.5,105.2,32.6),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(21.25,105.4,32.55),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(20,105.6,32.5),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(18.75,105.8,32.45),material = "sprites/light_ignorez",size = 12},
		
		{pos = Vector(35,103.2,30.8),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(33.75,103.4,30.75),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(32.5,103.6,30.7),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(31.25,103.8,30.65),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(30,104,30.6),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(28.75,104.2,30.55),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(27.5,104.4,30.5),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(26.25,104.6,30.45),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(25,104.8,30.4),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(23.75,105,30.45),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(22.5,105.2,30.3),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(21.25,105.4,30.25),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(20,105.6,30.2),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(18.75,105.8,30.15),material = "sprites/light_ignorez",size = 12},
		
		{pos = Vector(35,103.2,28.5),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(33.75,103.4,28.45),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(32.5,103.6,28.4),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(31.25,103.8,28.35),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(30,104,28.3),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(28.75,104.2,28.25),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(27.5,104.4,28.2),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(26.25,104.6,28.15),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(25,104.8,28.1),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(23.75,105,28.15),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(22.5,105.2,28),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(21.25,105.4,27.95),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(20,105.6,27.9),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(18.75,105.8,27.85),material = "sprites/light_ignorez",size = 12},
		
		{pos = Vector(-35,103.2,33.1),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-33.75,103.4,33.05),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-32.5,103.6,33),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-31.25,103.8,32.95),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-30,104,32.9),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-28.75,104.2,32.85),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-27.5,104.4,32.8),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-26.25,104.6,32.75),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-25,104.8,32.7),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-23.75,105,32.75),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-22.5,105.2,32.6),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-21.25,105.4,32.55),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-20,105.6,32.5),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-18.75,105.8,32.45),material = "sprites/light_ignorez",size = 12},
		
		{pos = Vector(-35,103.2,30.8),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-33.75,103.4,30.75),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-32.5,103.6,30.7),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-31.25,103.8,30.65),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-30,104,30.6),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-28.75,104.2,30.55),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-27.5,104.4,30.5),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-26.25,104.6,30.45),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-25,104.8,30.4),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-23.75,105,30.45),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-22.5,105.2,30.3),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-21.25,105.4,30.25),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-20,105.6,30.2),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-18.75,105.8,30.15),material = "sprites/light_ignorez",size = 12},
		
		{pos = Vector(-35,103.2,28.5),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-33.75,103.4,28.45),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-32.5,103.6,28.4),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-31.25,103.8,28.35),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-30,104,28.3),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-28.75,104.2,28.25),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-27.5,104.4,28.2),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-26.25,104.6,28.15),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-25,104.8,28.1),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-23.75,105,28.15),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-22.5,105.2,28),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-21.25,105.4,27.95),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-20,105.6,27.9),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-18.75,105.8,27.85),material = "sprites/light_ignorez",size = 12},
		
		{pos = Vector(-23.5,106,30.23),size = 30},
		{pos = Vector(-28.5,106,30.36),size = 30},
		{pos = Vector(23.5,106,30.23),size = 30},
		{pos = Vector(28.5,106,30.36),size = 30}
	},
	
	Headlamp_sprites = { 
		{pos = Vector(-23.5,106,30.23),size = 80},
		{pos = Vector(-28.5,106,30.36),size = 80},
		{pos = Vector(23.5,106,30.23),size = 80},
		{pos = Vector(28.5,106,30.36),size = 80}
	},
	
	Rearlight_sprites = {
		Vector(-34,-109.63,40.75),Vector(-35.4,-109.63,40.75),Vector(-36.8,-109.63,40.75),Vector(-36.8,-109.63,38),Vector(-35.4,-109.63,38),Vector(-34,-109.63,38),
		Vector(-23,-109.63,40.75),Vector(-24.4,-109.63,40.75),Vector(-25.8,-109.63,40.75),Vector(-25.8,-109.63,38),Vector(-24.4,-109.63,38),Vector(-23,-109.63,38),
		
		Vector(34,-109.63,40.75),Vector(35.4,-109.63,40.75),Vector(36.8,-109.63,40.75),Vector(36.8,-109.63,38),Vector(35.4,-109.63,38),Vector(34,-109.63,38),
		Vector(23,-109.63,40.75),Vector(24.4,-109.63,40.75),Vector(25.8,-109.63,40.75),Vector(25.8,-109.63,38),Vector(24.4,-109.63,38),Vector(23,-109.63,38),
	},
	Brakelight_sprites = {
		Vector(-34,-109.63,40.75),Vector(-35.4,-109.63,40.75),Vector(-36.8,-109.63,40.75),Vector(-36.8,-109.63,38),Vector(-35.4,-109.63,38),Vector(-34,-109.63,38),
		Vector(-23,-109.63,40.75),Vector(-24.4,-109.63,40.75),Vector(-25.8,-109.63,40.75),Vector(-25.8,-109.63,38),Vector(-24.4,-109.63,38),Vector(-23,-109.63,38),
		
		Vector(34,-109.63,40.75),Vector(35.4,-109.63,40.75),Vector(36.8,-109.63,40.75),Vector(36.8,-109.63,38),Vector(35.4,-109.63,38),Vector(34,-109.63,38),
		Vector(23,-109.63,40.75),Vector(24.4,-109.63,40.75),Vector(25.8,-109.63,40.75),Vector(25.8,-109.63,38),Vector(24.4,-109.63,38),Vector(23,-109.63,38),
	},
	RearMarker_sprites = {
		Vector(-42.87,-101.7,35.71),
		Vector(42.87,-101.7,35.71)
	},
	FogLight_sprites = {
		{pos = Vector(-26.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-27.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-28.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-29.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-30.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-31.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(-32.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		
		{pos = Vector(26.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(27.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(28.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(29.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(30.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(31.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
		{pos = Vector(32.06,109.39,15.74),material = "sprites/light_ignorez",size = 12},
	},
	
	ems_sounds = {"simulated_vehicles/police/siren_madmax.wav","common/null.wav"},
	--ems_sounds = {"simulated_vehicles/police/siren_1.wav","simulated_vehicles/police/siren_2.wav","simulated_vehicles/police/siren_3.wav"},
	ems_sprites = {
		{
			pos = Vector(15.89,20.46,55.79),
			material = "sprites/light_glow02_add_noz",
			size = 60,
			Colors = {Color(0,0,250,250),Color(0,0,255,255),Color(0,0,250,250),Color(0,0,200,200),Color(0,0,150,150),Color(0,0,100,100),Color(0,0,50,50),Color(0,0,0,0)}, -- the script will go from color to color
			Speed = 0.05, -- for how long each color will be drawn
		}
	}
}
list.Set( "simfphys_lights", "madmax", light_table)



local light_table = {
	L_HeadLampPos = Vector(-36.87,87.86,47.32),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(36.33,87.27,46.67),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(43.03,-194,25),
	L_RearLampAng = Angle(60,-90,0),
	R_RearLampPos = Vector(-43.03,-194,25),
	R_RearLampAng = Angle(60,-90,0),
	
	Headlight_sprites = { 
		{pos = Vector(-36.87,87.86,47.32),material = "sprites/light_ignorez",size = 64},
		{pos = Vector(-36.87,87.86,47.32),size = 75},
		
		{pos = Vector(36.33,87.27,46.67),material = "sprites/light_ignorez",size = 64},
		{pos = Vector(36.33,87.27,46.67),size = 75}
	},
	Headlamp_sprites = { 
		{pos = Vector(-36.87,87.86,47.32),size = 110},
		{pos = Vector(36.33,87.27,46.67),size = 110}
	},
	Rearlight_sprites = {
		Vector(43.04,-194,21.05),
		Vector(43.03,-194,22.49),
		Vector(43.23,-194,23.34),
		Vector(43.14,-194,24.32),
		
		Vector(-43.04,-194,21.05),
		Vector(-43.03,-194,22.49),
		Vector(-43.23,-194,23.34),
		Vector(-43.14,-194,24.32)
	},
	Brakelight_sprites = {
		Vector(43.04,-194,21.05),
		Vector(43.03,-194,22.49),
		Vector(43.23,-194,23.34),
		Vector(43.14,-194,24.32),
		
		Vector(-43.04,-194,21.05),
		Vector(-43.03,-194,22.49),
		Vector(-43.23,-194,23.34),
		Vector(-43.14,-194,24.32)
	},
	FrontMarker_sprites = {
		Vector(55.4,-156.48,56.9),
		Vector(56.74,-70.56,55.19),
		Vector(50,73.98,57.71),
		Vector(-53.4,-156.48,56.9),
		Vector(-54,-70.56,55.19),
		Vector(-50,73.98,57.71)
	},
}
list.Set( "simfphys_lights", "gaz", light_table)


local light_table = {
	L_HeadLampPos = Vector(71.15,23.26,27.92),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(71.07,-23.15,27.95),
	R_HeadLampAng = Angle(15,0,0),

	L_RearLampPos = Vector(-72,26.5,29),
	L_RearLampAng = Angle(30,185,0),
	R_RearLampPos = Vector(-72,-26.5,29),
	R_RearLampAng = Angle(30,175,0),
	
	Headlight_sprites = { 
		Vector(71.15,23.26,27.92),
		Vector(71.07,-23.15,27.95)
	},
	Headlamp_sprites = { 
		Vector(71.15,23.26,27.92),
		Vector(71.07,-23.15,27.95)
	},
	Rearlight_sprites = {
		Vector(-72,22,29),Vector(-72,23.5,29),Vector(-72,25,29),Vector(-72,26.5,29),Vector(-72,28,29),Vector(-72,29.5,29),Vector(-72,31,29),
		Vector(-72,-22,29),Vector(-72,-23.5,29),Vector(-72,-25,29),Vector(-72,-26.5,29),Vector(-72,-28,29),Vector(-72,-29.5,29),Vector(-72,-31,29),
	},
	Brakelight_sprites = {
		Vector(-72,22,29),Vector(-72,23.5,29),Vector(-72,25,29),Vector(-72,26.5,29),Vector(-72,28,29),Vector(-72,29.5,29),Vector(-72,31,29),
		Vector(-72,-22,29),Vector(-72,-23.5,29),Vector(-72,-25,29),Vector(-72,-26.5,29),Vector(-72,-28,29),Vector(-72,-29.5,29),Vector(-72,-31,29),
	},
}
list.Set( "simfphys_lights", "golf", light_table)

local light_table = {
	L_HeadLampPos = Vector(-36.74,121.35,45.43),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(32.15,118.88,45.13),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(-47,-133.97,28.14),
	L_RearLampAng = Angle(30,-90,0),
	R_RearLampPos = Vector(44.13,-134.42,27.34),
	R_RearLampAng = Angle(30,-90,0),
	
	Headlight_sprites = { 
		{pos = Vector(-36.74,121.35,45.43),material = "sprites/light_ignorez",size = 40},
		{pos = Vector(-36.74,121.35,45.43),size = 55},
		
		{pos = Vector(32.15,118.88,45.13),material = "sprites/light_ignorez",size = 40},
		{pos = Vector(32.15,118.88,45.13),size = 55},
	},
	Headlamp_sprites = { 
		{pos = Vector(-36.74,121.35,45.43),size = 80},
		{pos = Vector(32.15,118.88,45.13),size = 80},
	},
	Rearlight_sprites = {
		Vector(-47,-133.97,28.14),
		Vector(44.13,-134.42,27.34),
	},
	Brakelight_sprites = {
		Vector(-47,-133.97,28.14),
		Vector(44.13,-134.42,27.34),
	},
	Reverselight_sprites = {
		Vector(32.33,-134.11,27.34),
	}
}
list.Set( "simfphys_lights", "liaz", light_table)

local light_table = {
	L_HeadLampPos = Vector(75.7,28.09,31.28),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(75.7,-28.09,31.28),
	R_HeadLampAng = Angle(15,0,0),
	
	L_RearLampPos = Vector(-99.86,23.01,29.9),
	L_RearLampAng = Angle(45,180,0),
	R_RearLampPos = Vector(-99.86,-23.01,29.9),
	R_RearLampAng = Angle(45,180,0),
	
	Headlight_sprites = { 
		{pos = Vector(75.7,25.72,32.61),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,30.71,32.97),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,30.59,29.65),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,25.71,29.56),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,28.09,31.28),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,28.09,31.28),size = 45},
		
		{pos = Vector(75.7,-25.72,32.61),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,-30.71,32.97),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,-30.59,29.65),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,-25.71,29.56),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,-28.09,31.28),material = "sprites/light_ignorez",size = 32},
		{pos = Vector(75.7,-28.09,31.28),size = 45},
	},
	Headlamp_sprites = { 
		{pos = Vector(75.7,28.09,31.28),size = 80},
		{pos = Vector(75.7,-28.09,31.28),size = 80},
	},
	Rearlight_sprites = {
		Vector(-99.8,21.57,29.93),Vector(-99.86,23.01,29.9),Vector(-99.75,24.52,29.92),
		Vector(-99.8,-21.57,29.93),Vector(-99.86,-23.01,29.9),Vector(-99.75,-24.52,29.92),
	},
	Brakelight_sprites = {
		Vector(-99.8,21.57,29.93),Vector(-99.86,23.01,29.9),Vector(-99.75,24.52,29.92),
		Vector(-99.8,-21.57,29.93),Vector(-99.86,-23.01,29.9),Vector(-99.75,-24.52,29.92),
	},
	Reverselight_sprites = {
		Vector(-99.98,27.41,30.76),
		Vector(-99.98,-27.41,30.76)
	}
}
list.Set( "simfphys_lights", "moskvich", light_table)

local light_table = {
	L_HeadLampPos = Vector(-28.77,70.69,30.73),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(29.13,70.77,30.58),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(30.83,-78.44,25),
	L_RearLampAng = Angle(45,-95,0),
	R_RearLampPos = Vector(-30.83,-78.50,25),
	R_RearLampAng = Angle(45,-85,0),
	
	Headlight_sprites = { 
		Vector(-28.77,70.69,30.73),
		Vector(29.13,70.77,30.58)
	},
	Headlamp_sprites = { 
		Vector(-28.77,70.69,30.73),
		Vector(29.13,70.77,30.58)
	},
	Rearlight_sprites = {
		Vector(30.83,-78.44,24.),Vector(30.83,-78.44,25),Vector(30.83,-78.44,26),
		Vector(-30.83,-78.50,24),Vector(-30.83,-78.50,25),Vector(-30.83,-78.50,26)
	},
	Brakelight_sprites = {
		Vector(30.83,-78.44,24.),Vector(30.83,-78.44,25),Vector(30.83,-78.44,26),
		Vector(-30.83,-78.50,24),Vector(-30.83,-78.50,25),Vector(-30.83,-78.50,26)
	},
	Reverselight_sprites = {
		Vector(30.77,-76.39,20.09),
		Vector(-31.01,-76.14,20.29),
	},
}
list.Set( "simfphys_lights", "trabbi", light_table)

local light_table = {
	L_HeadLampPos = Vector(97.45,36.17,37.08),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(97.23,-36.19,37.03),
	R_HeadLampAng = Angle(15,0,0),
	
	L_RearLampPos = Vector(-117,-32.5,41),
	L_RearLampAng = Angle(45,180,0),
	R_RearLampPos = Vector(-117,32.5,41),
	R_RearLampAng = Angle(45,180,0),
	
	Headlight_sprites = { 
		Vector(97.41,33.55,37.05),Vector(97.45,36.17,37.08),Vector(97.61,38.86,37.14),
		Vector(97.25,-33.56,37.04),Vector(97.23,-36.19,37.03),Vector(97.13,-38.64,37.08)
	},
	Headlamp_sprites = { 
		Vector(97.45,36.17,37.08),
		Vector(97.23,-36.19,37.03)
	},
	Rearlight_sprites = {
		{pos = Vector(-117,-32.5,41),material = "sprites/light_ignorez",size = 35,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-117,-32.5,41),size = 45,color = Color( 255, 0, 0,  250)},
		
		{pos = Vector(-117,32.5,41),material = "sprites/light_ignorez",size = 35,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-117,32.5,41),size = 45,color = Color( 255, 0, 0,  250)},
	},
	Brakelight_sprites = {
		{pos = Vector(-117,-32.5,41),material = "sprites/light_ignorez",size = 50},
		{pos = Vector(-117,-32.5,41),size = 55},
		
		{pos = Vector(-117,32.5,41),material = "sprites/light_ignorez",size = 50},
		{pos = Vector(-117,32.5,41),size = 55},
	},
	Reverselight_sprites = {
		Vector(-117,-32.5,45),Vector(-117,-34.5,45),Vector(-117,-30.5,45),
		Vector(-117,32.5,45),Vector(-117,34.5,45),Vector(-117,30.5,45)
	},
}
list.Set( "simfphys_lights", "van", light_table)

local light_table = {
	L_HeadLampPos = Vector(91.33,30.44,30.63),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(91.33,-30.44,30.63),
	R_HeadLampAng = Angle(15,0,0),

	L_RearLampPos = Vector( -102.69,29.97,34.21),
	L_RearLampAng = Angle(45,180,0),
	R_RearLampPos = Vector( -102.69,-29.97,34.21),
	R_RearLampAng = Angle(45,180,0),
	
	Headlight_sprites = { 
		Vector(91.33,30.44,30.63),
		Vector(91.33,-30.44,30.63)
	},
	Headlamp_sprites = { 
		Vector(91.33,30.44,30.63),
		Vector(91.33,-30.44,30.63)
	},
	Rearlight_sprites = {
		{pos = Vector(-102.2,-30,34),material = "sprites/light_ignorez",size = 35,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-102.2,-30,34),size = 45,color = Color( 255, 0, 0,  90)},
		
		{pos = Vector(-102.2,30,34),material = "sprites/light_ignorez",size = 35,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-102.2,30,34),size = 45,color = Color( 255, 0, 0,  90)},
	},
	Brakelight_sprites = {
		{pos = Vector(-102.2,-30,34),material = "sprites/light_ignorez",size = 45,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-102.2,-30,34),size = 50,color = Color( 255, 0, 0,  150)},
		
		{pos = Vector(-102.2,30,34),material = "sprites/light_ignorez",size = 45,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-102.2,30,34),size = 50,color = Color( 255, 0, 0,  150)},
	},
	Reverselight_sprites = {
		Vector(-101.8,-29.4,30.7),Vector(-101.8,-31.09,30.7),
		Vector(-101.8,29.4,30.7),Vector(-101.8,31.09,30.7),
	}
}
list.Set( "simfphys_lights", "volga", light_table)

local light_table = {
	L_HeadLampPos = Vector(87.3,29.59,35.42),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(87.34,-31.76,35.52),
	R_HeadLampAng = Angle(15,0,0),
	
	L_RearLampPos = Vector(-95.5,22.25,32),
	L_RearLampAng = Angle(45,180,0),
	R_RearLampPos = Vector(-95.5,-24.75,32),
	R_RearLampAng = Angle(45,180,0),
	
	Headlight_sprites = { 
		Vector(87.3,29.59,35.42),
		Vector(87.34,-31.76,35.52)
	},
	Headlamp_sprites = { 
		Vector(87.3,29.59,35.42),
		Vector(87.34,-31.76,35.52)
	},
	
	Rearlight_sprites = {
		Vector(-95.5,21,34),Vector(-95.5,21,33),Vector(-95.5,21,32),Vector(-95.5,22.25,34),Vector(-95.5,22.25,32),Vector(-95.5,23.5,34),Vector(-95.5,23.5,33),Vector(-95.5,23.5,32),
		Vector(-95.5,-23.5,34),Vector(-95.5,-23.5,33),Vector(-95.5,-23.5,32),Vector(-95.5,-24.75,34),Vector(-95.5,-24.75,32),Vector(-95.5,-26,34),Vector(-95.5,-26,33),Vector(-95.5,-26,32)
	},
	Brakelight_sprites = {
		Vector(-95.5,15.5,34.8),Vector(-95.5,15.5,33.4),Vector(-95.5,15.5,32.6),Vector(-95.5,15.5,31.2),
		Vector(-95.5,-18,34.8),Vector(-95.5,-18,33.4),Vector(-95.5,-18,32.6),Vector(-95.5,-18,31.2)
	},
	Reverselight_sprites = {
		Vector(-95.5,18.25,34.8),Vector(-95.5,18.25,33.4),Vector(-95.5,18.25,32.6),Vector(-95.5,18.25,31.2),
		Vector(-95.5,-20.75,34.8),Vector(-95.5,-20.75,33.4),Vector(-95.5,-20.75,32.6),Vector(-95.5,-20.75,31.2)
	},
}
list.Set( "simfphys_lights", "zaz", light_table)

