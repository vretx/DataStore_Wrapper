local Players = game:GetService("Players")
local DataStoreService = require(script.DataStoreService)
local AutoSaver = require(script.AutoSaver)

Players.PlayerAdded:Connect(function(player)
	local profile = DataStoreService.LoadProfile(player)
	if not profile then
		player:Kick("Failed to load data session. Please rejoin.")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	DataStoreService.SaveProfile(player)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DataStoreService.SaveProfile(player)
	end
end)

AutoSaver.Start()
