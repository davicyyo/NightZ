AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

local nets = {
	"nightz:weapons:bow",
	"nightz:deathscreen",
	"changeCamera",
	"removeCamera",
	"nightz:hurt",
	"sendnotify",
	"sendSound",
}

for _,n in pairs(nets) do
	util.AddNetworkString(n)
end

local files = {
	"resource/fonts/HeadlinerNo.45 DEMO.ttf",
	"materials/nightz_walk.png",
	"materials/nightz_run.png",
	"materials/nightz_jump.png",
	"materials/nightz_crouch.png",
	"materials/nightz_melee.png",
	"materials/nightz_bow.png",
	"materials/nightz_infected.png",
	"materials/nightz_bone.png",
	"materials/nightz_bleeding.png",
	"materials/nightz_logo.png",
	"sound/nightz_notify.wav",
	"sound/nightz_heart.wav",
	"sound/nightz_death.wav",
	"sound/nightz_hunger.wav",
	"sound/nightz_thirst.wav",
}

for _,f in pairs(files) do
	resource.AddFile(f)
end

------[Reading Modules]------
		local files = file.Find( "gamemodes/nightz/gamemode/modules/*", "GAME" )
		for _,v in pairs(files) do
			MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Loaded "..v.."\n" )
			AddCSLuaFile("modules/"..v)
			include("modules/"..v)
		end
------[Reading Modules]------

local workshopFiles = {
"https://steamcommunity.com/sharedfiles/filedetails/?id=1323286207",	-- Bow
"https://steamcommunity.com/sharedfiles/filedetails/?id=152529683",	-- Zombie
}

for _,w in pairs(workshopFiles) do
	resource.AddWorkshop(string.Replace(w,"https://steamcommunity.com/sharedfiles/filedetails/?id=",""))
end

local allowed = {
	["76561197997048047"] = true, -- DaViCyYo
	["76561198132457102"] = true, -- Stremo
	["76561198119475814"] = true, -- Rudy [Tester]
	["76561198017769961"] = true, -- Chicho
	["76561198176726751"] = true, -- Peter
	["76561198291569465"] = true,  -- Samuel
}

hook.Add( "CheckPassword", "access_whitelist", function( steamID64 )
	local val = {id = steamID64}
	local json = util.TableToJSON(val)

	hook.Run("db.insert","playerslist",json)

	if not allowed[steamID64] then
		print("Not Allowed "..steamID64)
		return false, "This game mode is being created!, please visit https://www.nodes.headarrow.com/nightz"
	end

end )

function GM:PlayerCanPickupWeapon( ply, wep )

	if ply:HasWeapon(wep:GetClass()) then return false end

	timer.Simple(0.1,function()
		ply:SelectWeapon(wep:GetClass())
		ply:SetAmmo(wep:GetNWInt("ammo"),wep:GetPrimaryAmmoType())
	end)
	
	return true
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	if ( hitgroup == HITGROUP_HEAD ) then
		print("headshot")
		dmginfo:ScaleDamage( 9999999999999999999 )
		ply:SetPData("headshot",true)
	else
		ply:SetPData("headshot",false)
	end
end

function GM:PlayerConnect( name, ip )
	
	for _,v in pairs(player.GetAll()) do
		v:sendNotify(name.." Se ha conectado",5)
	end

end

net.Receive("nightz:hurt",function()
	local ply = net.ReadEntity()

	ply:TakeDamage( 10, ply, ply )

end)

function GM:GetFallDamage( ply, speed )
	return ( speed / 20 )
end

function GM:PlayerDeathSound()
	return true
end

local tb,json,solution
local delay = 0
local hp,armor
function GM:Think()

	if CurTime() < delay then return end

	for _,ply in pairs(player.GetAll()) do

		if !IsValid(ply) or ply:IsBot() then return end

		if !ply.hp then
			ply.hp = ply:Health()
		end
		if !ply.armor then
			ply.armor = ply:Armor()
		end


		-- update HP
		if ply:Health() != ply.hp then
			if !IsValid(ply) then return end
			ply:update("basic","hp",ply:Health())
			ply.hp = ply:Health()
		end

		-- update Armor
		if ply:Armor() != ply.armor then
			if !IsValid(ply) then return end
			ply:update("basic","armor",ply:Armor())
			ply.armor = ply:Armor()
		end

		-- update Pos
		ply:get("player","pos",function(result)
			local tb = util.JSONToTable(result)
			for _,pos in pairs(tb) do
				if !IsValid(ply) then return end
				if string.Left(tostring(ply:GetPos()),4) != string.Left(tostring(pos),4) then
					local tb = {ply:GetPos()}
					local json = util.TableToJSON(tb)
					ply:update("player","pos",json)
				end
			end
		end)

		-- update Ang
		ply:get("player","ang",function(result)
			if !IsValid(ply) then return end
				if string.Left(tostring(ply:GetAngles().y),3) != string.Left(tostring(result),3) then
					ply:update("player","ang",ply:GetAngles().y)
				end
		end)


	end

	delay = CurTime() + 1

