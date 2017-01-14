ENT.Type            = "anim"

ENT.PrintName = "Comedy Effect"
ENT.Author = "Blu"
ENT.Information = ""
ENT.Category = "Fun + Games"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Editable = (GetConVar("sv_simfphys_devmode"):GetInt() or 1) >= 1
ENT.IsSimfphyscar = true

function ENT:SetupDataTables()
	self:NetworkVar( "Float",1, "SteerSpeed",				{ KeyName = "steerspeed",			Edit = { type = "Float",		order = 1,min = 1, max = 16,		category = "Steering"} } )
	self:NetworkVar( "Float",2, "FastSteerConeFadeSpeed",	{ KeyName = "faststeerconefadespeed",	Edit = { type = "Float",		order = 2,min = 1, max = 5000,		category = "Steering"} } )
	self:NetworkVar( "Float",3, "FastSteerAngle",			{ KeyName = "faststeerangle",			Edit = { type = "Float",		order = 3,min = 0, max = 1,		category = "Steering"} } )
	
	self:NetworkVar( "Float",4, "FrontSuspensionHeight",		{ KeyName = "frontsuspensionheight",	Edit = { type = "Float",		order = 4,min = -1, max = 1,		category = "Suspension" } } )
	self:NetworkVar( "Float",5, "RearSuspensionHeight",		{ KeyName = "rearsuspensionheight",		Edit = { type = "Float",		order = 5,min = -1, max = 1,		category = "Suspension" } } )
	
	self:NetworkVar( "Int",0, "EngineSoundPreset",			{ KeyName = "enginesoundpreset",		Edit = { type = "Int",			order = 6,min = -1, max = 14,		category = "Engine"} } )
	self:NetworkVar( "Int",1, "IdleRPM", 					{ KeyName = "idlerpm",				Edit = { type = "Int",			order = 7,min = 1, max = 25000,	category = "Engine"} } )
	self:NetworkVar( "Int",2, "LimitRPM", 					{ KeyName = "limitrpm",				Edit = { type = "Int",			order = 8,min = 4, max = 25000,	category = "Engine"} } )
	self:NetworkVar( "Int",3, "PowerBandStart", 			{ KeyName = "powerbandstart",			Edit = { type = "Int",			order = 9,min = 2, max = 25000,	category = "Engine"} } )
	self:NetworkVar( "Int",4, "PowerBandEnd", 				{ KeyName = "powerbandend",			Edit = { type = "Int",			order = 10,min = 3, max = 25000,	category = "Engine"} } )
	self:NetworkVar( "Float",6, "MaxTorque",				{ KeyName = "maxtorque",			Edit = { type = "Float",		order = 11,min = 20, max = 1000,	category = "Engine"} } )
	self:NetworkVar( "Bool",10, "Revlimiter",				{ KeyName = "revlimiter",				Edit = { type = "Boolean",		order = 12,					category = "Engine"} } )
	self:NetworkVar( "Bool",1, "TurboCharged",				{ KeyName = "turbocharged",			Edit = { type = "Boolean",		order = 13,					category = "Engine"} } )
	self:NetworkVar( "Bool",4, "SuperCharged",				{ KeyName = "supercharged",			Edit = { type = "Boolean",		order = 14,					category = "Engine"} } )
	self:NetworkVar( "Bool",14, "BackFire",				{ KeyName = "backfire",				Edit = { type = "Boolean",		order = 15,					category = "Engine"} } )
	self:NetworkVar( "Bool",15, "DoNotStall",				{ KeyName = "donotstall",				Edit = { type = "Boolean",		order = 16,					category = "Engine"} } )
	
	self:NetworkVar( "Float",7, "DifferentialGear",			{ KeyName = "differentialgear",			Edit = { type = "Float",		order = 17,min = 0.2, max = 6,		category = "Transmission"} } )
	
	self:NetworkVar( "Float",8, "BrakePower",				{ KeyName = "brakepower",			Edit = { type = "Float",		order = 18,min = 0.1, max = 500,	category = "Wheels"} } )
	self:NetworkVar( "Float",9, "PowerDistribution",			{ KeyName = "powerdistribution",		Edit = { type = "Float",		order = 19,min = -1, max = 1,		category = "Wheels"} } )
	self:NetworkVar( "Float",10, "Efficiency",				{ KeyName = "efficiency",				Edit = { type = "Float",		order = 20,min = 0.2, max = 2,		category = "Wheels"} } )
	self:NetworkVar( "Float",11, "MaxTraction",				{ KeyName = "maxtraction",			Edit = { type = "Float",		order = 21,min = 5, max = 500,		category = "Wheels"} } )
	self:NetworkVar( "Float",12, "TractionBias",				{ KeyName = "tractionbias",			Edit = { type = "Float",		order = 22,min = -0.99, max = 0.99,	category = "Wheels"} } )
	self:NetworkVar( "Vector",0, "TireSmokeColor",			{ KeyName = "tiresmokecolor",			Edit = { type = "VectorColor",	order = 23,					category = "Wheels"} } )
	
	self:NetworkVar( "Float",13, "FlyWheelRPM" )
	self:NetworkVar( "Float",14, "Throttle" )
	self:NetworkVar( "Int",5, "Gear" )
	self:NetworkVar( "Int",6, "Clutch" )
	self:NetworkVar( "Bool",5, "IsCruiseModeOn" )
	self:NetworkVar( "Bool",7, "IsBraking" )
	self:NetworkVar( "Bool",8, "LightsEnabled" )
	self:NetworkVar( "Bool",9, "LampsEnabled" )
	self:NetworkVar( "Bool",12, "EMSEnabled" )
	self:NetworkVar( "Bool",11, "FogLightsEnabled" )
	self:NetworkVar( "Bool",16, "HandBrakeEnabled" )
	self:NetworkVar( "Float",27, "MousePos" )
	self:NetworkVar( "Float",28, "DeadZone" )
	self:NetworkVar( "Float",29, "ctPos" )
	
	self:NetworkVar( "Float",15, "VehicleSteer" )
	self:NetworkVar( "Entity",0, "Driver" )
	self:NetworkVar( "Entity",1, "DriverSeat" )
	self:NetworkVar( "Bool",3, "Active" )
	self:NetworkVar( "Bool",13, "Freelook" )
	
	self:NetworkVar( "String",1, "Spawn_List")
	self:NetworkVar( "String",2, "Lights_List")
	self:NetworkVar( "String",3, "Soundoverride")

	if ( SERVER ) then
		self:NetworkVarNotify( "FrontSuspensionHeight", self.OnFrontSuspensionHeightChanged )
		self:NetworkVarNotify( "RearSuspensionHeight", self.OnRearSuspensionHeightChanged )
		self:NetworkVarNotify( "TireSmokeColor", self.OnTireSmokeColorChanged )
		self:NetworkVarNotify( "TurboCharged", self.OnTurboCharged )
		self:NetworkVarNotify( "SuperCharged", self.OnSuperCharged )
		self:NetworkVarNotify( "Active", self.OnActiveChanged )
		self:NetworkVarNotify( "Throttle", self.OnThrottleChanged )
	end
end

function ENT:IsSimfphyscar()
	return true
end

local VehicleMeta = FindMetaTable("Entity")
local OldIsVehicle = VehicleMeta.IsVehicle

function VehicleMeta:IsVehicle()
	return self.IsSimfphyscar and self:IsSimfphyscar() or OldIsVehicle(self)
end

function ENT:GetCurHealth()
	return self:GetNWFloat( "Health", 0 )
end

function ENT:GetMaxHealth()
	return self:GetNWFloat( "MaxHealth", 0 )
end

if SERVER then

	function ENT:SetMaxHealth( nHealth )
		self:SetNWFloat( "MaxHealth", nHealth )
	end

	function ENT:SetCurHealth( nHealth )
		self:SetNWFloat( "Health", nHealth )
	end

end