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
local msretract = CreateClientConVar( "cl_simfphys_ms_return", "1", true, true )
local msdeadzone = CreateClientConVar( "cl_simfphys_ms_deadzone", "3", true, true )
local msexponent = CreateClientConVar( "cl_simfphys_ms_exponent", "1.5", true, true )
local mslockpitch = CreateClientConVar( "cl_simfphys_ms_lockpitch", "0", true, true )
local mshud = CreateClientConVar( "cl_simfphys_ms_hud", "1", true, false )
local k_msfreelook = CreateClientConVar( "cl_simfphys_ms_keyfreelook", KEY_Y, true, true )

CreateClientConVar( "cl_simfphys_hidesprites", "0", true, false )
CreateClientConVar( "cl_simfphys_spritedamage", "1", true, false )
CreateClientConVar( "cl_simfphys_frontlamps", "1", true, false )
CreateClientConVar( "cl_simfphys_rearlamps", "1", true, false )
CreateClientConVar( "cl_simfphys_shadows", "0", true, false )

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
local k_lock = CreateClientConVar( "cl_simfphys_key_lock", KEY_NONE, true, true )

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
	{k_cc,KEY_R,"Cruise Control"},
	{k_lgts,KEY_F,"Lights"},
	{k_flgts,KEY_V,"Foglights"},
	{k_horn,KEY_H,"Horn / Siren"},
	{k_engine,KEY_I,"Start/Stop Engine"},
	{k_afwd,KEY_PAD_8,"Tilt Backward"},
	{k_abck,KEY_PAD_2,"Tilt Forward"},
	{k_aleft,KEY_A,"Tilt Left"},
	{k_aright,KEY_D,"Tilt Right"},
	{k_lock,KEY_NONE ,"Lock / Unlock"},
}

