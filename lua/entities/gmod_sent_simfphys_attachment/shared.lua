ENT.Type            = "anim"

ENT.PrintName = "Comedy Effect attachment"
ENT.Author = "Blu"
ENT.Information = ""
ENT.Category = "Fun + Games"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar( "Bool",1, "DrawTranslucent" )
end

if (SERVER) then return end

function ENT:Draw()
	self:DrawModel()
end


function ENT:DrawTranslucent()
	if self:GetDrawTranslucent() then
		self:Draw()
	end
end

function ENT:Think()
	return false
end

