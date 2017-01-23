AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetNotSolid( true )
	self.DoNotDuplicate = true
end

function ENT:Think()
	return false
end

function ENT:OnRemove()
end

