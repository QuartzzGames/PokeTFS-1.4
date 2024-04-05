local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local monstersToSummon = {"Rat", "Wolf", "Bear", "Cyclops", "Dragon", "Demon"} -- Lista de monstros a serem invocados
local currentMonsterIndex = 0 -- Índice do monstro atual na lista
local currentMonster = nil -- Referência para o monstro atualmente invocado

-- Função para invocar um monstro
local function summonMonster(cid)
	local npc = Npc(cid)
    local creature = Creature(cid)
    if creature then
        if currentMonsterIndex < #monstersToSummon then
            -- Verifica se o monstro anterior foi derrotado
            if currentMonsterId == 0 or not Creature(currentMonsterId) then
                currentMonsterIndex = currentMonsterIndex + 1
                local pos = creature:getPosition()
                pos.x = pos.x + 1
                local monster = Game.createMonster(monstersToSummon[currentMonsterIndex], pos)
                if monster then
                    currentMonsterId = monster:getId() -- Atualiza o ID do monstro atual
					monster:setMaster(npc)
				end
            end
        end
    end
end

local function greetCallback(cid)
    npcHandler:setMessage(MESSAGE_GREET, "Bem-vindo, viajante! Diga 'ataque' para iniciar o desafio.")
    return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)

local function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end

    if msgcontains(msg, 'ataque') and currentMonsterIndex == 0 then
        npcHandler:say("Prepare-se para enfrentar um desafio!", cid)
        summonMonster(cid) -- Invoca o primeiro monstro
        return true
    end
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())

-- Função chamada periodicamente para verificar se o monstro foi derrotado
function onThink()
    if currentMonsterIndex > 0 then
        -- Verifica se o monstro atual foi derrotado
        if not Creature(currentMonsterId) then
            if currentMonsterIndex < #monstersToSummon then
                summonMonster(getNpcCid()) -- Invoca o próximo monstro
            else
                -- Todos os monstros foram invocados e derrotados
                currentMonsterIndex = 0 -- Reseta o índice para permitir reiniciar o desafio
                currentMonsterId = 0 -- Reseta o ID do monstro
            end
        end
    end
    npcHandler:onThink()
end