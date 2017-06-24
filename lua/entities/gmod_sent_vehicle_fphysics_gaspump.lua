AddCSLuaFile()

ENT.Type            = "anim"

ENT.PrintName	= "gas pump"
ENT.Author	= ""
ENT.Information = ""
ENT.Category	= "simfphys"

ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:SetupDataTables()
end

if CLIENT then 
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
	
	--[[
	local fueltype = vehicle:GetFuelType()
	local fueltype_color = Color(0,127,255,150)
	if fueltype == 1 then
		fueltype_color = Color(240,200,0,150)
	elseif fueltype == 2 then
		fueltype_color = Color(255,60,0,150)
	end
	]]--
	
	function ENT:Draw()
		self:DrawModel()
		local pos = self:LocalToWorld( Vector(10,0,45) )
		local ang = self:LocalToWorldAngles( Angle(0,90,90) )
		cam.Start3D2D( pos, ang, 0.1 )
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawTexturedRect( -150, -120, 300, 240 )
			
			draw.SimpleText( "***PETROL***", "simfphys_gaspump", 0, -75, Color(240,200,0,150), 1, 1 )
			draw.SimpleText( "***DIESEL***", "simfphys_gaspump", 0, -50, Color(255,60,0,150), 1, 1 )
			draw.SimpleText( "***ELECTRIC***", "simfphys_gaspump", 0, -25, Color(0,127,255,150), 1, 1 )
			draw.SimpleText( "please turn off the engine", "simfphys_gaspump", 0, 25, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( "ok", "simfphys_gaspump", 0, 50, Color( 255, 255, 255, 255 ), 1, 1 )
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
	
function ENT:Initialize()
	self:SetModel( "models/props_wasteland/gaspump001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	local PObj = self:GetPhysicsObject()
	
	if not IsValid( PObj ) then print("how the fuck did you break this man") return end
	
	PObj:EnableMotion( false )
end

function ENT:Think()	
	local ents = ents.FindInSphere( self:GetPos(), 150 ) 
	
	for k,v in pairs( ents ) do
		if simfphys.IsCar( v ) then
			if not v:EngineActive() then
				local Fuel = v:GetFuel()
				if Fuel < v:GetMaxFuel() then
					self:EmitSound( "vehicles/jetski/jetski_no_gas_start.wav" )
					v:SetFuel( Fuel + 5 )
				end
			end
		end
	end
	
	self:NextThink( CurTime() + 1 )
	
	return true
end

function ENT:OnRemove()
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:PhysicsCollide( data, physobj )
end