-- Services
local DataStoreService = game:GetService("DataStoreService")

-- Data Stores
local PortfolioDataStore = DataStoreService:GetDataStore("PlayerPortfolio")

-- Module
local PortfolioManager = {}
PortfolioManager.PlayerPortfolio = {}

-- Public Functions

function PortfolioManager:GetPortfolio(player)
	return self.PlayerPortfolio[player.UserId] or {}
end

function PortfolioManager:GetShares(player, symbol)
	local portfolio = self:GetPortfolio(player)
	return portfolio[symbol] or 0
end

function PortfolioManager:SetShares(player, symbol, quantity)
	local userId = player.UserId
	if not self.PlayerPortfolio[userId] then
		self.PlayerPortfolio[userId] = {}
	end

	if quantity > 0 then
		self.PlayerPortfolio[userId][symbol] = quantity
	else
		-- Remove entry if quantity is 0 or less
		self.PlayerPortfolio[userId][symbol] = nil
	end

	return self.PlayerPortfolio[userId][symbol]
end

function PortfolioManager:AddShares(player, symbol, quantity)
	if quantity <= 0 then
		warn("Cannot add non-positive quantity of shares")
		return nil
	end

	local current = self:GetShares(player, symbol)
	local newQuantity = current + quantity
	self:SetShares(player, symbol, newQuantity)
	return newQuantity
end

function PortfolioManager:RemoveShares(player, symbol, quantity)
	if quantity <= 0 then
		warn("Cannot remove non-positive quantity of shares")
		return nil
	end

	local current = self:GetShares(player, symbol)
	if current >= quantity then
		local newQuantity = current - quantity
		self:SetShares(player, symbol, newQuantity)
		return newQuantity
	else
		warn("Insufficient shares to remove for", player.Name, "- Has:", current, "Trying to remove:", quantity)
		return nil
	end
end

function PortfolioManager:LoadPlayerPortfolio(player)
	local userId = player.UserId
	local success, portfolio = pcall(function()
		return PortfolioDataStore:GetAsync("Player_" .. userId)
	end)

	if success and portfolio then
		self.PlayerPortfolio[userId] = portfolio
		print("Loaded portfolio for", player.Name)
	else
		-- New players start with empty portfolio
		self.PlayerPortfolio[userId] = {}
		print("New player", player.Name, "starting with empty portfolio")
	end
end

function PortfolioManager:SavePlayerPortfolio(player)
	local userId = player.UserId
	local portfolio = self.PlayerPortfolio[userId]

	if not portfolio then
		warn("No portfolio data to save for", player.Name)
		return false
	end

	local success, err = pcall(function()
		PortfolioDataStore:SetAsync("Player_" .. userId, portfolio)
	end)

	if success then
		print("Saved portfolio for", player.Name)
		return true
	else
		warn("Failed to save portfolio for", player.Name, ":", err)
		return false
	end
end

return PortfolioManager
