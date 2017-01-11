------ shared
entity:GetSteerSpeed()	-- returns a number
entity:GetFastSteerConeFadeSpeed()	-- returns a number
entity:GetFastSteerAngle()	-- returns a number

entity:GetFrontSuspensionHeight()	-- returns a number
entity:GetRearSuspensionHeight()	-- returns a number

entity:GetEngineSoundPreset()	-- returns a number
entity:GetIdleRPM()	-- returns a number
entity:GetLimitRPM()	-- returns a number
entity:GetPowerBandStart()	-- returns a number
entity:GetPowerBandEnd()	-- returns a number
entity:GetMaxTorque()	-- returns a number
entity:GetRevlimiter() -- returns a bool
entity:GetTurboCharged() -- returns a bool
entity:GetSuperCharged() -- returns a bool
entity:GetBackFire() -- returns a bool
entity:GetDoNotStall() -- returns a bool
entity:GetFlyWheelRPM() -- returns a number

entity:GetClutch() -- returns a number
entity:GetThrottle() -- returns a number
entity:GetGear() -- returns a number
entity:GetDifferentialGear() -- returns a number 

entity:GetBrakePower() -- returns a number
entity:GetPowerDistribution() -- returns a number
entity:GetEfficiency() -- returns a number
entity:GetMaxTraction() -- returns a number
entity:GetTractionBias() -- returns a number
entity:GetTireSmokeColor() -- returns a vector

entity:GetHealthp() -- returns a number
entity:GetMaxHealth() -- returns a number

entity:GetIsCruiseModeOn() -- returns a bool
entity:GetIsBraking() -- returns a bool
entity:GetLightsEnabled() -- returns a bool
entity:GetLampsEnabled() -- returns a bool
entity:GetEMSEnabled() -- returns a bool
entity:GetFogLightsEnabled() -- returns a bool
entity:GetHandBrakeEnabled() -- returns a bool

entity:GetVehicleSteer() -- returns a number
entity:GetDriver() -- returns an entity
entity:GetDriverSeat() -- returns an entity
entity:GetActive() -- returns a bool

entity:GetSpawn_List() -- returns the vehicle spawnname as string
entity:GetLights_List() -- returns the lights table as string

entity:GetSoundoverride() -- returns an string



-- server
entity:Destroy()  -- destroys the vehicle
entity:SteerVehicle( number ) -- sets the angle of the steering
entity:Lock()  -- locks the vehicle
entity:UnLock() -- unlocks the vehicle

entity:SetControl( table ) -- controls the vehicle (only works without driver when the vehicle is active)
--[[
for example: 

entity:SetActive( true )
local Data = {
	["W"] = true,
	["S"] = true,
}
entity:SetControl( Data )

car should do an burnout now
]]--