local function simplebinder( x, y, tbl, num, parent)
	local sizex = 500
	local sizey = 40
	
	local kentry = tbl[num]
	local key = kentry[1]
	local setdefault = key:GetInt()
	
	local Shape = vgui.Create( "DShape", parent)
	Shape:SetType( "Rect" )
	Shape:SetPos( x, y )
	Shape:SetSize( 175, sizey )
	Shape:SetColor( Color( 0, 0, 0, 255 ) )
	
	local Shape = vgui.Create( "DShape", parent)
	Shape:SetType( "Rect" )
	Shape:SetPos( x + 1, y + 1 )
	Shape:SetSize( 173 - 2, sizey - 2 )
	Shape:SetColor( Color( 241, 241, 241, 255 ) )

	local binder = vgui.Create( "DBinder", parent)
	binder:SetPos( 175 + x, y )
	binder:SetSize( 500 - 175, sizey )
	binder:SetValue( setdefault )
	function binder:SetSelectedNumber( num )
		self.m_iSelectedNumber = num
		key:SetInt( num )
	end
	
	local TextLabel = vgui.Create( "DPanel", parent)
	TextLabel:SetPos( x, y )
	TextLabel:SetSize( 175, sizey )
	TextLabel.Paint = function()
		draw.SimpleText( kentry[3], "DSimfphysFont", 175 * 0.5, sizey * 0.5, Color( 100, 100, 100, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	end
	return binder
end

local function simplebinder_old( x, y, tbl, num, parent, sizex, sizey)
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
		draw.SimpleText( kentry[3], "DSimfphysFont", sizex * 0.25, 20, Color( 100, 100, 100, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
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
	Shape:SetSize( 350, 90 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	createcheckbox(25,25,"Show Hud","cl_simfphys_hud",self.PropPanel,hud:GetInt())
	createcheckbox(210,25,"Alternative Hud","cl_simfphys_althud",self.PropPanel,alt_hud:GetInt())
	createcheckbox(25,45,"MPH instead of KMH","cl_simfphys_hudmph",self.PropPanel,hud_mph:GetInt())
	createcheckbox(25,65,"Speed relative to \nplayersize instead \nworldsize","cl_simfphys_hudrealspeed",self.PropPanel,hud_realspeed:GetInt())
	
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 120 )
	Shape:SetSize( 350, 85 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	createcheckbox(25,125,"Hide Sprites","cl_simfphys_hidesprites",self.PropPanel,0)
	createcheckbox(210,125,"Allow light damaging","cl_simfphys_spritedamage",self.PropPanel,0)
	createcheckbox(25,145,"Front Projected Textures","cl_simfphys_frontlamps",self.PropPanel,0)
	createcheckbox(25,165,"Rear Projected Textures","cl_simfphys_rearlamps",self.PropPanel,0)
	createcheckbox(25,185,"Enable Shadows","cl_simfphys_shadows",self.PropPanel,0)
	
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 215 )
	Shape:SetSize( 350, 65 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	createcheckbox(25,220,"Always Fullthrottle","cl_simfphys_sanic",self.PropPanel,sanic:GetInt())
	createcheckbox(25,240,"Automatic Transmission","cl_simfphys_auto",self.PropPanel,auto:GetInt())
	createcheckbox(25,260,"Automatic Sportmode (late up and downshifts)","cl_simfphys_sport",self.PropPanel,sport:GetInt())
	
	local y = 290
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, y )
	Shape:SetSize( 350, 115 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	
	y = y + 5
	local ctitem_1 = createcheckbox(25,y,"Enable Countersteer","cl_simfphys_ctenable",self.PropPanel,ctenable:GetInt())
	y = y + 20
	local ctitem_2 = createslider(30,y,345,40,"Countersteer Mul","cl_simfphys_ctmul",self.PropPanel,0.1,2,ctmul:GetFloat())
	y = y + 20
	local ctitem_3 = createslider(30,y,345,40,"Countersteer MaxAng","cl_simfphys_ctang",self.PropPanel,1,90,ctang:GetFloat())
	
	y = y + 40
	local Reset = vgui.Create( "DButton" )
	Reset:SetParent( self.PropPanel )
	Reset:SetText( "Reset" )	
	Reset:SetPos( 25, y )
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
	local Background = vgui.Create( "DShape", self.PropPanel)
	Background:SetType( "Rect" )
	Background:SetPos( 20, 40 )
	Background:SetColor( Color( 0, 0, 0, 200 ) )
	
	local TextLabel = vgui.Create( "DPanel", self.PropPanel)
	TextLabel:SetPos( 0, 0 )
	TextLabel:SetSize( 600, 40 )
	TextLabel.Paint = function()
		draw.SimpleTextOutlined( "You need to re-enter the vehicle in order for the changes to take effect!", "DSimfphysFont_hint", 300, 20, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER , 1,Color( 0, 0, 0, 255 ) ) 
	end
	
	local yy = 45
	local binders = {}
	for i = 1, table.Count( k_list ) do
		binders[i] = simplebinder(25,yy,k_list,i,self.PropPanel)
		yy = yy + 45
	end
	
	local ResetButton = vgui.Create( "DButton" )
	ResetButton:SetParent( self.PropPanel )
	ResetButton:SetText( "Reset" )	
	ResetButton:SetPos( 25, yy + 10 )
	ResetButton:SetSize( 500, 25 )
	ResetButton.DoClick = function()
		for i = 1, table.Count( binders ) do
			local kentry = k_list[i]
			local key = kentry[1]
			local default = kentry[2]
			
			key:SetInt( default )
			binders[i]:SetValue( default )
		end
	end
	
	Background:SetSize( 510, yy )
end


local function buildmsmenu( self )
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 20 )
	Shape:SetSize( 350, 310 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	
	local msitem_1 = createcheckbox(25,25,"Enable Mouse Steering","cl_simfphys_mousesteer",self.PropPanel,mousesteer:GetInt())
	local msitem_2 = createcheckbox(25,55,"Lock Pitch View","cl_simfphys_ms_lockpitch",self.PropPanel,mslockpitch:GetInt())
	local msitem_8 = createcheckbox(25,85,"Show Hud","cl_simfphys_ms_hud",self.PropPanel,mshud:GetInt())
	
	local msitem_4 = createslider(30,110,345,40,"Deadzone","cl_simfphys_ms_deadzone",self.PropPanel,0,16,msdeadzone:GetFloat())
	local msitem_5 = createslider(30,140,345,40,"Exponent","cl_simfphys_ms_exponent",self.PropPanel,1,4,msexponent:GetFloat())
	local msitem_6 = createslider(30,170,345,40,"Sensitivity","cl_simfphys_ms_sensitivity",self.PropPanel,0.01,10,mssensitivity:GetFloat())
	local msitem_7 = createslider(30,200,345,40,"Return Speed","cl_simfphys_ms_return",self.PropPanel,0,10,msretract:GetFloat())
	
	local msitem_3 = simplebinder_old(25,240,{{k_msfreelook,KEY_Y,"Unlock View"}},1,self.PropPanel,340, 40)
	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( self.PropPanel )
	DermaButton:SetText( "Reset" )	
	DermaButton:SetPos( 25, 300 )
	DermaButton:SetSize( 340, 25 )
	DermaButton.DoClick = function()
		msitem_1:SetValue( 0 )
		msitem_2:SetValue( 0 )
		msitem_3:SetValue( KEY_Y )
		msitem_4:SetValue( 3 )
		msitem_5:SetValue( 1.5 )
		msitem_6:SetValue( 1 )
		msitem_7:SetValue( 1 )
		msitem_8:SetValue( 1 )
		
		mshud:SetInt( 1 )
		mousesteer:SetInt( 0 )
		mssensitivity:SetInt( 1 )
		msretract:SetInt( 1 )
		msdeadzone:SetFloat( 3 )
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
	
	-- KEYBOARD
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
	
	-- MOUSE STEERING
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
	
	-- CLIENT SETTINGS
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
	
	-- SERVER SETTINGS
	--[[
	local node = tree:AddNode( "Server Settings", "icon16/wrench_orange.png" )
	node.DoPopulate = function( self )
		if ( self.PropPanel ) then return end
		
		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )

		--buildclientsettingsmenu( self )
	end
	node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end
	]]--

	
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
	icon.OpenMenu = function( icon )

		local menu = DermaMenu()
			menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
			--menu:AddSpacer()
			--menu:AddOption( "Delete", function() icon:Remove() hook.Run( "SpawnlistContentChanged", icon ) end )
		menu:Open()

	end
	
	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon

end )