end

hook.Add("ULibPlayerBanned","checkerUlib",function(steamid,data)

	local tb = {
	id = util.SteamIDTo64(steamid),
	[2] = data.reason,
	[3] = data.time,
	}
	local json = util.TableToJSON(tb)

	hook.Run("db.insert","banlist",json)
	timer.Simple(2,function()
	local db = {id = util.SteamIDTo64(steamid)}
	local js = util.TableToJSON(db)
	hook.Run("db.delete","player",js)
	hook.Run("db.delete","basic",js)
	hook.Run("db.delete","stats",js)
	end)

end)

hook.Add("ULibPlayerUnBanned","unbannedUlib",function(steamid,admin)

	local tb = {id = util.SteamIDTo64(steamid)}
	local json = util.TableToJSON(tb)

	hook.Run("db.delete","banlist",json)

end)

-- SISTEMA DE CUERPOS
function GM:KeyPress(ply,key)
	if (key == IN_USE) then
		local trace = ply:GetEyeTrace()
		local ent = trace.Entity

		if ent:GetClass() == "prop_ragdoll" && !ent:GetNWBool("zombie") then
			local ExtraModels = ents.Create("prop_ragdoll")
			ExtraModels:SetPos(ply:GetPos())
			ExtraModels:SetParent(ply)
			ExtraModels:SetModel(ent:GetModel())
			ExtraModels:SetMoveType(MOVETYPE_NONE)
			ExtraModels:SetSolid(SOLID_BBOX)
			ExtraModels:Spawn()
			ent:Remove()
		end

	end

	if (key == IN_RELOAD) then

		local pos = ply:GetPos()

		if ply:GetActiveWeapon():GetClass() == "weapon_hl2shovel" then
			ply:SetEyeAngles( Angle(180,0,0) )
			net.Start("changeCamera")
			net.Send(ply)
			timer.Create("attack",1,0,function()
				if pos != ply:GetPos() then
					ply:ConCommand("-attack")
					timer.Remove("attack")
					net.Start("removeCamera")
					net.Send(ply)
				return end
				local tr = ply:GetEyeTrace()
				local Pos1 = tr.HitPos + tr.HitNormal
				local Pos2 = tr.HitPos - tr.HitNormal
				util.Decal("BeerSplash", Pos1, Pos2)
				ply:ConCommand("+attack")
			end)
		end

	end

end

function GM:EntityTakeDamage( target, dmginfo )

	if target:GetClass() == "prop_ragdoll" then

		if target:GetNWBool("zombie") then return end

		local bone = target:LookupBone( "ValveBiped.Bip01_Head1" )
		
		if target:GetBonePosition(bone):Distance(dmginfo:GetDamagePosition()) < 10 then
				if !target or !target:GetOwner() then return end

				if target:GetNWString("owner") != nil then
					local tb = {id = target:GetNWString("owner")}
					local json = util.TableToJSON(tb)
					hook.Run("db.delete","player",json)
					hook.Run("db.delete","basic",json)
					hook.Run("db.delete","stats",json)
					return
				end

				if target:GetOwner() != nil then
					target:GetOwner():SetPData("headshot",true)
				end
		end

	end

end

function GM:PlayerDeath(victim, inflictor, attacker)

	local body = ents.Create( "prop_ragdoll" )
	body:SetPos( victim:GetPos() )
	body:SetAngles(victim:GetAngles())
	body:SetModel( victim:GetModel() )
	body:SetOwner(victim)
	body:SetVelocity(victim:GetVelocity())
	body:Spawn()
	victim:Spawn()

	timer.Simple(10,function()
		print("spawn")
		if victim:GetPData("headshot") != true then


			print("dafuq?")

			local zm = ents.Create("zombie")
			zm:SetPos(body:GetPos())
			zm:Spawn()

			body:Remove()

		end
	end)

	if IsValid(victim) && !victim:IsBot() then
		victim:update("basic","status",0)
		victim:update("player","boneBroken",0)
		victim:update("player","bleeding",0)
		victim:update("player","infected",0)
		victim:SetPData("infection",nil)
		victim:SetPData("bleeding",nil)
		victim:SetNWInt("infection",nil)
		victim:SetNWInt("bleeding",nil)
		victim:SetNWInt("boneBroken",nil)
		timer.Remove("Extend_infection")
	end

	if (victim == attacker) then return end

	if attacker:IsNPC() then return end
	if attacker:IsBot() then return end

	attacker:get("stats","humanKills",function(result)
		attacker:update("stats","humanKills",result + 1)
	end)

