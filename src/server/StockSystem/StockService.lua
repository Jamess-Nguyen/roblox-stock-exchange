local StockService = {}
local stockData = require(script.Parent.StockData)

function StockService:GetAllStocks()
  return stockData
end

return StockService