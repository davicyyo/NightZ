local db = {}

if !SERVER then return end

local database = {host="HOST",user="userDB",password="passwordDB",db="nightzDB"}

local MYSQLOO = require("mysqloo")

local MYSQL = mysqloo.connect( database.host, database.user, database.password, database.db,3306)

function db.connectDatabase()
	MYSQL.onConnected = function()
		print("connected success!")
	end

	MYSQL.onConnectionFailed = function(db,msg)
		print("connection failed ".. msg)
	end

	MYSQL:connect()
end

function db.checkDatabase()
	if MYSQL:status() != mysqloo.DATABASE_CONNECTED then
		db.connectDatabase()
	end
end

function db.insert(database,values)
	if !database or !values then return end

	local tb = util.JSONToTable(values)

	local tab = {}
	local key = {}

	for k,v in pairs(tb) do
		if k == "id" then
			table.insert(tab,1,"'"..v.."'")
			table.insert(key,1,k)
		else
			table.insert(tab,"'"..v.."'")
			table.insert(key,k)
		end
	end

	db.checkDatabase()

	local query1 = MYSQL:query("SELECT * FROM "..database.." WHERE "..key[1].." = " .. tab[1]..";")
    query1.onSuccess = function()

    	if #query1:getData() == 0 then

			local query = MYSQL:query("INSERT INTO "..database.." VALUES ("..table.concat(tab,",")..");")
			query:start()

		end

	end
	query1:start()

end

function db.update(db,key,value,where)
	if !db or !key or !value then return end

	hook.Run("db.checkDatabase")

	local query
	if not where then
		query = MYSQL:query("UPDATE "..db.." SET "..key.." = '"..value.."';")
	else
		local w = util.JSONToTable(where)

		for _,v in pairs(w) do
			query = MYSQL:query("UPDATE "..db.." SET "..key.." = '"..value.."' WHERE ".._.." = '"..v.."';")
		end
	end

	query:start()

end

function db.get(db,key,where,result)
	if !db or !key then return end

	hook.Run("db.checkDatabase")

	local query
	if not where then
		query = MYSQL:query("SELECT "..key.." FROM "..db..";")

		query.onData = function(q,d)
			result(d[key])
			return
		end

	else
		local w = util.JSONToTable(where)

		for _,v in pairs(w) do
			query = MYSQL:query("SELECT "..key.." FROM "..db.." WHERE ".._.." = '"..v.."';")
			query.onData = function(q,d)
				result(d[key])
			return
			end
		end
	end

	query:start()

end

function db.delete(db,where)
	if !db then return end

	hook.Run("db.checkDatabase")

	local query
	if not where then
		query = MYSQL:query("DELETE FROM "..db..";")
	else
		local w = util.JSONToTable(where)

		for _,v in pairs(w) do
			query = MYSQL:query("DELETE FROM "..db.." WHERE ".._.." = '"..v.."';")
		end
	end

	query:start()

end

hook.Add("db.connect","nightz#hook1",db.connectDatabase)
hook.Add("db.checkDatabase","nightz#hook2",db.checkDatabase)
hook.Add("db.insert","nightz#hook3",db.insert)
hook.Add("db.update","nightz#hook4",db.update)
hook.Add("db.delete","nightz#hook5",db.delete)
hook.Add("db.get","nightz#hook6",db.get)