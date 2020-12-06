AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true

local quantity = {"01","02","03","04","05","06","07","08","09","10","11","12"}

local bool = false
function ENT:isSpawned(boolean)
	if !boolean then
		return bool
	end

	bool = boolean

end

function ENT:Initialize()

	bool = false

	local mdl = "models/zombie/zclassic_"..table.Random(quantity)..".mdl"

	self:SetModel( mdl )

	self:SetNWBool("headshot",false)
	self:SetHealth(100)

	/*local q = 29
	--50
	timer.Create("pene",1,#self:GetSequenceList(),function()
		self:ResetSequence(self:GetSequenceList()[q])
		print(q)
		if q == 29 then q = 50 else q = 29 end
	end)*/

	local phase = 0

	self:ResetSequence(self:GetSequenceList()[27])

	timer.Create("phases",1,3,function()
		if !IsValid(self) then return end
		if phase == 1 then
			self:ResetSequence(self:GetSequenceList()[28])
		elseif phase == 2 then
			self:isSpawned(true)
		end
		phase = phase + 1
	end)

end

function ENT:OnInjured( info )

	self:EmitSound("zmale/pain"..math.random(1,6)..".wav",60,100,1,CHAN_VOICE)
	
	local bone = self:LookupBone( "ValveBiped.Bip01_Head1" )

	if self:GetBonePosition(bone):Distance(info:GetDamagePosition()) < 10 then
		info:SetDamage(9999999)
	else
		info:SetDamage(0)
	end

end

function ENT:OnKilled(info)

	local mdl = self:GetModel()

	local ply = info:GetAttacker()

	local tb = {id = ply:SteamID64()}

	local json = util.TableToJSON(tb)

	hook.Run("db.get","stats","zombieKills",json,function(result)
		hook.Run("db.update","stats","zombieKills",result + 1,json)
	end)

	self:EmitSound("zmale/die"..math.random(1,8)..".wav",60,100,1,CHAN_VOICE)

	if SERVER then
			local body = ents.Create( "prop_ragdoll" )
			body:SetPos( self:GetPos() )
			body:SetAngles(self:GetAngles())
			body:SetModel( mdl )
			body:SetNWEntity("entity",self)
			body:SetNWBool("zombie",true)
			timer.Simple(0.1,function()
				body:SetModel( mdl )
			end)
			body:SetVelocity(self:GetVelocity())
			body:Spawn()

			if info:GetInflictor():GetClass() != "weapon_huntingbow" then
				if self:GetNWInt("arrows") != 0 then
					for i=1,self:GetNWInt("arrows") do
						local arrow = ents.Create("huntingbow_arrow")
						arrow:SetParent(body)
						arrow:SetPos(body:GetPos() + Vector(0,math.random(0,40),80))
						arrow:Spawn()
					end
					self:SetNWInt("arrows",0)
					self:SetNWEntity("attacker",nil)
				end
			end

			self:Remove()
	end

end

function ENT:SetEnemy( ent )
	self.Enemy = ent
end

function ENT:GetEnemy()
	return self.Enemy
end

if SERVER then
	local close = false
	local delay = false

	local bl = false
	function ENT:isRagdollAttack(boolean)
		if !IsValid(self) then return end
		if !boolean then
			return bl
		end

		bl = boolean
	end
end

local close,delay,call = false,false,0
function ENT:checkDistance()
	local enemy = self:GetEnemy()

	if !IsValid(enemy) or !IsValid(self) or enemy == nil then return end

	if enemy:IsPlayer() && enemy:Alive() then
		if enemy:GetPos():Distance(self:GetPos()) < 80 then
			if close then return end
				close = true
		self:ResetSequence(self:GetSequenceList()[51])
		self:EmitSound("zmale/alert"..math.random(1,8)..".wav",60,100,1,CHAN_VOICE)
		timer.Simple(0.5,function()
			if !IsValid(enemy) or !IsValid(self) then return end
			if enemy:GetPos():Distance(self:GetPos()) < 80 then
				enemy:TakeDamage(40,self)
				enemy:ViewPunch(Angle( -30, 0, 0 ))
				enemy:update("player","infected",1)
			end
		end)

		timer.Simple(2,function() close = false if !IsValid(self) then return end self:ResetSequence(self:GetSequenceList()[5]) end)
		end
		return
	end


	if enemy:GetClass() == "prop_ragdoll" then
		if enemy:GetPos():Distance(self:GetPos()) < 30 then
			if delay == false then
				delay = true
				timer.Create("timerThink",1,20,function()
					if !IsValid(enemy) then self:SetEnemy(nil) return end
					call = call + 1

					if call == 20 then
						self:SetEnemy(nil)
						enemy:Remove()
						return
					end

					if !IsValid(self) then timer.Remove("timerThink") return end
					self:isRagdollAttack(true)
					self.loco:SetDesiredSpeed( 0 )
					self:ResetSequence(self:GetSequenceList()[31])
					if !IsValid(enemy) then return end
					local vPoint = enemy:GetPos()
					local effectdata = EffectData()
					effectdata:SetOrigin( vPoint )
					effectdata:SetColor(255,0,0)
					util.Effect( "BloodImpact", effectdata )
				end)
			end
		end
	end

end

function ENT:FindEnemy()
	local ent = ents.FindInSphere(self:GetPos(),500)

	for k,v in pairs(ent) do
		if v:IsPlayer() && v:Alive() then
			self:SetEnemy(v)
			return
		end

		if v:GetClass() == "prop_ragdoll" then
			if v:GetNWBool("zombie") then return end
			self:SetEnemy(v)
			return
		end

		self.loco:SetDesiredSpeed( 40 )

	end

end

function ENT:RunBehaviour()
        while ( true ) do

        	if self:isSpawned() then

        		if self:GetEnemy() != nil then
        			print(self:GetEnemy())
        			self:checkDistance()
        			self:ChaseEnemy()
        		else
        			self:FindEnemy()
        			self:StartActivity( ACT_WALK )
					self.loco:SetDesiredSpeed( 40 )
					self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 )
        		end
        	end

		coroutine.yield()

	end

end

function ENT:ChaseEnemy( options )
	if self:isSpawned() then

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	if !IsValid(self) or !IsValid(self:GetEnemy()) then self:SetEnemy(nil) return end
	path:Compute( self, self:GetEnemy():GetPos() )

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self:GetEnemy() != nil ) do

		if ( path:GetAge() > 0.1 ) then
			if !IsValid(self) or !IsValid(self:GetEnemy()) then self:SetEnemy(nil) return end
			path:Compute( self, self:GetEnemy():GetPos() )
			self:checkDistance()
		end
		path:Update( self )

		if ( options.draw ) then path:Draw() end
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end

	return "ok"

	end

end