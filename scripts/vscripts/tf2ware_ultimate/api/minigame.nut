// by ficool2 and pokemonpasta

// Settings for a minigame or bossgame
class Ware_MinigameData
{
	function constructor(table = null)
	{
		location        = "home"
		min_players     = 0
		start_pass      = false
		allow_damage    = false
		allow_scale     = true
		allow_suicide   = false
		force_backstab  = false
		start_freeze    = false
		fail_on_death   = false
		suicide_on_end  = false
		collisions 	    = false
		friendly_fire   = true
		thirdperson     = false
		boss		    = false
		end_delay       = 0.0
		convars         = []
		entities        = []
		cleanup_names   = {}
		timers		    = []
		annotations     = []
		conditions      = []
		
		if (table)
		{
			foreach (key, value in table)
				this[key] = value
		}
	}
	
	// == Mandatory settings ==
	
	// Visual name
	name			= null
	// Who made the minigame?
	// Unused for now but might be used for credits in the future
	author			= null
	// Description shown to people
	// This can either be a string or an array of strings (when using missions)
	description		= null
	// Length before ending
	duration		= null
	// Music to play
	music			= null
	
	// == Optional settings ==
	
	// Map location to teleport to (Ware_Location enum), default is home
	location		= null
	// Minimum amount of players needed to start, default is 0
	min_players		= null
	// Whether players will be flagged as passed when minigame starts, default is false
	start_pass		= null
	// Is damage to other players allowed? Default is false
	allow_damage	= null
	// Are player scales from outside the minigame permitted?
	// If not, this will set it to 1.0 and revert it after the minigame has ended. Default is true
	// TODO: This probably makes more sense as max_scale and min_scale, but that'll require more specific minigame tuning. This is fine for now
	allow_scale     = null
	// Do suicides count for points? Default is false
	allow_suicide   = null	
	// Allow backstabs with any weapon
	force_backstab  = null
	// Freeze players when minigame starts for 0.5 seconds, default is false
	// Useful to allow some reaction time to not fall off a ledge etc
	start_freeze    = null
	// Whether players should be automatically failed when they die, default is false
	fail_on_death	= null
	// Whether players should suicide if they haven't passed when minigame ends, default is false
	suicide_on_end	= null
	// Enables collisions between players, default is false
	collisions    	= null
	// Toggle friendlyfire, default is true
	friendly_fire	= null
	// Force players into thirdperson? Default is false
	thirdperson	    = null
	// Delay after the minigame "ends" before showing results, default is 0.0
	end_delay		= null
	// Custom text overlay to show rather than the default implied from name
	// This can either be a string or an array of strings (when using missions)
	custom_overlay	= null
	// Secondary custom text overlay to show 
	// Same rules as above
	custom_overlay2 = null
	// Table of convars to set for this minigame
	// Reverted to previous values after minigame ends
	convars			= null
	
	// == Internal use only ==
	
	// Is a boss game?
	boss			= null
	// File name
	file_name       = null
	// Entities spawned by the minigame, to remove after it ends
	entities		= null
	// Entity names to delete after minigame ends (e.g. projectiles)
	cleanup_names	= null
	// Timers spawned by the minigame, stopped after it ends
	timers			= null
	// Annotations created by the minigame, hidden after it ends
	annotations		= null
	// Player conditions added by the minigame, reverted after end
	conditions		= null
	
	// == Callbacks ==
	// If these functions exist in a minigame's scope, they are passed to the appropriate points in the code.
	// Game events in a minigame scope are also supported in the typical format (e.g. "OnGameEvent_player_builtobject(params)")
	
	// OnTakeDamage(params)                - Called by OnTakeDamage in main.nut and functions as normal.
	cb_on_take_damage		= null
	// OnPlayerAttack(player)              - Called by Ware_OnUpdate, when a player attacks and passes that player.
	cb_on_player_attack		= null
	// OnPlayerDeath(params)               - Called by OnGameEvent_player_death, and passes its parameters.
	cb_on_player_death		= null
	// OnPlayerDisconnect(player)          - Called by OnGameEvent_player_disconnect, and passes the player.
	cb_on_player_disconnect	= null
	// OnPlayerSay(player, text)           - Called by OnGameEvent_player_say, and passes the player and what they typed.
	cb_on_player_say		= null
	// OnPlayerVoiceline(player, name)     - Called by Ware_OnUpdate, and passes the player who used a voiceline and the name of the voiceline.
	cb_on_player_voiceline	= null
	// OnPlayerHorn(player)                - Called by Ware_OnUpdate when a player uses the horn in a kart (MOUSE1). Passes the player who used a horn.
	cb_on_player_horn		= null
	// OnPlayerTouch(player, other_player) - Called by Ware_OnUpdate when two players touch and passes the two players.
	cb_on_player_touch		= null
	// OnPrecache()                        - Ware_PrecacheNext checks all minigame scopes for OnPrecache when the map is loaded and calls any found. Use this if you need to precache anything.
	cb_on_precache          = null
	// OnUpdate()                          - Called by Ware_OnUpdate every frame.
	cb_on_update			= null
	// CheckEnd()                          - Called by Ware_OnUpdate. Return a condition in this function and if the condition is met, the minigame will end early.
	cb_check_end			= null
}

