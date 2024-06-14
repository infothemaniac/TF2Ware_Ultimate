minigame <- Ware_MinigameData
({
	name           = "Pirate Attack"
	author         = "ficool2"
	description    = 
	[
		"Jump over the RED ship!"
		"Jump over the BLUE ship!"
	]
	duration       = 12.0
	music          = "piper"
	location       = "beach"
	custom_overlay = 
	[
		"pirate_red"
		"pirate_blue"
	]
})
 
ship_model <- "models/marioragdoll/super mario galaxy/bj ship/bjship.mdl"
PrecacheModel(ship_model)

red_ship  <- null
blue_ship <- null

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Stickybomb Jumper")
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		local team = player.GetTeam()
		if (team == TF_TEAM_RED)
			Ware_SetPlayerMission(player, 0)
		else if (team == TF_TEAM_BLUE)
			Ware_SetPlayerMission(player, 1);	
	}
	
	red_ship = Ware_SpawnEntity("prop_dynamic_override",
	{
		origin      = Ware_MinigameLocation.center + Vector(2200, 300, -136),
		model       = ship_model
		rendercolor = "255 0 0",
	})
	blue_ship = Ware_SpawnEntity("prop_dynamic_override",
	{
		origin      = Ware_MinigameLocation.center + Vector(2200, -500, -136),
		model       = ship_model
		rendercolor = "0 255 255",
	})
}

function OnUpdate()
{
	local offset = Vector(0, 0, 300)
	local red_point = red_ship.GetOrigin() + offset
	local blue_point = blue_ship.GetOrigin() + offset
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (!IsEntityAlive(player))
			continue
		
		if (player.GetFlags() & FL_INWATER)
		{
			Ware_TeleportPlayer(player, Ware_MinigameLocation.center, ang_zero, vec3_zero)
			continue
		}
		
		local origin = player.GetOrigin()
		local team = player.GetTeam()
		if (team == TF_TEAM_RED)
		{
			if (origin.z > red_point.z && (origin - red_point).Length2D() < 150.0)
			{
				Ware_ShowScreenOverlay(player, null)
				Ware_CreateTimer(@() Ware_PassPlayer(player, true), 0.1)
				Ware_TeleportPlayer(player, Ware_MinigameLocation.center, ang_zero, vec3_zero)
			}
		}
		else if (team == TF_TEAM_BLUE)
		{
			if (origin.z > blue_point.z && (origin - blue_point).Length2D() < 150.0)
			{
				Ware_ShowScreenOverlay(player, null);	
				Ware_CreateTimer(@() Ware_PassPlayer(player, true), 0.1)
				Ware_TeleportPlayer(player, Ware_MinigameLocation.center, ang_zero, vec3_zero)
			}			
		}
	}
}