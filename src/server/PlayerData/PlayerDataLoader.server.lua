-- Services
local Players = game:GetService("Players")

-- Modules
local CurrencyManager = require(script.Parent.CurrencyManager)

-- Constants
local AUTO_SAVE_INTERVAL = 300

-- Function Declarations

local function onPlayerAdded(player)
	CurrencyManager:LoadPlayerCurrency(player)
end

local function onPlayerRemoving(player)
	CurrencyManager:SavePlayerCurrency(player)
	CurrencyManager.PlayerCurrency[player.UserId] = nil
end

local function loadExistingPlayers()
	for _, player in Players:GetPlayers() do
		CurrencyManager:LoadPlayerCurrency(player)
	end
end

local function startAutoSave()
	task.spawn(function()
		while true do
			task.wait(AUTO_SAVE_INTERVAL)
			for _, player in Players:GetPlayers() do
				CurrencyManager:SavePlayerCurrency(player)
			end
			print("Auto-saved all player currency")
		end
	end)
end

local function setupShutdownSave()
	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			CurrencyManager:SavePlayerCurrency(player)
		end
		print("Saved all player currency on shutdown")
	end)
end

local function connectPlayerEvents()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

-- If __name__ == "__main__":

local function main()
	connectPlayerEvents()
	loadExistingPlayers()
	startAutoSave()
	setupShutdownSave()
	print("CurrencyManager initialized")
end

main()
