
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local split = param:splitTrimmed(",")

	local pokeName = split[1]

	--get the itemid from param
	local idItem = 21703
	local newMonster = MonsterType(pokeName)
	if not newMonster then
		player:sendCancelMessage("Invalid monster name.")
		return false
	end

	-- Code to create the new item based on the provided parameters
	local pokeball = Game.createItem(idItem, 1)
	if not pokeball then
		player:sendCancelMessage("Failed to create the item.")
		return false
	end
	--get a monsterMaxHealth from the monsterType
	local monsterMaxHealth = newMonster:getMaxHealth()

	pokeball:setCustomAttribute(ITEM_ATTRIBUTE_POKEBALL, newMonster:getName())
	doUsed(pokeball, 0)
	pokeball:setPokemonHealth(monsterMaxHealth)

	player:addItemEx(pokeball)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You have created a new pokeball.")

	return false
end
