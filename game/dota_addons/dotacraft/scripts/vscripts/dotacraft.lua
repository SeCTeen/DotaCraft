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

TREE_HEALTH = 50

DEBUG_SPEW = 1

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
	GameMode:SetRemoveIllusionsOnDeath( true )
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

	-- Default hero dummy
	GameMode:SetCustomGameForceHero("npc_dota_hero_ancient_apparition")

	-- DebugPrint
	Convars:RegisterConvar('debug_spew', tostring(DEBUG_SPEW), 'Set to 1 to start spewing debug info. Set to 0 to disable.', 0)

	print('[DOTACRAFT] Game Rules set')

	-- Multi Team Configuration - Should be acquired from the UI, to allow 1v1v1v1 or 2v2 on the same map for example.
	if GetMapName() == "hills_of_glory" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1,	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 	10 )
	
		-- Spectator
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_NOTEAM, 10 )
	elseif GetMapName() == "copper_canyon" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1,	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 	10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 	10 )
	
		-- Spectator
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_NOTEAM, 10 )
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
	ListenToGameEvent('player_chat', Dynamic_Wrap(dotacraft, 'OnPlayerChat'), self)
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

	-- Filters
    GameMode:SetExecuteOrderFilter( Dynamic_Wrap( dotacraft, "FilterExecuteOrder" ), self )
    GameMode:SetDamageFilter( Dynamic_Wrap( dotacraft, "FilterDamage" ), self )

    -- Register Listener
    CustomGameEventManager:RegisterListener( "reposition_player_camera", Dynamic_Wrap(dotacraft, "RepositionPlayerCamera"))
    CustomGameEventManager:RegisterListener( "update_selected_entities", Dynamic_Wrap(dotacraft, 'OnPlayerSelectedEntities'))
    CustomGameEventManager:RegisterListener( "gold_gather_order", Dynamic_Wrap(dotacraft, "GoldGatherOrder")) --Right click through panorama
    CustomGameEventManager:RegisterListener( "repair_order", Dynamic_Wrap(dotacraft, "RepairOrder")) --Right click through panorama
    CustomGameEventManager:RegisterListener( "moonwell_order", Dynamic_Wrap(dotacraft, "MoonWellOrder")) --Right click through panorama
    CustomGameEventManager:RegisterListener( "burrow_order", Dynamic_Wrap(dotacraft, "BurrowOrder")) --Right click through panorama 
    CustomGameEventManager:RegisterListener( "shop_active_order", Dynamic_Wrap(dotacraft, "ShopActiveOrder")) --Right click through panorama 
    CustomGameEventManager:RegisterListener( "right_click_order", Dynamic_Wrap(dotacraft, "RightClickOrder")) --Right click through panorama
    CustomGameEventManager:RegisterListener( "building_rally_order", Dynamic_Wrap(dotacraft, "OnBuildingRallyOrder")) --Right click through panorama
    CustomGameEventManager:RegisterListener( "building_helper_build_command", Dynamic_Wrap(BuildingHelper, "BuildCommand"))
	CustomGameEventManager:RegisterListener( "building_helper_cancel_command", Dynamic_Wrap(BuildingHelper, "CancelCommand"))

	-- Listeners for Pre_Game_Selection
	CustomGameEventManager:RegisterListener( "update_player", Dynamic_Wrap(dotacraft, "Selection_Update_Player"))
	CustomGameEventManager:RegisterListener( "selection_over", Dynamic_Wrap(dotacraft, "Create_Players"))	
	CustomGameEventManager:RegisterListener( "update_team_lock", Dynamic_Wrap(dotacraft, "Lock_Teams"))	
	
	-- register panaroma tables
	dotacraft:Setup_Tables()
	
	-- Remove building invulnerability
	local allBuildings = Entities:FindAllByClassname('npc_dota_building')
	for i = 1, #allBuildings, 1 do
		local building = allBuildings[i]
		if building:HasModifier('modifier_invulnerable') then
			building:RemoveModifierByName('modifier_invulnerable')
		end
	end

	-- Add gridnav blockers to the gold mines
	GameRules.GoldMines = Entities:FindAllByModel('models/mine/mine.vmdl')
	for k,gold_mine in pairs (GameRules.GoldMines) do
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

		-- Find and store the mine light
	end

	-- Allow cosmetic swapping
	SendToServerConsole( "dota_combine_models 0" )

	-- Console Commands
	Convars:RegisterCommand( "skip_selection", Dynamic_Wrap(dotacraft, 'Skip_Selection'), "Skip Selection", 0 )
	
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

	GameRules.DefeatedTeamCount = 0

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
  	GameRules.Buildings = LoadKeyValues("scripts/kv/buildings.kv")

  	GameRules.ALLTREES = Entities:FindAllByClassname("ent_dota_tree")
  	for _,t in pairs(GameRules.ALLTREES) do
  		t.health = TREE_HEALTH
  	end

  	-- Store and update selected units of each pID
	GameRules.SELECTED_UNITS = {}

	-- Keeps the blighted gridnav positions
	GameRules.Blight = {}
  	
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

	--PrecacheUnitByNameAsync("npc_dota_hero_keeper_of_the_light", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_zuus", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_omniknight", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_Invoker", function(...) end)

	PrecacheUnitByNameAsync("npc_dota_hero_antimage", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_mirana", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_leshrac", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_phantom_assassin", function(...) end)

	PrecacheUnitByNameAsync("npc_dota_hero_abaddon", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_night_stalker", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_lich", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_nyx_assassin", function(...) end)

	PrecacheUnitByNameAsync("npc_dota_hero_juggernaut", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_disruptor", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_elder_titan", function(...) end)
	PrecacheUnitByNameAsync("npc_dota_hero_shadow_shaman", function(...) end)

	PrecacheItemByNameAsync("item_orb_of_frost", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_fire", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_venom_wc3", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_corruption", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_darkness", function(...) end)
	PrecacheItemByNameAsync("item_orb_of_lightning", function(...) end)

	PrecacheItemByNameAsync("item_scroll_of_regeneration", function(...) end)
	PrecacheItemByNameAsync("item_mechanical_critter", function(...) end)
	PrecacheItemByNameAsync("item_lesser_clarity_potion", function(...) end)
	PrecacheItemByNameAsync("item_potion_of_healing", function(...) end)
	PrecacheItemByNameAsync("item_potion_of_mana", function(...) end)
	PrecacheItemByNameAsync("item_scroll_of_town_portal", function(...) end)
	PrecacheItemByNameAsync("item_build_ivory_tower", function(...) end)
	PrecacheItemByNameAsync("item_staff_of_sanctuary", function(...) end)
end

function dotacraft:OnFirstPlayerLoaded()
	print("[DOTACRAFT] First Player has loaded")
end

function dotacraft:OnAllPlayersLoaded()
	print("[DOTACRAFT] All Players have loaded into the game")

	print("[DOTACRAFT] Initializing Neutrals")
	GameRules.ALLNEUTRALS = Entities:FindAllByClassname("npc_dota_creature")
	for k,npc in pairs(GameRules.ALLNEUTRALS) do
		if npc:GetTeamNumber() == DOTA_TEAM_NEUTRALS then

			-- Apply armor and damage modifier (for visuals)
			local attack_type = GetAttackType(npc)
			if attack_type ~= 0 and npc:GetAttackDamage() > 0 then
				ApplyModifier(npc, "modifier_attack_"..attack_type)
		    end

		    local armor_type = GetArmorType(npc)
			if armor_type ~= 0 then
				ApplyModifier(npc, "modifier_armor_"..armor_type)
		    end

		    if HasSplashAttack(npc) then
		    	ApplyModifier(npc, "modifier_splash_attack")
		    end

		    -- Attack system
		    npc:SetIdleAcquire(false)
		    npc.AcquisitionRange = npc:GetAcquisitionRange()
		    npc:SetAcquisitionRange(0)
		    ApplyModifier(npc,"modifier_neutral_idle_aggro")
		    
		    NeutralAI:Start( npc )
		end
	end
end

function dotacraft:OnHeroInGame(hero)
	local hero_name = hero:GetUnitName()
	print("[DOTACRAFT] OnHeroInGame "..hero_name)

	-- Ignore the dummy hero to replace with
	if hero_name == "npc_dota_hero_ancient_apparition" then
		local aa = hero
		aa:AddNoDraw() -- Hides the model
		Timers:CreateTimer(function() 
			aa:SetAbsOrigin(Vector(11000,11000,0)) -- Hides the minimap icon
		end)
		return
	end

	if hero:HasAbility("hide_hero") then
		Timers:CreateTimer(0.03, function() 
			dotacraft:InitializePlayer(hero)
		end)
	else
		print("[DOTACRAFT] Hero spawned in game for first time -- " .. hero:GetUnitName())

		if Convars:GetBool("developer") then
			for i=1,9 do
				hero:HeroLevelUp(false)
			end
		end

		dotacraft:ModifyStatBonuses(hero)

		-- Innate abilities
		if hero:HasAbility("nightelf_shadow_meld") then
			hero:FindAbilityByName("nightelf_shadow_meld"):SetLevel(1)
		end

		if hero:HasAbility("blood_mage_orbs") then
			hero:FindAbilityByName("blood_mage_orbs"):SetLevel(1)
		end

		if hero:HasAbility("firelord_arcana_model") then
			hero:FindAbilityByName("firelord_arcana_model"):SetLevel(1)
		end
	end

end

function dotacraft:InitializePlayer( hero )
	local player = hero:GetPlayerOwner()
	local playerID = hero:GetPlayerID()

	print("[DOTACRAFT] Initializing main hero entity for player "..playerID)

	-- Initialize Variables for Tracking
	player.buildings = {} -- This keeps the name and quantity of each building, to access in O(1)
	player.units = {} -- This keeps the handle of all the units of the player army, to iterate for unlocking upgrades
	player.structures = {} -- This keeps the handle of the constructed units, to iterate for unlocking upgrades
	player.upgrades = {} -- This kees the name of all the upgrades researched, so each unit can check and upgrade itself on spawn
	player.heroes = {} -- Owned hero units (not this assigned hero, which will be a fake)
	player.altar_structures = {} -- Keeps altars linked
	player.idle_builders = {} -- Keeps indexes of idle builders to send to the panorama UI
	player.lumber = 0
	player.food_limit = 0 -- The amount of food available to build units
	player.food_used = 0 -- The amount of food used by this player creatures
	player.city_center_level = 1 -- The maximum level from city centers of the player

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

	local building = BuildingHelper:PlaceBuilding(player, city_center_name, position, true, 5, 0) 
	player.buildings[city_center_name] = 1
	
	-- Snap the camera to the created building and add it to selection
	Timers:CreateTimer(function()
		PlayerResource:SetCameraTarget(playerID, building)

		Timers:CreateTimer(0.1, function()
			PlayerResource:SetCameraTarget(playerID, nil)
			AddUnitToSelection(building)
		end)
	end)

	table.insert(player.structures, building)
	player.main_city_center = building

	CheckAbilityRequirements( building, player )

	-- Give Initial Food
    ModifyFoodLimit(player, GetFoodProduced(building))

	-- Create Builders in between the gold mine and the city center
	local num_builders = 5
	local angle = 360 / num_builders
	local closest_mine = GetClosestGoldMineToPosition(position)
	local closest_mine_pos = closest_mine:GetAbsOrigin()
	local mid_point = closest_mine_pos + (position-closest_mine_pos)/2

	-- Undead special rules
	if hero_name == "npc_dota_hero_life_stealer" then
		num_builders = 3
		local ghoul = CreateUnitByName("undead_ghoul", mid_point+Vector(1,0,0) * 200, true, hero, hero, hero:GetTeamNumber())
		ghoul:SetOwner(hero)
		ghoul:SetControllableByPlayer(playerID, true)
		ModifyFoodUsed(player, GetFoodCost(ghoul))

		-- Haunt the closest gold mine
		local haunted_gold_mine = CreateUnitByName("undead_haunted_gold_mine", closest_mine_pos, false, hero, hero, hero:GetTeamNumber())
		haunted_gold_mine:SetOwner(hero)
		haunted_gold_mine:SetControllableByPlayer(playerID, true)
		haunted_gold_mine.counter_particle = ParticleManager:CreateParticle("particles/custom/gold_mine_counter.vpcf", PATTACH_CUSTOMORIGIN, entangled_gold_mine)
		ParticleManager:SetParticleControl(haunted_gold_mine.counter_particle, 0, Vector(closest_mine_pos.x,closest_mine_pos.y,closest_mine_pos.z+200))
		haunted_gold_mine.builders = {}

		Timers:CreateTimer(function() 
			CreateBlight(haunted_gold_mine:GetAbsOrigin(), "small")
			CreateBlight(building:GetAbsOrigin(), "large")
		end)

		player.LumberCarried = 20 -- Ghouls carry harder

		haunted_gold_mine.mine = closest_mine -- A reference to the mine that the haunted mine is associated with
		closest_mine.building_on_top = haunted_gold_mine -- A reference to the building that haunts this gold mine
	end

	-- Night Elf special rules
	if hero_name == "npc_dota_hero_furion" then
		-- Entangle the closest gold mine
		local entangled_gold_mine = CreateUnitByName("nightelf_entangled_gold_mine", closest_mine_pos, false, hero, hero, hero:GetTeamNumber())
		entangled_gold_mine:SetOwner(hero)
		entangled_gold_mine:SetControllableByPlayer(playerID, true)
		entangled_gold_mine.counter_particle = ParticleManager:CreateParticle("particles/custom/gold_mine_counter.vpcf", PATTACH_CUSTOMORIGIN, entangled_gold_mine)
		ParticleManager:SetParticleControl(entangled_gold_mine.counter_particle, 0, Vector(closest_mine_pos.x,closest_mine_pos.y,closest_mine_pos.z+200))
		entangled_gold_mine.builders = {}

		entangled_gold_mine.mine = closest_mine -- A reference to the mine that the entangled mine is associated with
		entangled_gold_mine.city_center = building -- A reference to the city center that entangles this mine
		building.entangled_gold_mine = entangled_gold_mine -- A reference to the entangled building of the city center
		closest_mine.building_on_top = entangled_gold_mine -- A reference to the building that entangles this gold mine

		building:SwapAbilities("nightelf_entangle_gold_mine", "nightelf_entangle_gold_mine_passive", false, true)

		building:SetAngles(0,-90,0)
	end

	if hero_name == "npc_dota_hero_dragon_knight" or hero_name == "npc_dota_hero_huskar" then
		player.LumberCarried = 10
	end

	for i=1,num_builders do	
		--DebugDrawCircle(mid_point, Vector(255, 0 , 0), 255, 100, true, 10)
		local rotate_pos = mid_point + Vector(1,0,0) * 100
		local builder_pos = RotatePosition(mid_point, QAngle(0, angle*i, 0), rotate_pos)

		local builder = CreateUnitByName(builder_name, builder_pos, true, hero, hero, hero:GetTeamNumber())
		builder:SetOwner(hero)
		builder:SetControllableByPlayer(playerID, true)
		table.insert(player.units, builder)
		builder.state = "idle"

		-- Increment food used
		ModifyFoodUsed(player, GetFoodCost(builder))

		-- Go through the abilities and upgrade
		CheckAbilityRequirements( builder, player )
	end

	-- Give Initial Resources
	hero:SetGold(500, false)
	ModifyLumber(player, 150)

	-- Hide main hero under the main base
	local ability = hero:FindAbilityByName("hide_hero")
	ability:UpgradeAbility(true)
	hero:SetAbilityPoints(0)
	hero:SetAbsOrigin(Vector(position.x,position.y,position.z - 420 ))
	Timers:CreateTimer(function() hero:SetAbsOrigin(Vector(position.x,position.y,position.z - 420 )) return 1 end)
	hero:AddNoDraw()

	-- Find neutrals near the starting zone and remove them
	local neutrals = FindUnitsInRadius(hero:GetTeamNumber(), position, nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, true)
	for k,v in pairs(neutrals) do
		if v:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
			v:RemoveSelf()
		end
	end

	-- Test options
	if Convars:GetBool("developer") then
		dotacraft:DeveloperMode(player)
	end

	-- Show UI elements for this race
	local player_race = GetPlayerRace(player)
	CustomGameEventManager:Send_ServerToPlayer(player, "player_show_ui", { race = player_race, initial_builders = num_builders })

	-- Keep track of the Idle Builders and send them to the panorama UI every time the count updates
	Timers:CreateTimer(1, function() 
		local idle_builders = {}
		local player_units = player.units
		for k,unit in pairs(player_units) do
			if IsValidAlive(unit) and IsBuilder(unit) and IsIdleBuilder(unit) then
				table.insert(idle_builders, unit:GetEntityIndex())
			end
		end
		if #idle_builders ~= #player.idle_builders then
			--print("#Idle Builders changed: "..#idle_builders..", was "..#player.idle_builders)
			player.idle_builders = idle_builders
			CustomGameEventManager:Send_ServerToPlayer(player, "player_update_idle_builders", { idle_builder_entities = idle_builders })
		end
		return 0.3
	end)
end

function dotacraft:OnGameInProgress()
	print("[DOTACRAFT] The game has officially begun")

	-- Setup Tavern
	local taverns = Entities:FindAllByName("*shop_tavern")
	for k,v in pairs(taverns) do
		TeachAbility(v,"ability_shop")
	end

	GameRules.DayTime = true
	Timers:CreateTimer(240, function() 
		if GameRules.DayTime then
			LightsOut()
		else
			RiseAndShine()
		end
		return 240
	end)
end

-- Creeps go into sleep mode
function LightsOut()
	print("[DOTACRAFT] Night Time")
	GameRules.DayTime = false
end

-- Wake up creeps
function RiseAndShine()
	print("[DOTACRAFT] Day Time")
	GameRules.DayTime = true
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
	local newState = GameRules:State_Get()

	print("[DOTACRAFT] GameRules State Changed: ",newState)
		
	-- send the panaroma developer at each stage to ensure all js are exposed to it
	dotacraft:Panaroma_Developer_Mode(newState)
	
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

	if IsBuilder(npc) then
		BuildingHelper:InitializeBuilder(npc)
	end

	-- Apply armor and damage modifier (for visuals)
	local attack_type = GetAttackType(npc)
	if attack_type ~= 0 and npc:GetAttackDamage() > 0 then
		ApplyModifier(npc, "modifier_attack_"..attack_type)
    end

    local armor_type = GetArmorType(npc)
	if armor_type ~= 0 then
		ApplyModifier(npc, "modifier_armor_"..armor_type)
    end

    if HasSplashAttack(npc) then
    	ApplyModifier(npc, "modifier_splash_attack")
    end

    -- Attack system
    npc:SetIdleAcquire(false)
    npc.AcquisitionRange = npc:GetAcquisitionRange()
    npc:SetAcquisitionRange(0)
    ApplyModifier(npc, "modifier_attack_system")

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

  	-- Cheat code host only
  	if GameRules.WhosYourDaddy and victim and attacker then
  		local attackerID = cause:GetPlayerOwnerID()
  		if attackerID == 0 then
  			victim:Kill(nil, cause)
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
	DeepPrintTable(keys)

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
	    		--DebugDrawCircle(t:GetAbsOrigin(), Vector(0,255,0), 255, 32, true, 60)
	    		t.pathable = true
	    	end
	    end
	end
	
	-- Check for Night Elf Sentinels and Wisps
	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(treeX,treeY,0), nil, 64, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
	for _,v in pairs(units) do
		local unit_name = v:GetUnitName()
		if unit_name == "nightelf_sentinel_owl" then
			v:ForceKill(false)
		elseif unit_name == "nightelf_wisp" then
			local gather_ability = v:FindAbilityByName("nightelf_gather")
			v:RemoveModifierByName("modifier_gathering_lumber")
			v.state = "idle"
			v:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
			ToggleOff(gather_ability)
		end
	end
end

-- A player picked a hero
function dotacraft:OnPlayerPickHero(keys)
	print ('[DOTACRAFT] OnPlayerPickHero')
	--DeepPrintTable(keys)
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
		print("A Hero was killed")
		
		-- add hero to tavern, this function also works out cost etc
		unit_shops:AddHeroToTavern(killedUnit)
		
		if IsValidEntity(player.altar) then
			print("Player has "..#player.altar_structures.." valid "..player.altar:GetUnitName())
			for _,altar in pairs(player.altar_structures) do
				-- Set the strings for the _acquired ability to find and _revival ability to add
				local level = killedUnit:GetLevel()
				local name = killedUnit.RespawnAbility

				print("ALLOW REVIVAL OF THIS THIS HERO AT THIS ALTAR - Ability: ",name)

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
							print("ABILITY COULDNT BE CHANGED BECAUSE NO "..revival_ability_name.." WAS FOUND ON THIS ALTAR")
						end
					else
						-- The ability couldn't be found (a neutral hero), add it
						print("ABILITY COULDNT BE CHANGED BECAUSE NO "..acquired_ability_name.." WAS FOUND ON THIS ALTAR")

					end
				end
			end
		else
			print("Hero Killed but player doesn't have an altar to revive it")
		end
	end

	-- Substract the Food Used
	local food_cost = GetFoodCost(killedUnit)
	if food_cost > 0 and player and tableContains(player.units, killedUnit) then
		ModifyFoodUsed(player, - food_cost)
	end

	-- Table cleanup
	if player then
		-- Remake the tables
		local table_structures = {}
		for _,building in pairs(player.structures) do
			if building and IsValidEntity(building) and building:IsAlive() then
				--print("Valid building: "..building:GetUnitName())
				table.insert(table_structures, building)
			end
		end
		player.structures = table_structures

		local table_altars = {}
		for _,altar in pairs(player.altar_structures) do
			if altar and IsValidEntity(altar) and altar:IsAlive() then
				--print("Valid altar: "..altar:GetUnitName())
				table.insert(table_altars, altar)
			end
		end
		player.altar_structures = table_altars
				
		local table_units = {}
		for _,unit in pairs(player.units) do
			if unit and IsValidEntity(unit) then
				table.insert(table_units, unit)
			end
		end
		player.units = table_units		
	end

	-- Building Killed
	if IsCustomBuilding(killedUnit) then

		 -- Building Helper grid cleanup
		BuildingHelper:RemoveBuilding(killedUnit, true)

		local particle = ParticleManager:CreateParticle("particles/world_destruction_fx/base_statue_destruction_generic_c.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(particle,0 , killedUnit:GetAbsOrigin())
		killedUnit:AddNoDraw()

		-- Substract the Food Produced
		local food_produced = GetFoodProduced(killedUnit)
		if food_produced > 0 and player and not killedUnit.state == "canceled" then
			ModifyFoodLimit(player, - food_produced)
		end

		-- Check units for downgrades
		local building_name = killedUnit:GetUnitName()
				
		-- Substract 1 to the player building tracking table for that name
		if player.buildings[building_name] then
			player.buildings[building_name] = player.buildings[building_name] - 1
		end

		-- possible builder downgrades
		for k,units in pairs(player.units) do
		    CheckAbilityRequirements( units, player )
		end

		-- possible structure downgrades
		for k,structure in pairs(player.structures) do
			CheckAbilityRequirements( structure, player )
		end

		-- If the destroyed building was a city center, update the level
		if IsCityCenter(killedUnit) then
			CheckCurrentCityCenters(player)
		end

		-- Check for lose condition - All buildings destroyed
		print("Player "..player:GetPlayerID().." has "..#player.structures.." buildings left")
		if (#player.structures == 0) then
			dotacraft:CheckDefeatCondition(player)
		end

	-- Unit Killed
	else
		-- Give Experience to heroes based on the level of the killed creature
		if not IsCustomBuilding(killedUnit) then
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

		if IsBuilder(killedUnit) then
			BuildingHelper:ClearQueue(killedUnit)
		end
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
			Timers:CreateTimer(3, function() if IsValidEntity(corpse) then corpse:RemoveNoDraw() end end)

			-- Remove itself after the corpse duration
			Timers:CreateTimer(CORPSE_DURATION, function()
				if corpse and IsValidEntity(corpse) then
					print("removing corpse")
					corpse:RemoveSelf()
				end
			end)
		end
	end)
end

function dotacraft:OnPlayerSelectedEntities( event )
	local pID = event.pID

	GameRules.SELECTED_UNITS[pID] = event.selected_entities
	dotacraft:UpdateRallyFlagDisplays(pID)

	-- This is for Building Helper to know which is the currently active builder
	local mainSelected = GetMainSelectedEntity(pID)
	if IsValidEntity(mainSelected) and IsBuilder(mainSelected) then
		local player = PlayerResource:GetPlayer(pID)
		player.activeBuilder = mainSelected
	end
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

function dotacraft:RepositionPlayerCamera( event )
	local pID = event.pID
	local entIndex = event.entIndex
	local entity = EntIndexToHScript(entIndex)
	if entity and IsValidEntity(entity) then
		PlayerResource:SetCameraTarget(pID, entity)
		Timers:CreateTimer(function()
			PlayerResource:SetCameraTarget(pID, nil)
		end)
	end
end

-- Whenever a building is destroyed and the player structures hit 0, check for defeat & win condition
-- In team games, teams are defeated as a whole instead of each player (because of resource trading and other shenanigans)
-- Defeat condition: All players of the same team have 0 buildings
-- Win condition: All teams have been defeated but one (i.e. there are only structures left standing for players of the same team)
function dotacraft:CheckDefeatCondition( player )
	local teamNumber = player:GetTeamNumber()

	--SetNetTableValue("dotacraft_player_table", tostring(player:GetPlayerID()), {Status = "defeated"})

	-- Check the player.structures of all the members of that team to determine defeat
	local teamMembers = 0
	local defeatedTeamMembers = 0
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player:GetTeamNumber() == teamNumber then
				teamMembers = teamMembers + 1
				if #player.structures == 0 then
					defeatedTeamMembers = defeatedTeamMembers + 1
				end
			end			
		end
	end

	print("CheckDefeatCondition: There are ["..teamMembers.."] players in Team "..teamNumber.." and ["..defeatedTeamMembers.."] without structures left standing")
	
	if defeatedTeamMembers == teamMembers then
		print("All players of team "..teamNumber.." are defeated")
		GameRules.DefeatedTeamCount = GameRules.DefeatedTeamCount + 1
		dotacraft:PrintDefeateMessageForTeam( teamNumber )
	end

	-- Victory: Only 1 team left standing
	local teamCount = dotacraft:GetTeamCount()
	print("Team Count: "..teamCount,"Defeated Teams: "..GameRules.DefeatedTeamCount)

	if GameRules.DefeatedTeamCount+1 == teamCount then
		winningTeam = dotacraft:GetWinningTeam()
		print("Winning Team: "..winningTeam)
		dotacraft:PrintWinMessageForTeam(winningTeam)
		GameRules:SetGameWinner(winningTeam)
	end

end

-- Returns an Int with the number of teams with valid players in them
function dotacraft:GetTeamCount()
	local teamCount = 0
	for i=DOTA_TEAM_FIRST,DOTA_TEAM_CUSTOM_MAX do
		local playerCount = PlayerResource:GetPlayerCountForTeam(i)
		if playerCount > 0 then
			teamCount = teamCount + 1
			print("  Team ["..i.."] has "..playerCount.." players")
		end
	end
	return teamCount
end

-- This should only be called when all teams but one are defeated
-- Returns the first player with a building left standing
function dotacraft:GetWinningTeam()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if #player.structures > 0 then
				return player:GetTeamNumber()
			end
		end
	end
end

function dotacraft:PrintDefeateMessageForTeam( teamID )
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player:GetTeamNumber() == teamID then
				local playerName = PlayerResource:GetPlayerName(playerID)
				if playerName == "" then playerName = "Player "..playerID end
				GameRules:SendCustomMessage(playerName.." was defeated", 0, 0)
			end
		end
	end
end

function dotacraft:PrintWinMessageForTeam( teamID )
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player:GetTeamNumber() == teamID then
				local playerName = PlayerResource:GetPlayerName(playerID)
				if playerName == "" then playerName = "Player "..playerID end
				GameRules:SendCustomMessage(playerName.." was victorious", 0, 0)
			end
		end
	end
end

--[[

Pre_Game_Selection

]]
function dotacraft:Skip_Selection()
	CustomGameEventManager:Send_ServerToAllClients("dotacraft_skip_selection", {}) 
end

function dotacraft:Lock_Teams(data)

	if GameRules.LockTeams == nil then
		print("Creating lockteams")
		GameRules.LockTeams = false
	end
	
	-- toggle
	if GameRules.LockTeams then
		GameRules.LockTeams = false
	else
		GameRules.LockTeams = true
	end

	CustomGameEventManager:Send_ServerToAllClients("dotacraft_lock_teams", {Locked = GameRules.LockTeams})
end

function dotacraft:Create_Players(data)
	print("[DOTACRAFT] Create Players")
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS, 1 do
		if PlayerResource:IsValidPlayerID(playerID) then
			local Player_Table = GetNetTableValue("dotacraft_player_table", tostring(playerID))
			
			local color = GetNetTableValue("dotacraft_color_table", tostring(Player_Table.Color))
			local team = Player_Table.Team
			local race = GameRules.raceTable[Player_Table.Race]

			-- if race is nil it means that the id supplied is random since that is the only fallout index
			if race == nil then
				race = GameRules.raceTable[RandomInt(1, #GameRules.raceTable)]
			end

			-- player stuff
			PlayerResource:SetCustomPlayerColor(playerID, color.r, color.g, color.b)
			PlayerResource:SetCustomTeamAssignment(playerID, team)
			--CreateHeroForPlayer(race, PlayerResource:GetPlayer(playerID))
				
			Timers:CreateTimer(0.1,function()
				local hero_race = PlayerResource:GetPlayer(playerID):GetAssignedHero()
				PlayerResource:ReplaceHeroWith(playerID, race, 0, 0)
				print("[DOTACRAFT] Player Created: ",race,hero_race)
			end)
		end
	end
end

function dotacraft:Selection_Update_Player(args)
	print("updating player")
	local PlayerID = args.ID
		
	SetNetTableValue("dotacraft_player_table", tostring(PlayerID), {Team = args.Team, Color = args.Color, Race = args.Race, Ready = args.Ready})
end

function dotacraft:Setup_Tables()
	-- setup color table
	dotacraft:Setup_Color_Table()
	
	-- setup race reference table
	if GameRules.raceTable == nil then
		GameRules.raceTable = {}
		
		GameRules.raceTable[1] = "npc_dota_hero_dragon_knight"
		GameRules.raceTable[2] = "npc_dota_hero_huskar"
		GameRules.raceTable[3] = "npc_dota_hero_furion"
		GameRules.raceTable[4] = "npc_dota_hero_life_stealer"
	end
end

function dotacraft:Setup_Color_Table()
	print("creating color table")
		
	SetNetTableValue("dotacraft_color_table", "0", 	{r=255, g=0,   b=0	})	-- red
	SetNetTableValue("dotacraft_color_table", "1", 	{r=0, 	g=0,   b=255})	-- blue
	SetNetTableValue("dotacraft_color_table", "2", 	{r=0, 	g=255, b=255})	-- teal
	SetNetTableValue("dotacraft_color_table", "3", 	{r=125, g=0,   b=255})	-- purple
	SetNetTableValue("dotacraft_color_table", "4", 	{r=255, g=255, b=0	})	-- yellow
	SetNetTableValue("dotacraft_color_table", "5", 	{r=255, g=125, b=0	})	-- orange
	SetNetTableValue("dotacraft_color_table", "6", 	{r=0, 	g=255, b=0	})	-- green
	SetNetTableValue("dotacraft_color_table", "7",	{r=255, g=100, b=255})	-- pink
	SetNetTableValue("dotacraft_color_table", "8",	{r=125, g=125, b=125})	-- gray	

end

-- this function is called every state change so that each JS file will recieve the developer args
function dotacraft:Panaroma_Developer_Mode(state)
	-- the reason for this function is that some JS are initialised later at the given state defined in the uimanifest.
	-- use this event inside your JS to catch it: 	GameEvents.Subscribe( "panaroma_developer", Developer_Mode ); Developer_Mode is the function inside js

	-- check if developer mode
	if Convars:GetBool("developer") then	
		Timers:CreateTimer(1, function()
			CustomGameEventManager:Send_ServerToAllClients("panaroma_developer", {developer = true})
		end)
	end
end

function SetNetTableValue(NetTableName, key, table)
	CustomNetTables:SetTableValue(NetTableName, key, table)
end

function GetNetTableValue(NetTableName, key)
    --print("NetTable", key, CustomNetTables:GetTableValue("dotacraft_color_table", key))
    return CustomNetTables:GetTableValue(NetTableName, key)
end

-- Returns a Vector with the color of the player
function dotacraft:ColorForPlayer( playerID )
	local Player_Table = GetNetTableValue("dotacraft_player_table", tostring(playerID))
	local color = GetNetTableValue("dotacraft_color_table", tostring(Player_Table.Color))
	
	return Vector(color.r, color.g, color.b)
end