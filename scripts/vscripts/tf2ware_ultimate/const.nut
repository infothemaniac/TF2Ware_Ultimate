const EFL_USER = 2097152

const INT_MAX = 0x7FFFFFFF
const FLT_MAX = 3.402823466e+38
const RAD2DEG = 57.295779513;
const DEG2RAD = 0.0174532924;

const MAX_WEAPONS = 7

const DMG_SAWBLADE = 65536
const DMG_CRIT     = 1048576

const SND_CHANGE_VOL = 1;
const SND_CHANGE_PITCH = 2;
const SND_STOP = 4;

const PATTACH_ABSORIGIN			= 0
const PATTACH_ABSORIGIN_FOLLOW	= 1
const PATTACH_CUSTOMORIGIN		= 2
const PATTACH_POINT				= 3
const PATTACH_POINT_FOLLOW		= 4
const PATTACH_WORLDORIGIN		= 5
const PATTACH_ROOTBONE_FOLLOW	= 6

const TF_CLASS_FIRST = 1
const TF_CLASS_LAST  = 9

const TF_SLOT_PRIMARY   = 0
const TF_SLOT_SECONDARY = 1
const TF_SLOT_MELEE     = 2
const TF_SLOT_PDA       = 3
const TF_SLOT_PDA2      = 4

const TF_AMMO_DUMMY 	= 0
const TF_AMMO_PRIMARY 	= 1
const TF_AMMO_SECONDARY = 2
const TF_AMMO_METAL 	= 3
const TF_AMMO_GRENADES1 = 4
const TF_AMMO_GRENADES2 = 5
const TF_AMMO_GRENADES3 = 6
const TF_AMMO_COUNT 	= 7 

const TF_TRIGGER_STUN_MOVEMENT	= 0
const TF_TRIGGER_STUN_CONTROLS	= 1
const TF_TRIGGER_STUN_LOSER		= 2

const OBJ_DISPENSER         = 0
const OBJ_TELEPORTER        = 1
const OBJ_SENTRYGUN         = 2
const OBJ_ATTACHMENT_SAPPER = 3

const TFCOLLISION_GROUP_GRENADES                          = 20
const TFCOLLISION_GROUP_OBJECT                            = 21
const TFCOLLISION_GROUP_OBJECT_SOLIDTOPLAYERMOVEMENT      = 22
const TFCOLLISION_GROUP_COMBATOBJECT                      = 23
const TFCOLLISION_GROUP_ROCKETS                           = 24
const TFCOLLISION_GROUP_RESPAWNROOMS                      = 25
const TFCOLLISION_GROUP_PUMPKIN_BOMB                      = 26
const TFCOLLISION_GROUP_ROCKET_BUT_NOT_WITH_OTHER_ROCKETS = 27

const COLOR_RED        = "FF0000"
const COLOR_GREEN      = "00FF00"
const COLOR_BLUE       = "0000FF"
const COLOR_YELLOW     = "FFFF00"
const COLOR_LIME       = "22FF22"
const COLOR_WHITE      = "FFFFFF"
const TF_COLOR_DEFAULT = "FBECCB"
const TF_COLOR_RED     = "FF3F3F"
const TF_COLOR_BLUE    = "99CCFF"
const TF_COLOR_SPEC    = "CCCCCC"

const SFX_WARE_PASS      = "TF2Ware_Ultimate.Pass"

const PFX_WARE_PASS_RED  = "teleportedin_red"
const PFX_WARE_PASS_BLUE = "teleportedin_blue";

CONST.MAX_CLIENTS <- MaxClients().tointeger()

ITEM_PROJECTILE_MAP <-
{
	[18]   = "tf_projectile_rocket",
	[127]  = "tf_projectile_rocket",
	[1178] = "tf_projectile_balloffire",
	[19]   = "tf_projectile_pipe",
	[20]   = "tf_projectile_pipe_remote",
	[308]  = "tf_projectile_pipe",
	[44]   = "tf_projectile_stun_ball",
	[56]   = "tf_projectile_arrow",
}

	
foreach (key, value in CONST)
{
	if (startswith(key, "MDL"))
		PrecacheModel(value);
	else if (startswith(key, "SFX"))
		PrecacheScriptSound(value);
	else if (startswith(key, "PFX"))
		PrecacheEntityFromTable({classname = "info_particle_system", effect_name = value});
}
