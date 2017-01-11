local simfphys = {}
local checkinterval = 2
local NextCheck = CurTime() + checkinterval
local SpritesDisabled = false
local mat = Material( "sprites/light_ignorez" )
local mat2 = Material( "sprites/light_glow02_add_noz" )
if (file.Exists( "materials/sprites/glow_headlight_ignorez.vmt", "GAME" )) then
	mat2 = Material( "sprites/glow_headlight_ignorez" )
end


cvars.AddChangeCallback( "cl_simfphys_hidesprites", function( convar, oldValue, newValue )
	SpritesDisabled = ( tonumber( newValue )~=0 )
end)
SpritesDisabled = GetConVar( "cl_simfphys_hidesprites" ):GetBool()

if !simfphys.vtable then
	simfphys.vtable = {}
end

local function BodyGroupIsValid( bodygroups, entity )
	for index, groups in pairs( bodygroups ) do
		local mygroup = entity:GetBodygroup( index )
		for g_index = 1, table.Count( groups ) do
			if (mygroup == groups[g_index]) then return true end
		end
	end
	return false
end

local function SetUpLights( vname , ent )	
	ent.Sprites = {}
	
	local vehiclelist = list.Get( "simfphys_lights" )[vname]
	if (!vehiclelist) then return end
	
	ent.LightsEMS = vehiclelist.ems_sprites or false 
	local hl_col = vehiclelist.ModernLights and {215,240,255} or {220,205,160}
	
	if istable(vehiclelist.ems_sprites) then
		ent.PixVisEMS = {}
		for i = 1, table.Count( vehiclelist.ems_sprites ) do
			ent.PixVisEMS[i] = util.GetPixelVisibleHandle()
			
			ent.LightsEMS[i].material = ent.LightsEMS[i].material and Material( ent.LightsEMS[i].material ) or mat2
		end
	end
	
	if istable( vehiclelist.Headlight_sprites ) then
		for _, data in pairs( vehiclelist.Headlight_sprites ) do
			local s = {}
			s.PixVis = util.GetPixelVisibleHandle()
			s.trigger = 1
			
			if !isvector(data) then
				s.color = data.color and data.color or Color( hl_col[1], hl_col[2], hl_col[3],  255)
				s.material = data.material and Material( data.material ) or mat2
				s.size = data.size and data.size or 16
				s.pos = data.pos
				if (data.OnBodyGroups) then s.bodygroups = data.OnBodyGroups end
				table.insert(ent.Sprites, s)
			else
				s.pos = data
				s.color = Color( hl_col[1], hl_col[2], hl_col[3],  255)
				s.material = mat
				s.size = 16
				table.insert(ent.Sprites, s)
				
				local s2 = {}
				s2.PixVis = util.GetPixelVisibleHandle()
				s2.trigger = s.trigger
				s2.pos = data
				s2.color = Color( hl_col[1], hl_col[2], hl_col[3],  150)
				s2.material = mat2
				s2.size = 64
				table.insert(ent.Sprites, s2)
			end
		end
	end
	
	if istable( vehiclelist.Rearlight_sprites ) then
		for _, data in pairs( vehiclelist.Rearlight_sprites ) do
			local s = {}
			s.PixVis = util.GetPixelVisibleHandle()
			s.trigger = 1
			
			if !isvector(data) then
				s.color = data.color and data.color or Color( 255, 0, 0,  125)
				s.material = data.material and Material( data.material ) or mat2
				s.size = data.size and data.size or 16
				s.pos = data.pos
				if (data.OnBodyGroups) then s.bodygroups = data.OnBodyGroups end
				table.insert(ent.Sprites, s)
			else
				local s2 = {}
				s2.PixVis = util.GetPixelVisibleHandle()
				s2.trigger = s.trigger
				s2.pos = data
				s2.color = Color( 255, 120, 0,  125 )
				s2.material = mat2
				s2.size = 12
				table.insert(ent.Sprites, s2)
				
				s.pos = data
				s.color = Color( 255, 0, 0,  90 )
				s.material = mat
				s.size = 32
				table.insert(ent.Sprites, s)
			end
		end
	end
	
	if istable( vehiclelist.Brakelight_sprites ) then
		for _, data in pairs( vehiclelist.Brakelight_sprites ) do
			local s = {}
			s.PixVis = util.GetPixelVisibleHandle()
			s.trigger = 4
			
			if !isvector(data) then
				s.color = data.color and data.color or Color( 255, 0, 0,  125)
				s.material = data.material and Material( data.material ) or mat2
				s.size = data.size and data.size or 16
				s.pos = data.pos
				if (data.OnBodyGroups) then s.bodygroups = data.OnBodyGroups end
				table.insert(ent.Sprites, s)
			else
				s.pos = data
				s.color = Color( 255, 0, 0,  90 )
				s.material = mat
				s.size = 32
				table.insert(ent.Sprites, s)
				
				local s2 = {}
				s2.PixVis = util.GetPixelVisibleHandle()
				s2.trigger = s.trigger
				s2.pos = data
				s2.color = Color( 255, 120, 0,  125 ) 
				s2.material = mat2
				s2.size = 12
				table.insert(ent.Sprites, s2)
			end
		end
	end
	
	if istable( vehiclelist.Reverselight_sprites ) then
		for _, data in pairs( vehiclelist.Reverselight_sprites ) do
			local s = {}
			s.PixVis = util.GetPixelVisibleHandle()
			s.trigger = 5
			
			if !isvector(data) then
				s.color = data.color and data.color or Color( 255, 255, 255,  255)
				s.material = data.material and Material( data.material ) or mat2
				s.size = data.size and data.size or 16
				s.pos = data.pos
				if (data.OnBodyGroups) then s.bodygroups = data.OnBodyGroups end
				table.insert(ent.Sprites, s)
			else
				s.pos = data
				s.color = Color( 255, 255, 255,  255)
				s.material = mat
				s.size = 12
				table.insert(ent.Sprites, s)
				
				local s2 = {}
				s2.PixVis = util.GetPixelVisibleHandle()
				s2.trigger = s.trigger
				s2.pos = data
				s2.color =  Color( 255, 255, 255,  150 )
				s2.material = mat2
				s2.size = 16
				table.insert(ent.Sprites, s2)
			end
		end
	end
	
	if istable( vehiclelist.FrontMarker_sprites ) then
		for _, data in pairs( vehiclelist.FrontMarker_sprites ) do
			local s = {}
			s.PixVis = util.GetPixelVisibleHandle()
			s.trigger = 1
			
			if isvector(data) then
				s.pos = data
				s.color = Color( 200, 100, 0,  150)
				s.material = mat
				s.size = 12
				table.insert(ent.Sprites, s)
			end
		end
	end
	
	if istable( vehiclelist.RearMarker_sprites ) then
		for _, data in pairs( vehiclelist.RearMarker_sprites ) do
			local s = {}
			s.PixVis = util.GetPixelVisibleHandle()
			s.trigger = 1
			
			if isvector(data) then
				s.pos = data
				s.color = Color( 205, 0, 0,  150 )
				s.material = mat
				s.size = 12
				table.insert(ent.Sprites, s)
			end
		end
	end
	
	if istable( vehiclelist.Headlamp_sprites ) then
		for _, data in pairs( vehiclelist.Headlamp_sprites ) do
			local s = {}
			s.PixVis = util.GetPixelVisibleHandle()
			s.trigger = 2
			
			if !isvector(data) then
				s.color = data.color and data.color or Color( hl_col[1], hl_col[2], hl_col[3],  255)
				s.material = data.material and Material( data.material ) or mat2
				s.size = data.size and data.size or 16
				s.pos = data.pos
				if (data.OnBodyGroups) then s.bodygroups = data.OnBodyGroups end
				table.insert(ent.Sprites, s)
			else
				s.pos = data
				s.color = Color( hl_col[1], hl_col[2], hl_col[3],  255)
				s.material = mat
				s.size = 16
				table.insert(ent.Sprites, s)
				
				local s2 = {}
				s2.PixVis = util.GetPixelVisibleHandle()
				s2.trigger = s.trigger
				s2.pos = data
				s2.color = Color( hl_col[1], hl_col[2], hl_col[3],  150)
				s2.material = mat2
				s2.size = 64
				table.insert(ent.Sprites, s2)
			end
		end
	end
	
	if istable( vehiclelist.FogLight_sprites ) then
		for _, data in pairs( vehiclelist.FogLight_sprites ) do
			local s = {}
			s.PixVis = util.GetPixelVisibleHandle()
			s.trigger = 3
			
			if !isvector(data) then
				s.color = data.color and data.color or Color( hl_col[1], hl_col[2], hl_col[3],  255)
				s.material = data.material and Material( data.material ) or mat2
				s.size = data.size and data.size or 32
				s.pos = data.pos
				if (data.OnBodyGroups) then s.bodygroups = data.OnBodyGroups end
				table.insert(ent.Sprites, s)
			else
				s.pos = data
				s.color = Color( hl_col[1], hl_col[2], hl_col[3],  200)
				s.material = mat2
				s.size = 32
				table.insert(ent.Sprites, s)
			end
		end
	end
	
	ent.EnableLights = true
	table.insert(simfphys.vtable, ent)
