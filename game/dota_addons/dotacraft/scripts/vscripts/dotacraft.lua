 print ('[DOTACRAFT] dotacraft.lua' )
--[[
	dota_launch_custom_game dotacraft echo_isles
	dota_launch_custom_game dotacraft hills_of_glory
]]

CORPSE_MODEL = "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_troll_skeleton_fx.vmdl"
CORPSE_DURATION = 88

DISABLE_FOG_OF_WAR_ENTIRELY = false
CAMERA_DISTANCE_OVERRIDE = 1600
UNSEEN_FOG_ENABLED = false

UNDER_ATTACK_WARNING_INTERVAL = 60

XP_PER_LEVEL_TABLE = {
	0, -- 1
	200, -- 2 +200
	500, -- 3 +300
	900, -- 4 +400
	1400, -- 5 +500
	2000, -- 6 +600
	2700, -- 7 +700
	3500, -- 8 +800
	4400, -- 9 +900
	5400 -- 10 +1000
 }

XP_BOUNTY_TABLE = {
	25,
	40,
	60,
	85,
	115,
	150,
	190,
	235,
	285,
	340
}

XP_NEUTRAL_SCALING = {
	0.80,
	0.70, 
	0.62,
	0.55,
	0,
	0,
	0,
	0,
	0,
	0
}

TEAM_COLORS = {}
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 52, 85, 255 }   --  Blue
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 255, 52, 85 }  	--  Red
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 61, 210, 150 }  --  Teal
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 140, 42, 244 }  --  Purple
TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 243, 201, 9 }   --  Yellow
TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 255, 108, 0 }   --  Orange
TEAM_COLORS[DOTA_TEAM_CUSTOM_5] = { 101, 212, 19 }  --  Green
TEAM_COLORS[DOTA_TEAM_CUSTOM_6] = { 197, 77, 168 }  --  Pink
TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 129, 83, 54 }   --  Brown
TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 199, 228, 13 }  --  Olive

