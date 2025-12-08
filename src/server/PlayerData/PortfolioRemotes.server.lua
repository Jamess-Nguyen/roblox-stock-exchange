-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local PortfolioManager = require(script.Parent.PortfolioManager)
local StockData = require(game.ServerScriptService.StockSystem.StockData)

-- Remote Functions
local GetPortfolio
local GetPortfolioValue

-- Function Declarations

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

-- If __name__ == "__main__":

local function main()
	setupGetPortfolioFunction()
	setupGetPortfolioValueFunction()
	print("PortfolioRemotes initialized")
end

main()
