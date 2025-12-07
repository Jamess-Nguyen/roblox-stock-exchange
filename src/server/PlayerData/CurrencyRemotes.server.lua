-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local CurrencyManager = require(script.Parent.CurrencyManager)

-- Remote Functions
local GetCurrency

-- Function Declarations

local function onGetCurrency(player)
	local currency = CurrencyManager:GetCurrency(player)
	print("GetCurrency called for", player.Name, "- Returning:", currency)
	return currency
end

local function setupGetCurrencyFunction()
	GetCurrency = Instance.new("RemoteFunction")
	GetCurrency.Name = "GetCurrency"
	GetCurrency.Parent = ReplicatedStorage

	GetCurrency.OnServerInvoke = onGetCurrency
end

-- If __name__ == "__main__":

local function main()
	setupGetCurrencyFunction()
	print("CurrencyRemotes initialized")
end

main()