end

local function DrawEMSLights( ent )
	local Time = CurTime()
	if (ent.LightsEMS) then
		for i = 1, table.Count( ent.LightsEMS ) do
			local size = ent.LightsEMS[i].size
			local LightPos = ent:LocalToWorld( ent.LightsEMS[i].pos )
			local Visible = util.PixelVisible( LightPos, 4, ent.PixVisEMS[i] )
			local mat = ent.LightsEMS[i].material
			local numcolors = table.Count( ent.LightsEMS[i].Colors )
			
			ent.LightsEMS[i].Timer = ent.LightsEMS[i].Timer or 0
			ent.LightsEMS[i].Index = ent.LightsEMS[i].Index or 0
			if (numcolors > 1) then
				if (ent.LightsEMS[i].Timer < Time) then
					ent.LightsEMS[i].Timer = Time + ent.LightsEMS[i].Speed
					ent.LightsEMS[i].Index = ent.LightsEMS[i].Index + 1
					if (ent.LightsEMS[i].Index > numcolors) then
						ent.LightsEMS[i].Index = 1
					end
				end
			end
			local col = ent.LightsEMS[i].Colors[ent.LightsEMS[i].Index]
			
			if (ent.LightsEMS[i].OnBodyGroups) then
				Visible = !ent:BodyGroupIsValid( ent.LightsEMS[i].OnBodyGroups ) and 0 or Visible
			end
			
			if Visible and Visible >= 0.6 and col != Color(0,0,0,0) then
				Visible = (Visible - 0.6) / 0.4
				
				render.SetMaterial( mat )
				render.DrawSprite( LightPos, size, size,  Color( col["r"], col["g"], col["b"],  col["a"] * Visible) )
			end
		end
	end
