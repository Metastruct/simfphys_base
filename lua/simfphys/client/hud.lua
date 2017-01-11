local screenw = ScrW()
local screenh = ScrH()
local Widescreen = (screenw / screenh) > (4 / 3)
local sizex = screenw * (Widescreen and 1 or 1.32)
local sizey = screenh
local xpos = sizex * 0.02
local ypos = sizey * 0.8
local x = xpos * 43.5
local y = ypos * 1.015
local radius = 0.085 * sizex
local startang = 105

local ShowHud = false
cvars.AddChangeCallback( "cl_simfphys_hud", function( convar, oldValue, newValue )
	ShowHud = ( tonumber( newValue )~=0 )
end)
ShowHud = GetConVar( "cl_simfphys_hud" ):GetBool()

local AltHud = false
cvars.AddChangeCallback( "cl_simfphys_althud", function( convar, oldValue, newValue )
	AltHud = ( tonumber( newValue )~=0 )
end)
AltHud = GetConVar( "cl_simfphys_althud" ):GetBool()

local Hudmph = false
cvars.AddChangeCallback( "cl_simfphys_hudmph", function( convar, oldValue, newValue )
	Hudmph = ( tonumber( newValue )~=0 )
end)
Hudmph = GetConVar( "cl_simfphys_hudmph" ):GetBool()

local Hudreal = false
cvars.AddChangeCallback( "cl_simfphys_hudrealspeed", function( convar, oldValue, newValue )
	Hudreal = ( tonumber( newValue )~=0 )
end)
Hudreal = GetConVar( "cl_simfphys_hudrealspeed" ):GetBool()

local isMouseSteer = false
cvars.AddChangeCallback( "cl_simfphys_mousesteer", function( convar, oldValue, newValue )
	isMouseSteer = ( tonumber( newValue )~=0 )
end)
isMouseSteer = GetConVar( "cl_simfphys_mousesteer" ):GetBool()

local hasCounterSteerEnabled = false
cvars.AddChangeCallback( "cl_simfphys_ctenable", function( convar, oldValue, newValue )
	hasCounterSteerEnabled = ( tonumber( newValue )~=0 )
end)
hasCounterSteerEnabled = GetConVar( "cl_simfphys_ctenable" ):GetBool()

local slushbox = false
cvars.AddChangeCallback( "cl_simfphys_auto", function( convar, oldValue, newValue )
	slushbox = ( tonumber( newValue )~=0 )
end)
slushbox = GetConVar( "cl_simfphys_auto" ):GetBool()

local lights_on = Material( "simfphys/hud/low_beam_on" )
local lights_on2 = Material( "simfphys/hud/high_beam_on" )
local lights_off = Material( "simfphys/hud/low_beam_off" )

local fog_on = Material( "simfphys/hud/fog_light_on" )
local fog_off = Material( "simfphys/hud/fog_light_off" )

local cruise_on = Material( "simfphys/hud/cc_on" )
local cruise_off = Material( "simfphys/hud/cc_off" )

local hbrake_on = Material( "simfphys/hud/handbrake_on" )
local hbrake_off = Material( "simfphys/hud/handbrake_off" )

