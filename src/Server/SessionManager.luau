local SessionManager = {}
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local SESSION_LOCK_TIMEOUT = 120

function SessionManager.CreateSessionToken()
	return {
		JobId = game.JobId,
		Timestamp = os.time(),
	}
end

function SessionManager.IsSessionValid(sessionToken: any)
	if not sessionToken or not sessionToken.JobId or not sessionToken.Timestamp then
		return true
	end
	
	if sessionToken.JobId == game.JobId then
		return true
	end
	
	if os.time() - sessionToken.Timestamp > SESSION_LOCK_TIMEOUT then
		return true
	end
	
	return false
end

return SessionManager
