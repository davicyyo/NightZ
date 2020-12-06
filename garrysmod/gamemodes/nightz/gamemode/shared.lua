GM.Name = "NightZ"
GM.Author = "HeadArrow Studios"
GM.Email = "info@headarrow.com"
GM.Website = "nodes.headarrow.com"
GM.Version = "0.2"
GM.V2 = "PRE ALPHA"

DeriveGamemode( "sandbox" )

function GM:Initialize()
	self.BaseClass.Initialize(self)
end

function GM:PlayerNoClip(ply)
	return ply:IsAdmin()
end