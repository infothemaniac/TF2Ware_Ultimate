local charactersConst = [
    "scout",    // 1
    "sniper",   // 2
    "soldier",  // 3
    "demoman",  // 4
    "medic",    // 5
    "heavy",    // 6
    "pyro",     // 7
    "spy",      // 8
    "engineer"  // 9
];
characters <- [];
foreach ( character in charactersConst)
    characters.append(character)
character_selected <- ""
character_selected = characters[RandomInt(0, characters.len()-1)];
characters.remove(characters.find(character_selected));

minigame <- Ware_MinigameData
({
	name           = "Wanted"
	author         = ["PedritoGMG"]
	description    = "Find the Character"
	duration       = 10.0
    location       = "dirtsquare"
    custom_overlay = "wanted_"+character_selected
    music = "wanted"
})

character <- -1

character_queue <- []
props <- []

first <- true
xRange <- [-750, 750];
zRange <- [250, 1250];
yPos <- 0
boxSize <- 8

prop_model  <- "models/mariokart/head.mdl"
character_sprite <- "sprites/wanted/%s.vmt"

function OnPrecache()
{
    Ware_PrecacheMinigameMusic("wanted", false)
	PrecacheModel(prop_model)
    PrecacheOverlay("hud/tf2ware_ultimate/minigames/wanted_" + character_selected)
}

function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players,
		Ware_MinigameLocation.center - Vector(0, 400, 0),
		QAngle(-10, 90, 0),
		700.0,
		69.0, 64.0)
}

function CreateCharacter()
{
	if (character_queue.len() == 0)
		return CreateLastCharacter();

	return CreateGenericCharacter(character_queue.remove(0), false);
}

function CreateLastCharacter()
{
	return CreateGenericCharacter(character_selected, true);
}

function CreateGenericCharacter(name, isLast)
{
    yPos+=0.1
	local pos = Ware_MinigameLocation.center;
    pos += Vector(RandomFloat(xRange[0], xRange[1]), 1250+yPos, RandomFloat(zRange[0], zRange[1]));

	local prop = Ware_SpawnEntity("prop_physics_override",
	{
		targetname     = "character",
		model          = prop_model,
		origin         = pos,
        angles      = QAngle(0, 90, 360),
		massscale      = 0.0001,
        modelscale = 7
		disableshadows = true
	});
    prop.SetBodygroup(0, charactersConst.find(name));
	prop.SetCollisionGroup(TFCOLLISION_GROUP_COMBATOBJECT);
	prop.SetMoveType(MOVETYPE_FLY, MOVECOLLIDE_FLY_BOUNCE);

	Ware_SlapEntity(prop, RandomFloat(50, 300));
	local vel = prop.GetAbsVelocity();
	vel = Vector(vel.x * 1, vel.y * 0, vel.z * 1);
	prop.SetAbsVelocity(vel);

	props.append(prop);
    if (!isLast) {
        prop.SetSolid(SOLID_NONE);
        return 0.01;
    }
    prop.SetSolid(SOLID_BBOX)
    prop.SetSize(Vector(-boxSize, -boxSize, -boxSize), Vector(boxSize, boxSize, boxSize))
    return;
}


function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Festive Sniper Rifle")

    local character_counts = array(characters.len())

    foreach (i, character in character_counts)
    {
        character_counts[i] = RandomInt(5, 10);
    }

    foreach (i, character in characters)
	{
		for (local j = 0; j < character_counts[i]; j++)
		{
			character_queue.append(character)
		}
	}

	Ware_CreateTimer(@() CreateCharacter(), 0.0)
}
function OnUpdate() {
    local minigameLocation = Ware_MinigameLocation.center;
    local margin = 0.1;

    foreach (prop in props) {
        local vel = prop.GetAbsVelocity();
        local pos = prop.GetOrigin();

        if (pos.x - minigameLocation.x > xRange[1]) {
            vel.x = -abs(vel.x);
            prop.SetOrigin(Vector(minigameLocation.x + xRange[1] - margin, pos.y, pos.z));
        } else if (pos.x - minigameLocation.x < xRange[0]) {
            vel.x = abs(vel.x);
            prop.SetOrigin(Vector(minigameLocation.x + xRange[0] + margin, pos.y, pos.z));
        }

        if (pos.z - minigameLocation.z > zRange[1]) {
            vel.z = -abs(vel.z);
            prop.SetOrigin(Vector(pos.x, pos.y, minigameLocation.z + zRange[1] - margin));
        } else if (pos.z - minigameLocation.z < zRange[0]) {
            vel.z = abs(vel.z);
            prop.SetOrigin(Vector(pos.x, pos.y, minigameLocation.z + zRange[0] + margin));
        }

        prop.SetAbsVelocity(vel);
    }
}


function OnTakeDamage(params)
{
	if (!(params.damage_type & DMG_BULLET))
		return

	local entity = params.const_entity
	if (entity.GetName() == "character")
	{
		local attacker = params.attacker
		if (attacker != null && attacker.IsPlayer())
		{
			Ware_PassPlayer(attacker, true)
            if (first)
            {
                Ware_ChatPrint(null, "{player} {color}was the first to find " + character_selected + "!", attacker, TF_COLOR_DEFAULT)
                Ware_GiveBonusPoints(attacker)
                first = false
            }
		}
	}
}