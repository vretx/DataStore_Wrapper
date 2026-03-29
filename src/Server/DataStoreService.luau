local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local SessionManager = require(script.Parent.SessionManager)
local DefaultData = require(game:GetService("ReplicatedStorage"):WaitForChild("DataStore_Wrapper"):WaitForChild("Shared"):WaitForChild("DefaultData"))

local Wrapper = {}
local MainDataStore = DataStoreService:GetDataStore("Production_Data_v1")
local ActiveProfiles = {}

local function DeepMerge(target, source)
	for key, value in pairs(source) do
		if type(value) == "table" and type(target[key]) == "table" then
			DeepMerge(target[key], value)
		else
			if target[key] == nil then
				target[key] = value
			end
		end
	end
	return target
end

function Wrapper.LoadProfile(player: Player)
	local userId = player.UserId
	local key = "Player_" .. userId
	
	local success, result = pcall(function()
		return MainDataStore:UpdateAsync(key, function(oldData)
			oldData = oldData or { Data = {}, Session = nil }
			
			if not SessionManager.IsSessionValid(oldData.Session) then
				return nil
			end
			
			oldData.Session = SessionManager.CreateSessionToken()
			return oldData
		end)
	end)
	
	if success and result then
		local profileData = DeepMerge(result.Data, DefaultData)
		ActiveProfiles[userId] = {
			Data = profileData,
			Key = key
		}
		return profileData
	end
	
	return nil
end

function Wrapper.SaveProfile(player: Player)
	local userId = player.UserId
	local profile = ActiveProfiles[userId]
	if not profile then return end
	
	local success = pcall(function()
		MainDataStore:UpdateAsync(profile.Key, function(oldData)
			if oldData and oldData.Session and oldData.Session.JobId ~= game.JobId then
				return nil
			end
			
			return {
				Data = profile.Data,
				Session = nil
			}
		end)
	end)
	
	if success then
		ActiveProfiles[userId] = nil
	end
end

function Wrapper.GetProfile(player: Player)
	local profile = ActiveProfiles[player.UserId]
	return profile and profile.Data
end

return Wrapper
