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

if CLIENT then return end

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
			local Fuel = v:GetFuel()
			if Fuel < v:GetMaxFuel() then
				self:EmitSound( "vehicles/jetski/jetski_no_gas_start.wav" )
				v:SetFuel( Fuel + 5 )
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