local function drawsimfphysHUD(vehicle)
	if (isMouseSteer) then
		local MousePos = vehicle:GetMousePos()
		local deadzone = vehicle:GetDeadZone()
		local m_size = sizex * 0.15
		
		draw.SimpleText( "V", "simfphysfont", sizex * 0.5 + MousePos * m_size - 1, sizey * 0.45, Color( 240, 230, 200, 255 ), 1, 1 )
		draw.SimpleText( "[", "simfphysfont", sizex * 0.5 - m_size * 1.05, sizey * 0.45, Color( 240, 230, 200, 180 ), 1, 1 )
		draw.SimpleText( "]", "simfphysfont", sizex * 0.5 + m_size * 1.05, sizey * 0.45, Color( 240, 230, 200, 180 ), 1, 1 )
		
		if (deadzone > 0) then
			draw.SimpleText( "^", "simfphysfont", sizex * 0.5 - deadzone * m_size, sizey * 0.453, Color( 240, 230, 200, 180 ), 1, 2 )
			draw.SimpleText( "^", "simfphysfont", sizex * 0.5 + deadzone * m_size, sizey * 0.453, Color( 240, 230, 200, 180 ), 1, 2 )
		else
			draw.SimpleText( "^", "simfphysfont", sizex * 0.5, sizey * 0.453, Color( 240, 230, 200, 180 ), 1, 2 )
		end
		
		if (hasCounterSteerEnabled) then
			local ctpos = vehicle:GetctPos()
			if (math.abs(ctpos) > 0.1) then
				local hudctpos = math.Clamp(ctpos + deadzone * (ctpos < 0 and -1 or 1),-1,1)
				draw.SimpleText( "|", "simfphysfont", sizex * 0.5 + hudctpos * m_size, sizey * 0.45, Color( 255, 235, 0, 255 ), 1, 1 )
			end
		end
	end
	
	if (!ShowHud) then return end
	
	local maxrpm = vehicle:GetLimitRPM()
	local rpm = vehicle:GetRPM()
	local throttle = math.Round(vehicle:GetThrottle() * 100,0)
	local revlimiter = vehicle:GetRevlimiter() and (maxrpm > 2500) and (throttle > 0)
	
	local powerbandend = math.min(vehicle:GetPowerBandEnd(), maxrpm)
	local redline = math.max(rpm - powerbandend,0) / (maxrpm - powerbandend)
	
	local Active = vehicle:GetActive() and "" or "!"
	local speed = vehicle:GetVelocity():Length()
	local mph = math.Round(speed * 0.0568182,0)
	local kmh = math.Round(speed * 0.09144,0)
	local wiremph = math.Round(speed * 0.0568182 * 0.75,0)
	local wirekmh = math.Round(speed * 0.09144 * 0.75,0)
	local cruisecontrol = vehicle:GetIsCruiseModeOn()
	local gear = vehicle:GetGear()
	local DrawGear = !slushbox and (gear == 1 and "R" or gear == 2 and "N" or (gear - 2)) or (gear == 1 and "R" or gear == 2 and "N" or "(".. (gear - 2)..")")
	
	if (AltHud) then
		local LightsOn = vehicle:GetLightsEnabled()
		local LampsOn = vehicle:GetLampsEnabled()
		local FogLightsOn = vehicle:GetFogLightsEnabled()
		local HandBrakeOn = vehicle:GetHandBrakeEnabled()
		
		s_smoothrpm = s_smoothrpm or 0
		s_smoothrpm = math.Clamp(s_smoothrpm + (rpm - s_smoothrpm) * 0.3,0,maxrpm)
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		local mat = LightsOn and (LampsOn and lights_on2 or lights_on) or lights_off
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( x * 1.119, y * 0.98, sizex * 0.014, sizex * 0.014 )
		
		local mat = FogLightsOn and fog_on or fog_off
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( x * 1.116, y * 0.92, sizex * 0.018, sizex * 0.018 )
		
		local mat = cruisecontrol and cruise_on or cruise_off
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( x * 1.116, y * 0.861, sizex * 0.02, sizex * 0.02 )
		
		local mat = HandBrakeOn and hbrake_on or hbrake_off
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( x * 1.1175, y * 0.815, sizex * 0.018, sizex * 0.018 )
		
		draw.NoTexture()
		
		local endang = startang + math.Round( (s_smoothrpm/maxrpm) * 255, 0)
		local c_ang = math.cos( math.rad(endang) )
		local s_ang = math.sin( math.rad(endang) )
		local ang_pend = startang + math.Round( (powerbandend / maxrpm) * 255, 0)
		local r_rpm = math.floor(maxrpm / 1000) * 1000
		local in_red = s_smoothrpm < powerbandend
		
		for i = 0,r_rpm,1000 do
			local anglestep = (255 / maxrpm) * i
			
			local n_col_on
			local n_col_off
			if (i < powerbandend) then
				n_col_off = Color(150, 150, 150, 150)
				n_col_on = Color(255, 255, 255, 255)
			else
				n_col_off = Color( 150, 0, 0, 150)
				n_col_on = Color( 255, 0, 0, 255 )
			end
			local u_col = (s_smoothrpm > i) and n_col_on or n_col_off
			surface.SetDrawColor( u_col )
			
			local cos_a = math.cos( math.rad(startang + anglestep) )
			local sin_a = math.sin( math.rad(startang + anglestep) )
			
			surface.DrawLine( x + cos_a * radius / 1.3, y + sin_a * radius / 1.3, x + cos_a * radius, y + sin_a * radius)
			local printnumber = tostring(i / 1000)
			draw.SimpleText(printnumber, "simfphysfont3", x + cos_a * radius / 1.5, y + sin_a * radius / 1.5,u_col, 1, 1 )
		end
		
		local center_ncol = in_red and Color(0,254,235,200) or Color( 255, 0, 0, 255 )
		
		surface.SetDrawColor( in_red and Color(255,255,255,255) or Color( 255, 0, 0, 255 ) )
		surface.DrawLine( x + c_ang * radius / 3.5, y + s_ang * radius / 3.5, x + c_ang * radius, y + s_ang * radius)
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		draw.Arc(x,y,radius,radius / 6.66,startang,math.min(endang,ang_pend),1,Color(255,255,255,150),true)
		
		-- middle
		draw.Arc(x,y,radius / 3.5,radius / 66,startang,360,15,Color(255,255,255,50),true)
		
		-- outer
		draw.Arc(x,y,radius,radius / 6.66,startang,ang_pend,1,Color(150,150,150,50),true)
		draw.Arc(x,y,radius,radius / 6.66,ang_pend,360,1,Color(120,0,0,120),true)
		
		draw.Arc(x,y,radius,radius / 6.66,math.Round(ang_pend - 1,0),startang + (s_smoothrpm / maxrpm) * 255,1,Color(255,0,0,140),true)
		
		--inner
		draw.Arc(x,y,radius / 5,radius / 70,0,360,15,center_ncol,true)
		
		draw.SimpleText( (gear == 1 and "R" or gear == 2 and "N" or (gear - 2)), "simfphysfont2", x * 0.999, y * 0.996, center_ncol, 1, 1 )
		
		local print_text = Hudmph and "MPH" or "KM/H"
		draw.SimpleText( print_text, "simfphysfont3", x * 1.08, y * 1.03, Color(255,255,255,50), 1, 1 )
		
		local printspeed = Hudmph and (Hudreal and mph or wiremph) or (Hudreal and kmh or wirekmh)
		
		local digit_1  =  printspeed % 10
		local digit_2 =  (printspeed - digit_1) % 100
		local digit_3  = (printspeed - digit_1 - digit_2) % 1000
		
		local col_on = Color(150,150,150,50)
		local col_off = Color(255,255,255,150)
		local col1 = (printspeed > 0) and col_off or col_on
		local col2 = (printspeed >= 10) and col_off or col_on
		local col3 = (printspeed >= 100) and col_off or col_on
		
		draw.SimpleText( digit_1, "simfphysfont4", x * 1.08, y * 1.11, col1, 1, 1 )
		draw.SimpleText( digit_2/ 10, "simfphysfont4", x * 1.045, y * 1.11, col2, 1, 1 )
		draw.SimpleText( digit_3 / 100, "simfphysfont4", x * 1.01, y * 1.11, col3, 1, 1 )
		
		local t_size = (sizey * 0.1)
		draw.RoundedBox( 0, x * 1.12, y * 1.06, sizex * 0.007, sizey * 0.1, Color(150,150,150,50) )
		draw.RoundedBox( 0, x * 1.12, y * 1.06 + t_size - t_size * math.min(throttle / 100,1), sizex * 0.007, t_size * math.min(throttle / 100,1), Color(255,255,255,150) )
		
		return
	end

	if (cruisecontrol) then
		draw.SimpleText( "cruise", "simfphysfont", xpos + sizex * 0.115, ypos + sizey * 0.035, Color( 255, 127, 0, 255 ), 2, 1 )
	end

	draw.RoundedBox( 8, xpos, ypos, sizex * 0.118, sizey * 0.075, Color( 0, 0, 0, 80 ) )
	
	draw.SimpleText( "Throttle: "..throttle.." %", "simfphysfont", xpos + sizex * 0.005, ypos + sizey * 0.035, Color( 255, 235, 0, 255 ), 0, 1)
	
	draw.SimpleText( "RPM: "..rpm..Active, "simfphysfont", xpos + sizex * 0.005, ypos + sizey * 0.012, Color( 255, 235 * (1 - redline), 0, 255 ), 0, 1 )
	
	draw.SimpleText( "GEAR:", "simfphysfont", xpos + sizex * 0.062, ypos + sizey * 0.012, Color( 255, 235, 0, 255 ), 0, 1 )
	draw.SimpleText( DrawGear, "simfphysfont", xpos + sizex * 0.11, ypos + sizey * 0.012, Color( 255, 235, 0, 255 ), 2, 1 )
	
	draw.SimpleText( (Hudreal and mph or wiremph).." mph", "simfphysfont", xpos + sizex * 0.005, ypos + sizey * 0.062, Color( 255, 235, 0, 255 ), 0, 1 )
	
	draw.SimpleText( (Hudreal and kmh or wirekmh).." kmh", "simfphysfont", xpos + sizex * 0.11, ypos + sizey * 0.062, Color( 255, 235, 0, 255 ), 2, 1 )
