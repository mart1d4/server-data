function CreatePlayer(
	playerId,
	identifier,
	name,
	group,
	position,
	accounts,
	banking,
	inventory,
	loadout,
	identity,
	vehicles,
	properties,
	carryWeight,
	job
)
	local self = {}

	self.playerId = playerId
	self.identifier = identifier
	self.name = name
	self.group = group
	self.position = position
	self.accounts = accounts
	self.banking = banking
	self.inventory = inventory
	self.loadout = loadout
	self.identity = identity
	self.vehicles = vehicles
	self.properties = properties
	self.carryWeight = carryWeight
	self.maxWeight = Config.MaxWeight
	self.job = job

	ExecuteCommand(('add_principal identifier.%s group.%s'):format(
		'license:' .. self.identifier,
		self.group
	))

	local stateBag = Player(self.playerId).state
	stateBag:set('name', self.name, true)
	stateBag:set('group', self.group, true)
	stateBag:set('job', self.job, true)

	function self.triggerEvent(eventName, ...)
		TriggerClientEvent(eventName, self.playerId, ...)
	end

	function self.updateCoords()
		SetTimeout(500, function()
			local ped = GetPlayerPed(self.playerId)

			if DoesEntityExist(ped) then
				local coords = GetEntityCoords(ped)
				local distance = #(coords - vector3(self.position.x, self.position.y, self.position.z))

				if distance > 0.5 then
					local heading = GetEntityHeading(ped)

					self.position = {
						x = coords.x,
						y = coords.y,
						z = coords.z,
						heading = heading,
					}
				end
			end

			self.updateCoords()
		end)
	end

	function self.kick(reason)
		DropPlayer(self.playerId, reason or 'Unknown')
	end

	function self.setGroup(newGroup)
		ExecuteCommand(('remove_principal identifier.%s group.%s'):format(
			'license:' .. self.identifier,
			self.group
		))

		self.group = newGroup
		Player(self.playerId).state:set('group', self.group, true)

		ExecuteCommand(('add_principal identifier.%s group.%s'):format(
			'license:' .. self.identifier,
			self.group
		))
	end

	-- Accounts
	function getTotalMoney()
		local total = 0

		for _, v in pairs(self.accounts) do
			total = total + v
		end

		return total
	end

	function getAccountMoney(account)
		for k, v in pairs(self.accounts) do
			if k == account then
				return v
			end
		end

		return nil
	end

	function setAccountMoney(account, amount)
		if not tonumber(amount) then
			print('[Player:SetAccountMoney] Invalid Money Type')
			return nil
		end

		if getAccountMoney(account) ~= nil and amount > 0 then
			accounts[account] = System.Math.Round(amount)

			self.triggerEvent('system:playerUpdated', 'accounts', self.accounts)
			TriggerEvent('system:playerUpdated', self.playerId)

			return amount
		end

		return nil
	end

	function addAccountMoney(account, amount)
		if not tonumber(amount) then
			print('[Player:AddAccountMoney] Invalid Money Type')
			return nil
		end

		if getAccountMoney(account) ~= nil and amount > 0 then
			accounts[account] = accounts[account] + System.Math.Round(amount)

			self.triggerEvent('system:playerUpdated', 'accounts', self.accounts)
			TriggerEvent('system:playerUpdated', self.playerId)

			return accounts[account]
		end

		return nil
	end

	function removeAccountMoney(account, amount)
		if not tonumber(amount) then
			print('[Player:RemoveAccountMoney] Invalid Money Type')
			return nil
		end

		if getAccountMoney(account) ~= nil and amount > 0 then
			if accounts[account] - amount >= 0 then
				accounts[account] = accounts[account] - System.Math.Round(amount)

				self.triggerEvent('system:playerUpdated', 'accounts', self.accounts)
				TriggerEvent('system:playerUpdated', self.playerId)

				return accounts[account]
			end
		end

		return nil
	end

	-- Banking
	function self.addBankingTransaction(transaction)
		table.insert(self.banking.transactionHistory, transaction)

		self.triggerEvent('system:playerUpdated', 'banking', self.banking)
		TriggerEvent('system:playerUpdated', self.playerId)
	end

	-- Vehicles
	function self.addVehicle(vehicle, makeActive)
		table.insert(self.vehicles, vehicle)

		if makeActive then
			for _, v in ipairs(self.vehicles) do
				if v.plate == vehicle.plate then
					v.state.active = true
					break
				else
					v.state.active = false
				end
			end
		end

		self.triggerEvent('system:playerUpdated', 'vehicles', self.vehicles)
		TriggerEvent('system:playerUpdated', self.playerId)
	end

	function self.removeVehicle(plate)
		for k, v in ipairs(self.vehicles) do
			if v.plate == plate then
				table.remove(self.vehicles, k)
				break
			end
		end

		self.triggerEvent('system:playerUpdated', 'vehicles', self.vehicles)
		TriggerEvent('system:playerUpdated', self.playerId)
	end

	-- Items
	function getItemPrice(item)
		return self.inventory[item]["Price"]
	end

	function getItemAmount(item)
		return self.inventory[item]["Amount"]
	end

	function getItemWeight(item)
		return self.inventory[item]["Weight"]
	end

	function getItemDescription(item)
		return self.inventory[item]["Description"]
	end

	function getItemsWeight()
		local total = 0

		for _, v in pairs(self.inventory) do
			total = total + v["Weight"]
		end

		return total
	end

	function getItemsPrice()
		local total = 0

		for _, v in pairs(self.inventory) do
			total = total + v["Price"]
		end

		return total
	end

	function getItemsCount()
		local total = 0

		for _, v in pairs(self.inventory) do
			total = total + v["Amount"]
		end

		return total
	end

	function addItem(item, amount)
		if self.inventory[item] ~= nil then
			if getItemsWeight() + amount <= self.carryWeight then
				self.inventory[item]["Amount"] = self.inventory[item]["Amount"] + amount

				self.triggerEvent('system:playerUpdated', 'inventory', self.inventory)
				TriggerEvent('system:playerUpdated', self.playerId)

				return self.inventory[item]["Amount"]
			end
		end

		return nil
	end

	function removeItem(item, amount)
		if self.inventory[item] ~= nil then
			if self.inventory[item]["Amount"] - amount >= 0 then
				self.inventory[item]["Amount"] = self.inventory[item]["Amount"] - amount

				self.triggerEvent('system:playerUpdated', 'inventory', self.inventory)
				TriggerEvent('system:playerUpdated', self.playerId)

				return self.inventory[item]["Amount"]
			end
		end

		return nil
	end

	-- Weight
	function self.setMaxWeight(newWeight)
		if not tonumber(newWeight) then
			print('[Player:SetMaxWeight] Invalid Weight Type')
			return nil
		end

		if newWeight > 0 then
			self.maxWeight = newWeight
			self.triggerEvent('system:playerUpdated', 'maxWeight', self.maxWeight)
			TriggerEvent('system:playerUpdated', self.playerId)

			return self.maxWeight
		end
	end

	-- Jobs
	function self.setJob(jobName, grade)
		grade = tostring(grade)

		if System.Jobs[jobName] ~= nil then
			local jobObject, gradeObject = System.Jobs[jobName], System.Jobs[jobName].grades[grade]

			self.job = {
				name = jobObject.name,
				grade = tonumber(grade),
				gradeName = gradeObject.name,
				salary = gradeObject.salary,
			}

			self.job.skinMale = json.decode(gradeObject.skinMale) or {}
			self.job.skinFemale = json.decode(gradeObject.skinFemale) or {}

			self.triggerEvent('system:playerUpdated', 'job', self.job)
			TriggerEvent('system:playerUpdated', self.playerId)

			Player(self.playerId).state:set('job', self.job, true)
		else
			print('Invalid Job Name or Grade')
		end
	end

	-- Weapons
	--
	--
	--

	return self
end
