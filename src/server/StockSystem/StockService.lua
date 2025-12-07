-- Modules
local stockData = require(script.Parent.StockData)

-- Module
local StockService = {}

-- Public Functions

function StockService:GetAllStocks()
	return stockData
end

return StockService
