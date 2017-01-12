local BaseHealth = 1000
local DamageEnabled = false
cvars.AddChangeCallback( "sv_simfphys_enabledamage", function( convar, oldValue, newValue )
	DamageEnabled = ( tonumber( newValue )~=0 )
end)
DamageEnabled = GetConVar( "sv_simfphys_enabledamage" ):GetBool()

local function Spark( pos , normal, speed )
	local effectdata = EffectData()
	effectdata:SetOrigin( pos - normal )
	effectdata:SetNormal( -normal )
	util.Effect( "stunstickimpact", effectdata, true, true )
end

local function BloodEffect( pos )
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "BloodImpact", effectdata, true, true )
end

local function DamageVehicle( ent , damage )
	if !DamageEnabled then return end
	
	--local MaxHealth = ent:GetNWFloat( "MaxHealth", 0 )
	local CurHealth = ent:GetNWFloat( "Health", 0 )
	
	
	ent:SetNWFloat( "Health", math.max( math.Round(CurHealth - damage,0) , 0 ) )
end

local function HurtPlayers( ent, damage )
	local Driver = ent:GetDriver()
	
	if IsValid(Driver) then
		Driver:TakeDamage(damage, Entity(0), ent )
	end
	
	if ent.PassengerSeats then
		for i = 1, table.Count( ent.PassengerSeats ) do
			local Passenger = ent.pSeat[i]:GetDriver()
			
			if IsValid(Passenger) then
				Passenger:TakeDamage(damage, Entity(0), ent )
			end
		end
	end
end

local function onColide( ent, data )
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then
		if (data.Speed > 1000) then
			ent:EmitSound( "MetalVehicle.ImpactHard" )
			Spark( data.HitPos , data.HitNormal , data.Speed )
			
			HurtPlayers( ent , 5 )
			
			DamageVehicle( ent , data.Speed / 8 )
		else
			ent:EmitSound( "MetalVehicle.ImpactSoft" )
			Spark( data.HitPos , data.HitNormal , data.Speed )
			
			if (data.Speed > 700) then
				HurtPlayers( ent , 2 )
			end
		end
	end
end

local function OnDamage( ent, dmginfo )
	ent:TakePhysicsDamage( dmginfo )
	
	if (ent.EnableSuspension != 1) then return end
	
	local Damage = dmginfo:GetDamage() 
	local DamagePos = dmginfo:GetDamagePosition() 
	local Type = dmginfo:GetDamageType()
	local Driver = ent:GetDriver()
	
	DamageVehicle( ent , Damage * ((Type == DMG_BLAST) and 10 or 2.5) )
	
	if IsValid(Driver) then
		local Distance = (DamagePos - Driver:GetPos()):Length() 
		if (Distance < 70) then
			local Damage = (70 - Distance) / 22
			dmginfo:ScaleDamage( Damage )
			Driver:TakeDamageInfo( dmginfo )
			BloodEffect( DamagePos )
		end
	end
	
	if ent.PassengerSeats then
		for i = 1, table.Count( ent.PassengerSeats ) do
			local Passenger = ent.pSeat[i]:GetDriver()
			
			if IsValid(Passenger) then
				local Distance = (DamagePos - Passenger:GetPos()):Length()
				local Damage = (70 - Distance) / 22
				if (Distance < 70) then
					dmginfo:ScaleDamage( Damage )
					Passenger:TakeDamageInfo( dmginfo )
					BloodEffect( DamagePos )
				end
			end
		end
	end
end

hook.Add( "OnEntityCreated", "memes", function( ent )
	if ent:GetClass() == "gmod_sent_vehicle_fphysics_base" then
		timer.Simple( 0.5, function()
			if !IsValid(ent) then return end
			
			local Health = ent.MaxHealth and ent.MaxHealth or BaseHealth + ent:GetPhysicsObject():GetMass() / 3
			
			ent:SetNWFloat( "MaxHealth", Health )
			ent:SetNWFloat( "Health", Health )
			
			ent.PhysicsCollide = onColide
			ent.OnTakeDamage = OnDamage
		end)
	end
end)