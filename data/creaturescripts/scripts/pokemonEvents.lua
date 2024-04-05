function onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	local creature = Creature(creature)
	if creature then
		local player = creature:getMaster()
		local usingBall = player:getPokeballUsing()
		if not usingBall then return false end
		usingBall:pokemonDie()
	end

end
