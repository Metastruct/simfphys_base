ENT.Type            = "anim"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false
ENT.DoNotDuplicate = true

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 1, "OnGround" )
	self:NetworkVar( "String", 2, "SurfaceMaterial" )
	self:NetworkVar( "Float", 3, "Speed" )
	self:NetworkVar( "Float", 4, "SkidSound" )
	self:NetworkVar( "Float", 5, "GripLoss" )
	self:NetworkVar( "Bool", 1, "Damaged" )
	self:NetworkVar( "Entity", 1, "BaseEnt" )
	
	if ( SERVER ) then
		self:NetworkVarNotify( "Damaged", self.OnDamaged )
	end
end
