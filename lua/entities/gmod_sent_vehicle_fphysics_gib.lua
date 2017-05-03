AddCSLuaFile()

ENT.Type            = "anim"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

if SERVER then
	function ENT:Initialize()
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion(true)
		self:GetPhysicsObject():Wake()
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS ) 
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		
		self:SetMaterial( "models/player/player_chrome1" )
		self:SetColor( Color( 145 , 145, 145 , 255) )

		timer.Simple( 0.05, function()
			if not IsValid( self ) then return end
			if self.MakeSound == true then
				
				local Light = ents.Create( "light_dynamic" )
				Light:SetPos( self:GetPos() + Vector( 0, 0, 10 ) )
				local Lightpos = Light:GetPos() + Vector( 0, 0, 10 )
				Light:SetPos( Lightpos )
				Light:SetKeyValue( "_light", "220 40 0 255" )
				Light:SetKeyValue( "style", 1)
				Light:SetKeyValue( "distance", 255 )
				Light:SetKeyValue( "brightness", 2 )
				Light:SetParent( self )
				Light:Spawn()
				
				self.particleeffect = ents.Create( "info_particle_system" )
				self.particleeffect:SetKeyValue( "effect_name" , "fire_large_01")
				self.particleeffect:SetKeyValue( "start_active" , 1)
				self.particleeffect:SetOwner( self )
				self.particleeffect:SetPos( self:LocalToWorld( self:GetPhysicsObject():GetMassCenter() + Vector(0,0,15) ) )
				self.particleeffect:SetAngles( self:GetAngles() )
				self.particleeffect:Spawn()
				self.particleeffect:Activate()
				self.particleeffect:SetParent( self )
				
				Light:Fire( "TurnOn", "", "0" )
				
				timer.Simple( 120, function()
					if not IsValid(self) then return end
					if IsValid(Light) then
						Light:Remove()
					end
					if IsValid(self.particleeffect) then
						self.particleeffect:Remove()
					end
					if self.FireSound then
						self.FireSound:Stop()
					end
				end)
				
				local ran_n = math.Round(math.random(1,3),0)
				
				if (ran_n == 1) then
					sound.Play( Sound( "ambient/explosions/explode_3.wav" ), self:GetPos(), 160, 100, 1 )
				elseif (ran_n == 2) then
					sound.Play( Sound( "ambient/explosions/explode_8.wav" ), self:GetPos(), 160, 140, 1 )
				else
					sound.Play( Sound( "ambient/explosions/explode_5.wav" ), self:GetPos(), 160, 100, 1 )
				end
				
				self.FireSound = CreateSound(self, "ambient/fire/firebig.wav")
				self.FireSound:Play()
				
				local effectdata = EffectData()
					effectdata:SetOrigin( self:LocalToWorld( self:GetPhysicsObject():GetMassCenter() ) )
					effectdata:SetAngles( Angle(0,0,0) )
					effectdata:SetEntity( self )
					effectdata:SetFlags( 4 ) 
					util.Effect( "Explosion", effectdata, true, true )
					
				util.ScreenShake( self:GetPos(), 50, 50, 1.5, 700 )
				util.BlastDamage( self, Entity(0), self:GetPos(), 300,200 )
			else
				self.particleeffect = ents.Create( "info_particle_system" )
				self.particleeffect:SetKeyValue( "effect_name" , "fire_small_03")
				self.particleeffect:SetKeyValue( "start_active" , 1)
				self.particleeffect:SetOwner( self )
				self.particleeffect:SetPos( self:LocalToWorld( self:GetPhysicsObject():GetMassCenter() ) )
				self.particleeffect:SetAngles( self:GetAngles() )
				self.particleeffect:Spawn()
				self.particleeffect:Activate()
				self.particleeffect:SetParent( self )
				self.particleeffect:Fire( "Stop", "", math.random(0.5,3) )
			end
			
		end)
		
		self.RemoveDis = GetConVar("sv_simfphys_gib_lifetime"):GetFloat()
		self.RemoveTimer = CurTime() + self.RemoveDis
	end

	function ENT:Think()	
		if self.RemoveTimer < CurTime() then
			if self.RemoveDis > 0 then
				self:Remove()
			end
		end
		
		self:NextThink( CurTime() + 0.2 )
		return true
	end

	function ENT:OnRemove()
		if self.FireSound then
			self.FireSound:Stop()
		end
	end

	function ENT:OnTakeDamage( dmginfo )
		self:TakePhysicsDamage( dmginfo )
	end

	function ENT:PhysicsCollide( data, physobj )
	end
end