local AutoSaver = {}
local DataStoreService = require(script.Parent.DataStoreService)
local Players = game:GetService("Players")

local SAVE_INTERVAL = 60

function AutoSaver.Start()
	task.spawn(function()
		while true do
			task.wait(SAVE_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				local data = DataStoreService.GetProfile(player)
				if data then
					DataStoreService.SaveProfile(player)
				end
			end
		end
	end)
end

return AutoSaver
