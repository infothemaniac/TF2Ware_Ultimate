
minigame <- Ware_MinigameData();
minigame.name = "Spycrab Limbo";
minigame.description = "Limbo under the laser!"
minigame.duration = 11.0;
minigame.location = "boxarena";
minigame.music = "limbo";
minigame.no_collisions = true;

local beam_model = "sprites/laser.vmt";
PrecacheModel(beam_model);
local goal_vectors;


function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players, 
		Ware_MinigameLocation.center + Vector(0, -600, 0), 
		QAngle(0, 90, 0), 
		1600.0, 
		128.0, 128.0);
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, null);
	Ware_CreateTimer(@() Ware_SetGlobalLoadout(TF_CLASS_SPY, "Disguise Kit"), 0.1);
	
	local beam = Ware_CreateEntity("env_beam");
	beam.SetOrigin(Ware_MinigameLocation.center + Vector(-1000, 0, 96));
	SetPropVector(beam, "m_vecEndPos", Ware_MinigameLocation.center + Vector(1000, 0, 96));
	beam.SetModel(beam_model);
	beam.KeyValueFromString("rendercolor", "255 255 0");
	beam.KeyValueFromInt("renderamt", 100);
	beam.DispatchSpawn();
	SetPropFloat(beam, "m_fWidth", 7.0);
	SetPropFloat(beam, "m_fEndWidth", 7.0);
	EntFireByHandle(beam, "TurnOn", "", -1, null, null);
	
	local trigger = Ware_SpawnEntity("trigger_multiple",
	{
		classname = "cow_mangler", // kill icon
		origin = Ware_MinigameLocation.center + Vector(0, 0, 96),
		spawnflags = 1
	});
	trigger.SetSolid(SOLID_BBOX);
	trigger.SetSize(Vector(-1000, -8, -8), Vector(1000, 8, 8));
	trigger.ValidateScriptScope();
	trigger.GetScriptScope().OnStartTouch <- OnBeamTouch;
	trigger.ConnectOutput("OnStartTouch", "OnStartTouch");
	
	goal_vectors = beam.GetOrigin();
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		
		if (player.GetOrigin().y > goal_vectors.y + 50.0)
			Ware_PassPlayer(player, true);
		
		if ((player.GetFlags() & FL_DUCKING) && (player.EyeAngles().x < -70.0))
		{
			player.RemoveFlag(FL_ATCONTROLS);
			continue;
		}
		
		player.AddFlag(FL_ATCONTROLS);
	}
}

function OnBeamTouch()
{
	if (activator)
		activator.TakeDamageCustom(self, self, null, Vector(), Vector(), 1000.0, DMG_GENERIC, TF_DMG_CUSTOM_PLASMA);
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		
		if (IsEntityAlive(player) && !data.passed)
			Ware_ChatPrint(player, "{color}Spycrabs must look up and crouch!", TF_COLOR_DEFAULT);
		
		player.RemoveFlag(FL_ATCONTROLS);
	}
}
