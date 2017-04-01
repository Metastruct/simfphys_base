TOOL.Category		= "simfphys"
TOOL.Name			= "#Sound Editor"
TOOL.Command		= nil
TOOL.ConfigName		= ""


TOOL.ClientConVar[ "Idle" ] = "simulated_vehicles/misc/e49_idle.wav"
TOOL.ClientConVar[ "IdlePitch" ] = 1
TOOL.ClientConVar[ "Mid" ] = "simulated_vehicles/misc/gto_onlow.wav"
TOOL.ClientConVar[ "MidPitch" ] = 1
TOOL.ClientConVar[ "MidVolume" ] = 0.75
TOOL.ClientConVar[ "MidFadeOutRPMpercent" ] = 68
TOOL.ClientConVar[ "MidFadeOutRate" ] = 0.4
TOOL.ClientConVar[ "High" ] = "simulated_vehicles/misc/nv2_onlow_ex.wav"
TOOL.ClientConVar[ "HighPitch" ] = 1
TOOL.ClientConVar[ "HighVolume" ] = 1
TOOL.ClientConVar[ "HighFadeInRPMpercent" ] = 26.6
TOOL.ClientConVar[ "HighFadeInRate" ] = 0.266
TOOL.ClientConVar[ "Throttle" ] = "simulated_vehicles/valve_noise.wav"
TOOL.ClientConVar[ "ThrottlePitch" ] = 0.65
TOOL.ClientConVar[ "ThrottleVolume" ] = 1

if CLIENT then
	language.Add( "tool.simfphyssoundeditor.name", "Sound Editor" )
	language.Add( "tool.simfphyssoundeditor.desc", "A tool used to edit engine sounds on simfphys vehicles" )
	language.Add( "tool.simfphyssoundeditor.0", "Left click apply settings. Reload to reset" )
	language.Add( "tool.simfphyssoundeditor.1", "Left click apply settings. Reload to reset" )

	language.Add( "tool.simfphyssoundeditor.fadeout", "Fadeout RPM %" )
	language.Add( "tool.simfphyssoundeditor.fadeout.help", "At wich percentage of limitrpm the sound fades out" )
	language.Add( "tool.simfphyssoundeditor.fadeoutrate", "Fadeout rate" )
	language.Add( "tool.simfphyssoundeditor.fadeoutrate.help", "how fast it fades out   0 = instant       1 = never" )
	
	language.Add( "tool.simfphyssoundeditor.fadein", "Fadein RPM %" )
	language.Add( "tool.simfphyssoundeditor.fadein.help", "At wich percentage of limitrpm the sound fades in" )
	language.Add( "tool.simfphyssoundeditor.fadeinrate", "Fadein rate" )
	language.Add( "tool.simfphyssoundeditor.fadeinrate.help", "how fast it fades in   0 = instant       1 = never" )
	
	presets.Add( "simfphys_sound", "Jalopy", {
		simfphyssoundeditor_High					= "simulated_vehicles/jalopy/jalopy_high.wav",
		simfphyssoundeditor_HighFadeInRate			= "0.40",
		simfphyssoundeditor_HighFadeInRPMpercent	= "55.00",
		simfphyssoundeditor_HighPitch				= "0.75",
		simfphyssoundeditor_HighVolume			= "0.90",
		simfphyssoundeditor_Idle					= "simulated_vehicles/jalopy/jalopy_idle.wav",
		simfphyssoundeditor_IdlePitch				= "0.95",
		simfphyssoundeditor_Mid					= "simulated_vehicles/jalopy/jalopy_mid.wav",
		simfphyssoundeditor_MidFadeOutRate			= "0.25",
		simfphyssoundeditor_MidFadeOutRPMpercent	= "55.00",
		simfphyssoundeditor_MidPitch				= "1.00",
		simfphyssoundeditor_MidVolume				= "1.00",
		simfphyssoundeditor_ThrottlePitch			= "0.00",
		simfphyssoundeditor_ThrottleVolume			= "0.00"
	} )

	presets.Add( "simfphys_sound", "APC", {
		simfphyssoundeditor_High					= "simulated_vehicles/misc/v8high2.wav",
		simfphyssoundeditor_HighFadeInRate			= "0.19",
		simfphyssoundeditor_HighFadeInRPMpercent	= "58.00",
		simfphyssoundeditor_HighPitch				= "1.00",
		simfphyssoundeditor_HighVolume			= "0.75",
		simfphyssoundeditor_Idle					= "simulated_vehicles/misc/nanjing_loop.wav",
		simfphyssoundeditor_IdlePitch				= "1.00",
		simfphyssoundeditor_Mid					= "simulated_vehicles/misc/m50.wav",
		simfphyssoundeditor_MidFadeOutRate			= "0.48",
		simfphyssoundeditor_MidFadeOutRPMpercent	= "58.00",
		simfphyssoundeditor_MidPitch				= "1.00",
		simfphyssoundeditor_MidVolume				= "1.00",
		simfphyssoundeditor_ThrottlePitch			= "0.00",
		simfphyssoundeditor_ThrottleVolume			= "0.00"
	} )
