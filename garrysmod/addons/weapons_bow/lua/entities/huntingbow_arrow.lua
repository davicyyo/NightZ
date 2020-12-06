AddCSLuaFile()

ENT.Type      = "anim"
ENT.Spawnable = false

ENT.Model = "models/weapons/w_huntingbow_arrow.mdl"

local ARROW_MINS = Vector(-0.25, -0.25, 0.25)
local ARROW_MAXS = Vector(0.25, 0.25, 0.25)

function ENT:Initialize()
	if SERVER then
		self:SetModel(self.Model)

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_FLYGRAVITY)
		self:SetSolid(SOLID_BBOX)
		self:DrawShadow(true)

		self:SetCollisionBounds(ARROW_MINS, ARROW_MAXS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
	end
end

local taked = false
function ENT:Think()
	if SERVER then
		if self:GetMoveType() == MOVETYPE_FLYGRAVITY then
			self:SetAngles(self:GetVelocity():Angle())
		end


			hook.Add("KeyPress","yeahboii",function(ply,key)
				if (key == IN_USE) then

					for k,v in pairs(ents.FindByClass("huntingbow_arrow")) do
						if ply:GetPos():Distance(v:GetPos()) < 160 then

							
							v:Remove()
							ply:SetAmmo(ply:GetAmmoCount("huntingbow_arrows") + 1,"huntingbow_arrows")
						end
					end

					for k,v in pairs(ents.GetAll()) do
						if v:IsNPC() or v:IsPlayer() then
							if !IsValid(v) or !IsValid(self.Owner) then return end
							if v:GetNWEntity("attacker") == self.Owner then
								if v:GetNWInt("arrows") != 0 then
									v:SetNWInt("arrows",v:GetNWInt("arrows") - 1)
								end
							end
						end
					end


				end
			end)

	end
end

function ENT:Use(activator, caller)
	return false
end

function ENT:OnRemove()
	return false
end

local StickSound = {
	"weapons/huntingbow/impact_arrow_stick_1.wav",
	"weapons/huntingbow/impact_arrow_stick_2.wav",
	"weapons/huntingbow/impact_arrow_stick_3.wav"
}

local FleshSound = {
	"weapons/huntingbow/impact_arrow_flesh_1.wav",
	"weapons/huntingbow/impact_arrow_flesh_2.wav",
	"weapons/huntingbow/impact_arrow_flesh_3.wav",
	"weapons/huntingbow/impact_arrow_flesh_4.wav"
}

local count = 0
local called = false
function ENT:Touch(ent)
	local vel   = self:GetVelocity()
	local speed = vel:Length()

	local tr = self:GetTouchTrace()
	local tr2

	if tr.Hit then
		local damage = math.floor(math.Clamp(speed / 25, 0, 100))

		self:FireBullets {
			Damage = damage,
			Attacker = self.Owner,
			Inflictor = self.Weapon,
			Callback = function(attacker, tr, damageinfo) tr2 = tr end,
			Force = damage * 0.1,
			Tracer = 0,
			Src = tr.StartPos,
			Dir = tr.Normal,
			AmmoType = "huntingbow_arrows"
		}
	end

	if ent:IsWorld() then
		sound.Play(table.Random(StickSound), tr.HitPos)

		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_NONE)
		return
	end

	if ent:IsValid() then
		if ent:GetClass() == "zombie" or ent:IsPlayer() then
			if tr2.Entity == ent then sound.Play(table.Random(FleshSound), tr.HitPos) end

			timer.Create("RemoveCount",1,0,function()
				if !IsValid(ent) then count = 0 end
			end)

			if ent:Health() <= 0 then
				called = true
				for _,entity in pairs(ents.FindByClass("prop_ragdoll")) do
					if entity:GetNWEntity("entity") == ent then
					local bone = entity:LookupBone( "ValveBiped.Bip01_Head1" )
					self:SetParent(entity)
					self:SetMoveType(MOVETYPE_NONE)
					self:SetSolid(SOLID_NONE)
					self:SetPos(entity:GetPos() + Vector(0,math.random(0,40),5))

					for i=1,ent:GetNWInt("arrows") do
						local arrow = ents.Create("huntingbow_arrow")
						arrow:SetParent(entity)
						arrow:SetPos(entity:GetPos() + Vector(0,math.random(0,40),80))
						arrow:Spawn()
					end

					count = 0

					ent:SetNWInt("arrows",0)
					ent:SetNWEntity("attacker",nil)

					end

				end

			else
				if !IsValid(ent) then return end
				self:SetParent(ent)
				self:SetMoveType(MOVETYPE_NONE)
				self:SetSolid(SOLID_NONE)
				count = count + 1

				ent:SetNWInt("arrows",count)
				ent:SetNWEntity("attacker",self.Owner)
			end

		else
			self:SetParent(ent)
			sound.Play(table.Random(StickSound), tr.HitPos)

			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolid(SOLID_NONE)
		end
	end
end

function ENT:PhysicsCollide(data, physobj)

end