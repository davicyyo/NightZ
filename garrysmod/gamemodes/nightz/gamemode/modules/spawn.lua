/*if !SERVER then return end

local mapSize = {}

mapSize[0] = Vector(0,0,0)
mapSize[1] = Vector(1839.503784, 6443.006836, -121)
mapSize[2] = Vector(-5231.968750, -3695.968750, 320.031250)

local pos = mapSize[0]:WithinAABox(mapSize[1],mapSize[2])

local spawnPos = {x=0,y=0,z=0}

local calls = {}
function zombieSpawns(quantity)

	if !quantity then return end

	for id=1,quantity do

		function zombieSpawn(id)
			if !id then return end
			for _,v in pairs(ents.FindByClass("zombie")) do
				if v:GetNWInt("id") == id then return end
			end
			MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Spawning Zombie: "..id.."\n" )
			spawnPos = {x = math.random(mapSize[1].x,mapSize[0].x),y = math.random(mapSize[1].y,mapSize[0].y),z = math.random(mapSize[1].z,mapSize[0].z)}

			local zombie = ents.Create("zombie")
			zombie:SetPos(Vector(spawnPos.x,spawnPos.y,spawnPos.z))
			zombie:Spawn()
			zombie:SetNWInt("id",id)
			zombie:DropToFloor()

		calls[id] = 0
		timer.Create("checker",3,2,function()
			if !IsValid(zombie) then return end
			calls[id] = calls[id] + 1
			if calls[id] == 1 then
				if zombie:WaterLevel() != 0 then
					zombie:Remove()
					MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie on water!"..id.."\n" )
					zombieSpawn(id)
				return
				else
					zombie:SetNWBool("spawned",true)
					MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie Out of water! "..id.."\n" )
					zombie:SetNWVector("spawn",zombie:GetPos())
				end
			end

			if calls[id] == 2 then
				if !zombie:GetNWBool("spawned") then return end
				for _,zombie in pairs(ents.FindByClass("zombie")) do
					if zombie:GetNWInt("id") != nil then
						if zombie:GetPos():Distance(zombie:GetNWVector("spawn")) <= 50 then zombie:Remove() MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie Stuck! "..id.."\n" ) zombieSpawn(id) return end
						if zombie:WaterLevel() != 0 then MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie detected on water, removing "..id.."\n" ) zombie:Remove() zombieSpawn(id) return end
						MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie Spawned! "..id.."\n" )
						zombie:SetNWBool("fspawn",true)
					end
				end
			end
		end)
		end
		zombieSpawn(id)

	endº

end

timer.Simple(2,function()
zombieSpawns(3)
end)

/*function zombieSpawn(id)

	if !id then return end

	print(id)

	timer.Simple(0.3,function()

		MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Spawning Zombie: "..id.."\n" )

		spawnPos = {x = math.random(mapSize[1].x,mapSize[0].x),y = math.random(mapSize[1].y,mapSize[0].y),z = math.random(mapSize[1].z,mapSize[0].z)}

		local zombie = ents.Create("zombie")
		zombie:SetPos(Vector(spawnPos.x,spawnPos.y,spawnPos.z))
		zombie:Spawn()
		zombie:SetNWInt("id",id)
		zombie:DropToFloor()

		local calls = 0
		timer.Create("checker",3,2,function()
			if !IsValid(zombie) then return end
			calls = calls + 1
			if calls == 1 then
				if zombie:WaterLevel() != 0 then
					zombie:Remove()
					MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie on water!"..id.."\n" )
					zombieSpawn(id)
				return
				else
					zombie:SetNWBool("spawned",true)
					MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie Out of water! "..id.."\n" )
					zombie:SetNWVector("spawn",zombie:GetPos())
				end
			end

			if calls == 2 then
				if !zombie:GetNWBool("spawned") then return end
				for _,zombie in pairs(ents.FindByClass("zombie")) do
					if zombie:GetNWInt("id") != nil then
						if zombie:GetPos():Distance(zombie:GetNWVector("spawn")) <= 50 then zombie:Remove() MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie Stuck! "..id.."\n" ) zombieSpawn(id) return end
						if zombie:WaterLevel() != 0 then MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie detected on water, removing "..id.."\n" ) zombie:Remove() zombieSpawn(id) return end
						MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " Zombie Spawned! "..id.."\n" )
						zombie:SetNWBool("fspawn",true)
					end
				end
			end

		end)

	end)

end

/*function removeAll()
	for _,v in pairs(ents.FindByClass("prop_ragdoll")) do
		v:Remove()
	end
end*/

/*function createTimer()

	local zombies = 3
	local zID = 1

	timer.Create("SpawnSecureZombies",10,zombies,function()
	zombieSpawn(zID)

		for _,v in pairs(ents.FindByClass("zombie")) do
			if v:GetNWInt("id") == zID then
				if v:GetNWBool("fspawn") then
					zID = zID + 1
					MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " ZOMBIE: "..zID.." Spawned, spawning more\n" )
				else
					removeAll()
					MsgC( Color( 255, 0, 0 ), "[NIGHTZ]:",Color( 255, 255, 255 ), " ZOMBIE: "..zID.." Not Spawned, pause Spawn\n" )
					timer.Remove("SpawnSecureZombies")
					createTimer()
				end
			end
		end

	end)

end

createTimer()*/