end

local function simfphysHUD()
	local ply = LocalPlayer()
	
	if !ply or !ply:Alive() then return end

	local vehicle = ply:GetVehicle()
	if (!IsValid(vehicle)) then return end
	
	local vehiclebase = vehicle.vehiclebase
	
	if (!IsValid(vehiclebase)) then return end
	
	local IsDriverSeat = vehicle == vehiclebase:GetDriverSeat()
	if (!IsDriverSeat) then return end
	
	drawsimfphysHUD(vehiclebase)
end
hook.Add( "HUDPaint", "simfphys_HUD", simfphysHUD)

-- draw.arc function by bobbleheadbob
-- https://dl.dropboxusercontent.com/u/104427432/Scripts/drawarc.lua
-- https://facepunch.com/showthread.php?t=1438016&p=46536353&viewfull=1#post46536353

function surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness,bClockwise)
	local triarc = {}
	local deg2rad = math.pi / 180
	
	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0
	if bClockwise and (startang < endang) then
		local temp = startang
		startang = endang
		endang = temp
		temp = nil
	elseif (startang > endang) then 
		local temp = startang
		startang = endang
		endang = temp
		temp = nil
	end
	
	
	-- Define step
	local roughness = math.max(roughness or 1, 1)
	local step = roughness
	if bClockwise then
		step = math.abs(roughness) * -1
	end
	
	
	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = deg2rad * deg
		table.insert(inner, {
			x=cx+(math.cos(rad)*r),
			y=cy+(math.sin(rad)*r)
		})
	end
	
	
	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = deg2rad * deg
		table.insert(outer, {
			x=cx+(math.cos(rad)*radius),
			y=cy+(math.sin(rad)*radius)
		})
	end
	
	
	-- Triangulize the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[math.floor(tri/2)+1]
		p3 = inner[math.floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[math.floor((tri+1)/2)]
		else
			p2 = inner[math.floor((tri+1)/2)]
		end
	
		table.insert(triarc, {p1,p2,p3})
	end
	
	-- Return a table of triangles to draw.
	return triarc
	
end

function surface.DrawArc(arc)
	for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end

function draw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color,bClockwise)
	surface.SetDrawColor(color)
	surface.DrawArc(surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness,bClockwise))
end
