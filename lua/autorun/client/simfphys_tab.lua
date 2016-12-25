killicon.Add( "gmod_sent_vehicle_fphysics_base", "HUD/killicons/simfphys_car", Color( 255, 80, 0, 255 ) )
killicon.Add( "gmod_sent_sim_veh_wheel", "HUD/killicons/simfphys_car", Color( 255, 80, 0, 255 ) )

surface.CreateFont( "simfphysfont", {
font = "Verdana",
extended = false,
size = ScrH() >= 900 and (ScrH() >= 1080 and 20 or 18) or 12,
weight = 500,
blursize = 0,
scanlines = 0,
antialias = true,
underline = false,
italic = false,
strikeout = false,
symbol = false,
rotary = false,
shadow = false,
additive = false,
outline = false,
} )

surface.CreateFont( "simfphysfont2", {font = "Verdana",
extended = false,
size = (ScrH() >= 900 and (ScrH() >= 1080 and 20 or 18) or 12) * 2.8,
weight = 500,
blursize = 0,
scanlines = 0,
antialias = true,
underline = false,
italic = true,
strikeout = false,
symbol = false,
rotary = false,
shadow = false,
additive = false,
outline = false,
} )

surface.CreateFont( "simfphysfont3", {
font = "Verdana",
extended = false,
size = (ScrH() >= 900 and (ScrH() >= 1080 and 20 or 18) or 12) * 1.3,
weight = 500,
blursize = 0,
scanlines = 0,
antialias = true,
underline = false,
italic = true,
strikeout = false,
symbol = false,
rotary = false,
shadow = false,
additive = false,
outline = false,
} )

surface.CreateFont( "simfphysfont4", {
font = "Verdana",
extended = false,
size = (ScrH() >= 900 and (ScrH() >= 1080 and 20 or 18) or 12) * 6,
weight = 500,
blursize = 0,
scanlines = 0,
antialias = true,
underline = false,
italic = true,
strikeout = false,
symbol = false,
rotary = false,
shadow = false,
additive = false,
outline = false,
} )

