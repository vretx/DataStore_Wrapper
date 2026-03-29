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
	
	print("[DataStore] Loading data for " .. player.Name)
	
	local success, result = pcall(function()
		return MainDataStore:GetAsync(key)
	end)
	
	if success then
		local data = result or table.clone(DefaultData)
		local profileData = DeepMerge(data, DefaultData)
		ActiveProfiles[userId] = {
			Data = profileData,
			Key = key
		}
		print("[DataStore] Successfully loaded for " .. player.Name)
		return profileData
	else
		warn("[DataStore] Failed to load for " .. player.Name .. ": " .. tostring(result))
	end
	
	return nil
end

function Wrapper.SaveProfile(player: Player)
	local userId = player.UserId
	local profile = ActiveProfiles[userId]
	if not profile then 
		warn("[DataStore] No profile found to save for " .. player.Name)
		return 
	end
	
	print("[DataStore] Saving data for " .. player.Name)
	
	local success, err = pcall(function()
		MainDataStore:SetAsync(profile.Key, profile.Data)
	end)
	
	if success then
		print("[DataStore] Successfully saved for " .. player.Name)
		ActiveProfiles[userId] = nil
	else
		warn("[DataStore] Failed to save for " .. player.Name .. ": " .. tostring(err))
	end
end

function Wrapper.GetProfile(player: Player)
	local profile = ActiveProfiles[player.UserId]
	return profile and profile.Data
end

return Wrapper
