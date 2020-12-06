NodesMenu = {}

NodesMenu.Text = "DeathRun F2 Menu"

NodesMenu['1'] = {
	name = "Main",
	access = true,
	items = {
		[1] = {title="Admin Menu",action="goto",result="admin"},
		[2] = {title="DR Store",action="goto",result = "drstore"},
		[3] = {title="Server list",action="goto",result = "servers"},
		[4] = {title="Shop",action="serverside",result = function(ply) ply:sendNotify("Shop Working...") end},
		[5] = {title="Restart [one player only]",action="clientside",result=function() LocalPlayer():ConCommand("say /restart") end},
		[6] = {title="Enable/Disable Music",action="clientside",result=function() LocalPlayer():ConCommand("say !music") end},
		[7] = {title="Exit",action="exit"},
	},
}

NodesMenu['drstore'] = {
	name = "DeathRun Store",
	access = true,
	items = {
		[1] = {title="Buy Gravity [400 DR Packs]",action="clientside",result= function() net.Start("comprarMejora") net.WriteEntity(LocalPlayer()) net.WriteString("400") net.WriteString("gravity") net.SendToServer() end},
		[2] = {title="Speed [350 DR Packs]",action="clientside",result= function() net.Start("comprarMejora") net.WriteEntity(LocalPlayer()) net.WriteString("300") net.WriteString("speed") net.SendToServer() end},
		[3] = {title="Impulse Jump [2500 DR Packs]",action="clientside",result= function() net.Start("comprarMejora") net.WriteEntity(LocalPlayer()) net.WriteString("2500") net.WriteString("impulse") net.SendToServer() end},
		[4] = {title="Rocket [Not Available]",action="goto",result="drstore"},
		[5] = {title="Return",action="goto",result="1"},
		[6] = {title="Exit",action="exit"},
	},
}

NodesMenu['admin'] = {
	name = "Admin Menu",
	access = {"superadmin","admin"},
	items = {
		[1] = {title="Kick player",action="kick"},
		[2] = {title="Ban Player",action="ban"},
		[3] = {title="Return",action="goto",result="1"},
		[4] = {title="Exit",action="exit"},
	},
}

NodesMenu['servers'] = {
	name = "Server list",
	access = true,
	items = {
		[1] = {title="Deathrun",action="goto",result="servers"},
		[2] = {title="Outlast [Soon]",action="goto",result="servers"},
		[3] = {title="Surf [Soon]",action="goto",result="servers"},
		[4] = {title="Saloon [Soon]",action="goto",result="servers"},
		[5] = {title="Jailbreak [Soon]",action="goto",result="servers"},
		[6] = {title="C4 Run [Soon]",action="goto",result="servers"},
		[7] = {title="Zombie Left 4 dead 2 [Soon]",action="goto",result="servers"},
		[8] = {title="Return",action="goto",result="1"},
		[9] = {title="Exit",action="exit"},
	},
}