end

local called = false
function GM:PlayerDeathThink(ply)

	ply:Spawn()
	ply:SetPos(NightZ.SecurePos)
	ply:delete("basic")
	ply:delete("player")
	ply:delete("stats")
	net.Start("nightz:deathscreen")
	net.Send(ply)
	ply:SetPData("nightz_hunger",nil)
	ply:SetPData("nightz_thirst",nil)


end

concommand.Add("cleanup",function(ply)
	if !IsValid(ply) or !ply:IsAdmin() then return end

	for _,ent in pairs(ents.FindByClass("prop_ragdoll")) do
		ent:Remove()
	end


end)

concommand.Add("cleanzombies",function(ply)
	if ply:IsPlayer() then
	if !IsValid(ply) or !ply:IsAdmin() then return end

	for _,ent in pairs(ents.FindByClass("zombie")) do
		ent:Remove()
	end
	else
		print("removed")

		for _,ent in pairs(ents.FindByClass("zombie")) do
			ent:Remove()
		end

	end


end)

concommand.Add("test",function(ply)
	if !IsValid(ply) or !ply:IsAdmin() then return end

	/*ply:SetPData("bleedingMSG",false)
	ply:SetPData("thirstMSG",false)
	ply:SetPData("hungerMSG",false)

	ply:SetPData("nightz_hunger",nil)
	ply:SetPData("nightz_thirst",nil)*/

	ply:SetPos(ents.FindByClass("zombie")[1]:GetPos())

end)

concommand.Add("ent",function(ply)
	if !IsValid(ply) or !ply:IsAdmin() then return end

	local trace = ply:GetEyeTrace()
	local ent = trace.Entity

	print(ent)
	print(ent:GetClass())

	if ent:GetClass() == "prop_ragdoll" then
		ent:SetModel("models/zombie/zclassic_10.mdl")
	end

end)


concommand.Add("pos",function(ply)
	if !IsValid(ply) or !ply:IsAdmin() then return end

	print(ply:GetPos().x)
	print(ply:GetPos().y)
	print(ply:GetPos().z)

end)

local initialspawn
function GM:PlayerSpawn(ply)

	if ply.initialspawn == true then return end
	
	hook.Run("PlayerInitialSpawn",ply)

end

function GM:PlayerDisconnected(ply)
	local tb = {id = ply:SteamID64()}
	local json = util.TableToJSON(tb)

	hook.Run("db.get","basic","status",json,function(result)

		if result == 3 then return end

		hook.Run("db.update","basic","status",2,json)

	end)

	local body = ents.Create( "prop_ragdoll" )
	body:SetPos( ply:GetPos() )
	body:SetAngles(ply:GetAngles())
	body:SetModel( ply:GetModel() )
	body:SetNWBool("sleep",true)
	body:SetNWString("owner",tostring(ply:SteamID64()))
	body:SetVelocity(ply:GetVelocity())
	body:Spawn()
end

function GM:PlayerSetHandsModel( ply, ent )

	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end

end

