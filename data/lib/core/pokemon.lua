--dofile('data/items/pokeballs.lua')

function beingUsed(cid)
		if not cid then return false end
		local beingUse = cid:getCustomAttribute("isBeingUsed")

		if beingUse ~= nil and beingUse == 1 then
			cid:setCustomAttribute("isBeingUsed", 0)
			return false
		elseif beingUse ~= nil and beingUse == 0 then
			cid:setCustomAttribute("isBeingUsed", 1)
			return true
		end

		return false
end

--FUNCIONANDO
function getPokemonNameItem(item)
		local pokeName = item:getCustomAttribute(ITEM_ATTRIBUTE_POKEBALL)
		if pokeName ~= nil and pokeName ~= "" then
			return pokeName
		end
		return nil
end


function getPokemonNickOrName(cid)
		local pokeName = cid:getCustomAttribute("pokeName")
		local nickname = cid:getCustomAttribute("nickname")
		if pokeName ~= nil and pokeName ~= "" then
			if nickname ~= nil and nickname ~= "" then
				return nickname
			end
			return pokeName
		end
		return nil
end

function Item.isPokeball(self)
		local pokeName = getPokemonNameItem(self)
		if pokeName ~= nil and pokeName ~= "" then
			return true
		end
		return false
end

--FUNCIONANDO
function Item.setPokemonHealth(self, health)
		if(health <= 0 ) then
			health = 0
			doUsed(self, 0)
		end
		self:setCustomAttribute(ITEM_ATTRIBUTE_POKEMONHEALTH, health)
end

--FUNCIONANDO
function Item.getPokemonHealthAtual(self)
	 local life = self:getCustomAttribute(ITEM_ATTRIBUTE_POKEMONHEALTH)
	 return life
end


function Player.resetBalls(self)
	local balls = self:getPokeballs()
		for i = 1, #balls do
			local ball = balls[i]
			ball:setCustomAttribute("isBeingUsed", 0)
		end
end

function Item.dischargedPokeball(self)
	self:setCustomAttribute("isBeingUsed", 0)
	return
end

function Player.comSummon(self)
	local haveSummon = self:haveSummon()
		if haveSummon then	return true	end
		self:getPosition():sendMagicEffect(CONST_ME_POFF)
	return false
end

--FUNCIONANDO
function Player.getPokeballUsing(self)

	local pokeballs = self:getPokeballsOnContainer()
	if not pokeballs then
		print("WARNING! getPokeballUsing not found player " .. self:getName())
		return nil
	end
	
	for i = 1, #pokeballs do
		local ball = pokeballs[i]
		if not ball then return end
		local isBallBeingUsed = ball:getCustomAttribute(ITEM_ATTRIBUTE_ISUSED)
		local pokeName = ball:getCustomAttribute(ITEM_ATTRIBUTE_POKEBALL)
		
		if isBallBeingUsed and isBallBeingUsed == 1 then
			return ball
		end
	end
	return nil
end





--FUNCIONANDO
function doBackSummon(cid)
	local player = Player(cid)
	if not player then return false end
	local summons = player:getSummons()
	if not summons then return false end
	local summon = Creature(summons[1])
	if not summon then return false	end
	
	if isInCombat(player,summon) then
		return false
	end
	
		local ballUsing = player:getPokeballUsing()
		ballUsing:setPokemonHealth(summon:getHealth())
				   
    

		summon:unregisterEvent("PokemonDeath")
		doUsed(ballUsing, 0)
		summon:remove()	

		return true
end

--funcionando
function summonMonster(player, monsterName, toPosition, item)
    
	local healthAtual = item:getPokemonHealthAtual()
	
	local monster = Game.createMonster(monsterName, player:getPosition())
	
    if monster then  
       
		monster:setMaster(player)
        monster:setHealth(healthAtual)
		monster:registerEvent("PokemonDeath")
        doUsed(item, 1) 
    end
end

--funcionando
function handleSummonWithItem(player, item, toPosition)


	if not item:canCallPokemon(player) then return false end

    local monsterName = getPokemonNameItem(item)
    if not monsterName then
        return player:sendTextMessage(MESSAGE_STATUS_SMALL, "This item is not a pokeball.")
    end

    local usingBall = player:getPokeballUsing()

    if not usingBall then
        summonMonster(player, monsterName, toPosition, item)
    else

		
       if doBackSummon(player) then

		 if monsterName ~= getPokemonNameItem(usingBall) then
            summonMonster(player, monsterName, toPosition, item)
		 else
			if usingBall:getUniqueId() ~= item:getUniqueId() then
				summonMonster(player, monsterName, toPosition, item)
			end
		 end
		end
    end
end

--FUNCIONANDO
function Item.pokemonDie(usingBall)
	usingBall:setPokemonHealth(0)
end

function isBeignUsed(item)
	if not item then return false end
	local beingUse = item:getCustomAttribute(ITEM_ATTRIBUTE_ISUSED)
	if beingUse ~= nil and beingUse == 1 then
		return true
	elseif beingUse ~= nil and beingUse == 0 then
		--cid:setCustomAttribute("isBeingUsed", 0)
		return false
	end
end


--FUNCIONANDO
function doUsed(item, value)
	if not item then return false end
	item:setCustomAttribute(ITEM_ATTRIBUTE_ISUSED, value)
	return true
end

--FUNCIONANDO
function Item.canCallPokemon(self, player)
	if self:pokemonVivo(player) then
		return true
	else
		return false
	end
end


function hasSummons(cid)
	local summons = cid:getSummons()
	if #summons > 0 then
		return true
	end
	return false
end


function isInCombat(player, monster)
    local target = monster:getTarget()
    if target and target ~= player then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your Pokemon is in combat.")
		return true
		
    end

    -- Verifica se o alvo do summon é outro summon do jogador
    local summons = player:getSummons()
    for i, summon in ipairs(summons) do
        if target == summon then
            return false -- O alvo é outro summon do jogador, então não está em combate real
        end
    end
		
    return false
end

--FUNCIONANDO
function Item.pokemonVivo(self, player)
	local treiner = Player(player)

	if not treiner then return false end
	local healthAtual = self:getPokemonHealthAtual()

	if  healthAtual <= 0 then
		treiner:sendTextMessage(MESSAGE_STATUS_SMALL, "Sorry, not possible. Your summon is dead.")
		self:pokemonDie()
		return false
	end
	return true
end