// Global variables

// The current minigame data. Null if no minigame active
Ware_Minigame             <- null
// Current minigame's scope
Ware_MinigameScope        <- {}
// Current minigame's location
Ware_MinigameLocation     <- null
// Current home location, players get teleported back here after a minigame
Ware_MinigameHomeLocation <- null

// Gets the time elapsed in seconds since the minigame has started
function Ware_GetMinigameTime()
{
	return Time() - Ware_MinigameStartTime
}

// Gets the time remaining in seconds before a minigame ends
function Ware_GetMinigameRemainingTime()
{
	return (Ware_MinigameStartTime + Ware_Minigame.duration + Ware_Minigame.end_delay) - Time()
}

// Sets the value of a convar
// The current value will be saved (if not already saved) and reverted after the minigame ends
function Ware_SetConvarValue(convar, value)
{
	Ware_Minigame.convars[convar] <- value
	if (!(name in Ware_MinigameSavedConvars))
		Ware_MinigameSavedConvars[name] <- GetConvarValue(name)
	SetConvarValue(name, value)
}

// Creates a timer that will be automatically killed early if the minigame ends before the timer executes
// Behaves identically to CreateTimer
function Ware_CreateTimer(on_timer_func, delay)
{
	local timer = CreateTimer(on_timer_func, delay)
	Ware_Minigame.timers.append(timer)
	return timer
}

// Creates an entity that will be automatically deleted after the minigame is over
// This behaves identically to Entities.CreateByClassname
function Ware_CreateEntity(classname)
{
	local entity = CreateEntitySafe(classname)
	Ware_Minigame.entities.append(entity)
	return entity
}

// Creates an entity that will be automatically deleted after the minigame is over
// This behaves identically to SpawnEntityFromTable
function Ware_SpawnEntity(classname, keyvalues)
{
	local entity = SpawnEntityFromTableSafe(classname, keyvalues)
	Ware_Minigame.entities.append(entity)
	return entity
}

// Spawns a temporary wearable (cosmetic, etc) that will be removed when a minigame ends
// This doesn't attach it to the player. You need to use SetEntityParent after spawning it
function Ware_SpawnWearable(player, model_name)
{
	local wearable = Ware_CreateEntity("tf_wearable")
	wearable.KeyValueFromString("classname", "ware_wearable")
	SetPropInt(wearable, "m_nModelIndex", PrecacheModel(model_name))
	SetPropBool(wearable, "m_bValidatedAttachedEntity", true)
	wearable.SetOwner(player)
	wearable.DispatchSpawn()
	return wearable
}

// Toggles the visibility of a cosmetic
function Ware_ToggleWearable(wearable, toggle)
{
	wearable.SetDrawEnabled(toggle)
}

// Shows a 2D annotation positioned in the 3D world
// Annotations are automatically hidden when a minigame ends
// "input" can be a vector or an entity handle
// If it's an entity handle, the annotation will follow that entity
// If you want it to start at an entity but stay there, pass that entity's origin instead
// Returns a unique ID which may be used to hide it later with Ware_HideAnnotation
function Ware_ShowAnnotation(input, text, lifetime = -1)
{
	local vector, entindex

	if (typeof(input) == "Vector")
	{
		vector = input
		entindex = 0
	}
	else if (typeof(input) == "instance")
	{
		vector = input.GetOrigin()
		entindex = input.entindex()
	}
	else
	{
		Ware_Error("Invalid input type passed to Ware_ShowAnnotation")
		return
	}
	
	if (Ware_SpecialRound && Ware_SpecialRound.reverse_text)
		text = ReverseString(text)
	
	local id = Ware_AnnotationIDs++
	
	SendGlobalGameEvent("show_annotation",
	{
		worldPosX = vector.x,
		worldPosY = vector.y,
		worldPosZ = vector.z,
		id = id,
		text = text,
		lifetime = lifetime,
		visibilityBitfield = 0,
		follow_entindex = entindex,
		show_distance = false,
		show_effect = false,
		play_sound = "common/null.wav",
	})
	
	if (Ware_Minigame != null)
		Ware_Minigame.annotations.append(id)
	
	return id
}

// Hides an annotation using an ID returned from Ware_ShowAnnotation
function Ware_HideAnnotation(id)
{
	SendGlobalGameEvent("hide_annotation", { id = id })
	if (Ware_Minigame != null)
	{
		local idx = Ware_Minigame.annotations.find(id)
		if (idx != null)
			Ware_Minigame.annotations.remove(idx)
	}
}