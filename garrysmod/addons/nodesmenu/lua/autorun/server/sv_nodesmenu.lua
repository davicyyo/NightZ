if !SERVER then return end

util.AddNetworkString("NET:NodesMenu")
util.AddNetworkString("NET:ServerFunction")
util.AddNetworkString("NET:SendCommand")

resource.AddFile("materials/nodes_gardient.png")
resource.AddFile("sound/nodes_select.wav")

net.Receive("NET:ServerFunction",function()
	local ply = net.ReadEntity()
	local id = net.ReadString()
	local item = net.ReadString()

	NodesMenu[id].items[tonumber(item)].result(ply)

	hook.Call("CalledServer")

end)