local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyManager = require(script.Parent.CurrencyManager)

local GetCurrency = Instance.new("RemoteFunction")
GetCurrency.Name = "GetCurrency"
GetCurrency.Parent = ReplicatedStorage

GetCurrency.OnServerInvoke = function(player)
	return CurrencyManager:GetCurrency(player)
end