--------------

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function dotacraft:InitGameMode()
	print('[DOTACRAFT] Starting to load dotacraft gamemode...')

	-- Setup rules
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( false )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetHeroSelectionTime( 30 )
	GameRules:SetPreGameTime( 0 )
	GameRules:SetPostGameTime( 60 )
	GameRules:SetTreeRegrowTime( 10000.0 )
	GameRules:SetUseCustomHeroXPValues ( true )
	GameRules:SetGoldPerTick(0)
	GameRules:SetUseBaseGoldBountyOnHeroes( false ) -- Need to check legacy values
	GameRules:SetHeroMinimapIconScale( 1 )
	GameRules:SetCreepMinimapIconScale( 1 )
	GameRules:SetRuneMinimapIconScale( 1 )
	GameRules:SetFirstBloodActive( false )
  	GameRules:SetHideKillMessageHeaders( true )

  	-- Set game mode rules
	GameMode = GameRules:GetGameModeEntity()        
	GameMode:SetRecommendedItemsDisabled( true )
	GameMode:SetBuybackEnabled( false )
	GameMode:SetTopBarTeamValuesOverride ( true )
	GameMode:SetTopBarTeamValuesVisible( true )
	GameMode:SetUseCustomHeroLevels ( true )
	GameMode:SetUnseenFogOfWarEnabled( UNSEEN_FOG_ENABLED )	
	GameMode:SetTowerBackdoorProtectionEnabled( false )
	GameMode:SetGoldSoundDisabled( false )
	GameMode:SetRemoveIllusionsOnDeath( false )
	GameMode:SetAnnouncerDisabled( true )
	GameMode:SetLoseGoldOnDeath( false )
	GameMode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
	GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	GameMode:SetFogOfWarDisabled( DISABLE_FOG_OF_WAR_ENTIRELY )
	GameMode:SetCustomHeroMaxLevel ( 10 )

	-- Team Colors
	for team,color in pairs(TEAM_COLORS) do
      SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
    end

	GameMode:SetHUDVisible(9, false)  -- Get Rid of Courier
	GameMode:SetHUDVisible(12, false)  -- Get Rid of Recommended items
	GameMode:SetHUDVisible(1, false) -- Get Rid of Heroes on top
	GameMode:SetHUDVisible(6, false)  -- Get Rid of Shop button
	GameMode:SetHUDVisible(8, false) -- Get Rid of Quick Buy

	-- TEST --
	-- GameMode:SetCustomGameForceHero("npc_dota_hero_dragon_knight")
	----------

	print('[DOTACRAFT] Game Rules set')

	-- Multi Team Configuration - Should be acquired from the UI, to allow 1v1v1v1 or 2v2 on the same map for example.
	if GetMapName() == "hills_of_glory" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
	elseif GetMapName() == "copper_canyon" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3 )
	else
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 2 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 2 )
	end

	-- Keep track of the last time each player was damaged (to play warnings/"we are under attack")
	GameRules.PLAYER_BUILDINGS_DAMAGED = {}	
	GameRules.PLAYER_DAMAGE_WARNING = {}

	dotacraft:DeterminePathableTrees()
	print('[DOTACRAFT] Pathable Trees set')

	-- Event Hooks
	ListenToGameEvent('entity_killed', Dynamic_Wrap(dotacraft, 'OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(dotacraft, 'OnConnectFull'), self)
	ListenToGameEvent('player_connect', Dynamic_Wrap(dotacraft, 'PlayerConnect'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(dotacraft, 'OnAbilityUsed'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(dotacraft, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(dotacraft, 'OnPlayerPickHero'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(dotacraft, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('entity_hurt', Dynamic_Wrap(dotacraft, 'OnEntityHurt'), self)
	ListenToGameEvent('tree_cut', Dynamic_Wrap(dotacraft, 'OnTreeCut'), self)
	--ListenToGameEvent('player_disconnect', Dynamic_Wrap(dotacraft, 'OnDisconnect'), self)
	--ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(dotacraft, 'OnItemPurchased'), self)
	--ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(dotacraft, 'OnItemPickedUp'), self)
	--ListenToGameEvent('last_hit', Dynamic_Wrap(dotacraft, 'OnLastHit'), self)
	--ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(dotacraft, 'OnNonPlayerUsedAbility'), self)
	--ListenToGameEvent('player_changename', Dynamic_Wrap(dotacraft, 'OnPlayerChangedName'), self)
	--ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(dotacraft, 'OnRuneActivated'), self)
	--ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(dotacraft, 'OnPlayerTakeTowerDamage'), self)
	--ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(dotacraft, 'OnTeamKillCredit'), self)
	--ListenToGameEvent("player_reconnected", Dynamic_Wrap(dotacraft, 'OnPlayerReconnect'), self)
	--ListenToGameEvent('player_spawn', Dynamic_Wrap(dotacraft, 'OnPlayerSpawn'), self)
	--ListenToGameEvent('dota_unit_event', Dynamic_Wrap(dotacraft, 'OnDotaUnitEvent'), self)
	--ListenToGameEvent('nommed_tree', Dynamic_Wrap(dotacraft, 'OnPlayerAteTree'), self)
	--ListenToGameEvent('player_completed_game', Dynamic_Wrap(dotacraft, 'OnPlayerCompletedGame'), self)
	--ListenToGameEvent('dota_match_done', Dynamic_Wrap(dotacraft, 'OnDotaMatchDone'), self)
	--ListenToGameEvent('dota_combatlog', Dynamic_Wrap(dotacraft, 'OnCombatLogEvent'), self)
	--ListenToGameEvent('dota_player_killed', Dynamic_Wrap(dotacraft, 'OnPlayerKilled'), self)
	--ListenToGameEvent('player_team', Dynamic_Wrap(dotacraft, 'OnPlayerTeam'), self)

	-- Filter Execute Order
    GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( dotacraft, "FilterExecuteOrder" ), self )

    -- Register Listener
    CustomGameEventManager:RegisterListener( "update_selected_entities", Dynamic_Wrap(dotacraft, 'OnPlayerSelectedEntities'))
    CustomGameEventManager:RegisterListener( "gold_gather_order", Dynamic_Wrap(dotacraft, "GoldGatherOrder")) --Right click through panorama
    CustomGameEventManager:RegisterListener( "repair_order", Dynamic_Wrap(dotacraft, "RepairOrder")) --Right click through panorama
    CustomGameEventManager:RegisterListener( "building_rally_order", Dynamic_Wrap(dotacraft, "OnBuildingRallyOrder")) --Right click through panorama
    CustomGameEventManager:RegisterListener( "building_helper_build_command", Dynamic_Wrap(BuildingHelper, "RegisterLeftClick"))
	CustomGameEventManager:RegisterListener( "building_helper_cancel_command", Dynamic_Wrap(BuildingHelper, "RegisterRightClick"))

	-- Remove building invulnerability
	local allBuildings = Entities:FindAllByClassname('npc_dota_building')
	for i = 1, #allBuildings, 1 do
		local building = allBuildings[i]
		if building:HasModifier('modifier_invulnerable') then
			building:RemoveModifierByName('modifier_invulnerable')
		end
	end

	-- Add gridnav blockers to the gold mines
	local allGoldMines = Entities:FindAllByModel('models/mine/mine.vmdl') --Target name in Hammer
	for k,gold_mine in pairs (allGoldMines) do
		local location = gold_mine:GetAbsOrigin()
		location.x = SnapToGrid32(location.x)
    	location.y = SnapToGrid32(location.y)
		local gridNavBlockers = BuildingHelper:BlockGridNavSquare(5, location)
		--gold_mine:SetAbsOrigin(location)
	    gold_mine.blockers = gridNavBlockers

	    -- Find and store the mine entrance
		local mine_entrance = Entities:FindAllByNameWithin("*mine_entrance", location, 300)
		for k,v in pairs(mine_entrance) do
			gold_mine.entrance = v:GetAbsOrigin()
		end
	end

	-- Allow cosmetic swapping
	SendToServerConsole( "dota_combines_model 0" )

	Convars:RegisterCommand( "debug_trees", Dynamic_Wrap(dotacraft, 'DebugTrees'), "Prints the trees marked as pathable", 0 )

	-- Lumber AbilityValue, credits to zed https://github.com/zedor/AbilityValues
	-- Note: When the abilities change, we need to update this value.
	Convars:RegisterCommand( "ability_values_entity", function(name, entityIndex)
		local cmdPlayer = Convars:GetCommandClient()
		local pID = cmdPlayer:GetPlayerID()

		if cmdPlayer then
			local unit = EntIndexToHScript(tonumber(entityIndex))
			if not IsValidEntity(unit) then
				return
			end
			
	  		if unit then
	  			--and (unit:GetUnitName() == "human_peasant"
		  		local abilityValues = {}
		  		local itemValues = {}

		  		-- Iterate over the abilities
		  		for i=0,15 do
		  			local ability = unit:GetAbilityByIndex(i)

		  			-- If there's an ability in this slot and its not hidden, define the number to show
		  			if ability and not ability:IsHidden() then
		  				local lumberCost = ability:GetLevelSpecialValueFor("lumber_cost", ability:GetLevel() - 1)
		  				if lumberCost then
		  					table.insert(abilityValues,lumberCost)
		  				else
		  					table.insert(abilityValues,0)
		  				end
				  	end
		  		end

		  		FireGameEvent( 'ability_values_send', { player_ID = pID, 
		    										hue_1 = -10, val_1 = abilityValues[1], 
		    										hue_2 = -10, val_2 = abilityValues[2], 
		    										hue_3 = -10, val_3 = abilityValues[3], 
		    										hue_4 = -10, val_4 = abilityValues[4], 
		    										hue_5 = -10, val_5 = abilityValues[5],
		    										hue_6 = -10, val_6 = abilityValues[6] } )

		  		-- Iterate over the items
		  		for i=0,5 do
		  			local item = unit:GetItemInSlot(i)

		  			-- If there's an item in this slot, define the number to show
		  			if item then
		  				local lumberCost = item:GetSpecialValueFor("lumber_cost")
		  				if lumberCost then
		  					table.insert(itemValues,lumberCost)
		  				else
		  					table.insert(itemValues,0)
		  				end
				  	end
		  		end

		  		FireGameEvent( 'ability_values_send_items', { player_ID = pID, 
		    										hue_1 = 0, val_1 = itemValues[1], 
		    										hue_2 = 0, val_2 = itemValues[2], 
		    										hue_3 = 0, val_3 = itemValues[3], 
		    										hue_4 = 0, val_4 = itemValues[4], 
		    										hue_5 = 0, val_5 = itemValues[5],
		    										hue_6 = 0, val_6 = itemValues[6] } )
		    	
		    else
		    	-- Hide all the values if the unit is not supposed to show any.
		    	FireGameEvent( 'ability_values_send', { player_ID = pID, val_1 = 0, val_2 = 0, val_3 = 0, val_4 = 0, val_5 = 0, val_6 = 0 } )
		    	FireGameEvent( 'ability_values_send_items', { player_ID = pID, val_1 = 0, val_2 = 0, val_3 = 0, val_4 = 0, val_5 = 0, val_6 = 0 } )
		    end
	  	end
	end, "Change AbilityValues", 0 )


	-- Fill server with fake clients
	-- Fake clients don't use the default bot AI for buying items or moving down lanes and are sometimes necessary for debugging
	Convars:RegisterCommand('fake', function()
		-- Check if the server ran it
		if not Convars:GetCommandClient() then
		  -- Create fake Players
			SendToServerConsole('dota_create_fake_clients')

			Timers:CreateTimer('assign_fakes', {
			  	useGameTime = false,
			  	endTime = Time(),
			  	callback = function(dotacraft, args)
			  	local userID = 20
			  	for i=0, 9 do
			  		userID = userID + 1
			        -- Check if this player is a fake one
			        if PlayerResource:IsFakeClient(i) then
			          	-- Grab player instance
			          	local ply = PlayerResource:GetPlayer(i)
			          	-- Make sure we actually found a player instance
			        	if ply then
				          	CreateHeroForPlayer('npc_dota_hero_axe', ply)
			          		self:OnConnectFull({ userid = userID, index = ply:entindex()-1 })
				          	ply:GetAssignedHero():SetControllableByPlayer(0, true)
			    		end
			      	end
			  	end
			end})
		end
	end, 'Connects and assigns fake Players.', 0)

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))

	-- Initialized tables for tracking state
	self.vUserIds = {}
	self.vSteamIds = {}
	self.vBots = {}
	self.vBroadcasters = {}

	self.vPlayers = {}
	self.vRadiant = {}
	self.vDire = {}

	self.nRadiantKills = 0
	self.nDireKills = 0

	self.bSeenWaitForPlayers = false

	-- Full units file to get the custom values
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  	GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  	GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  	GameRules.Requirements = LoadKeyValues("scripts/kv/tech_tree.kv")
  	GameRules.Wearables = LoadKeyValues("scripts/kv/wearables.kv")
  	GameRules.Modifiers = LoadKeyValues("scripts/kv/modifiers.kv")
  	GameRules.UnitUpgrades = LoadKeyValues("scripts/kv/unit_upgrades.kv")
  	GameRules.Abilities = LoadKeyValues("scripts/kv/abilities.kv")

  	GameRules.ALLTREES = Entities:FindAllByClassname("ent_dota_tree")

  	-- Store and update selected units of each pID
	GameRules.SELECTED_UNITS = {}
  	
  	-- Starting positions
  	GameRules.StartingPositions = {}
	local targets = Entities:FindAllByName( "*starting_position" ) --Inside player_start.vmap prefab
	for k,v in pairs(targets) do
		local pos_table = {}
		pos_table.position = v:GetOrigin()
		pos_table.playerID = -1
		GameRules.StartingPositions[k-1] = pos_table
	end
	print("[DOTACRAFT] Starting Positions:")
	DeepPrintTable(GameRules.StartingPositions)

	print('[DOTACRAFT] Done loading dotacraft gamemode!\n\n')
