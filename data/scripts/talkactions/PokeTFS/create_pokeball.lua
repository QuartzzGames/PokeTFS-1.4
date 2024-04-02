local createpokeball = TalkAction("/cb")

function createpokeball.onSay(player, words, param)
    local name = param -- use the command parameter as the name
    if name == "" then
        print("No name specified.")
        return false
    end
    local monsterType = Game.getMonsterType(name)
    if monsterType == nil then
        print("Invalid monster name.")
        return false
    end
    local result = player:addItem(2520, 1, false, 1, CONST_SLOT_BACKPACK)
    if result ~= nil then
        local baseHealth = monsterType:getMaxHealth()
        result:setSpecialAttribute("pokeName", name)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
        return true
    else
        player:sendCancelMessage("Backpack full.")
    end
    return false
end

createpokeball:separator(" ")
createpokeball:register()