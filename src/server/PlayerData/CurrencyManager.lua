-- Services
local DataStoreService = game:GetService("DataStoreService")

-- Data Stores
local CurrencyDataStore = DataStoreService:GetDataStore("PlayerCurrency")

-- Module
local CurrencyManager = {}
CurrencyManager.PlayerCurrency = {}

-- Constants
local DEFAULT_CURRENCY = 100000

-- Public Functions

function CurrencyManager:GetCurrency(player)
	return self.PlayerCurrency[player.UserId] or 0
end

function CurrencyManager:SetCurrency(player, amount)
	self.PlayerCurrency[player.UserId] = amount
	return amount
end

function CurrencyManager:AddCurrency(player, amount)
	local current = self:GetCurrency(player)
	self.PlayerCurrency[player.UserId] = current + amount
	return self.PlayerCurrency[player.UserId]
end

function CurrencyManager:RemoveCurrency(player, amount)
	local current = self:GetCurrency(player)
	if current >= amount then
		self.PlayerCurrency[player.UserId] = current - amount
		return self.PlayerCurrency[player.UserId]
	end
	return nil
end

function CurrencyManager:LoadPlayerCurrency(player)
	local userId = player.UserId
	local success, currency = pcall(function()
		return CurrencyDataStore:GetAsync("Player_" .. userId)
	end)

	if success and currency then
		self.PlayerCurrency[userId] = currency
		print("Loaded currency for", player.Name, ":", currency)
	else
		self.PlayerCurrency[userId] = DEFAULT_CURRENCY
		print("New player", player.Name, "starting with:", DEFAULT_CURRENCY)
	end
end

function CurrencyManager:SavePlayerCurrency(player)
	local userId = player.UserId
	local currency = self.PlayerCurrency[userId]

	if not currency then
		warn("No currency data to save for", player.Name)
		return false
	end

	local success, err = pcall(function()
		CurrencyDataStore:SetAsync("Player_" .. userId, currency)
	end)

	if success then
		print("Saved currency for", player.Name, ":", currency)
		return true
	else
		warn("Failed to save currency for", player.Name, ":", err)
		return false
	end
end

return CurrencyManager
