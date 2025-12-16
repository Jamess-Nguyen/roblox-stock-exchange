-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local PortfolioManager = require(script.Parent.PortfolioManager)
local TransactionManager = require(script.Parent.TransactionManager)
local StockDataLoader = require(game.ServerScriptService.StockSystem.StockDataLoader)
local StockData = StockDataLoader:GetStockData()

-- Remote Functions
local GetPortfolio
local GetPortfolioValue
local GetEnrichedPortfolio

-- Function Declarations

local function getStockBySymbol(symbol)
	for _, stock in ipairs(StockData) do
		if stock.Symbol == symbol then
			return stock
		end
	end
	return nil
end

local function onGetPortfolio(player)
	local portfolio = PortfolioManager:GetPortfolio(player)
	print("GetPortfolio called for", player.Name)
	return portfolio
end

local function onGetPortfolioValue(player)
	local portfolio = PortfolioManager:GetPortfolio(player)
	local totalValue = 0

	-- Create a lookup table for stock prices
	local stockPrices = {}
	for _, stock in ipairs(StockData) do
		stockPrices[stock.Symbol] = stock.CurrentPrice
	end

	-- Calculate total value
	for symbol, quantity in pairs(portfolio) do
		local price = stockPrices[symbol]
		if price then
			totalValue = totalValue + (quantity * price)
		else
			warn("Unknown stock symbol in portfolio:", symbol)
		end
	end

	print("GetPortfolioValue called for", player.Name, "- Total value:", totalValue)
	return totalValue
end

local function onGetEnrichedPortfolio(player)
	local portfolio = PortfolioManager:GetPortfolio(player)
	local enrichedData = {}

	for symbol, quantity in pairs(portfolio) do
		local stockInfo = getStockBySymbol(symbol)
		if not stockInfo then
			warn("Unknown stock symbol:", symbol)
			continue
		end

		local costBasis = TransactionManager:GetCostBasis(player, symbol)
		local currentPrice = stockInfo.CurrentPrice
		local totalValue = quantity * currentPrice
		local unrealizedPL = totalValue - costBasis
		local unrealizedPLPercent = (costBasis > 0) and ((unrealizedPL / costBasis) * 100) or 0

		table.insert(enrichedData, {
			symbol = symbol,
			name = stockInfo.Name,
			quantity = quantity,
			currentPrice = currentPrice,
			totalValue = totalValue,
			totalCost = costBasis,
			averageCost = (quantity > 0) and (costBasis / quantity) or 0,
			unrealizedPL = unrealizedPL,
			unrealizedPLPercent = unrealizedPLPercent,
			isProfit = unrealizedPL > 0
		})
	end

	print("GetEnrichedPortfolio called for", player.Name, "- Stocks:", #enrichedData)
	return enrichedData
end

local function setupGetPortfolioFunction()
	GetPortfolio = Instance.new("RemoteFunction")
	GetPortfolio.Name = "GetPortfolio"
	GetPortfolio.Parent = ReplicatedStorage

	GetPortfolio.OnServerInvoke = onGetPortfolio
end

local function setupGetPortfolioValueFunction()
	GetPortfolioValue = Instance.new("RemoteFunction")
	GetPortfolioValue.Name = "GetPortfolioValue"
	GetPortfolioValue.Parent = ReplicatedStorage

	GetPortfolioValue.OnServerInvoke = onGetPortfolioValue
end

local function setupGetEnrichedPortfolioFunction()
	GetEnrichedPortfolio = Instance.new("RemoteFunction")
	GetEnrichedPortfolio.Name = "GetEnrichedPortfolio"
	GetEnrichedPortfolio.Parent = ReplicatedStorage

	GetEnrichedPortfolio.OnServerInvoke = onGetEnrichedPortfolio
end

-- If __name__ == "__main__":

local function main()
	setupGetPortfolioFunction()
	setupGetPortfolioValueFunction()
	setupGetEnrichedPortfolioFunction()
	print("PortfolioRemotes initialized")
end

main()
