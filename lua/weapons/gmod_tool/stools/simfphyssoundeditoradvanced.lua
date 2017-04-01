TOOL.Category		= "simfphys"
TOOL.Name			= "#Sound Editor - Advanced"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if CLIENT then
	language.Add( "tool.simfphyssoundeditoradvanced.name", "Sound Editor - Advanced" )
	language.Add( "tool.simfphyssoundeditoradvanced.desc", "A tool used to edit engine sounds on simfphys vehicles" )
	language.Add( "tool.simfphyssoundeditoradvanced.0", "Left click apply settings. Reload to reset" )
	language.Add( "tool.simfphyssoundeditoradvanced.1", "Left click apply settings. Reload to reset" )
end

function TOOL:LeftClick( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	return true
end

function TOOL:RightClick( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	return true
end

function TOOL:Reload( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	return true
end

function TOOL.BuildCPanel( panel )
end
