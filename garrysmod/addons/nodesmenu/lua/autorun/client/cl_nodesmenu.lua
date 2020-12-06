if !CLIENT then return end


surface.CreateFont( "HeaderTitle", {
	font = "Coolvetica",
	extended = false,
	size = ScreenScale(20),
	weight = 100,
} )

surface.CreateFont( "TitleName", {
	font = "Coolvetica",
	extended = false,
	size = ScreenScale(12),
	weight = 100,
} )

surface.CreateFont( "MenuItem", {
	font = "Coolvetica",
	extended = false,
	size = ScreenScale(9),
	weight = 100,
} )

surface.CreateFont( "Credits", {
	font = "Coolvetica",
	extended = false,
	size = ScreenScale(7),
	weight = 100,
} )


local menuOpen = false
local keyPressed = false
local tbl
local time = 30
hook.Add("NodesMenu.Open","openNodesMenu",function(menuid)

	if !menuid then menuOpen = false hook.Remove("nodesMenu.Open") return end

	if NodesMenu[menuid].access != true then
		if not table.HasValue(NodesMenu[menuid].access,LocalPlayer():GetUserGroup()) then
			menuOpen = false
			hook.Remove("nodesMenu.Open")
			return
		end
	end

	menuOpen = true

	function HUDMenu()

		function kick()

			local target
			local reason

			local fr = vgui.Create( "DFrame" )
			fr:SetSize( ScrW()/2,ScrH()/2 )
			fr:Center()
			fr:MakePopup()
			fr:ShowCloseButton(true)
			fr:SetDraggable(false)
			fr:SetTitle("")
			fr.Paint = function(self,w,h)
			Derma_DrawBackgroundBlur(self,self.Start)
			draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0))
			end

			local Scroll = vgui.Create( "DScrollPanel", fr ) -- Create the Scroll panel
			Scroll:SetSize(fr:GetWide(),fr:GetTall())
			Scroll:SetPos(fr:GetWide()*0,fr:GetTall()*0.1)

			local sbar = Scroll:GetVBar()
			function sbar:Paint( w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 57,57,57, 0 ) )
			end
			function sbar.btnUp:Paint( w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0,0 ) )
			end
			function sbar.btnDown:Paint( w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0,0 ) )
			end
			function sbar.btnGrip:Paint( w, h )
				draw.RoundedBox( 5, w * 0.25, 0, w * 0.4, h, Color( 247,173,41 ) )
			end

			local List = vgui.Create( "DIconLayout", Scroll )
			List:SetSize(Scroll:GetWide(),Scroll:GetTall())
			List:SetPos(Scroll:GetWide()*0,Scroll:GetTall()*0)
			List:SetSpaceY( 5 ) -- Sets the space in between the panels on the Y Axis by 5
			List:SetSpaceX( 5 ) -- Sets the space in between the panels on the X Axis by 5

			for k,v in pairs(player.GetAll()) do

				local pl = List:Add("DButton")
				pl:SetSize(fr:GetWide(),fr:GetTall() * 0.3)
				pl:Center()
				pl:SetText(v:Nick())
				pl:SetFont("MenuItem")
				pl:SetTextColor(Color(255,255,255))
				pl.Paint = function(self,w,h)
					draw.RoundedBox(0,0,0,w,h,Color(0,0,0,200))
				end
				pl.DoClick = function()
					target = v:Nick()
					Scroll:Remove()


					local TextEntry = vgui.Create( "DTextEntry", fr ) -- create the form as a child of frame
					TextEntry:SetSize( fr:GetWide(),fr:GetTall() * 0.5 )
					TextEntry:Center()
					TextEntry:SetFont("MenuItem")
					TextEntry:SetText( "Reason (enter for finish)" )
					TextEntry.OnEnter = function( self )
						reason = self:GetValue()
						
						LocalPlayer():ConCommand('ulx kick "'..target..'" "'..reason..'"')

						fr:Remove()
					end

				end

			end

		end

		function ban()

			local target
			local time
			local reason

			local fr = vgui.Create( "DFrame" )
			fr:SetSize( ScrW()/2,ScrH()/2 )
			fr:Center()
			fr:MakePopup()
			fr:ShowCloseButton(true)
			fr:SetDraggable(false)
			fr:SetTitle("")
			fr.Paint = function(self,w,h)
			Derma_DrawBackgroundBlur(self,self.Start)
			draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0))
			end

			local Scroll = vgui.Create( "DScrollPanel", fr ) -- Create the Scroll panel
			Scroll:SetSize(fr:GetWide(),fr:GetTall())
			Scroll:SetPos(fr:GetWide()*0,fr:GetTall()*0.1)

			local sbar = Scroll:GetVBar()
			function sbar:Paint( w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 57,57,57, 0 ) )
			end
			function sbar.btnUp:Paint( w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0,0 ) )
			end
			function sbar.btnDown:Paint( w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0,0 ) )
			end
			function sbar.btnGrip:Paint( w, h )
				draw.RoundedBox( 5, w * 0.25, 0, w * 0.4, h, Color( 247,173,41 ) )
			end

			local List = vgui.Create( "DIconLayout", Scroll )
			List:SetSize(Scroll:GetWide(),Scroll:GetTall())
			List:SetPos(Scroll:GetWide()*0,Scroll:GetTall()*0)
			List:SetSpaceY( 5 ) -- Sets the space in between the panels on the Y Axis by 5
			List:SetSpaceX( 5 ) -- Sets the space in between the panels on the X Axis by 5

			for k,v in pairs(player.GetAll()) do

				local pl = List:Add("DButton")
				pl:SetSize(fr:GetWide(),fr:GetTall() * 0.3)
				pl:Center()
				pl:SetText(v:Nick())
				pl:SetFont("MenuItem")
				pl:SetTextColor(Color(255,255,255))
				pl.Paint = function(self,w,h)
					draw.RoundedBox(0,0,0,w,h,Color(0,0,0,200))
				end
				pl.DoClick = function()
					target = v:SteamID()
					Scroll:Remove()


					local TextEntry = vgui.Create( "DTextEntry", fr ) -- create the form as a child of frame
					TextEntry:SetSize( fr:GetWide(),fr:GetTall() * 0.5 )
					TextEntry:Center()
					TextEntry:SetFont("MenuItem")
					TextEntry:SetText( "Time (in minutes)" )
					TextEntry.OnEnter = function( self )
						time = self:GetValue()

						TextEntry:Remove()

						local TextEntry = vgui.Create( "DTextEntry", fr ) -- create the form as a child of frame
						TextEntry:SetSize( fr:GetWide(),fr:GetTall() * 0.5 )
						TextEntry:Center()
						TextEntry:SetFont("MenuItem")
						TextEntry:SetText( "Reason (enter for finish)" )
						TextEntry.OnEnter = function( self )
							reason = self:GetValue()
						
						LocalPlayer():ConCommand('ulx banid "'..target..'" "'..time..'" "'..reason..'"')

						fr:Remove()
					end
						
						
					end

				end

			end

		end

		resources = {
			[1] = {rect=0.36},
			[2] = {rect=0.42},
			[3] = {rect=0.48},
			[4] = {rect=0.54},
			[5] = {rect=0.60},
			[6] = {rect=0.66},
			[7] = {rect=0.72},
			[8] = {rect=0.78},
			[9] = {rect=0.84},
		}

		local w,h = ScrW(),ScrH()
		local centerH = ScrH()/2
		local sizeFrame = resources[#NodesMenu[menuid].items].rect
		local posH = centerH/(sizeFrame+(#NodesMenu[menuid].items/2))

		if not menuOpen then hook.Remove("nodesMenu.Open") return end

		surface.SetDrawColor( 0,0,0,0 )
		surface.DrawRect(/*Pos*/ w*0.1,posH,/*Size*/w*0.25,h*sizeFrame)

		surface.SetDrawColor( 255, 255, 255, 255 ) 
		surface.SetMaterial( Material( "materials/nodes_gardient.png" ) )
		surface.DrawTexturedRect( w*0.1, posH , w*0.25,h*0.15 )

		draw.DrawText(NodesMenu.Text,"HeaderTitle",w* 0.225,posH+40,Color(255,255,255),TEXT_ALIGN_CENTER)

		surface.SetDrawColor( 0,0,0,250 )
		surface.DrawRect(/*Pos*/ w*0.1,posH+100,/*Size*/w*0.25,h*0.05)

		draw.DrawText(NodesMenu[menuid].name,"TitleName",w* 0.11,posH+105,Color(255,255,255),TEXT_ALIGN_LEFT)


		itemH = {
			[1] = 150,
			[2] = 200,
			[3] = 250,
			[4] = 300,
			[5] = 350,
			[6] = 400,
			[7] = 450,
			[8] = 500,
			[9] = 550,
		}

		for item,value in pairs(NodesMenu[menuid].items) do
			if itemH[item] != nil then
				surface.SetDrawColor( 0,0,0,200 )
				surface.DrawRect(/*Pos*/ w*0.1,posH+itemH[item],/*Size*/ w*0.25,h*0.05)

				draw.DrawText(item..". "..value.title,"MenuItem",w* 0.105,posH+(itemH[item] + 7),Color(255,255,255),TEXT_ALIGN_LEFT)
			end
		end

		--draw.DrawText("Nodes by Nodes","Credits",w* 0.22,posH+(itemH[#NodesMenu[menuid].items]+50),Color(255,255,255),TEXT_ALIGN_CENTER)



		--## Keys

		if keyPressed then return end

		local keys = {
			[1] = KEY_1,
			[2] = KEY_2,
			[3] = KEY_3,
			[4] = KEY_4,
			[5] = KEY_5,
			[6] = KEY_6,
			[7] = KEY_7,
			[8] = KEY_8,
			[9] = KEY_9,
		}
		for i=1,9 do
			if input.IsKeyDown(keys[i]) then
				if NodesMenu[menuid].items[i] == nil then return end
				keyPressed = true
				hook.Run("NodesMenu.Close")
				surface.PlaySound("nodes_select.wav")

				timer.Simple(0.1,function()
				if NodesMenu[menuid].items[i].action == "goto" then

					hook.Run("NodesMenu.Open",NodesMenu[menuid].items[i].result)

				elseif NodesMenu[menuid].items[i].action == "clientside" then

					hook.Add("CalledClient","clientFunction",NodesMenu[menuid].items[i].result)

					hook.Call("CalledClient")

				elseif NodesMenu[menuid].items[i].action == "serverside" then

					net.Start("NET:ServerFunction")
					net.WriteEntity(LocalPlayer())
					net.WriteString(menuid)
					net.WriteString(i)
					net.SendToServer()

				elseif NodesMenu[menuid].items[i].action == "kick" then

					kick()

				elseif NodesMenu[menuid].items[i].action == "ban" then

					ban()

				end
				end)

			end
		end

	end


	hook.Add("HUDPaint","PaintSimpleMenu",HUDMenu)

end)

local key = 0
hook.Add("NodesMenu.Close","closeNodesMenu",function()
	menuOpen = false
	keyPressed = false
	timer.Simple(0.1,function()
	key = 0
	end)
end)

local pressed = false
hook.Add("Think","identifier",function()
	if input.IsKeyDown(KEY_F2) then
		print(pressed)
		print(key)
		key = key + 1
		if key >= 2 then return end
		if pressed then
			hook.Call("NodesMenu.Close")
			pressed = false
		else
		pressed = true
		hook.Run("NodesMenu.Open","1")

			timer.Simple(0.1,function()
				key = 0
			end)
		end
	end
end)