end

function TOOL:LeftClick( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	if (SERVER) then
		local outputstring = {}
		outputstring[1] = self:GetClientInfo( "Idle" )
		outputstring[2] = self:GetClientInfo( "IdlePitch" )
		outputstring[3] = self:GetClientInfo( "Mid" )
		outputstring[4] = self:GetClientInfo( "MidPitch" )
		outputstring[5] = self:GetClientInfo( "MidVolume" )
		outputstring[6] = self:GetClientInfo( "MidFadeOutRPMpercent" )
		outputstring[7] = self:GetClientInfo( "MidFadeOutRate" )
		outputstring[8] = self:GetClientInfo( "High" )
		outputstring[9] = self:GetClientInfo( "HighPitch" )
		outputstring[10] = self:GetClientInfo( "HighVolume" )
		outputstring[11] = self:GetClientInfo( "HighFadeInRPMpercent" )
		outputstring[12] = self:GetClientInfo( "HighFadeInRate" )
		outputstring[13] = self:GetClientInfo( "Throttle" )
		outputstring[14] = self:GetClientInfo( "ThrottlePitch" )
		outputstring[15] = self:GetClientInfo( "ThrottleVolume" )
		
		ent:SetEngineSoundPreset( 0 )
		ent:SetSoundoverride( string.Implode(",", outputstring )  )
	end

	return true
end

function TOOL:RightClick( trace )
	return false
end

function TOOL:Reload( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	if (SERVER) then
		local vname = ent:GetSpawn_List()
		local VehicleList = list.Get( "simfphys_vehicles" )[vname]
		
		ent:SetEngineSoundPreset( VehicleList.Members.EngineSoundPreset )
		ent:SetSoundoverride( "" )
	end
	
	return true
end


local ConVarsDefault = TOOL:BuildConVarList()
function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "#tool.simfphyssoundeditor.name", Description = "#tool.simfphyssoundeditor.desc" } )
	panel:AddControl( "ComboBox", { MenuButton = 1, Folder = "simfphys_sound", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "-- Idle --" } )
	panel:AddControl( "Textbox", 
	{
		Label 	= "Soundpath",
		Command = "simfphyssoundeditor_Idle"
	})	
	panel:AddControl( "Slider", 
	{
		Label 	= "Pitch",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "2.55",
		Command = "simfphyssoundeditor_IdlePitch"
	})
	
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "-- Mid --" } )
	panel:AddControl( "Textbox", 
	{
		Label 	= "Soundpath",
		Command = "simfphyssoundeditor_Mid"
	})	
	panel:AddControl( "Slider", 
	{
		Label 	= "Pitch",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "2.55",
		Command = "simfphyssoundeditor_MidPitch"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Volume",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "1",
		Command = "simfphyssoundeditor_MidVolume"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "#tool.simfphyssoundeditor.fadeout",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "100",
		Command = "simfphyssoundeditor_MidFadeOutRPMpercent",
		Help = true
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "#tool.simfphyssoundeditor.fadeoutrate",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "1",
		Command = "simfphyssoundeditor_MidFadeOutRate",
		Help = true
	})
	
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "-- High --" } )
	panel:AddControl( "Textbox", 
	{
		Label 	= "Soundpath",
		Command = "simfphyssoundeditor_High"
	})	
	panel:AddControl( "Slider", 
	{
		Label 	= "Pitch",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "2.55",
		Command = "simfphyssoundeditor_HighPitch"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Volume",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "1",
		Command = "simfphyssoundeditor_HighVolume"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "#tool.simfphyssoundeditor.fadein",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "100",
		Command = "simfphyssoundeditor_HighFadeInRPMpercent",
		Help = true
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "#tool.simfphyssoundeditor.fadeinrate",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "1",
		Command = "simfphyssoundeditor_HighFadeInRate",
		Help = true
	})
	
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "-- OnThrottle --" } )
	panel:AddControl( "Textbox", 
	{
		Label 	= "Soundpath",
		Command = "simfphyssoundeditor_Throttle"
	})	
	panel:AddControl( "Slider", 
	{
		Label 	= "Pitch",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "2.55",
		Command = "simfphyssoundeditor_ThrottlePitch"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Volume",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "1",
		Command = "simfphyssoundeditor_ThrottleVolume"
	})
end
