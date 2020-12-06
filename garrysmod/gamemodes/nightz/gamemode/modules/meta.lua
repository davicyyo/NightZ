local meta = FindMetaTable("Player")

if SERVER then

	function meta:sendNotify(string,time,color,background)
		if !string or !time or !IsValid(self) then return end

		if !color then
			color = Color(255,255,255)
		end

		if !background then
			background = Color(0,0,0,240)
		end

		net.Start("sendnotify")
		net.WriteString(string)
		net.WriteString(time)
		net.WriteColor(color)
		net.WriteColor(background)
		net.Send(self)

		return
	end

	function meta:sendSound(sound,volume)
		if !sound or !volume or !IsValid(self) then return end

		net.Start("sendSound")
		net.WriteString(sound)
		net.WriteString(volume)
		net.Send(self)

		return

	end

	function meta:get(db,key,func)
		if !db or !key or !IsValid(self) then return end

		tb = {id = self:SteamID64()}
		json = util.TableToJSON(tb)

		hook.Run("db.get",db,key,json,function(result)
			func(result)
		end)
	end

	function meta:update(db,key,value)
		if !db or !key or !value or !IsValid(self) then return end

		tb = {id = self:SteamID64()}
		json = util.TableToJSON(tb)

		hook.Run("db.update",db,key,value,json)
		return
	end

	function meta:delete(db)
		if !db or !IsValid(self) then return end

		tb = {id = self:SteamID64()}
		json = util.TableToJSON(tb)

		hook.Run("db.delete",db,json)
		return
	end

end

if CLIENT then
	
end