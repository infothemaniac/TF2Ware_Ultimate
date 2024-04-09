// the code in this file related to player parenting is sensitive and dodgy to workaround for various issues
// do NOT modify those components unless you know what you are doing

minigame <- Ware_MinigameData();
minigame.name = "Piggyback Heavy";
minigame.description = "Piggyback the heavy before he reaches the end!"
minigame.description2 = "Reach the end with less than 3 players on your back!"
minigame.duration = 27.7;
minigame.min_players = 5;
minigame.location = "pinball";
minigame.music = "makemegroove";
minigame.custom_overlay = "piggyback_end";
minigame.custom_overlay2 = "piggyback_heavy";
minigame.convars =
{
	mp_teams_unbalance_limit = 0,
	tf_avoidteammates = 0,
	tf_allow_sliding_taunt = 1,
}

local piggybacker;
local piggybacker_dummy;
local piggybacked_count = 0;

local dummy_model = "models/tf2ware_ultimate/dummy_sphere.mdl";
PrecacheModel(dummy_model);

function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;		
		if (player == piggybacker)
		{
			Ware_SetPlayerMission(player, 2);
			Ware_SetPlayerClass(player, TF_CLASS_HEAVYWEAPONS);
			Ware_SetPlayerTeam(player, TF_TEAM_BLUE);
			player.SetForcedTauntCam(1);
			
			// parented players will be invisible, workaround this by parenting to a dummy
			// not using Ware_SpawnEntity because the kill must be delayed
			piggybacker_dummy = SpawnEntityFromTableSafe("prop_dynamic",
			{
				model = dummy_model,
				origin = player.GetOrigin(),
				disableshadows = true,
				rendermode = kRenderNone
			});
			SetEntityParent(piggybacker_dummy, player, "flag");				
		}
		else
		{
			Ware_SetPlayerMission(player, 1);
			Ware_SetPlayerClass(player, TF_CLASS_PYRO);
			Ware_SetPlayerTeam(player, TF_TEAM_RED);
			player.AddCond(TF_COND_SPEED_BOOST);
		}
	}
}

function OnTeleport(players)
{
	local idx = RandomIndex(players);
	//idx = players.find(GetListenServerHost());
	piggybacker = players[idx];
	players.remove(idx);

	piggybacker.Teleport(
		true, Ware_MinigameLocation.center_top + Vector(0, 2912, -777),
		true, QAngle(0, 90, 0),
		true, Vector());
	
	Ware_TeleportPlayersRow(players,
		Ware_MinigameLocation.center_top,
		QAngle(0, 90, 0),
		2100.0,
		-64.0, 60.0);		
}

function PiggybackUnparent(player, invis_hack)
{
	if (player.GetMoveParent())
	{
		SetPlayerParent(player, null);	
		
		if (invis_hack)
		{
			// gross hack: need to fake reparent for a bit so they re-appear
			Ware_CreateTimer(function() { SetPropInt(player, "m_iParentAttachment", 1); SetPropEntity(player, "moveparent", World); }, 0.0);
			Ware_CreateTimer(function() { SetPropInt(player, "m_iParentAttachment", 0); SetPropEntity(player, "moveparent", null); }, 0.1);
		}
	}

	player.SetCollisionGroup(COLLISION_GROUP_PLAYER);
	player.SetForcedTauntCam(0);
	player.SetMoveType(MOVETYPE_WALK, 0);
	player.SetModelScale(1.0, 0.0);
}

function PiggybackKilled(invis_hack)
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (player == piggybacker)
			continue;
			
		Ware_PassPlayer(player, true);
		
		PiggybackUnparent(player, invis_hack);
	}
}

function OnPlayerDeath(params)
{
	local victim = GetPlayerFromUserID(params.userid);
	if (victim == piggybacker)
		PiggybackKilled(false);
}

function OnPlayerDisconnect(player)
{
	if (player == piggybacker)
	{
		PiggybackKilled(true);
	}
}

function OnUpdate()
{
	local can_piggyback = false;
	
	if (piggybacker.IsValid() 
		&& IsEntityAlive(piggybacker))
	{
		local win_y = Ware_MinigameLocation.center_bottom.y - 400.0;
		if (piggybacker.GetOrigin().y > win_y)
		{
			if (piggybacked_count < 3)
				Ware_PassPlayer(piggybacker, true);
		}
		else
		{
			can_piggyback = !Ware_IsPlayerPassed(piggybacker);
		}
	}
	
	local piggybacker_origin;
	if (can_piggyback)
		piggybacker_origin = piggybacker.GetOrigin();
		
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (player == piggybacker)
			continue;	
			
		if (player.GetMoveParent())
		{
			// allow taunting on his back!
			SetPropEntity(player, "m_hGroundEntity", World);
			continue;
		}
			
		if (!can_piggyback)
			continue;
		
		if ((piggybacker_origin - player.GetOrigin()).Length() < 96.0)
		{
			Ware_PassPlayer(player, true);
			player.SetForcedTauntCam(1);
			player.SetMoveType(MOVETYPE_NONE, 0);
			player.SetAbsVelocity(Vector());
			player.RemoveCond(TF_COND_SPEED_BOOST);
			player.SetModelScale(0.25, 0.0);
			player.SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER);
			SetPlayerParent(player, piggybacker_dummy, "static_prop");
			piggybacked_count++;
		}
	}
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		PiggybackUnparent(player, false);
		player.RemoveCond(TF_COND_SPEED_BOOST);
	}
	
	// must delay this or unparented players will go invisible
	if (piggybacker_dummy.IsValid())
		EntFireByHandle(piggybacker_dummy, "Kill", "", 0.5, null, null);
}