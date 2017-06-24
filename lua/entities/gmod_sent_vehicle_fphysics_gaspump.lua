AddCSLuaFile()

ENT.Type            = "anim"

ENT.PrintName	= "gas pump"
ENT.Author	= ""
ENT.Information = ""
ENT.Category	= "simfphys"

ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "User" )
	self:NetworkVar( "Bool",0, "Active" )
	
	if SERVER then
		self:NetworkVarNotify( "Active", self.OnActiveChanged )
	end
end

local function bezier(p0, p1, p2, p3, t)
	local e = p0 + t * (p1 - p0)
	local f = p1 + t * (p2 - p1)
	local g = p2 + t * (p3 - p2)

	local h = e + t * (f - e)
	local i = f + t * (g - f)

	local p = h + t * (i - h)

	return p
end

if CLIENT then 
	local cable = Material( "cable/cable2" )
	
	surface.CreateFont( "simfphys_gaspump", {
		font = "Verdana",
		extended = false,
		size = 22,
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
	
	function ENT:Draw()
		self:DrawModel()
		
		local pos = self:LocalToWorld( Vector(10,0,45) )
		local ang = self:LocalToWorldAngles( Angle(0,90,90) )
		local ply = self:GetUser()
		
		local startPos = self:LocalToWorld( Vector(0.06,-17.77,55.48) )
		local p2 = self:LocalToWorld( Vector(8,-17.77,30) )
		local p3 = self:LocalToWorld( Vector(0,-20,30) )
		local endPos = self:LocalToWorld( Vector(0.06,-20.3,37) )
		
		if IsValid( ply ) then
			local id = ply:LookupAttachment("anim_attachment_rh")
			local attachment = ply:GetAttachment( id )
			
			if not attachment then return end
			
			endPos = (attachment.Pos + attachment.Ang:Forward() * -3 + attachment.Ang:Right() * 2 + attachment.Ang:Up() * -3.5)
			p3 = endPos + attachment.Ang:Right() * 20 - attachment.Ang:Up() * 20
		end
		
		for i = 1,15 do
			local active = IsValid( ply )
			
			local de = active and 1 or 2
			
			if (not active and i > 1) or active then
			
				local sp = bezier(startPos, p2, p3, endPos, (i - de) / 15)
				local ep = bezier(startPos, p2, p3, endPos, i / 15)
				
				render.SetMaterial( cable )
				render.DrawBeam( sp, ep, 2, 1, 1, Color( 100, 100, 100, 255 ) ) 
			end
		end
		
		cam.Start3D2D( self:LocalToWorld( Vector(10,0,45) ), self:LocalToWorldAngles( Angle(0,90,90) ), 0.1 )
			draw.NoTexture()
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawTexturedRect( -150, -120, 300, 240 )
			
			draw.SimpleText( "***PETROL***", "simfphys_gaspump", 0, -75, Color(240,200,0,150), 1, 1 )
			draw.SimpleText( "***DIESEL***", "simfphys_gaspump", 0, -50, Color(255,60,0,150), 1, 1 )
			draw.SimpleText( "***ELECTRIC***", "simfphys_gaspump", 0, -25, Color(0,127,255,150), 1, 1 )
			
			draw.SimpleText( "Pump Status:", "simfphys_gaspump", 0, 25, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( (self:GetActive() and ("in use by "..self:GetUser():GetName()) or "Off"), "simfphys_gaspump", 0, 50, Color( 255, 255, 255, 255 ), 1, 1 )
		cam.End3D2D()
	end
	return
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal )
	ent:SetAngles( Angle(0,ply:EyeAngles().y + 180,0) )
	ent:Spawn()
	ent:Activate()

	return ent

end
	
function ENT:Use( ply )
	if not self:GetActive() then
		self:SetActive( true )
		self:SetUser( ply )
		ply:Give( "weapon_simfillerpistol" )
		ply:SelectWeapon( "weapon_simfillerpistol" )
	else
		if ply == self:GetUser() then
			ply:StripWeapon( "weapon_simfillerpistol" ) 
			self:SetActive( false )
			self:SetUser( NULL )
		end
	end
end

function ENT:OnActiveChanged( name, old, new)
	if new == old then return end
	
	if new then
		if self.sound then
			self.sound:Stop()
			self.sound = nil
		end
		self.sound = CreateSound(self, "vehicles/crane/crane_idle_loop3.wav")
		self.sound:PlayEx(0,0)
		self.sound:ChangeVolume( 1,2 )
		self.sound:ChangePitch( 255,3 )
		if IsValid( self.PumpEnt ) then
			self.PumpEnt:SetNoDraw( true )
		end
	else
		if IsValid( self.PumpEnt ) then
			self.PumpEnt:SetNoDraw( false )
		end
		
		if self.sound then
			self.sound:ChangeVolume( 0,2 )
			self.sound:ChangePitch( 0,3 )
		end
	end
end
	
function ENT:Initialize()
	self:SetModel( "models/props_wasteland/gaspump001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetUseType( SIMPLE_USE )
	
	self.PumpEnt = ents.Create( "prop_physics" )
	self.PumpEnt:SetModel( "models/props_equipment/gas_pump_p13.mdl" )
	self.PumpEnt:SetPos( self:LocalToWorld( Vector(-0.2,-14.6,45.7)  ) )
	self.PumpEnt:SetAngles( self:LocalToWorldAngles( Angle(-0.3,92.3,-0.1) ) )
	self.PumpEnt:SetMoveType( MOVETYPE_NONE )
	self.PumpEnt:SetSolid( SOLID_NONE )
	self.PumpEnt:Spawn()
	self.PumpEnt:Activate()
	self.PumpEnt:SetParent( self )
	
	local PObj = self:GetPhysicsObject()
	if not IsValid( PObj ) then return end
	
	PObj:EnableMotion( false )
end

function ENT:Think()	
	self:NextThink( CurTime() + 0.5 )
	
	local ply = self:GetUser()
	if IsValid( ply ) then
		local Dist = (ply:GetPos() - self:GetPos()):Length()
		
		if ply:Alive() then
			if ply:InVehicle() then
				if ply:HasWeapon( "weapon_simfillerpistol" ) then
					ply:StripWeapon( "weapon_simfillerpistol" ) 
				end
				self:Disable()
			else
				if ply:HasWeapon( "weapon_simfillerpistol" ) then
					if ply:GetActiveWeapon():GetClass() ~= "weapon_simfillerpistol" or Dist >= 200 then
						ply:StripWeapon( "weapon_simfillerpistol" ) 
						self:Disable()
					end
				else
					self:Disable()
				end
			end
		else
			self:Disable()
		end
	end
	
	return true
end

function ENT:Disable()
	self:SetUser( NULL )
	self:SetActive( false )
end

function ENT:OnRemove()
	if self.sound then
		self.sound:Stop()
	end
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:PhysicsCollide( data, physobj )
end