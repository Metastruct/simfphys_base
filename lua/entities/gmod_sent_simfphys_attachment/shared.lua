ENT.Type            = "anim"

ENT.PrintName = "Comedy Effect attachment"
ENT.Author = "Blu"
ENT.Information = ""
ENT.Category = "Fun + Games"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then return end

function ENT:Draw()
	self:DrawModel()
end


function ENT:DrawTranslucent()
	--self:Draw()
end

function ENT:Think()
	return false
end