end

mode = nil

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function dotacraft:PlayerConnect(keys)
	print('[DOTACRAFT] PlayerConnect')
	--DeepPrintTable(keys)

	if keys.bot == 1 then
	-- This user is a Bot, so add it to the bots table
	self.vBots[keys.userid] = 1
	end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function dotacraft:OnConnectFull(keys)
	print ('[DOTACRAFT] OnConnectFull')
	--DeepPrintTable(keys)

	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)

	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()

	--CreateHeroForPlayer("npc_dota_hero_dragon_knight", ply)

	-- Update the user ID table with this user
	self.vUserIds[keys.userid] = ply

	-- Update the Steam ID table
	self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply

	-- If the player is a broadcaster flag it in the Broadcasters table
	if PlayerResource:IsBroadcaster(playerID) then
		self.vBroadcasters[keys.userid] = 1
		return
	end
end

function dotacraft:PostLoadPrecache()
	print("[DOTACRAFT] Performing Post-Load precache")

	PrecacheUnitByNameAsync("cosmetic_precache", function(...) end) -- Cosmetic model_folders

	PrecacheUnitByNameAsync("human_arcane_sanctum", function(...) end)
	PrecacheUnitByNameAsync("human_guard_tower", function(...) end)
	PrecacheUnitByNameAsync("human_cannon_tower", function(...) end)
	PrecacheUnitByNameAsync("human_arcane_tower", function(...) end)
	PrecacheUnitByNameAsync("human_workshop", function(...) end)
	PrecacheUnitByNameAsync("human_gryphon_aviary", function(...) end)

	PrecacheUnitByNameAsync("nightelf_ancient_of_lore", function(...) end)
	PrecacheUnitByNameAsync("nightelf_ancient_of_wind", function(...) end)
	PrecacheUnitByNameAsync("nightelf_ancient_protector", function(...) end)
	PrecacheUnitByNameAsync("nightelf_tree_of_ages", function(...) end)
	PrecacheUnitByNameAsync("nightelf_tree_of_eternity", function(...) end)
	PrecacheUnitByNameAsync("nightelf_chimaera_roost", function(...) end)

	PrecacheUnitByNameAsync("undead_halls_of_the_dead", function(...) end)
	PrecacheUnitByNameAsync("undead_black_citadel", function(...) end)
	PrecacheUnitByNameAsync("undead_boneyard", function(...) end)
	PrecacheUnitByNameAsync("undead_temple_of_the_damned", function(...) end)
	PrecacheUnitByNameAsync("undead_slaughterhouse", function(...) end)
	PrecacheUnitByNameAsync("undead_nerubian_tower", function(...) end)
	PrecacheUnitByNameAsync("undead_spirit_tower", function(...) end)
	PrecacheUnitByNameAsync("undead_sacrificial_pit", function(...) end)

	PrecacheUnitByNameAsync("orc_beastiary", function(...) end)
	PrecacheUnitByNameAsync("orc_stronghold", function(...) end)
	PrecacheUnitByNameAsync("orc_fortress", function(...) end)
	PrecacheUnitByNameAsync("orc_spirit_lodge", function(...) end)
	PrecacheUnitByNameAsync("orc_tauren_totem", function(...) end)
	PrecacheUnitByNameAsync("orc_watch_tower", function(...) end)

	PrecacheUnitByNameAsync("npc_dota_hero_keeper_of_the_light", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_zuus", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_omniknight", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_Invoker", function(...) end)

	PrecacheItemByNameAsync("item_orb_of_frost", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_fire", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_venom_wc3", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_corruption", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_darkness", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_lightning", function(...) end)
end

function dotacraft:OnFirstPlayerLoaded()
	print("[DOTACRAFT] First Player has loaded")
end

function dotacraft:OnAllPlayersLoaded()
	print("[DOTACRAFT] All Players have loaded into the game")
end

function dotacraft:OnHeroInGame(hero)
	print("[DOTACRAFT] Hero spawned in game for first time -- " .. hero:GetUnitName())

	dotacraft:ModifyStatBonuses(hero)

	if Convars:GetBool("developer") then
		for i=1,9 do
			hero:HeroLevelUp(false)
		end
	end

	if hero:HasAbility("hide_hero") then
		local player = hero:GetPlayerOwner()
		player.lumber = 0
		player.food_limit = 0 -- The amount of food available to build units
		player.food_used = 0 -- The amount of food used by this player creatures
	
		-- Give Initial Resources
		if Convars:GetBool("developer") then
			hero:SetGold(50000, false)
			ModifyLumber(player, 50000)
		else
			hero:SetGold(500, false)
			ModifyLumber(player, 150)
		end

		-- Hide main hero under the main base
		local pID = hero:GetPlayerOwnerID()
		local position = GameRules.StartingPositions[pID].position
		local ability = hero:FindAbilityByName("hide_hero")
		ability:UpgradeAbility(true)
		hero:SetAbilityPoints(0)
		hero:SetAbsOrigin(Vector(position.x,position.y,position.z - 420 ))
		Timers:CreateTimer(function() hero:SetAbsOrigin(Vector(position.x,position.y,position.z - 420 )) return 1 end)
		hero:AddNoDraw()

		-- Find neutrals near the starting zone and remove them
		local neutrals = FindUnitsInRadius(hero:GetTeamNumber(), position, nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, true)
		for k,v in pairs(neutrals) do
			if v:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
				v:RemoveSelf()
			end
		end
	end

end

function dotacraft:OnGameInProgress()
	print("[DOTACRAFT] The game has officially begun")
end

-- Cleanup a player when they leave
function dotacraft:OnDisconnect(keys)
	print('[DOTACRAFT] Player Disconnected ' .. tostring(keys.userid))
	--DeepPrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid

end

-- The overall game state has changed
function dotacraft:OnGameRulesStateChange(keys)
	print("[DOTACRAFT] GameRules State Changed")
	--DeepPrintTable(keys)

	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		self.bSeenWaitForPlayers = true
	elseif newState == DOTA_GAMERULES_STATE_INIT then
		Timers:RemoveTimer("alljointimer")
	elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		local et = 6
		if self.bSeenWaitForPlayers then
			et = .01
		end
		Timers:CreateTimer("alljointimer", {
			useGameTime = true,
			endTime = et,
			callback = function()
			if PlayerResource:HaveAllPlayersJoined() then
				dotacraft:PostLoadPrecache()
				dotacraft:OnAllPlayersLoaded()
				return 
			end
			return 1
		end
		})
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		dotacraft:OnGameInProgress()
	end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function dotacraft:OnNPCSpawned(keys)
	--print("[DOTACRAFT] NPC Spawned")
	--DeepPrintTable(keys)
	local npc = EntIndexToHScript(keys.entindex)

	if npc:IsHero() then
		npc.strBonus = 0
        npc.intBonus = 0
        npc.agilityBonus = 0
        npc.attackspeedBonus = 0
    end

	if npc:IsRealHero() and npc.bFirstSpawned == nil then
		npc.bFirstSpawned = true
		dotacraft:OnHeroInGame(npc)
	end
end

-- An entity somewhere has been hurt.
function dotacraft:OnEntityHurt(keys)
	--print("[DOTACRAFT] Entity Hurt")
	----DeepPrintTable(keys)
	local damagebits = keys.damagebits
  	local attacker = keys.entindex_attacker
  	local damaged = keys.entindex_killed
  	local inflictor = keys.entindex_inflictor
  	local victim
  	local cause
  	local damagingAbility

  	if attacker and damaged then
	    cause = EntIndexToHScript(keys.entindex_attacker)
	    victim = EntIndexToHScript(keys.entindex_killed)	    
	    
	    if inflictor then
	    	damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
	    end
  	end

	local time = GameRules:GetGameTime()
	if victim and IsCustomBuilding(victim) then
		local pID = victim:GetPlayerOwnerID()
		if pID then
			-- Set the new attack time
			GameRules.PLAYER_BUILDINGS_DAMAGED[pID] = time	

			-- Define the warning 
			local last_warning = GameRules.PLAYER_DAMAGE_WARNING[pID]

			-- If its the first time being attacked or its been long since the last warning, show a warning
			if not last_warning or (time - last_warning) > UNDER_ATTACK_WARNING_INTERVAL then

				-- Damage Particle
				local particle = ParticleManager:CreateParticleForPlayer("particles/generic_gameplay/screen_damage_indicator.vpcf", PATTACH_EYES_FOLLOW, victim, victim:GetPlayerOwner())
				ParticleManager:SetParticleControl(particle, 1, victim:GetAbsOrigin())
				Timers:CreateTimer(3, function() ParticleManager:DestroyParticle(particle, false) end)

				-- Ping
				local origin = victim:GetAbsOrigin()
				MinimapEvent( victim:GetTeamNumber(), victim, origin.x, origin.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 1 )
				MinimapEvent( victim:GetTeamNumber(), victim, origin.x, origin.y, DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 3 )

				-- Update the last warning to the current time
				GameRules.PLAYER_DAMAGE_WARNING[pID] = time
			else
				-- Ping on each building, every 2 seconds at most
				local last_damaged = victim.last_damaged
				if not last_damaged or (time - last_damaged) > 2 then
					victim.last_damaged = time
					local origin = victim:GetAbsOrigin()
					MinimapEvent( victim:GetTeamNumber(), victim, origin.x, origin.y, DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 2 )
				end
			end
		end
	end



end

-- An item was picked up off the ground
function dotacraft:OnItemPickedUp(keys)
	print ( '[DOTACRAFT] OnItemPurchased' )
	--DeepPrintTable(keys)

	local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function dotacraft:OnPlayerReconnect(keys)
	print ( '[DOTACRAFT] OnPlayerReconnect' )
	--DeepPrintTable(keys) 
end

-- An item was purchased by a player
function dotacraft:OnItemPurchased( keys )
	print ( '[DOTACRAFT] OnItemPurchased' )
	--DeepPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	-- The name of the item purchased
	local itemName = keys.itemname 

	-- The cost of the item purchased
	local itemcost = keys.itemcost

end

-- An ability was used by a player
function dotacraft:OnAbilityUsed(keys)

	local player = EntIndexToHScript(keys.PlayerID)
	local abilityname = keys.abilityname

end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function dotacraft:OnNonPlayerUsedAbility(keys)
	print('[DOTACRAFT] OnNonPlayerUsedAbility')
	--DeepPrintTable(keys)

	local abilityname=  keys.abilityname
end

-- A player changed their name
function dotacraft:OnPlayerChangedName(keys)
	print('[DOTACRAFT] OnPlayerChangedName')
	--DeepPrintTable(keys)

	local newName = keys.newname
	local oldName = keys.oldName
end

-- A player leveled up an ability
function dotacraft:OnPlayerLearnedAbility( keys)
	print ('[DOTACRAFT] OnPlayerLearnedAbility')
	--DeepPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function dotacraft:OnAbilityChannelFinished(keys)
	print ('[DOTACRAFT] OnAbilityChannelFinished')
	--DeepPrintTable(keys)

	local abilityname = keys.abilityname
	local interrupted = keys.interrupted == 1
end

-- A player leveled up
function dotacraft:OnPlayerLevelUp(keys)
	print ('[DOTACRAFT] OnPlayerLevelUp')
	--DeepPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function dotacraft:OnLastHit(keys)
	print ('[DOTACRAFT] OnLastHit')
	--DeepPrintTable(keys)

	local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)
end

-- A tree was cut down
function dotacraft:OnTreeCut(keys)
	print ('[DOTACRAFT] OnTreeCut')
	--DeepPrintTable(keys)

	local treeX = keys.tree_x
	local treeY = keys.tree_y

	-- Update the pathable trees nearby
	local vecs = {
    	Vector(0,64,0),-- N
    	Vector(64,64,0), -- NE
    	Vector(64,0,0), -- E
    	Vector(64,-64,0), -- SE
    	Vector(0,-64,0), -- S
    	Vector(-64,-64,0), -- SW
    	Vector(-64,0,0), -- W
    	Vector(-64,64,0) -- NW
  	}

  	for k=1,#vecs do
  		local vec = vecs[k]
 		local xoff = vec.x
 		local yoff = vec.y
 		local pos = Vector(treeX + xoff, treeY + yoff, 0)

 		local nearbyTree = GridNav:IsNearbyTree(pos, 64, true)
	    if nearbyTree then
	    	local trees = GridNav:GetAllTreesAroundPoint(pos, 32, true)
	    	for _,t in pairs(trees) do
	    		--if GridNav:CanFindPath(Vector(0,0,0), t:GetAbsOrigin()) then
	    		DebugDrawCircle(t:GetAbsOrigin(), Vector(0,255,0), 255, 32, true, 60)
	    		t.pathable = true
	    		--end
	    	end
	    end
	end
end

-- A rune was activated by a player
function dotacraft:OnRuneActivated (keys)
	print ('[DOTACRAFT] OnRuneActivated')
	--DeepPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local rune = keys.rune

	--[[ Rune Can be one of the following types
	DOTA_RUNE_DOUBLEDAMAGE
	DOTA_RUNE_HASTE
	DOTA_RUNE_HAUNTED
	DOTA_RUNE_ILLUSION
	DOTA_RUNE_INVISIBILITY
	DOTA_RUNE_MYSTERY
	DOTA_RUNE_RAPIER
	DOTA_RUNE_REGENERATION
	DOTA_RUNE_SPOOKY
	DOTA_RUNE_TURBO
	]]
end

-- A player took damage from a tower
function dotacraft:OnPlayerTakeTowerDamage(keys)
	print ('[DOTACRAFT] OnPlayerTakeTowerDamage')
	--DeepPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local damage = keys.damage
end

-- A player picked a hero
function dotacraft:OnPlayerPickHero(keys)
	print ('[DOTACRAFT] OnPlayerPickHero')
	--DeepPrintTable(keys)

	local hero = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
	local playerID = hero:GetPlayerID()

	-- Initialize Variables for Tracking
	player.buildings = {} -- This keeps the name and quantity of each building, to access in O(1)
	player.units = {} -- This keeps the handle of all the units of the player army, to iterate for unlocking upgrades
	player.structures = {} -- This keeps the handle of the constructed units, to iterate for unlocking upgrades
	player.upgrades = {} -- This kees the name of all the upgrades researched, so each unit can check and upgrade itself on spawn
	player.heroes = {} -- Owned hero units (not this assigned hero, which will be a fake)
	player.altar_structures = {} -- Keeps altars linked

    -- Create Main Building
    DeepPrintTable(GameRules.StartingPositions)
    local position = GameRules.StartingPositions[playerID].position
    GameRules.StartingPositions[playerID].playerID = playerID

    print("Position for "..playerID..": ",position)
    DeepPrintTable(GameRules.StartingPositions)
    print("Remaining",#GameRules.StartingPositions,"positions")

    -- Stop game logic on the model overview map
    if GetMapName() == "dotacraft" then
    	return
    end

    -- Define the initial unit names to spawn for this hero_race
    local hero_name = hero:GetUnitName()
    local city_center_name = GetCityCenterNameForHeroRace(hero_name)
    local builder_name = GetBuilderNameForHeroRace(hero_name)

	local building = BuildingHelper:PlaceBuilding(player, city_center_name, position, true, 5) 
	player.buildings[city_center_name] = 1
	PlayerResource:SetCameraTarget(playerID, building)
	Timers:CreateTimer(function() PlayerResource:SetCameraTarget(playerID, nil) end)
	table.insert(player.structures, building)

	CheckAbilityRequirements( building, player )

	-- Give Initial Food
    ModifyFoodLimit(player, GetFoodProduced(building))

	-- Create Builders in between the gold mine and the city center
	local num_builders = 30
	local angle = 360 / num_builders
	local closest_mine = GetClosestGoldMineToPosition(position)
	local closest_mine_pos = closest_mine:GetAbsOrigin()
	local mid_point = closest_mine_pos + (position-closest_mine_pos)/2

	-- Undead special worker rules
	if hero_name == "npc_dota_hero_life_stealer" then
		num_builders = 3
		local ghoul = CreateUnitByName("undead_ghoul", mid_point+Vector(1,0,0) * 200, true, hero, hero, hero:GetTeamNumber())
		ghoul:SetOwner(hero)
		ghoul:SetControllableByPlayer(playerID, true)
	end

	for i=1,num_builders do	
		--DebugDrawCircle(mid_point, Vector(255, 0 , 0), 255, 100, true, 10)
		local rotate_pos = mid_point + Vector(1,0,0) * 100
		local builder_pos = RotatePosition(mid_point, QAngle(0, angle*i, 0), rotate_pos)

		print("BUILDER POS ",i,builder_pos)

		--DebugDrawCircle(builder_pos, Vector(255, 255 , 0), 255, 20, true, 10)

		local builder = CreateUnitByName(builder_name, builder_pos, true, hero, hero, hero:GetTeamNumber())
		builder:SetOwner(hero)
		builder:SetControllableByPlayer(playerID, true)
		table.insert(player.units, builder)
		builder.state = "idle"

		-- Increment food used
		ModifyFoodUsed(player, GetFoodCost(builder))

		-- Go through the abilities and upgrade
		CheckAbilityRequirements( builder, player )
		FindClearSpaceForUnit(builder, builder_pos, true)
	end

	Timers:CreateTimer(1, function() 
		local idle_builders = 0
		local player_units = player.units
		for k,unit in pairs(player_units) do
			if IsBuilder(unit) and IsIdleBuilder(unit) then
				idle_builders = idle_builders + 1
			end
		end
		--print("#Idle Builders: "..idle_builders)
		return 1
	end)
end

-- A player killed another player in a multi-team context
function dotacraft:OnTeamKillCredit(keys)
	print ('[DOTACRAFT] OnTeamKillCredit')
	--DeepPrintTable(keys)

	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	local numKills = keys.herokills
	local killerTeamNumber = keys.teamnumber
	end

-- An entity died
function dotacraft:OnEntityKilled( event )
	--print( '[DOTACRAFT] OnEntityKilled Called' )

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	-- The Killing entity
	local killerEntity
	if event.entindex_attacker then
		killerEntity = EntIndexToHScript(event.entindex_attacker)
	end

	-- Player owner of the unit
	local player = killedUnit:GetPlayerOwner()

	-- Hero Killed
	if killedUnit:IsRealHero() then
		if player.altar then
			for _,altar in pairs(player.altar_structures) do
				print("ALLOW REVIVAL OF THIS THIS HERO AT THIS ALTAR")

				-- Set the strings for the _acquired ability to find and _revival ability to add
				local level = killedUnit:GetLevel()
				local name = killedUnit.RespawnAbility
				if name then
					local acquired_ability_name = name.."_acquired"
					local revival_ability_name = name.."_revive"..level

					print("FIND "..acquired_ability_name.." AND SWAP TO "..revival_ability_name)

					local ability = altar:FindAbilityByName(acquired_ability_name)
					if ability then
						altar:AddAbility(revival_ability_name)
						altar:SwapAbilities(acquired_ability_name, revival_ability_name, false, true)
						altar:RemoveAbility(acquired_ability_name)

						local new_ability = altar:FindAbilityByName(revival_ability_name)
						if new_ability then
							new_ability:SetLevel(new_ability:GetMaxLevel())
							print("ADDED "..revival_ability_name.." at level "..new_ability:GetMaxLevel())
						else
							print("ABILITY COULDNT BE CHANGED BECAUSE OF REASONS")
						end
					end
				end
			end
		end
	end

	-- Substract the Food Used
	local food_cost = GetFoodCost(killedUnit)
	if food_cost > 0 and player then
		ModifyFoodUsed(player, - food_cost)
	end

	if IsCustomBuilding(killedUnit) then
		killedUnit:RemoveBuilding(false) -- Building Helper grid cleanup

		-- Substract the Food Produced
		local food_produced = GetFoodProduced(killedUnit)
		if food_produced > 0 and player and not killedUnit.state == "canceled" then
			ModifyFoodLimit(player, - food_produced)
		end
	end

	-- Give Experience to heroes based on the level of the killed creature
	if not killedUnit.isBuilding then
		local XPGain = XP_BOUNTY_TABLE[killedUnit:GetLevel()]

		-- Grant XP in AoE
		local heroesNearby = FindUnitsInRadius( killerEntity:GetTeamNumber(), killedUnit:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		--print("There are ",#heroesNearby," nearby the dead unit, base value for this unit is: "..XPGain)
		for _,hero in pairs(heroesNearby) do
			if hero:IsRealHero() and hero:GetTeam() ~= killedUnit:GetTeam() then

				-- Scale XP if neutral
				local xp = XPGain
				if killedUnit:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
					xp = ( XPGain * XP_NEUTRAL_SCALING[hero:GetLevel()] ) / #heroesNearby
				end

				hero:AddExperience(math.floor(xp), false, false)
				--print("granted "..xp.." to "..hero:GetUnitName())
			end
		end		
	end

	-- Table cleanup
	if player then
		-- Remake the tables
		local table_structures = {}
		for _,building in pairs(player.structures) do
			if building and IsValidEntity(building) and building:IsAlive() then
				print("Valid building: "..building:GetUnitName())
				table.insert(table_structures, building)
			end
		end


		local table_altars = {}
		for _,altar in pairs(player.altar_structures) do
			if altar and IsValidEntity(altar) and altar:IsAlive() then
				print("Valid altar: "..altar:GetUnitName())
				table.insert(table_structures, altar)
			end
		end
		player.altar_structures = table_altars
		
		-- Check for lose condition - All buildings destroyed
		print("Player "..player:GetPlayerID().." has "..#player.structures.." buildings left")
		if (#player.structures == 0) then
			GameRules:MakeTeamLose(player:GetTeamNumber())
		end
		
		local table_units = {}
		for _,unit in pairs(player.units) do
			if unit and IsValidEntity(unit) then
				table.insert(table_units, unit)
			end
		end
		player.units = table_units		
	end

	-- If the unit is supposed to leave a corpse, create a dummy_unit to use abilities on it.
	Timers:CreateTimer(1, function() 
	if LeavesCorpse( killedUnit ) then
			-- Create and set model
			local corpse = CreateUnitByName("dummy_unit", killedUnit:GetAbsOrigin(), true, nil, nil, killedUnit:GetTeamNumber())
			corpse:SetModel(CORPSE_MODEL)

			-- Set the corpse invisible until the dota corpse disappears
			corpse:AddNoDraw()
			
			-- Keep a reference to its name and expire time
			corpse.corpse_expiration = GameRules:GetGameTime() + CORPSE_DURATION
			corpse.unit_name = killedUnit:GetUnitName()

			-- Set custom corpse visible
			Timers:CreateTimer(3, function() corpse:RemoveNoDraw() end)

			-- Remove itself after the corpse duration
			Timers:CreateTimer(CORPSE_DURATION, function()
				if corpse and IsValidEntity(corpse) then
					print("removing corpse")
					corpse:RemoveSelf()
				end
			end)
		end
	end)

	-- Remove from units table
	if killedUnit and player then
		-- IF BUILDING DESTROYED, CHECK FOR POSSIBLE DOWNGRADES OF ABILITIES THAT CAN'T BE BUILT ANYMORE
		if IsCustomBuilding(killedUnit) then

			-- Remove from it from player building tables
			local building = getIndex(player.structures, killedUnit:GetEntityIndex())
			if building and building ~= -1 then
				local building_name = killedUnit:GetUnitName()
				print("Removing "..killedUnit:GetUnitName().." from the player structures")
				table.remove(player.structures, building)

				-- Substract 1 to the player building tracking table for that name
				if player.buildings[building_name] then
					player.buildings[building_name] = player.buildings[building_name] - 1
				end

		    	for k,builder in pairs(player.units) do
		    		CheckAbilityRequirements( builder, player )
		    	end

		    	for k,structure in pairs(player.structures) do
		    		CheckAbilityRequirements( structure, player )
		    	end
		    end
	    elseif killedUnit:IsCreature() and player then
			local unit = getIndex(player.units, killedUnit)
			if unit and unit ~= -1 then
				--DeepPrintTable(player.units)
				print("Removing "..unit.." from the player's units")
				table.remove(player.units, unit)
				--DeepPrintTable(player.units)
			end
		end
	end
end

-- This is an example console command
function dotacraft:ExampleConsoleCommand()
	print( '******* Example Console Command ***************' )
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
	  	-- Do something here for the player who called this command
	  	PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
		end
	end

	print( '*********************************************' )
end


--Custom Stat Rules
function dotacraft:ModifyStatBonuses(unit)
	local spawnedUnitIndex = unit
	print("Modifying Stats Bonus")
		Timers:CreateTimer(DoUniqueString("updateHealth_" .. spawnedUnitIndex:GetPlayerID()), {
		endTime = 0.25,
		callback = function()
			-- ==================================
			-- Adjust health based on strength
			-- ==================================
 
			-- Get player strength
			local strength = spawnedUnitIndex:GetStrength()
			--Check if strBonus is stored on hero, if not set it to 0
			if spawnedUnitIndex.strBonus == nil then
				spawnedUnitIndex.strBonus = 0
			end
 
			-- If player strength is different this time around, start the adjustment
			if strength ~= spawnedUnitIndex.strBonus then
				-- Modifier values
				local bitTable = {128,64,32,16,8,4,2,1}
 
				-- Gets the list of modifiers on the hero and loops through removing and health modifier
				local modCount = spawnedUnitIndex:GetModifierCount()
				for i = 0, modCount do
					for u = 1, #bitTable do
						local val = bitTable[u]
						if spawnedUnitIndex:GetModifierNameByIndex(i) == "modifier_health_mod_" .. val  then
							spawnedUnitIndex:RemoveModifierByName("modifier_health_mod_" .. val)
						end
					end
				end
 
				-- Creates temporary item to steal the modifiers from
				local healthUpdater = CreateItem("item_health_modifier", nil, nil) 
				for p=1, #bitTable do
					local val = bitTable[p]
					local count = math.floor(strength / val)
					if count >= 1 then
						healthUpdater:ApplyDataDrivenModifier(spawnedUnitIndex, spawnedUnitIndex, "modifier_health_mod_" .. val, {})
						strength = strength - val
					end
				end
				-- Cleanup
				UTIL_RemoveImmediate(healthUpdater)
				healthUpdater = nil
			end
			-- Updates the stored strength bonus value for next timer cycle
			spawnedUnitIndex.strBonus = spawnedUnitIndex:GetStrength()
			spawnedUnitIndex.HealthTomesStack = spawnedUnitIndex:GetModifierStackCount("tome_health_modifier", spawnedUnitIndex)
			-- ==================================
			-- Adjust mana based on intellect
			-- ==================================
 
			-- Get player intellect
			local intellect = spawnedUnitIndex:GetIntellect()
 
			--Check if intBonus is stored on hero, if not set it to 0
			if spawnedUnitIndex.intBonus == nil then
				spawnedUnitIndex.intBonus = 0
			end
 
			-- If player intellect is different this time around, start the adjustment
			if intellect ~= spawnedUnitIndex.intBonus then
				-- Modifier values
				local bitTable = {128,64,32,16,8,4,2,1}
 
				-- Gets the list of modifiers on the hero and loops through removing and mana modifier
				local modCount = spawnedUnitIndex:GetModifierCount()
				for i = 0, modCount do
					for u = 1, #bitTable do
						local val = bitTable[u]
						if spawnedUnitIndex:GetModifierNameByIndex(i) == "modifier_mana_mod_" .. val  then
							spawnedUnitIndex:RemoveModifierByName("modifier_mana_mod_" .. val)
						end
					end
				end
 
				-- Creates temporary item to steal the modifiers from
				local manaUpdater = CreateItem("item_mana_modifier", nil, nil) 
				for p=1, #bitTable do
					local val = bitTable[p]
					local count = math.floor(intellect / val)
					if count >= 1 then
						manaUpdater:ApplyDataDrivenModifier(spawnedUnitIndex, spawnedUnitIndex, "modifier_mana_mod_" .. val, {})
						intellect = intellect - val
					end
				end
				-- Cleanup
				UTIL_RemoveImmediate(healthUpdater)
				manaUpdater = nil
			end
			-- Updates the stored intellect bonus value for next timer cycle
			spawnedUnitIndex.intBonus = spawnedUnitIndex:GetIntellect()
	
			-- ==================================
			-- Adjust attackspeed based on agility
			-- ==================================
 
			-- Get player agility
			local agility = spawnedUnitIndex:GetAgility()
 
			--Check if intBonus is stored on hero, if not set it to 0
			if spawnedUnitIndex.attackspeedBonus == nil then
				spawnedUnitIndex.attackspeedBonus = 0
			end
 
			-- If player agility is different this time around, start the adjustment
			if agility ~= spawnedUnitIndex.attackspeedBonus then
				-- Modifier values
				local bitTable = {128,64,32,16,8,4,2,1}
 
				-- Gets the list of modifiers on the hero and loops through removing and attackspeed modifier
				local modCount = spawnedUnitIndex:GetModifierCount()
				for i = 0, modCount do
					for u = 1, #bitTable do
						local val = bitTable[u]
						if spawnedUnitIndex:GetModifierNameByIndex(i) == "modifier_attackspeed_mod_" .. val  then
							spawnedUnitIndex:RemoveModifierByName("modifier_attackspeed_mod_" .. val)
						end
					end
				end
 
				-- Creates temporary item to steal the modifiers from
				local attackspeedUpdater = CreateItem("item_attackspeed_modifier", nil, nil) 
				for p=1, #bitTable do
					local val = bitTable[p]
					local count = math.floor(agility / val)
					if count >= 1 then
						attackspeedUpdater:ApplyDataDrivenModifier(spawnedUnitIndex, spawnedUnitIndex, "modifier_attackspeed_mod_" .. val, {})
						agility = agility - val
					end
				end
				-- Cleanup
				UTIL_RemoveImmediate(healthUpdater)
				attackspeedUpdater = nil
			end
			-- Updates the stored agility bonus value for next timer cycle
			spawnedUnitIndex.attackspeedBonus = spawnedUnitIndex:GetAgility()
			
			
			-- ==================================
			-- Adjust armor based on agi 
			-- Added as +Armor and not Base Armor because there's no BaseArmor modifier (please...)
			-- ==================================

			-- Get player primary stat value
			local agility = spawnedUnitIndex:GetAgility()

			--Check if primaryStatBonus is stored on hero, if not set it to 0
			if spawnedUnitIndex.agilityBonus == nil then
				spawnedUnitIndex.agilityBonus = 0
			end

			-- If player int is different this time around, start the adjustment
			if agility ~= spawnedUnitIndex.agilityBonus then
				-- Modifier values
				local bitTable = {64,32,16,8,4,2,1}

				-- Gets the list of modifiers on the hero and loops through removing and armor modifier
				for u = 1, #bitTable do
					local val = bitTable[u]
					if spawnedUnitIndex:HasModifier( "modifier_armor_mod_" .. val)  then
						spawnedUnitIndex:RemoveModifierByName("modifier_armor_mod_" .. val)
					end
					
					if spawnedUnitIndex:HasModifier( "modifier_negative_armor_mod_" .. val)  then
						spawnedUnitIndex:RemoveModifierByName("modifier_negative_armor_mod_" .. val)
					end
				end
				print("========================")
				agility = agility / 7
				print("Agi / 7: "..agility)
				-- Remove Armor
				-- Creates temporary item to steal the modifiers from
				local armorUpdater = CreateItem("item_armor_modifier", nil, nil) 
				for p=1, #bitTable do
					local val = bitTable[p]
					local count = math.floor(agility / val)
					if count >= 1 then
						armorUpdater:ApplyDataDrivenModifier(spawnedUnitIndex, spawnedUnitIndex, "modifier_negative_armor_mod_" .. val, {})
						print("Adding modifier_negative_armor_mod_" .. val)
						agility = agility - val
					end
				end

				agility = spawnedUnitIndex:GetAgility()
				agility = agility / 3
				print("Agi / 3: "..agility)
				for p=1, #bitTable do
					local val = bitTable[p]
					local count = math.floor(agility / val)
					if count >= 1 then
						armorUpdater:ApplyDataDrivenModifier(spawnedUnitIndex, spawnedUnitIndex, "modifier_armor_mod_" .. val, {})
						agility = agility - val
						print("Adding modifier_armor_mod_" .. val)
					end
				end

				-- Cleanup
				UTIL_RemoveImmediate(armorUpdater)
				armorUpdater = nil
			end
			-- Updates the stored Int bonus value for next timer cycle
			spawnedUnitIndex.agilityBonus = spawnedUnitIndex:GetAgility()

			return 0.25
		end
	})

end

function dotacraft:OnPlayerSelectedEntities( event )
	local pID = event.pID
	--print("Player "..pID.." updated selection:")
	--DeepPrintTable(event.selected_entities)
	GameRules.SELECTED_UNITS[pID] = event.selected_entities
	dotacraft:UpdateRallyFlagDisplays(pID)
end

function GetSelectedEntities( playerID )
	return GameRules.SELECTED_UNITS[playerID]
end

function GetMainSelectedEntity( playerID )
	if GameRules.SELECTED_UNITS[playerID]["0"] then
		return EntIndexToHScript(GameRules.SELECTED_UNITS[playerID]["0"])
	end
	return nil
end

-- Hides or shows the rally flag particles for the player (avoids visual clutter)
function dotacraft:UpdateRallyFlagDisplays( playerID )
    
    local mainSelected = GetMainSelectedEntity(playerID)
    if not mainSelected then
        return
    end
    local player = PlayerResource:GetPlayer(playerID)

    -- Destroy the old flag
    if player.flagParticle then
        ParticleManager:DestroyParticle(player.flagParticle, true)
        player.flagParticle = nil
    else
        --print("NO PLAYER FLAG PARTICLE TO DESTROY")
    end

    if mainSelected.flag and IsValidEntity(mainSelected.flag) then
        if HasTrainAbility(mainSelected) and not IsCustomTower(mainSelected) then
            CreateRallyFlagForBuilding(mainSelected)
        end
    end
end

--https://en.wikipedia.org/wiki/Flood_fill
function dotacraft:DeterminePathableTrees()

	--------------------------
	--      Flood Fill      --
	--------------------------

	print("DeterminePathableTrees")

	local world_positions = {}
	local valid_trees = {}
	local seen = {}

	--Set Q to the empty queue.
	local Q = {}

 	--Add node to the end of Q.
 	table.insert(Q, Vector(0,0,0))

 	local vecs = {
    	Vector(0,64,0),-- N
    	Vector(64,64,0), -- NE
    	Vector(64,0,0), -- E
    	Vector(64,-64,0), -- SE
    	Vector(0,-64,0), -- S
    	Vector(-64,-64,0), -- SW
    	Vector(-64,0,0), -- W
    	Vector(-64,64,0) -- NW
  	}

 	while #Q > 0 do
 		--Set n equal to the first element of Q and Remove first element from Q.
 		local position = table.remove(Q)

 		--If the color of n is equal to target-color:
 		local blocked = not GridNav:IsTraversable(position) or GridNav:IsBlocked(position)
 		if not blocked then
 			--table.insert(world_positions, position)

 			-- Mark position processed.
 			seen[GridNav:WorldToGridPosX(position.x)..","..GridNav:WorldToGridPosX(position.y)] = 1

 			for k=1,#vecs do
 				local vec = vecs[k]
 				local xoff = vec.x
 				local yoff = vec.y
 				local pos = Vector(position.x + xoff, position.y + yoff, position.z)

 				-- Add unprocessed nodes
 				if not seen[GridNav:WorldToGridPosX(pos.x)..","..GridNav:WorldToGridPosX(pos.y)] then
 					--table.insert(world_positions, position)
 					table.insert(Q, pos)
 				end
 			end
	    
	    else
	    	local nearbyTree = GridNav:IsNearbyTree(position, 64, true)
	    	if nearbyTree then
	    		local trees = GridNav:GetAllTreesAroundPoint(position, 1, true)
	    		if #trees > 0 then
	    			local t = trees[1]
	    			t.pathable = true
	    			--table.insert(valid_trees,t)
	    		end
	    	end
	    end
	end

	--DEBUG
	--for k,tree in pairs(valid_trees) do
		--DebugDrawCircle(tree:GetAbsOrigin(), Vector(0,255,0), 0, 32, true, 60)
	--end
end

function dotacraft:DebugTrees()
	for k,v in pairs(GameRules.ALLTREES) do
		if IsTreePathable(v) then
			DebugDrawCircle(v:GetAbsOrigin(), Vector(0,255,0), 255, 32, true, 60)
		else
			DebugDrawCircle(v:GetAbsOrigin(), Vector(255,0,0), 255, 32, true, 60)
		end
	end
end