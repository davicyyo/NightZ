if !CLIENT then return end

local stamina = 100
local pl = {}

function pl.isRunning()
	return input.IsKeyDown(IN_SPEED)
end

function pl.isJumping()
	return input.IsKeyDown(IN_JUMP)
end

function pl.isDucking()
	return input.IsKeyDown(IN_DUCK)
end

local isDown = false
local gradualStamina = 5
local delay = 0
local run,jump,duck,melee,bow = false
local isOnWater = false
function GM:CreateMove(cmd)

	if !LocalPlayer():Alive() then return end
	if LocalPlayer():InVehicle() then return end
	if LocalPlayer():GetNWInt("boneBroken") == 1 then cmd:RemoveKey( IN_JUMP ) cmd:RemoveKey( IN_SPEED ) cmd:RemoveKey( IN_DUCK ) return end

	if cmd:KeyDown(IN_JUMP) then
		if stamina >= 10 then
			jump = true
			if isDown then return end
			isDown = true
			timer.Simple(0.1,function()
			stamina = stamina - 20
			gradualStamina = 1
			if stamina <= 0 then stamina = 0 end
			end)
		end
	elseif cmd:KeyDown(IN_SPEED) then
		if stamina >= 10 then
			run = true
			timer.Simple(0.1,function()
			stamina = stamina - 0.1
			isDown = false
			gradualStamina = 1
			if stamina <= 0 then stamina = 0 end
			end)
		end
	elseif cmd:KeyDown(IN_ATTACK) then
		if stamina >= 10 then
			if NightZ.MeleeWeapons[LocalPlayer():GetActiveWeapon():GetClass()] then
				if NightZ.MeleeWeapons[LocalPlayer():GetActiveWeapon():GetClass()].type == 0 then
					melee = true
					if isDown then return end
					isDown = true
				else
					bow = true
					isDown = false
				end
				timer.Simple(0.1,function()
				stamina = stamina - NightZ.MeleeWeapons[LocalPlayer():GetActiveWeapon():GetClass()].attack1
				gradualStamina = 1
				if stamina <= 0 then stamina = 0 end
				end)
			end
		end
	elseif cmd:KeyDown(IN_ATTACK2) then
		if stamina >= 10 then
			if NightZ.MeleeWeapons[LocalPlayer():GetActiveWeapon():GetClass()] then
				if NightZ.MeleeWeapons[LocalPlayer():GetActiveWeapon():GetClass()].type == 0 then
					melee = true
					if isDown then return end
					isDown = true
				else
					bow = true
					isDown = false
				end
			timer.Simple(0.1,function()
			stamina = stamina - NightZ.MeleeWeapons[LocalPlayer():GetActiveWeapon():GetClass()].attack2
			gradualStamina = 1
			if stamina <= 0 then stamina = 0 end
			end)
			end
		end
	elseif cmd:KeyDown(IN_DUCK) then
		if stamina >= 10 then
			duck = true
			stamina = stamina - 0.02
			isDown = false
			gradualStamina = 1
			if stamina <= 0 then stamina = 0 end
		end
	else
		if onWater then return end
		timer.Simple(5,function()
			melee,jump = false
		end)

		run,duck,bow = false
		if stamina >= 100 then stamina = 100 return end

		if CurTime() < delay then return end

		stamina = stamina + gradualStamina

		gradualStamina = gradualStamina + gradualStamina

		delay = CurTime() + 1
		isDown = false
	end


	if stamina <= 10 then
		isDown = false
		cmd:RemoveKey( IN_JUMP )
		cmd:RemoveKey( IN_SPEED )
		cmd:RemoveKey( IN_DUCK )
		if NightZ.MeleeWeapons[LocalPlayer():GetActiveWeapon():GetClass()] then

			if NightZ.MeleeWeapons[LocalPlayer():GetActiveWeapon():GetClass()].attack1 then
				cmd:RemoveKey( IN_ATTACK )
			end

			if NightZ.MeleeWeapons[LocalPlayer():GetActiveWeapon():GetClass()].attack2 then
				cmd:RemoveKey( IN_ATTACK2 )
			end

		end
		return
	end

end

