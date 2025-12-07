local Players = game:GetService("Players")
local CurrencyManager = require(script.Parent.CurrencyManager)

local AUTO_SAVE_INTERVAL = 300

Players.PlayerAdded:Connect(function(player)
	CurrencyManager:LoadPlayerCurrency(player)
end)

Players.PlayerRemoving:Connect(function(player)
	CurrencyManager:SavePlayerCurrency(player)
	CurrencyManager.PlayerCurrency[player.UserId] = nil
end)

for _, player in Players:GetPlayers() do
	CurrencyManager:LoadPlayerCurrency(player)
end

task.spawn(function()
	while true do
		task.wait(AUTO_SAVE_INTERVAL)
		for _, player in Players:GetPlayers() do
			CurrencyManager:SavePlayerCurrency(player)
		end
		print("Auto-saved all player currency")
	end
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		CurrencyManager:SavePlayerCurrency(player)
	end
	print("Saved all player currency on shutdown")
end)

print("CurrencyManager initialized")
