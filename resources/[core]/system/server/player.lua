local SetTimeout = SetTimeout
local GetPlayerPed = GetPlayerPed
local DoesEntityExist = DoesEntityExist
local GetEntityCoords = GetEntityCoords
local GetEntityHeading = GetEntityHeading

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

	function self.setCoords(coords)
		local ped = GetPlayerPed(-1)

		if not type(coords) == 'vector4' then
			print('Invalid Coords Type')
		end

		SetEntityCoords(ped, coords.xyz, false, false, false, false)
		SetEntityHeading(ped, coords.w)
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
						heading = heading or 0.0,
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

	function self.getAccount(account)
		return self.accounts[account]
	end

	function self.getMoney(accountName)
		local account = self.getAccount(accountName)

		if account then
			return account.money
		end
	end

	function self.getFullMoney()
		local money = 0

		for i = 1, #self.accounts do
			money = money + self.accounts[i].money
		end

		return money
	end

	function self.setAccountMoney(accountName, money, reason)
		reason = reason or 'Unknown'
        
		if not tonumber(money) then 
			print('Invalid Money Type')
			return
		end

		if money >= 0 then
			local account = self.getAccount(accountName)

			if account then
				money = System.Math.Round(money)
				self.accounts[accountName].balance = money

				self.triggerEvent('system:setAccountMoney', account)
				TriggerEvent('system:setAccountMoney', self.playerId, accountName, money, reason)
			else 
				print('Invalid Account Name')
			end
		else 
			print('Invalid Money Amount')
		end
	end

	function self.addAccountMoney(accountName, money, reason)
		reason = reason or 'Unknown'

		if not tonumber(money) then 
			print('Invalid Money Type')
			return
		end

		if money > 0 then
			local account = self.getAccount(accountName)
			if account then
				money = System.Math.Round(money)
				self.accounts[accountName].balance += money

				self.triggerEvent('system:setAccountMoney', account)
				TriggerEvent('system:setAccountMoney', self.playerId, accountName, money, reason)
			else 
				print('Invalid Account Name')
			end
		else 
			print('Invalid Money Amount')
		end
	end

	function self.removeAccountMoney(accountName, money, reason)
		reason = reason or 'Unknown'

		if not tonumber(money) then 
			print('Invalid Money Type')
			return
		end

		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				money = System.Math.Round(money)
				self.accounts[accountName].balance -= money

				self.triggerEvent('system:setAccountMoney', account)
				TriggerEvent('system:setAccountMoney', self.playerId, accountName, money, reason)
			else 
				print('Invalid Account Name')
			end
		else 
			print('Invalid Money Amount')
		end
	end

	function self.setBanking(field, value, add)
		if add then
			if type(self.banking[field]) == 'table' then
				local index = #self.banking[field] + 1
				self.banking[field][index] = value
			else
				self.banking[field] += value
			end
		else
			self.banking[field] = value
		end
	end

	function self.getInventoryItem(name)
		for k, item in ipairs(self.inventory) do
			if itemv.name == name then
				return item
			end
		end
	end

	function self.addInventoryItem(name, count)
		local item = self.getInventoryItem(name)

		if item then
			count = System.Math.Round(count)
			item.count = item.count + count
			self.weight = self.weight + (item.weight * count)

			self.triggerEvent('system:addedInventoryItem', item.name, item.count)
			TriggerEvent('system:onAddInventoryItem', self.playerId, item.name, item.count)
		end
	end

	function self.removeInventoryItem(name, count)
		local item = self.getInventoryItem(name)

		if item then
			count = System.Math.Round(count)
			if count > 0 then
				local newCount = item.count - count

				if newCount >= 0 then
					item.count = newCount
					self.weight = self.weight - (item.weight * count)

					self.triggerEvent('system:removedInventoryItem', item.name, item.count)
					TriggerEvent('system:onRemoveInventoryItem', self.playerId, item.name, item.count)
				end
			else
				print('Invalid Count')
			end
		end
	end

	function self.setInventoryItem(name, count)
		local item = self.getInventoryItem(name)

		if item and count >= 0 then
			count = System.Math.Round(count)

			if count > item.count then
				self.addInventoryItem(item.name, count - item.count)
			else
				self.removeInventoryItem(item.name, item.count - count)
			end
		end
	end

	function self.addVehicle(vehicle, makeActive)
		table.insert(self.vehicles, vehicle)

		if makeActive then
			for _, v in ipairs(self.vehicles) do
				if v == vehicle then
					v.state.active = true
					break
				else
					v.state.active = false
				end
			end
		end

		self.triggerEvent('system:setVehicles', self.vehicles)
		TriggerEvent('system:setVehicles', self.playerId, self.vehicles)
	end

	function self.removeVehicle(plate)
		for k, v in ipairs(self.vehicles) do
			if v.plate == plate then
				table.remove(self.vehicles, k)
				break
			end
		end

		self.triggerEvent('system:setVehicles', self.vehicles)
		TriggerEvent('system:setVehicles', self.playerId, self.vehicles)
	end

	function self.setVehicles(vehicleList)
		self.vehicles = vehicleList

		self.triggerEvent('system:setVehicles', self.vehicles)
		TriggerEvent('system:setVehicles', self.playerId, self.vehicles)
	end

	function self.canCarryItem(name, count)
        if System.Items[name] then
            local currentWeight, itemWeight = self.weight, System.Items[name].weight
            local newWeight = currentWeight + (itemWeight * count)

            return newWeight <= self.maxWeight
        else
            print('Invalid Item Name')
        end
	end

	function self.setMaxWeight(newWeight)
		self.maxWeight = newWeight
		self.triggerEvent('system:updatedMaxWeight', self.maxWeight)
	end

	function self.setJob(job, grade)
		grade = tostring(grade)
		local lastJob = self.job

		if System.DoesJobExist(job, grade) then
			local jobObject, gradeObject = System.Jobs[job], System.Jobs[job].grades[grade]

			self.job = {
				id = jobObject.id,
				name = jobObject.name,
				label = jobObject.label,
				grade = tonumber(grade),
				gradeName = gradeObject.name,
				gradeSalary = gradeObject.salary,
			}

			if gradeObject.skinMale then
				self.job.skinMale = json.decode(gradeObject.skinMale)
			else
				self.job.skinMale = {}
			end

			if gradeObject.skin_female then
				self.job.skinFemale = json.decode(gradeObject.skinFemale)
			else
				self.job.skinFemale = {}
			end

			self.triggerEvent('system:updatedJob', self.job, lastJob)
			TriggerEvent('system:setJob', self.playerId, self.job, lastJob)

			Player(self.playerId).state:set('job', self.job, true)
		else
			print('Invalid Job Name or Grade')
		end
	end

	function self.addWeapon(weaponName, ammo)
		if not self.hasWeapon(weaponName) then
			local weaponLabel = System.GetWeaponLabel(weaponName)
			local weapon = {
				name = weaponName,
				ammo = ammo,
				label = weaponLabel,
				components = {},
				tintIndex = 0
			}

			table.insert(self.loadout, weapon)

			self.triggerEvent('system:addedWeapon', weapon)
			GiveWeaponToPed(GetPlayerPed(self.playerId), joaat(weaponName), ammo, false, false)
		end
	end

	function self.addWeaponComponent(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = System.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if not self.hasWeaponComponent(weaponName, weaponComponent) then
					self.loadout[loadoutNum].components[#self.loadout[loadoutNum].components + 1] = weaponComponent
					local componentHash = System.GetWeaponComponent(weaponName, weaponComponent).hash

					self.triggerEvent('system:addedWeaponComponent', weaponName, weaponComponent)
					GiveWeaponComponentToPed(GetPlayerPed(self.playerId), joaat(weaponName), componentHash)
				end
			end
		end
	end

	function self.addWeaponAmmo(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo + ammoCount
			SetPedAmmo(GetPlayerPed(self.playerId), joaat(weaponName), weapon.ammo)
		end
	end

	function self.updateWeaponAmmo(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = ammoCount
		end
	end

	function self.setWeaponTint(weaponName, weaponTintIndex)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local weaponNum, weaponObject = System.GetWeapon(weaponName)

			if weaponObject.tints and weaponObject.tints[weaponTintIndex] then
				self.loadout[loadoutNum].tintIndex = weaponTintIndex
				self.triggerEvent('system:updatedWeaponTint', weaponName, weaponTintIndex)
			end
		end
	end

	function self.getWeaponTint(weaponName)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			return weapon.tintIndex
		end

		return 0
	end

	function self.removeWeapon(weaponName)
		local weaponLabel

		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				weaponLabel = v.label

				for k2,v2 in ipairs(v.components) do
					self.removeWeaponComponent(weaponName, v2)
				end

				table.remove(self.loadout, k)
				break
			end
		end

		if weaponLabel then
			self.triggerEvent('system:removedWeapon', weaponName)
		end
	end

	function self.removeWeaponComponent(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = System.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if self.hasWeaponComponent(weaponName, weaponComponent) then
					for k,v in ipairs(self.loadout[loadoutNum].components) do
						if v == weaponComponent then
							table.remove(self.loadout[loadoutNum].components, k)
							break
						end
					end

					self.triggerEvent('system:removedWeaponComponent', weaponName, weaponComponent)
				end
			end
		end
	end

	function self.removeWeaponAmmo(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo - ammoCount
			self.triggerEvent('system:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	function self.hasWeaponComponent(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			for k,v in ipairs(weapon.components) do
				if v == weaponComponent then
					return true
				end
			end

			return false
		else
			return false
		end
	end

	function self.hasWeapon(weaponName)
		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return true
			end
		end

		return false
	end

	function self.hasItem(item, metadata)
		for k,v in ipairs(self.inventory) do
			if (v.name == item) and (v.count >= 1) then
				return v, v.count
			end
		end

		return false
	end

	function self.getWeapon(weaponName)
		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return k, v
			end
		end
	end

	return self
end
