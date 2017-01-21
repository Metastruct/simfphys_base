ENT.Type            = "anim"

ENT.PrintName = "Simulated Wheel"
ENT.Author = "Blu"
ENT.Information = "memes"
ENT.Category = "Fun + Games"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false
ENT.DoNotDuplicate = true

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 1, "OnGround" )
	self:NetworkVar( "String", 2, "SurfaceMaterial" )
	self:NetworkVar( "Float", 3, "Speed" )
	self:NetworkVar( "Float", 4, "SkidSound" )
	self:NetworkVar( "Float", 5, "GripLoss" )
	self:NetworkVar( "Vector", 6, "SmokeColor" )
	self:NetworkVar( "Bool", 1, "Damaged" )
	
	if ( SERVER ) then
		self:NetworkVarNotify( "Damaged", self.OnDamaged )
	end
end