surface.CreateFont( "DSimfphysFont", {
	font = "Arial", 
	extended = false,
	size = 23.5,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "DSimfphysFont_hint", {
	font = "Arial", 
	extended = false,
	size = 21,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = true,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

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

local auto = CreateClientConVar( "cl_simfphys_auto", 1 , true, true )
local sport = CreateClientConVar( "cl_simfphys_sport", 0 , true, true )
local sanic = CreateClientConVar( "cl_simfphys_sanic", 0 , true, true )
local ctenable = CreateClientConVar( "cl_simfphys_ctenable", 1 , true, true )
local ctmul = CreateClientConVar( "cl_simfphys_ctmul", 0.7 , true, true )
local ctang = CreateClientConVar( "cl_simfphys_ctang", 15 , true, true )
local hud = CreateClientConVar( "cl_simfphys_hud", "1", true, false )
local alt_hud = CreateClientConVar( "cl_simfphys_althud", "1", true, false )
local hud_mph = CreateClientConVar( "cl_simfphys_hudmph", "0", true, false )
local hud_realspeed = CreateClientConVar( "cl_simfphys_hudrealspeed", "0", true, false )

local mousesteer = CreateClientConVar( "cl_simfphys_mousesteer", "0", true, true )
local mssensitivity = CreateClientConVar( "cl_simfphys_ms_sensitivity", "1", true, true )
local msretract = CreateClientConVar( "cl_simfphys_ms_return", "0", true, true )
local msdeadzone = CreateClientConVar( "cl_simfphys_ms_deadzone", "4", true, true )
local msexponent = CreateClientConVar( "cl_simfphys_ms_exponent", "1.5", true, true )
local mslockpitch = CreateClientConVar( "cl_simfphys_ms_lockpitch", "0", true, true )
local k_msfreelook = CreateClientConVar( "cl_simfphys_ms_keyfreelook", KEY_Y, true, true )

CreateClientConVar( "cl_simfphys_debugwheels", "0", false, false )
CreateClientConVar( "cl_simfphys_hidesprites", "0", true, false )

local k_fwd = CreateClientConVar( "cl_simfphys_keyforward", KEY_W , true, true )
local k_bck = CreateClientConVar( "cl_simfphys_keyreverse", KEY_S , true, true )
local k_left = CreateClientConVar( "cl_simfphys_keyleft", KEY_A , true, true )
local k_right = CreateClientConVar( "cl_simfphys_keyright", KEY_D , true, true )
local k_wot = CreateClientConVar( "cl_simfphys_keywot", KEY_LSHIFT , true, true )
local k_clth = CreateClientConVar( "cl_simfphys_keyclutch", KEY_LALT , true, true )
local k_gup = CreateClientConVar( "cl_simfphys_keygearup", MOUSE_LEFT , true, true )
local k_gdn = CreateClientConVar( "cl_simfphys_keygeardown", MOUSE_RIGHT , true, true )
local k_hbrk = CreateClientConVar( "cl_simfphys_keyhandbrake", KEY_SPACE , true, true )
local k_cc = CreateClientConVar( "cl_simfphys_cruisecontrol", KEY_R, true, true )
local k_lgts = CreateClientConVar( "cl_simfphys_lights", KEY_F , true, true )
local k_flgts = CreateClientConVar( "cl_simfphys_foglights", KEY_V , true, true )
local k_horn = CreateClientConVar( "cl_simfphys_keyhorn", KEY_H , true, true )
local k_engine = CreateClientConVar( "cl_simfphys_keyengine", KEY_I , true, true )
local k_afwd = CreateClientConVar( "cl_simfphys_key_air_forward", KEY_PAD_8, true, true )
local k_abck = CreateClientConVar( "cl_simfphys_key_air_reverse", KEY_PAD_2, true, true )
local k_aleft = CreateClientConVar( "cl_simfphys_key_air_left", k_left:GetInt(), true, true )
local k_aright = CreateClientConVar( "cl_simfphys_key_air_right", k_right:GetInt(), true, true )
local k_list = {
	{k_fwd,KEY_W,"Forward"},
	{k_bck,KEY_S,"Reverse"},
	{k_left,KEY_A,"Steer Left"},
	{k_right,KEY_D,"Steer Right"},
	{k_wot,KEY_LSHIFT,"Throttle Modifier"},
	{k_clth,KEY_LALT,"Clutch"},
	{k_gup,MOUSE_LEFT,"Gear Up"},
	{k_gdn,MOUSE_RIGHT,"Gear Down"},
	{k_hbrk,KEY_SPACE,"Handbrake"},
	{k_cc,KEY_R,"Toggle Cruise Control"},
	{k_lgts,KEY_F,"Toggle Lights"},
	{k_flgts,KEY_V,"Toggle Foglights"},
	{k_horn,KEY_H,"Horn / Siren"},
	{k_engine,KEY_I,"Toggle Engine"},
	{k_afwd,KEY_PAD_8,"Tilt Backward"},
	{k_abck,KEY_PAD_2,"Tilt Forward"},
	{k_aleft,KEY_A,"Tilt Left"},
	{k_aright,KEY_D,"Tilt Right"},
}

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


local function createbinder( x, y, tbl, num, parent, sizex, sizey)
	local kentry = tbl[num]
	local key = kentry[1]
	local setdefault = key:GetInt()
	
	local sizex = sizex or 400
	local sizey = sizey or 40
	
	local Shape = vgui.Create( "DShape", parent)
	Shape:SetType( "Rect" )
	Shape:SetPos( x, y )
	Shape:SetSize( sizex, sizey )
	Shape:SetColor( Color( 0, 0, 0, 255 ) )
	
	local Shape = vgui.Create( "DShape", parent)
	Shape:SetType( "Rect" )
	Shape:SetPos( x + 1, y + 1 )
	Shape:SetSize( sizex - 2, sizey - 2 )
	Shape:SetColor( Color( 241, 241, 241, 255 ) )

	local binder = vgui.Create( "DBinder", parent)
	binder:SetPos( sizex * 0.5 + x, y )
	binder:SetSize( sizex * 0.5, sizey )
	binder:SetValue( setdefault )
	function binder:SetSelectedNumber( num )
		self.m_iSelectedNumber = num
		key:SetInt( num )
	end
	
	local TextLabel = vgui.Create( "DPanel", parent)
	TextLabel:SetPos( x, y )
	TextLabel:SetSize( sizex * 0.5, sizey )
	TextLabel.Paint = function()
		draw.SimpleText( kentry[3], "DSimfphysFont", sizex * 0.25, 20, Color( 0, 127, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	end
	return binder
end

local function createcheckbox(x, y, label, command, parent, default)
	local boxy = vgui.Create( "DCheckBoxLabel", parent)
	boxy:SetParent( parent )
	boxy:SetPos( x, y )
	boxy:SetText( label )
	boxy:SetConVar( command )
	boxy:SetValue( default )
	boxy:SizeToContents()
	return boxy
end

local function createslider(x, y, sizex, sizey, label, command, parent,min,max,default)
	local slider = vgui.Create( "DNumSlider", parent)
	slider:SetPos( x, y )
	slider:SetSize( sizex, sizey )
	slider:SetText( label )
	slider:SetMin( min )
	slider:SetMax( max )
	slider:SetDecimals( 2 )
	slider:SetConVar( command )
	slider:SetValue( default )
	return slider
end

local function buildclientsettingsmenu( self )
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 20 )
	Shape:SetSize( 350, 150 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	
	createcheckbox(25,25,"Show Hud","cl_simfphys_hud",self.PropPanel,hud:GetInt())
	
	createcheckbox(240,25,"Alternative Hud","cl_simfphys_althud",self.PropPanel,alt_hud:GetInt())
	createcheckbox(240,45,"MPH instead of KMH","cl_simfphys_hudmph",self.PropPanel,hud_mph:GetInt())
	createcheckbox(240,65,"Speed relative to \nplayersize instead \nworldsize","cl_simfphys_hudrealspeed",self.PropPanel,hud_realspeed:GetInt())
	
	createcheckbox(25,45,"Hide Sprites","cl_simfphys_hidesprites",self.PropPanel,0)
	createcheckbox(25,65,"Debug Wheels","cl_simfphys_debugwheels",self.PropPanel,0)
	createcheckbox(25,105,"Always Fullthrottle","cl_simfphys_sanic",self.PropPanel,sanic:GetInt())
	createcheckbox(25,125,"Automatic Transmission","cl_simfphys_auto",self.PropPanel,auto:GetInt())
	createcheckbox(25,145,"Automatic Sportmode (late up and downshifts)","cl_simfphys_sport",self.PropPanel,sport:GetInt())
	
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 180 )
	Shape:SetSize( 350, 115 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	
	local ctitem_1 = createcheckbox(25,185,"Enable Countersteer","cl_simfphys_ctenable",self.PropPanel,ctenable:GetInt())
	local ctitem_2 = createslider(25,200,350,40,"Countersteer Mul","cl_simfphys_ctmul",self.PropPanel,0.1,2,ctmul:GetFloat())
	local ctitem_3 = createslider(25,225,350,40,"Countersteer MaxAng","cl_simfphys_ctang",self.PropPanel,1,90,ctang:GetFloat())
	
	local Reset = vgui.Create( "DButton" )
	Reset:SetParent( self.PropPanel )
	Reset:SetText( "Reset" )	
	Reset:SetPos( 25, 265 )
	Reset:SetSize( 340, 25 )
	Reset.DoClick = function()
		ctitem_1:SetValue( 1 )
		ctitem_2:SetValue( 0.7 )
		ctitem_3:SetValue( 15 )
		ctenable:SetInt( 1 )
		ctmul:SetFloat( 0.7 )
		ctang:SetFloat( 15 )
	end
end


local function buildcontrolsmenu( self )
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 40 )
	Shape:SetSize( 525, 745 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	
	local TextLabel = vgui.Create( "DPanel", self.PropPanel)
	TextLabel:SetPos(5, 0 )
	TextLabel:SetSize(600, 40 )
	TextLabel.Paint = function()
		draw.SimpleTextOutlined( "You need to re-enter the vehicle in order for the changes to take effect!", "DSimfphysFont_hint", 300, 20, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER , 1,Color( 0, 0, 0, 255 ) ) 
	end
	
	local binders = {}
	binders[1] = createbinder(25,45,k_list,1,self.PropPanel,250, 40)
	binders[2] = createbinder(290,45,k_list,2,self.PropPanel,250, 40)
	binders[3] = createbinder(25,100,k_list,3,self.PropPanel,250, 40)
	binders[4] = createbinder(290,100,k_list,4,self.PropPanel,250, 40)
	binders[5] = createbinder(25,155,k_list,5,self.PropPanel,516, 40)	
	binders[6] = createbinder(25,235,k_list,6,self.PropPanel,250, 40)
	binders[7] = createbinder(25,290,k_list,7,self.PropPanel,250, 40)
	binders[8] = createbinder(290,290,k_list,8,self.PropPanel,250, 40)
	binders[9] = createbinder(290,235,k_list,9,self.PropPanel,250, 40)
	binders[10] = createbinder(25,345,k_list,10,self.PropPanel,516, 40)
	binders[11] = createbinder(25,455,k_list,11,self.PropPanel,516, 40)
	binders[12] = createbinder(25,510,k_list,12,self.PropPanel,516, 40)
	binders[13] = createbinder(25,565,k_list,13,self.PropPanel,516, 40)
	binders[14] = createbinder(25,400,k_list,14,self.PropPanel,516, 40)
	binders[15] = createbinder(290,645,k_list,15,self.PropPanel,250, 40)
	binders[16] = createbinder(25,645,k_list,16,self.PropPanel,250, 40)
	binders[17] = createbinder(25,700,k_list,17,self.PropPanel,250, 40)
	binders[18] = createbinder(290,700,k_list,18,self.PropPanel,250, 40)
	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( self.PropPanel )
	DermaButton:SetText( "Reset" )	
	DermaButton:SetPos( 25, 755 )
	DermaButton:SetSize( 516, 25 )
	DermaButton.DoClick = function()
		for i = 1, table.Count( binders ) do
			local kentry = k_list[i]
			local key = kentry[1]
			local default = kentry[2]
			
			key:SetInt( default )
			binders[i]:SetValue( default )
		end
	end
end

local function buildmsmenu( self )
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 20 )
	Shape:SetSize( 525, 180 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	
	local msitem_1 = createcheckbox(25,25,"Enable Mouse Steering","cl_simfphys_mousesteer",self.PropPanel,mousesteer:GetInt())
	local msitem_2 = createcheckbox(25,55,"Lock Pitch View","cl_simfphys_ms_lockpitch",self.PropPanel,mslockpitch:GetInt())
	local msitem_3 = createbinder(25,110,{{k_msfreelook,KEY_Y,"Unlock View"}},1,self.PropPanel,250, 40)
	
	local msitem_4 = createslider(290,20,255,40,"Deadzone","cl_simfphys_ms_deadzone",self.PropPanel,0,16,msdeadzone:GetFloat())
	local msitem_5 = createslider(290,55,255,40,"Exponent","cl_simfphys_ms_exponent",self.PropPanel,1,4,msexponent:GetFloat())
	local msitem_6 = createslider(290,90,255,40,"Sensitivity","cl_simfphys_ms_sensitivity",self.PropPanel,0.01,10,mssensitivity:GetFloat())
	local msitem_7 = createslider(290,125,255,40,"Return Speed","cl_simfphys_ms_return",self.PropPanel,0,10,msretract:GetFloat())
	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( self.PropPanel )
	DermaButton:SetText( "Reset" )	
	DermaButton:SetPos( 25, 170 )
	DermaButton:SetSize( 516, 25 )
	DermaButton.DoClick = function()
		msitem_1:SetValue( 0 )
		msitem_2:SetValue( 0 )
		msitem_3:SetValue( KEY_Y )
		msitem_4:SetValue( 4 )
		msitem_5:SetValue( 1.5 )
		msitem_6:SetValue( 1 )
		msitem_7:SetValue( 0 )
		mousesteer:SetInt( 0 )
		mssensitivity:SetInt( 1 )
		msretract:SetInt( 0 )
		msdeadzone:SetFloat( 4 )
		msexponent:SetFloat( 1.5 )
		mslockpitch:SetInt( 0 )
		k_msfreelook:SetInt( KEY_Y )
	end
end


hook.Add( "SimfphysPopulateVehicles", "AddEntityContent", function( pnlContent, tree, node )

	local Categorised = {}

	-- Add this list into the tormoil
	local Vehicles = list.Get( "simfphys_vehicles" )
	if ( Vehicles ) then
		for k, v in pairs( Vehicles ) do

			v.Category = v.Category or "Other"
			Categorised[ v.Category ] = Categorised[ v.Category ] or {}
			v.ClassName = k
			v.PrintName = v.Name
			table.insert( Categorised[ v.Category ], v )

		end
	end
	--
	-- Add a tree node for each category
	--
	for CategoryName, v in SortedPairs( Categorised ) do

		-- Add a node to the tree
		local node = tree:AddNode( CategoryName, "icon16/bricks.png" )
		
			-- When we click on the node - populate it using this function
		node.DoPopulate = function( self )
			
			-- If we've already populated it - forget it.
			if ( self.PropPanel ) then return end
			
			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )
			
			for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do
				
				spawnmenu.CreateContentIcon( "simfphys_vehicles", self.PropPanel, {
					nicename	= ent.PrintName or ent.ClassName,
					spawnname	= ent.ClassName,
					material	= "entities/"..ent.ClassName..".png",
					admin		= ent.AdminOnly
				} )
				
			end
			
		end
		
		-- If we click on the node populate it and switch to it.
		node.DoClick = function( self )
			
			self:DoPopulate()
			pnlContent:SwitchPanel( self.PropPanel )
			
		end

	end
	
	local node = tree:AddNode( "Controls", "icon16/keyboard.png" )
	node.DoPopulate = function( self )
		if ( self.PropPanel ) then return end
		
		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )

		buildcontrolsmenu( self )
	end
	node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end
	
	local node = tree:AddNode( "Mouse Steering", "icon16/mouse.png" )
	node.DoPopulate = function( self )
		if ( self.PropPanel ) then return end
		
		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )

		buildmsmenu( self )
	end
	node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end
	
	local node = tree:AddNode( "Client Settings", "icon16/wrench.png" )
	node.DoPopulate = function( self )
		if ( self.PropPanel ) then return end
		
		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )

		buildclientsettingsmenu( self )
	end
	node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end

	
	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if ( IsValid( FirstNode ) ) then
		FirstNode:InternalDoClick()
	end

end )

spawnmenu.AddCreationTab( "simfphys", function()

	local ctrl = vgui.Create( "SpawnmenuContentPanel" )
	ctrl:CallPopulateHook( "SimfphysPopulateVehicles" )
	return ctrl

end, "icon16/car.png", 50 )


spawnmenu.AddContentType( "simfphys_vehicles", function( container, obj )
	if ( !obj.material ) then return end
	if ( !obj.nicename ) then return end
	if ( !obj.spawnname ) then return end

	local icon = vgui.Create( "ContentIcon", container )
	icon:SetContentType( "simfphys_vehicles" )
	icon:SetSpawnName( obj.spawnname )
	icon:SetName( obj.nicename )
	icon:SetMaterial( obj.material )
	icon:SetAdminOnly( obj.admin )
	icon:SetColor( Color( 0, 0, 0, 255 ) )
	icon.DoClick = function()
		RunConsoleCommand( "simfphys_spawnvehicle", obj.spawnname )
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	end

	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon

end )

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
	local flywheelrpm = vehicle:GetFlyWheelRPM()
	local throttle = math.Round(vehicle:GetThrottle() * 100,0)
	local revlimiter = vehicle:GetRevlimiter() and (maxrpm > 2500) and (throttle > 0)
	local rpm = math.Round(((flywheelrpm >= maxrpm - 200) and revlimiter) and math.Round(flywheelrpm - 200 + math.sin(CurTime() * 50) * 200,0) or flywheelrpm,0)
	
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
		s_smoothrpm = math.Clamp(s_smoothrpm + (rpm - s_smoothrpm) * 0.15,0,maxrpm)
		
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
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawLine( x + c_ang * radius / 3.5, y + s_ang * radius / 3.5, x + c_ang * radius, y + s_ang * radius)
		
		draw.Arc(x,y,radius,radius / 6.66,startang,math.min(endang,ang_pend),1,Color(255,255,255,150),true)
		
		-- middle
		draw.Arc(x,y,radius / 3.5,radius / 66,startang,360,15,Color(255,255,255,50),true)
		
		-- outer
		draw.Arc(x,y,radius,radius / 6.66,startang,ang_pend,1,Color(150,150,150,50),true)
		draw.Arc(x,y,radius,radius / 6.66,ang_pend,360,1,Color(120,0,0,120),true)
		
		draw.Arc(x,y,radius,radius / 6.66,math.Round(ang_pend - 1,0),startang + (s_smoothrpm / maxrpm) * 255,1,Color(255,0,0,140),true)
		
		--inner
		draw.Arc(x,y,radius / 5,radius / 70,0,360,15,Color(0,254,235,200),true)
		
		draw.SimpleText( (gear == 1 and "R" or gear == 2 and "N" or (gear - 2)), "simfphysfont2", x * 0.999, y * 0.996, Color(0,254,235,200), 1, 1 )
		
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
	
	if (!vehicle.vehiclebase) then
		local parent = vehicle:GetParent()
		if (IsValid(parent)) then
			if (parent:GetClass() == "gmod_sent_vehicle_fphysics_base") then
				vehicle.vehiclebase = parent
			end
		end
	end
	local vehiclebase = vehicle.vehiclebase
	
	if (!IsValid(vehiclebase)) then return end
	
	local IsDriverSeat = vehicle == (vehiclebase:GetDriverSeat() or Entity(0))
	if (!IsDriverSeat) then return end
	
	drawsimfphysHUD(vehiclebase)
end
hook.Add( "HUDPaint", "simfphys_HUD", simfphysHUD)


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
