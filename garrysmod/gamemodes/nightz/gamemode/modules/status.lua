if !SERVER then return end

local tb = {hunger=100,thirst=100}

local delay = 0
hook.Add("Think","Hunger/Thirst/BrokenBone/Infection/Bleeding",function()

	if CurTime() < delay then return end

	for _,ply in pairs(player.GetAll()) do

		if !IsValid(ply) or !ply:Alive() then return end

		ply:get("player","boneBroken",function(result)
			ply:SetNWInt("boneBroken",result)
		end)

		ply:get("player","bleeding",function(result)
			ply:SetNWInt("bleeding",result)
		end)

		ply:SetNWInt("infection",ply:GetPData("infection"))

		ply:SetNWInt("bleedingQ",ply:GetPData("bleeding"))

		for k,v in pairs(tb) do
			if ply:GetPData("nightz_"..k) == "nil" or ply:GetPData("nightz_"..k) == nil then
				ply:SetPData("nightz_"..k,v)
				ply:SetNWInt("nightz_"..k,v)
			else

				function hungerSystem()
					local hunger = ply:GetPData("nightz_hunger")

					if hunger == nil then return end

					if tonumber(hunger) <= 0 then ply:SetPData("nightz_hunger",0) return end

					ply:SetPData("nightz_hunger",tonumber(hunger) - NightZ.HungerSystem["normal"])
					ply:SetNWInt("nightz_hunger",ply:GetPData("nightz_hunger"))


				end

				function thirstSystem()
					local thirst = ply:GetPData("nightz_thirst")

					if tonumber(thirst) <= 0 then ply:SetPData("nightz_thirst",0) return end

					ply:SetPData("nightz_thirst",tonumber(thirst) - NightZ.ThirstSystem["normal"])
					ply:SetNWInt("nightz_thirst",ply:GetPData("nightz_thirst"))


				end

				hungerSystem()
				thirstSystem()


				if ply:WaterLevel() == 3 then
					local hunger = ply:GetPData("nightz_hunger")
					local thirst = ply:GetPData("nightz_thirst")

					if tonumber(hunger) <= 0 then ply:SetPData("nightz_hunger",0) return end
					if tonumber(thirst) <= 0 then ply:SetPData("nightz_thirst",0) return end

					ply:SetPData("nightz_hunger",tonumber(hunger) - NightZ.HungerSystem["dive"])
					ply:SetNWInt("nightz_hunger",ply:GetPData("nightz_hunger"))

					ply:SetPData("nightz_thirst",tonumber(thirst) - NightZ.ThirstSystem["dive"])
					ply:SetNWInt("nightz_thirst",ply:GetPData("nightz_thirst"))
				end

				if ply:WaterLevel() == 2 then
					local hunger = ply:GetPData("nightz_hunger")
					local thirst = ply:GetPData("nightz_thirst")

					if tonumber(hunger) <= 0 then ply:SetPData("nightz_hunger",0) return end
					if tonumber(thirst) <= 0 then ply:SetPData("nightz_thirst",0) return end

					ply:SetPData("nightz_hunger",tonumber(hunger) - NightZ.HungerSystem["swim"])
					ply:SetNWInt("nightz_hunger",ply:GetPData("nightz_hunger"))

					ply:SetPData("nightz_thirst",tonumber(thirst) - NightZ.ThirstSystem["swim"])
					ply:SetNWInt("nightz_thirst",ply:GetPData("nightz_thirst"))
				end


				if tonumber(ply:GetPData("nightz_"..k)) <= 0 then
					ply:TakeDamage(NightZ.Damage[k],ply,ply)
				end

			end
		end

		delay = CurTime() + 2

	end
end)

