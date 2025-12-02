local stockService = {}
local stockData = require(script.Parent.StockData)

function stockService:GetAllStocks()
  return stockData
end

return stockService