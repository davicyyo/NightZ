if SERVER then

	util.AddNetworkString("nightz:dropweapon")

	net.Receive("nightz:dropweapon",function()
		local ply = net.ReadEntity()

		ply:GetActiveWeapon():SetNWInt("ammo",ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()))

		ply:RemoveAmmo(ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()),ply:GetActiveWeapon():GetPrimaryAmmoType())

		ply:DropWeapon(ply:GetActiveWeapon())

	end)

end

if CLIENT then

	chatEnable = false
	hook.Add( "StartChat", "HasStartedTyping", function( isTeamChat )
		chatEnable = true
	end )

	hook.Add( "FinishChat", "ClientFinishTyping", function()
		chatEnable = false
	end )

	local call = false
	hook.Add("Think","inputKeyNightZ",function()
		if input.IsKeyDown(KEY_G) then
			if call then return end
			call = true
			if !table.HasValue(NightZ.WeaponsCantDrop,LocalPlayer():GetActiveWeapon():GetClass()) && !gui.IsConsoleVisible() && !gui.IsGameUIVisible() && !chatEnable then
				net.Start("nightz:dropweapon")
				net.WriteEntity(LocalPlayer())
				net.SendToServer()
			end
			timer.Simple(0.1,function()
				call = false
			end)
		end
	end)

end