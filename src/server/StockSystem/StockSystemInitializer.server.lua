-- Stock System Initializer
-- Initializes stock data loader on server start

local StockDataLoader = require(script.Parent.StockDataLoader)

-- Initialize stock data
StockDataLoader:Initialize()
