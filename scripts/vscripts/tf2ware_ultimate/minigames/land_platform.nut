local mode = RandomInt(0, 1);

minigame <- Ware_MinigameData();
minigame.name = "Land the Platform";
minigame.description = "Land on the platform!";
minigame.duration = mode == 0 ? 6.0 : 4.0;
minigame.no_collisions = true;
minigame.location = "factoryplatform";
minigame.music = mode == 0 ? "sweetdays" : "surfin";

function OnStart()
{
	if (mode == 0)
		Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Iron Bomber");
	else
		Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Thermal Thruster");
}

function OnTeleport(players)
{
	local red_players = [];
	local blue_players = [];
	foreach (player in players)
	{
		local team = player.GetTeam();
		if (team == TF_TEAM_RED)
			red_players.append(player);
		else if (team == TF_TEAM_BLUE)
			blue_players.append(player);
	}
	
	Ware_TeleportPlayersRow(red_players,
		Ware_MinigameLocation.center_left,
		QAngle(0, 0, 0),
		500.0,
		-65.0, 65.0);
	Ware_TeleportPlayersRow(blue_players,
		Ware_MinigameLocation.center_right,
		QAngle(0, 180, 0),
		500.0,
		65.0, 65.0);
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (GetPropEntity(player, "m_hGroundEntity") == null)
			continue;
			
		local origin = player.GetOrigin();
		if (origin.x >= (Ware_MinigameLocation.center.x - 128.0)
			&& origin.x <= (Ware_MinigameLocation.center.x + 128.0)
			&& (origin.z - Ware_MinigameLocation.center.z) < 40.0)
		{
			Ware_PassPlayer(player, true);
		}
	}
}