end

hook.Add( "Think", "simfphys_sprites_managment", function()
	local curtime = CurTime()
	
	if NextCheck < curtime then
		NextCheck = curtime + checkinterval
		
		for i, ent in pairs(simfphys.vtable) do
			if ent:GetNWBool( "lights_disabled" ) then
				simfphys.vtable[i] = nil
				ent.EnableLights = true
			end
		end
		
		for i, ent in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) ) do
			if (ent.EnableLights == true) then return end
			local listname = ent:GetLights_List()
			
			if (!listname) then return end
			
			if (listname != "no_lights") then
				SetUpLights( listname, ent )
			else
				ent.EnableLights = true
			end
		end
	end
end )

hook.Add( "PostDrawTranslucentRenderables", "simfphys_draw_sprites", function()
	if simfphys.vtable then
		for i, ent in pairs(simfphys.vtable) do
			if IsValid(ent) then
				if (ent:GetEMSEnabled()) then
					DrawEMSLights( ent )
				end
			
				if SpritesDisabled then return end
				
				local triggers = {
					[1] = ent:GetLightsEnabled(),
					[2] = ent:GetLampsEnabled(),
					[3] = ent:GetFogLightsEnabled(),
					[4] = ent:GetIsBraking(),
					[5] = (ent:GetGear() == 1),
				}
				
				for _, sprite in pairs( ent.Sprites ) do
					local triggered = sprite.trigger
					if triggers[triggered] then
						local LightPos = ent:LocalToWorld( sprite.pos )
						local Visible = util.PixelVisible( LightPos, 4, sprite.PixVis )
						local s_col = sprite.color
						local s_mat = sprite.material
						local s_size = sprite.size
						
						if sprite.bodygroups then
							Visible = !BodyGroupIsValid( sprite.bodygroups, ent ) and 0 or Visible
						end
						
						if Visible and Visible >= 0.6 then
							Visible = (Visible - 0.6) / 0.4
							render.SetMaterial( s_mat )
							render.DrawSprite( LightPos, s_size, s_size,  Color( s_col["r"], s_col["g"], s_col["b"],  s_col["a"] * Visible) )
						end
					end
				end
			else
				simfphys.vtable[i] = nil
			end
		end
	end
end )