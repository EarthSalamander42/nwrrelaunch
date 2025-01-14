-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false
--Set this to false to deactive cheat inputs(cheats.lua) and true to activate cheat inputs 
CHEATS_ACTIVATED = true

if GameMode == nil then
	_G.GameMode = class({})
end

--TODO find a way to get position of the shops by name/entityname
--base shop position team 1 
SHOP_TEAM_1 = Vector(-832, 768, 128) 
--base shop position team 2
SHOP_TEAM_2 = Vector(-832, 768, 128)

require('libraries/vanilla_extension')
require('libraries/adv_log') -- extended print functionalities. Credits: Dota IMBA
-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
require('libraries/keyvalues')

require('utilities')
-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

require('components/garbage_collector')
require('components/voicelines/voicelines')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

--[[
	This function should be used to set up Async precache calls at the beginning of the gameplay.

	In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
	after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
	be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
	precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
	defined on the unit.

	This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
	time, you can call the functions individually (for example if you want to precache units in a new wave of
	holdout).

	This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
--[[
	PrecacheResource("soundfile", "soundevents/oddball_sounds.vsndevts", context)
	PrecacheItemByNameSync("item_oddball", context)
--]]
end

--[[
	This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
	It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
end

--[[
	This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
	It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
end

--[[
	This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
	if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
	levels, changing the starting gold, removing/adding abilities, adding physics, etc.

	The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
	local playerId = hero:GetPlayerOwnerID()
	Timers:CreateTimer(80, function()
		local playerId = hero:GetPlayerOwnerID()
		if hero:GetTeamNumber() == 2 then
			EmitSoundOnEntityForPlayer("shinobi_start", hero, playerId)
		else
			EmitSoundOnEntityForPlayer("akat_start", hero, playerId)
		end
	end
	)

	GameMode:RemoveWearables( hero )

	if hero:IsCustomHero() then
		sendOverrideHeroImage(hero)

		VoiceResponses:RegisterUnit(hero:GetUnitName(), "scripts/vscripts/components/voicelines/keyvalues/"..string.gsub(hero:GetUnitName(), "npc_dota_hero_", "").."_responses.txt")
	end
end


function sendOverrideHeroImage(hero)
	CustomGameEventManager:Send_ServerToAllClients("override_hero_image", {
		player_id = hero:GetPlayerID(),
		icon_path = hero:GetUnitName(),
	})

	Timers:CreateTimer( 5, function()
		sendOverrideHeroImage(hero)
	end)
end

function GameMode:OnNewHeroSelected(event)


	DebugPrint("TESSSSSST")
	DebugPrintTable(event)


end


function GameMode:OnNewHeroChosen(event)


	DebugPrint("TESSST2")
	DebugPrintTable(event)


end

function GameMode:OnEntityKilled(event)

	local hAttacker = ( type(event.entindex_attacker) == "number" ) and EntIndexToHScript(event.entindex_attacker) or nil
	local hTarget   = ( type(event.entindex_killed) == "number" ) and EntIndexToHScript(event.entindex_killed) or nil

	if not hAttacker:IsRealHero() then
		return nil
	end

	if hTarget ~= nil
	and hTarget:IsRealHero()
		and not hTarget:IsClone()
		and not hTarget:IsTempestDouble()
		and not hTarget:IsReincarnating()
		then
			CustomGameEventManager:Send_ServerToAllClients("hero_killed", {
				attacker = hAttacker,
				target = hTarget,
				victim_team_id = hTarget:GetTeamNumber(),
				victim_id = hTarget:GetPlayerID(),
				team_id = hAttacker:GetTeamNumber(),
				killer_id = hAttacker:GetPlayerID()
			})
			return nil
	end

	if hTarget ~= nil
		and hTarget:IsCreep()
		and hAttacker:IsRealHero()
		and hTarget:GetTeamNumber() ~= hAttacker:GetTeamNumber()
		and not hTarget:IsTempestDouble()
		and not hTarget:IsReincarnating()
		then
			CustomGameEventManager:Send_ServerToAllClients("lasthit", {
				attacker = hAttacker,
				target = hTarget,
				team_id = hAttacker:GetTeamNumber(),
				killer_id = hAttacker:GetPlayerID()
			})
			return nil
	end

	if hTarget ~= nil
		and hTarget:IsCreep()
		and hAttacker:IsRealHero()
		and hTarget:GetTeamNumber() == hAttacker:GetTeamNumber()
		and not hTarget:IsTempestDouble()
		and not hTarget:IsReincarnating()
		then
			CustomGameEventManager:Send_ServerToAllClients("deny", {
				attacker = hAttacker,
				target = hTarget,
				team_id = hAttacker:GetTeamNumber(),
				killer_id = hAttacker:GetPlayerID()
			})
			return nil
	end
end

--[[
	This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
	gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
	is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()

end


-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
	SendToServerConsole("dota_combine_models 0")
	-- Call the internal function to set up the rules/behaviors specified in constants.lua
	-- This also sets up event hooks for all event handlers in events.lua
	-- Check out internals/gamemode to see/modify the exact code
	self:_InitGameMode()

	-- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
	Convars:RegisterCommand( "command_example", Dynamic_Wrap(self, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )
	ListenToGameEvent('player_chat', Dynamic_Wrap(self, 'OnPlayerChat'), self)
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
	local cmdPlayer = Convars:GetCommandClient()

	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
			-- Do something here for the player who called this command
			PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
		end
	end
end

function GameMode:RemoveWearables( hero )
	local wearables = {}
	local model = hero:FirstMoveChild()
	while model ~= nil do
		if model ~= nil and model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
			table.insert(wearables, model)
		end
		model = model:NextMovePeer()
	end

	for i = 1, #wearables do
		wearables[i]:RemoveSelf()
	end
end

function GameMode:OnThink()
	GarbageCollector:OnThink()

	return 1
end

function GameMode:SetShops()
	local shopkeeper_radiant = Entities:FindByModel(nil, "models/heroes/shopkeeper/shopkeeper.vmdl")

	if shopkeeper_radiant then
		shopkeeper_radiant:SetModelScale(2.4)
	end

	local shopkeeper_dire = Entities:FindByModel(nil, "models/heroes/shopkeeper_dire/shopkeeper_dire.vmdl")

	if shopkeeper_dire then
		shopkeeper_dire:SetModelScale(2.4)
	end
end