local oxygen = 100
local gradualOxygen = 5
timer.Create("thinkWater",1,0,function()

	if !IsValid(LocalPlayer()) then return end

	if LocalPlayer():WaterLevel() == 2 then
			isOnWater = true
			stamina = stamina - 2
			onWater = true
	elseif LocalPlayer():WaterLevel() == 3 then
			isOnWater = true
			stamina = stamina - 3
			oxygen = oxygen - 8
			if stamina <= 10 then
				oxygen = oxygen - 14
			end
			onWater = true
	else
		isOnWater = false
	end

	if isOnWater then
		if LocalPlayer():WaterLevel() == 3 then
			if oxygen <= 0 then
				oxygen = 0
				net.Start("nightz:hurt")
				net.WriteEntity(LocalPlayer())
				net.SendToServer()
			end
		else
			if stamina <= 30 then
				net.Start("nightz:hurt")
				net.WriteEntity(LocalPlayer())
				net.SendToServer()
			end
		end
	else
		timer.Simple(2,function()
		if isOnWater then gradualOxygen = 5 return end
		onWater = false
		if oxygen >= 100 then oxygen = 100 return end
		oxygen = oxygen + gradualOxygen

		gradualOxygen = gradualOxygen + gradualOxygen
		end)
	end

end)

function GM:RenderScreenspaceEffects()
	if LocalPlayer():GetNWInt("bleeding") == nil or LocalPlayer():GetNWInt("bleedingQ") == "nil" or LocalPlayer():GetNWInt("bleedingQ") == nil or LocalPlayer():GetNWInt("bleeding") == 0 or LocalPlayer():GetNWInt("bleeding") == "nil" then
	else
			local tab = {}
			tab[ "$pp_colour_colour" ] = 1-(tonumber(LocalPlayer():GetNWInt("bleedingQ"))/100)
			tab[ "$pp_colour_contrast" ] = 1
			DrawColorModify( tab )
	end
end

