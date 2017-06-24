AddCSLuaFile()

SWEP.Category				= "simfphys"
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.ViewModel			= "models/weapons/v_slam.mdl"
SWEP.WorldModel			= "models/props_equipment/gas_pump_p13.mdl"
SWEP.UseHands				= false
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 10
SWEP.Weight 				= 42
SWEP.AutoSwitchTo 			= true
SWEP.AutoSwitchFrom 		= true
SWEP.HoldType				= "slam"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo		= "none"

if CLIENT then
	SWEP.PrintName		= "Fuel filler pistol"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 12
	SWEP.IconLetter			= "k"
	
	--SWEP.WepSelectIcon 			= surface.GetTextureID( "weapons/s_repair" ) 
	SWEP.DrawWeaponInfoBox 	= false
	
	SWEP.pViewModel = ClientsideModel("models/props_equipment/gas_pump_p13.mdl", RENDERGROUP_OPAQUE)
	SWEP.pViewModel:SetNoDraw( true )
	
	
	function SWEP:ViewModelDrawn()
		if IsValid( self.Owner ) then
			local vm = self.Owner:GetViewModel()
			
			local bm = vm:GetBoneMatrix(0)
			local pos =  bm:GetTranslation()
			local ang =  bm:GetAngles()	
			
			pos = pos + ang:Up() * 220
			pos = pos + ang:Right() * 2
			pos = pos + ang:Forward() * -12
			
			ang:RotateAroundAxis(ang:Forward(), -70)
			ang:RotateAroundAxis(ang:Right(), -20)
			ang:RotateAroundAxis(ang:Up(), -70)
			
			self.pViewModel:SetPos(pos)
			self.pViewModel:SetAngles(ang)
			self.pViewModel:DrawModel()
		end
	end
	
	function SWEP:DrawWorldModel()
		local id = self.Owner:LookupAttachment("anim_attachment_rh")
		local attachment = self.Owner:GetAttachment( id )
		
		if not attachment then return end

		local pos = attachment.Pos + attachment.Ang:Forward() * 6 + attachment.Ang:Right() * -1.5 + attachment.Ang:Up() * 2.2
		local ang = attachment.Ang
		ang:RotateAroundAxis(attachment.Ang:Up(), 20)
		ang:RotateAroundAxis(attachment.Ang:Right(), -30)
		ang:RotateAroundAxis(attachment.Ang:Forward(), 0)
		
		self:SetRenderOrigin( pos )
		self:SetRenderAngles( ang )
		
		self:DrawModel()	
	end
end

function SWEP:Initialize()
	self.Weapon:SetHoldType( self.HoldType )
end

function SWEP:OwnerChanged()
end

function SWEP:Think()
end

function SWEP:CanPrimaryAttack()
	self.NextFire = self.NextFire or 0
	
	if self.NextFire > CurTime() then
		return false
	end
	
	return true
end

function SWEP:SetNextPrimaryFire( time )
	self.NextFire = time
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	
	if not self:CanPrimaryAttack() then return end
	
	self:SetNextPrimaryFire( CurTime() + 1 )
	
	local Trace = self.Owner:GetEyeTrace()
	local ent = Trace.Entity
	
	if not IsValid( ent ) then return end
	if not simfphys.IsCar( ent ) then return end
	
	local Fuel = ent:GetFuel()
	local MaxFuel = ent:GetMaxFuel()
	
	if Fuel < MaxFuel then
		ent:SetFuel( Fuel + 5 )
		self.Owner:EmitSound( Sound( "vehicles/jetski/jetski_no_gas_start.wav" ) )
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return true
end

function SWEP:Holster()
	return true
end