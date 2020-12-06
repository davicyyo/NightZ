include( "shared.lua" )

files = {"stamina","translate","config","weapons","meta"}

for k,v in pairs(files) do
include("modules/"..v..".lua")
end

surface.CreateFont( "Nightz:normal", {
	font = "Headliner No. 45",
	extended = false,
	size = ScreenScale(25),
} )

surface.CreateFont( "Nightz:little", {
	font = "Headliner No. 45",
	extended = false,
	size = ScreenScale(10),
} )

surface.CreateFont( "Nightz:notify", {
	font = "Roboto",
	extended = false,
	size = ScreenScale(10),
} )

function motd()
	print("spawneee")
end

local hide = {
	["CHudHealth"] = true,
	["CHudGMod"] = true,
}

local scoreboard = false
function GM:ScoreboardShow()
	scoreboard = true
	LocalPlayer():ChatPrint("Lel")
end

function GM:ScoreboardHide()
	scoreboard = false
end

net.Receive("nightz:deathscreen",function()

	surface.PlaySound("nightz_death.wav")


	local scr = vgui.Create("DFrame")
	scr:SetSize(ScrW(),ScrH())
	scr:SetPos(0,0)
	scr:SetTitle("")
	scr:SetDraggable(false)
	scr:ShowCloseButton(false)
	scr:MakePopup()
	scr.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0))
	end

	local db = vgui.Create("DButton",scr)
	db:SetSize(scr:GetWide()*0.4,scr:GetTall())
	db:Center()
	db:SetText(lang[LocalPlayer():GetNWString("lang")].dead)
	db:SetColor(Color(255,255,255))
	db:SetMouseInputEnabled(false)
	db:SetAlpha(0)
	db:SetFont("Nightz:normal")
	db:AlphaTo(255,5,0)
	db.Paint = function(self,w,h) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0)) end
	db:AlphaTo(0,10,5,function()
		scr:Remove()
		motd()
	end)

end)

function GM:ContextMenuOpen()

	return LocalPlayer():IsAdmin()

end

function GM:SpawnMenuOpen()

	return LocalPlayer():IsAdmin()

end

local isCameraEnable = false
local function MyCalcView(ply, pos, angles, fov)

	if !isCameraEnable then return end

	local view = {}

	view.origin = pos-(angles:Forward()*200)
	view.angles = angles
	view.fov = fov
	view.drawviewer = true

	return view

end

hook.Add( "CalcView", "MyCalcView", MyCalcView )

net.Receive("changeCamera",function()
	isCameraEnable = true
	MyCalcView()
end)

net.Receive("removeCamera",function()
	isCameraEnable = false
end)

/*function GM:KeyPress(ply,key)
	if (key == IN_RELOAD) then
		for _,v in pairs(ents.FindByClass("zombie")) do
			v:SetModel("models/zombie/zclassic_04.mdl")
		end
	end
end*/

local notify = false
local nt = {}
function sendNotify(string,time,color,background,title,colortitle)
	if !string or !time then return end

	if notify then

		local tb = {s=string,t=time,c=color,b=background}

		table.insert(nt,tb)

		return
	end

	notify = true

	if !color then
		color = Color(255,255,255)
	end

	if !background then
		background = Color(0,0,0,240)
	end

	if !title then
		title = "NIGHTZ"
	end

	if !colortitle then
		colortitle = Color(255,20,20)
	end

	timer.Simple(0.2,function()
		surface.PlaySound("nightz_notify.wav")
	end)

	local w,h = ScrW(),ScrH()

	local tw, th = surface.GetTextSize( string )
	local size = h*0

		-- Create a window frame
	local ntf = vgui.Create( "DFrame" )
	ntf:SetSize( w*0.2,size )
	ntf:SetPos(w*0.05,h*0.05)
	ntf:SetTitle( "" )
	ntf:SetDraggable(false)
	ntf:ShowCloseButton(false)
	ntf:SetMouseInputEnabled(false)
	ntf.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,background)
	end

	local richtext = vgui.Create( "RichText", ntf )
	richtext:SetPos(0,0)
	richtext:SetWidth( 260 )
	timer.Simple(0.1,function()
	richtext:SetToFullHeight()
	--richtext:Center()
	end)
	richtext:InsertColorChange( colortitle.r,colortitle.g,colortitle.b,colortitle.a or 255 )
	richtext:AppendText( title..":  " )
	richtext:InsertColorChange( color.r,color.g,color.b,color.a or 255 )
	richtext:AppendText( string )
	richtext:SetMultiline(true)
	richtext:SetVerticalScrollbarEnabled(false)
	function richtext:PerformLayout()

		self:SetFontInternal( "Nightz:notify" )
		self:SetFGColor( color )

	end

	timer.Simple(0.8,function()
		size = th * (richtext:GetNumLines() * 2)
		ntf:SetSize( w*0.2,size )
	end)

	timer.Simple(time-1,function()
		ntf:MoveTo(w*-1,h*0.05,1)
	end)

	timer.Simple(time,function()
		ntf:Remove()
		notify = false
		local ntfN = {}
		if table.Count( nt ) == 0 then return end
		local cl,back = true,true
		if not nt[1].c then
			cl = false
		end

		if not nt[1].b then
			back = false
		end

		if !cl and !back then
			ntfN = {nt[1].s,nt[1].t}
		elseif cl && !back then
			ntfN = {nt[1].s,nt[1].t,nt[1].c}
		else
			ntfN = {nt[1].s,nt[1].t,nt[1].c,nt[1].b}
		end

		table.remove(nt,1)

		if #ntfN == 4 then
			sendNotify(ntfN[1],ntfN[2],ntfN[3],ntfN[4])
		elseif #ntfN == 3 then
			sendNotify(ntfN[1],ntfN[2],ntfN[3])
		elseif #ntfN == 2 then
			sendNotify(ntfN[1],ntfN[2])
		end
	end)

end

net.Receive("sendnotify",function()

	local str = net.ReadString()
	local time = net.ReadString()
	local color = net.ReadColor()
	local back = net.ReadColor()

	sendNotify(str,tonumber(time),color,back)

end)

net.Receive("sendSound",function()

	local path = net.ReadString()
	local volume = net.ReadString()

	sound.PlayFile( path, "", function( station )
		if ( IsValid( station ) ) then
			station:Play()
			station:SetVolume(tonumber(volume))
		else
			print("invalid file")
		end
	end )

end)

concommand.Add("pene",function()

	sendNotify("Me pica el pene",8,Color(0,0,0),Color(255,255,255))
	sendNotify("Me dejó de picar",8)

end)