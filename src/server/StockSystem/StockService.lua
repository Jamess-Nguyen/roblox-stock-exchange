-- Modules
local StockDataLoader = require(script.Parent.StockDataLoader)

-- Module
local StockService = {}

-- Public Functions

function StockService:GetAllStocks()
	return StockDataLoader:GetStockData()
end

return StockService
