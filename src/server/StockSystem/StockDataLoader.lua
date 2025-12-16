-- Stock Data Loader
-- Fetches stock prices from GitHub data repository via HttpService

local HttpService = game:GetService("HttpService")

-- Data repository URL
local DATA_URL = "https://raw.githubusercontent.com/Jamess-Nguyen/roblox-stock-exchange-data/main/stock-prices.json"

-- Module
local StockDataLoader = {}

-- Cached stock data in game-compatible format
local cachedStockData = nil
local lastFetchTime = 0
local CACHE_DURATION = 300 -- 5 minutes

-- Map symbol to full name
local SYMBOL_NAMES = {
	RBLX = "Roblox",
	AAPL = "Apple",
	MSFT = "Microsoft"
}

-- Convert JSON format to game format
local function convertToGameFormat(jsonData)
	local gameData = {}

	for symbol, stock in pairs(jsonData.stocks) do
		table.insert(gameData, {
			Name = SYMBOL_NAMES[symbol] or symbol,
			Symbol = stock.symbol,
			CurrentPrice = stock.close
		})
	end

	return gameData
end

-- Fetch stock data from GitHub
function StockDataLoader:FetchStockData()
	print("[StockDataLoader] Fetching stock data from GitHub...")

	local success, response = pcall(function()
		return HttpService:GetAsync(DATA_URL)
	end)

	if not success then
		warn("[StockDataLoader] Failed to fetch stock data:", response)
		return nil
	end

	local success, jsonData = pcall(function()
		return HttpService:JSONDecode(response)
	end)

	if not success then
		warn("[StockDataLoader] Failed to parse stock data JSON:", jsonData)
		return nil
	end

	-- Convert to game format
	local stockData = convertToGameFormat(jsonData)

	print(string.format("[StockDataLoader] Loaded %d stocks (updated: %s)", #stockData, jsonData.last_updated))

	return stockData
end

-- Get stock data with caching
function StockDataLoader:GetStockData(forceRefresh)
	local currentTime = tick()

	-- Return cached data if still valid
	if not forceRefresh and cachedStockData and (currentTime - lastFetchTime) < CACHE_DURATION then
		return cachedStockData
	end

	-- Fetch fresh data
	local stockData = self:FetchStockData()

	if stockData then
		cachedStockData = stockData
		lastFetchTime = currentTime
	else
		-- If fetch failed, return cached data if available
		if cachedStockData then
			warn("[StockDataLoader] Using cached data due to fetch failure")
			return cachedStockData
		end

		-- No cached data and fetch failed - return default data
		warn("[StockDataLoader] No data available, using default prices")
		return {
			{Name = "Roblox", Symbol = "RBLX", CurrentPrice = 100},
			{Name = "Apple", Symbol = "AAPL", CurrentPrice = 50},
			{Name = "Microsoft", Symbol = "MSFT", CurrentPrice = 25}
		}
	end

	return cachedStockData
end

-- Initialize on server start
function StockDataLoader:Initialize()
	print("[StockDataLoader] Initializing...")
	self:GetStockData(true) -- Force fetch on startup
	print("[StockDataLoader] Ready")
end

return StockDataLoader