function GM:PlayerHurt(ply,attacker,idk,dmg)

	local att = attacker

	timer.Simple(1,function()

		if dmg >= 20 then
			ply:get("player","boneBroken",function(result)
				if result == 1 then return end
				local rand = math.random(0,1)
				ply:update("player","boneBroken",rand)
				ply:SetNWInt("boneBroken",rand)
				if rand == 1 then
					ply:SetWalkSpeed(100)
					ply:SetRunSpeed(100)
				end
			end)
		end

		if dmg >= 20 then
			ply:get("player","bleeding",function(result)
				if result != 1 then
					local rand = math.random(0,1)
					ply:update("player","bleeding",rand)
					ply:SetNWInt("bleeding",rand)
				end
			end)
		end

		ply:get("player","infected",function(result)
			if tonumber(result) == 1 then

				timer.Create("Extend_infection",1,0,function()
					if !IsValid(ply) or !ply:Alive() then timer.Remove("Extend_infection") return end
					if ply:GetPData("infection") == nil or ply:GetPData("infection") == "nil" then
						ply:SetPData("infection",1)
					else
						if tonumber(ply:GetPData("infection")) >= 100 then
							ply:SetPData("infection",100)
							ply:TakeDamage(30,att,att)
							timer.Remove("Extend_infection")
							return
						end
						ply:SetPData("infection",tonumber(ply:GetPData("infection")) + 1)
						print(ply:GetPData("infection"))
					end
				end)

			end
		end)


		timer.Create("Extend_Bleeding",1,0,function()
		ply:get("player","bleeding",function(result)
			if tonumber(result) == 1 then

					if !IsValid(ply) or !ply:Alive() then timer.Remove("Extend_Bleeding") return end
					if ply:GetPData("bleeding") == nil or ply:GetPData("bleeding") == "nil" then
						ply:SetPData("bleeding",1)
					else
						if tonumber(ply:GetPData("bleeding")) >= 100 then
							ply:SetPData("bleeding",100)
							ply:Kill()
							timer.Remove("Extend_Bleeding")
							return
						end
							ply:SetPData("bleeding",tonumber(ply:GetPData("bleeding")) + 1)
							if tonumber(ply:GetPData("bleeding")) > 40 then
								if ply:GetPData("bleedingMSG") != "1" then
									ply:SetPData("bleedingMSG","1")
									ply:get("basic","lang",function(result)
										ply:sendNotify(lang[result].ntf_blood,8)
									end)
								end
								ply:sendSound("sound/nightz_heart.wav",tonumber(ply:GetPData("bleeding"))/100)
							end
							local vPoint = ply:GetPos()
							local effectdata = EffectData()
							effectdata:SetOrigin( vPoint )
							util.Effect( "BloodImpact", effectdata )
					end
				end
			end)
		end)
	end)

end

local infection,bleeding = false,false
local infQuantity,infQuantityB = 0,0
function GM:PlayerInitialSpawn(ply)

	ply.initialspawn = true

	timer.Simple(2,function()
		ply:Give("weapon_fists")

		ply:SetWalkSpeed(200)
		ply:SetRunSpeed(250)

		ply:get("basic","lang",function(result)
			ply:SetNWString("lang",result)
		end)


		for _,ent in pairs(ents.FindByClass("prop_ragdoll")) do
			if ent:GetNWBool("sleep") && ent:GetNWString("owner") == tostring(ply:SteamID64()) then
				ply:SetPos(ent:GetPos())
				ent:Remove()
			end
		end

		timer.Create("Checkers",2,3,function()

			if ply.bleeding then
				if ply.infQuantityB == nil then
					ply.infQuantityB = ply:GetPData("bleeding")
				else
					if tonumber(ply.infQuantityB) == tonumber(ply:GetPData("bleeding")) then
						ply:TakeDamage(1,ply,ply)
						timer.Remove("Checkers")
					end
				end
			end

			if ply:GetPData("bleeding") == 0 or ply:GetPData("bleeding") == nil or ply:GetPData("bleeding") == "nil" then
				ply.bleeding = false
			else
				if ply.bleeding then return end
				ply.bleeding = true
			end

			if ply.infection then
				if ply.infQuantity == nil then
					ply.infQuantity = ply:GetPData("infection")
				else
					if tonumber(ply.infQuantity) == tonumber(ply:GetPData("infection")) then
						ply:TakeDamage(1,ply,ply)
						timer.Remove("Checkers")
					end
				end
			end

			if ply:GetPData("infection") == 0 or ply:GetPData("infection") == nil or ply:GetPData("infection") == "nil" then
				ply.infection = false
			else
				if ply.infection then return end
				ply.infection = true
			end

		end)

	end)

timer.Simple(1,function()
	ply:SetupHands()
	ply.initialspawn = false
	ply:StripWeapons()
	ply:SetModel("models/player/alyx.mdl")
	if ply:IsBot() then return end
	ply:update("basic","status",1)

	local tb = {id = ply:SteamID64()}
	local json = util.TableToJSON(tb)

	local insert = {
		id = ply:SteamID64(),
		[2] = ply:Nick(),
		[3] = 100,
		[4] = 0,
		[5] = "models/player/alyx.mdl",
		[6] = 0,
		[7] = 1,
		[8] = "en",
	}

	local json = util.TableToJSON(insert)

	hook.Run("db.insert","basic",json)

	local pos = {ply:GetPos()}

	posJson = util.TableToJSON(pos)

	local insert = {
		id = ply:SteamID64(),
		[2] = posJson,
		[3] = ply:GetAngles().y,
		[4] = 0,
		[5] = 0,
		[6] = 0,
	}

	local json = util.TableToJSON(insert)

	hook.Run("db.insert","player",json)

	local insert = {
		id = ply:SteamID64(),
		[2] = 0,
		[3] = 0,
	}

	local json = util.TableToJSON(insert)

	hook.Run("db.insert","stats",json)

end)

end