local alpha,alphaW = 255,255
local mat = "materials/nightz_walk.png"
local infection,bone,bleeding = false,false,false
local pos = {
	[1] = {pos=.02,active=false},
	[2] = {pos=.08,active=false},
	[3] = {pos=.14,active=false},
	[4] = {pos=.2,active=false},
}
local i,bb,b = 0,0,0
function GM:HUDPaint()
	if !LocalPlayer():Alive() then return end

	if run then
		mat = "materials/nightz_run.png"
	elseif jump then
		mat = "materials/nightz_jump.png"
	elseif duck then
		mat = "materials/nightz_crouch.png"
	elseif melee then
		mat = "materials/nightz_melee.png"
	elseif bow then
		mat = "materials/nightz_bow.png"
	elseif LocalPlayer():WaterLevel() >= 2 then
		mat = "materials/nightz_crouch.png"
	else
		mat = "materials/nightz_walk.png"
	end

	local w,h = ScrW(),ScrH()

	surface.SetDrawColor( 255,255,255,100 )
	surface.SetMaterial(Material("materials/nightz_logo.png"))
	surface.DrawTexturedRect( w*0.8,h*0.8, w*0.1,h*0.05 )
	draw.DrawText( GAMEMODE.V2.." "..GAMEMODE.Version, "Nightz:little", w * 0.85, h * 0.85, Color( 255, 255, 255, 100 ), TEXT_ALIGN_CENTER )

	if LocalPlayer():GetNWInt("infection") == nil or LocalPlayer():GetNWInt("infection") == 0 or LocalPlayer():GetNWInt("infection") == "nil" then
	else
		local alphaI = LocalPlayer():GetNWInt("infection")
		local infected = "materials/nightz_infected.png"

		local PL = LocalPlayer()
		PL.BLUR = PL.BLUR or vgui.Create( "DFrame" )
    
        PL.BLUR:SetSize( w,h )
        PL.BLUR:SetPos( w*0,h*0 )
        PL.BLUR:SetTitle("")
        PL.BLUR:SetAlpha(alphaI)
        PL.BLUR:SetDraggable(false)
        PL.BLUR:ShowCloseButton(false)
        PL.BLUR.Paint = function(self,w,h)
        	Derma_DrawBackgroundBlur(self,self.Start)
        	draw.RoundedBox(0,0,0,w,h,Color(0,0,0,alphaI))
    	end
        PL.BLUR:SetPaintedManually(false)
		PL.BLUR:PaintManual()
		PL.BLUR:SetPaintedManually(true)

		surface.SetDrawColor( 255,255,255,100 )
		surface.SetMaterial(Material(infected))
		if pos[1].active == false then
			if i == 0 then
				i = pos[1].pos
				pos[1].active = "infected"
			end
		end

		if pos[2].active == false then
			if i == 0 then
				i = pos[2].pos
				pos[2].active = "infected"
			end
		end

		if pos[3].active == false then
			if i == 0 then
				i = pos[3].pos
				pos[3].active = "infected"
			end
		end

		if pos[4].active == false then
			if i == 0 then
				i = pos[4].pos
				pos[4].active = "infected"
			end
		end

		surface.DrawTexturedRect( w*i,h*0.7, 50,50 )

	end

	if LocalPlayer():GetNWInt("boneBroken") == nil or tostring(LocalPlayer():GetNWInt("boneBroken")) == "0" then
	else
		local bone = "materials/nightz_bone.png"

		surface.SetDrawColor( 255,255,255,100 )
		surface.SetMaterial(Material(bone))
		if pos[1].active == false then
			if bb == 0 then
				bb = pos[1].pos
				pos[1].active = "bone"
			end
		end

		if pos[2].active == false then
			if bb == 0 then
				bb = pos[2].pos
				pos[2].active = "bone"
			end
		end

		if pos[3].active == false then
			if bb == 0 then
				bb = pos[3].pos
				pos[3].active = "bone"
			end
		end

		if pos[4].active == false then
			if bb == 0 then
				bb = pos[4].pos
				pos[4].active = "bone"
			end
		end

		surface.DrawTexturedRect( w*bb,h*0.7, 50,50 )


	end

	if LocalPlayer():GetNWInt("bleeding") == nil or LocalPlayer():GetNWInt("bleeding") == 0 or LocalPlayer():GetNWInt("bleeding") == "nil" then
	else
		local alphaB = LocalPlayer():GetNWInt("bleeding")
		local bleeding = "materials/nightz_bleeding.png"

		local PL = LocalPlayer()
		PL.BLUR = PL.BLUR or vgui.Create( "DFrame" )
    
        PL.BLUR:SetSize( w,h )
        PL.BLUR:SetPos( w*0,h*0 )
        PL.BLUR:SetTitle("")
        PL.BLUR:SetAlpha(alphaB)
        PL.BLUR:SetDraggable(false)
        PL.BLUR:ShowCloseButton(false)
        PL.BLUR.Paint = function(self,w,h)
        	Derma_DrawBackgroundBlur(self,self.Start)
        	draw.RoundedBox(0,0,0,w,h,Color(57,57,57,alphaI))
    	end
        PL.BLUR:SetPaintedManually(false)
		PL.BLUR:PaintManual()
		PL.BLUR:SetPaintedManually(true)

		surface.SetDrawColor( 255,255,255,100 )
		surface.SetMaterial(Material(bleeding))
		if pos[1].active == false then
			if b == 0 then
				b = pos[1].pos
				pos[1].active = "blood"
			end
		end

		if pos[2].active == false then
			if b == 0 then
				b = pos[2].pos
				pos[2].active = "blood"
			end
		end

		if pos[3].active == false then
			if b == 0 then
				b = pos[3].pos
				pos[3].active = "blood"
			end
		end

		if pos[4].active == false then
			if b == 0 then
				b = pos[4].pos
				pos[4].active = "blood"
			end
		end

		surface.DrawTexturedRect( w*b,h*0.7, 50,50 )

	end


	VisualStamina = Lerp(10 * FrameTime(), VisualStamina, stamina)

	if VisualStamina > 100 then VisualStamina = 100 end

	if VisualStamina >= 80 then

		alpha = alpha - 1

	else
		alpha = VisualStamina + 100
	end

	VisualOxygen = Lerp(10 * FrameTime(), VisualOxygen, oxygen)

	if VisualOxygen > 100 then VisualOxygen = 100 end

	if VisualOxygen >= 80 then

		alphaW = alphaW - 1

	else
		alphaW = VisualOxygen + 100
	end

		if alphaW > 0 then

		surface.SetDrawColor( 10,10,255,alphaW - 10 )
		surface.DrawRect( w*0.4, h*0.8, w*0.2, h*0.05 )
		surface.SetDrawColor( 10,10,255,alphaW )
		surface.DrawRect( w*0.4, h*0.8, w*0.2 * (VisualOxygen / 100), h*0.05 )

		end

	if alpha <= 0 then return end

	surface.SetDrawColor( 10,10,10,alpha - 10 )
	surface.DrawRect( w*0.4, h*0.7, w*0.2, h*0.05 )
	surface.SetDrawColor( 10,10,10,alpha )
	surface.DrawRect( w*0.4, h*0.7, w*0.2 * (VisualStamina / 100), h*0.05 )
	surface.SetDrawColor( 255,255,255,alpha )
	surface.SetMaterial(Material(mat))
	surface.DrawTexturedRect( w*0.4,h*0.7, 35, 35 ) 


end