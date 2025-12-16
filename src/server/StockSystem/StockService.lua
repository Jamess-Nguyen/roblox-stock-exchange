-- Modules
local stockData = require(91072619691201)

-- Module
local StockService = {}

-- Public Functions

function StockService:GetAllStocks()
	return stockData
end

return StockService