local isSpeed = false
local hCalled,tCalled = false,false
hook.Add("KeyPress","keyMovements",function(ply,key)
	if !IsValid(ply) or !ply:Alive() or ply:InVehicle() or ply:GetPData("nightz_hunger") == "nil" or ply:GetPData("nightz_hunger") == nil then return end
	

	if tonumber(ply:GetPData("nightz_hunger")) < 30 then
		if !hCalled then
			hCalled = true
			if ply:GetPData("hungerMSG") != "1" then
				ply:SetPData("hungerMSG","1")
				ply:get("basic","lang",function(result)
					ply:sendNotify(lang[result].ntf_hunger,8)
				end)
			end
			ply:sendSound("sound/nightz_hunger.wav",1-(ply:GetPData("nightz_hunger")/100))
			timer.Simple(3,function()
				hCalled = false
			end)
		end
	end

	if tonumber(ply:GetPData("nightz_thirst")) < 30 then
		if !tCalled then
			tCalled = true
			if ply:GetPData("thirstMSG") != "1" then
				ply:SetPData("thirstMSG","1")
				ply:get("basic","lang",function(result)
					ply:sendNotify(lang[result].ntf_thirst,8)
				end)
			end
			ply:sendSound("sound/nightz_thirst.wav",1-(ply:GetPData("nightz_thirst")/100))
			timer.Simple(3,function()
				tCalled = false
			end)
		end
	end

	if (key == IN_JUMP) then
		local hunger = ply:GetPData("nightz_hunger")
		local thirst = ply:GetPData("nightz_thirst")

		if tonumber(hunger) <= 0 then ply:SetPData("nightz_hunger",0) return end
		if tonumber(thirst) <= 0 then ply:SetPData("nightz_thirst",0) return end

		ply:SetPData("nightz_hunger",tonumber(hunger) - NightZ.HungerSystem["jump"])
		ply:SetPData("nightz_thirst",tonumber(thirst) - NightZ.ThirstSystem["jump"])

	end

	if (key == IN_SPEED) then
		isSpeed = true
		timer.Create("speedthink",1,0,function()
		if !isSpeed or !IsValid(ply) then timer.Remove("speedthink") return end
		local hunger = ply:GetPData("nightz_hunger")
		local thirst = ply:GetPData("nightz_thirst")

		if tonumber(hunger) <= 0 then ply:SetPData("nightz_hunger",0) return end
		if tonumber(thirst) <= 0 then ply:SetPData("nightz_thirst",0) return end

		ply:SetPData("nightz_hunger",tonumber(hunger) - NightZ.HungerSystem["run"])
		ply:SetPData("nightz_thirst",tonumber(thirst) - NightZ.ThirstSystem["run"])
		end)

	end

	if (key == IN_ATTACK) then
		if NightZ.MeleeWeapons[ply:GetActiveWeapon():GetClass()] then

			if NightZ.MeleeWeapons[ply:GetActiveWeapon():GetClass()].attack1 != 0 then
				if NightZ.MeleeWeapons[ply:GetActiveWeapon():GetClass()].type == 0 then
					local hunger = ply:GetPData("nightz_hunger")
					local thirst = ply:GetPData("nightz_thirst")

					if tonumber(hunger) <= 0 then ply:SetPData("nightz_hunger",0) return end
					if tonumber(thirst) <= 0 then ply:SetPData("nightz_thirst",0) return end

					ply:SetPData("nightz_hunger",tonumber(hunger) - NightZ.HungerSystem["bowattack"])
					ply:SetPData("nightz_thirst",tonumber(thirst) - NightZ.ThirstSystem["bowattack"])
				else
					isAttacking = true
					timer.Create("speedthink",1,0,function()
					if !isAttacking then timer.Remove("speedthink") return end
					local hunger = ply:GetPData("nightz_hunger")
					local thirst = ply:GetPData("nightz_thirst")

					if tonumber(hunger) <= 0 then ply:SetPData("nightz_hunger",0) return end
					if tonumber(thirst) <= 0 then ply:SetPData("nightz_thirst",0) return end

					ply:SetPData("nightz_hunger",tonumber(hunger) - NightZ.HungerSystem["attack"])
					ply:SetPData("nightz_thirst",tonumber(thirst) - NightZ.ThirstSystem["attack"])
					end)
				end
			end

		end
	end

end)

function GM:KeyRelease( player, key )
	if ( key == IN_SPEED ) then
		isSpeed = false
	end

	if ( key == IN_ATTACK ) then
		isSpeed = false
	end
end