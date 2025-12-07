local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyManager = require(script.Parent.CurrencyManager)

local GetCurrency = Instance.new("RemoteFunction")
GetCurrency.Name = "GetCurrency"
GetCurrency.Parent = ReplicatedStorage

GetCurrency.OnServerInvoke = function(player)
	local currency = CurrencyManager:GetCurrency(player)
	print("GetCurrency called for", player.Name, "- Returning:", currency)
	return currency
end

print("CurrencyRemotes initialized")
