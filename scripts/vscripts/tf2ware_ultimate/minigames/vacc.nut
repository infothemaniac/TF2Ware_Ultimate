minigame <- Ware_MinigameData
({
	name           = "Pop the Vacc"
	author         = ["tilderain"]
	description    = "Vaccinate!"
	duration       = 4
	music          = "falling"
	fail_on_death    = true
	start_pass     = true
})


class_names <- ["soldier","pyro","heavy",]

CLASS_SOLDIER <- 0
CLASS_PYRO <- 1
CLASS_HEAVY <- 2

class_idx <- RandomInt(0,2)
	
team_idx <- RandomInt(TF_TEAM_RED, TF_TEAM_BLUE)

prop <- null

minigun_particle <- "muzzle_minigun_constant_core"
flamethrower_particle <- "flamethrower"

function OnStart()
{
	foreach (player in Ware_MinigamePlayers)
	{
		Ware_SetPlayerClass(player, TF_CLASS_MEDIC)
		Ware_StripPlayer(player, false)
		Ware_GivePlayerWeapon(player, "Vaccinator")
		local weapon = player.GetActiveWeapon()
		SetPropFloat(weapon, "m_flChargeLevel", 0.25)

		//Doesn't work
		//SetPropFloat(weapon, "m_flNextPrimaryAttack", 1e100)

		Ware_CreateTimer(@() SetPropInt(weapon, "m_nChargeResistType", RandomInt(0,2)), 0.05)
	}
	local pos = Ware_MinigameLocation.center
	prop = Ware_SpawnEntity("prop_dynamic",
	{
		model       = format("models/player/%s.mdl", class_names[class_idx])
		origin      = pos
		skin        = team_idx - 2
		modelscale  = 2
		defaultanim = RandomBool() ? "taunt_aerobic_A" : "taunt_aerobic_B"
	})

	Ware_ShowAnnotation(pos + Vector(0, 0, 150), "WATCH OUT!")

	local name = class_names[class_idx] + format(".Taunts%02d", RandomInt(1,19))

	if(class_idx == CLASS_PYRO )
		name = "Pyro.BattleCry0" + RandomInt(1,2)

	prop.EmitSound(name)

	if(class_idx == CLASS_SOLDIER)
	{
		Ware_CreateTimer(@() SpawnRockets(), 0.8)
		Ware_CreateTimer(@() SpawnHurt(DMG_BLAST), 2.5)
	}

	else if(class_idx == CLASS_PYRO)
		Ware_CreateTimer(@() SpawnFires(), 2.5)
	else
		Ware_CreateTimer(@() SpawnGuns(), 2.5)
}

function OnPrecache()
{
	PrecacheParticle(flamethrower_particle)
	PrecacheParticle(minigun_particle)
}

function SpawnHurt(type)
{
	local hurt = Ware_SpawnEntity("trigger_hurt",
	{
		origin     = Ware_MinigameLocation.center
		damage     = 150
		damagetype = type
		spawnflags = SF_TRIGGER_ALLOW_CLIENTS
	})
	hurt.SetSolid(SOLID_BBOX)
	hurt.SetSize(Vector(-3000, -3000, -3000), Vector(3000, 3000, 3000))
}
function SpawnRockets()
{
	local spawner = Ware_SpawnEntity("tf_point_weapon_mimic", 
	{
		origin     = Ware_MinigameLocation.center
		WeaponType = class_idx
		SpeedMin   = 500
		SpeedMax   = 500
		Damage     = 125
		Crits      = true
		angles     = QAngle(90, 0, 0)
		SplashRadius = 10000
	})
	spawner.SetTeam(TEAM_SPECTATOR)

	foreach (player in Ware_MinigamePlayers)
	{
		local down = QAngle(90, 0, 0)
		local dir = down.Forward() + down.Left() * RandomFloat(-0.4, 0.4) + down.Up() * RandomFloat(-0.4, 0.4)
		dir.Norm()
		spawner.SetForwardVector(dir)
		
		local pos = player.GetOrigin()
		spawner.SetOrigin(player.GetOrigin() + dir * RandomFloat(-900.0, -1300.0))
	
		spawner.AcceptInput("FireOnce", "", null, null)
		
		local rocket = FindByClassname(null, "tf_projectile_rocket")
		if (rocket != null)
		{
			MarkForPurge(rocket)
			rocket.SetOwner(player)
			rocket.SetTeam(TEAM_SPECTATOR)
			rocket.KeyValueFromString("classname", "ware_projectile")
		}
	}
}

function SpawnParticle(particle)
{
	local particle = Ware_SpawnEntity("info_particle_system",
	{
		origin       = Ware_MinigameLocation.center + Vector(0,0,50)
		angles       = QAngle(1, 0, 0)
		effect_name  = particle
		start_active = true // set to false if you don't want particle to start initially
	})
}

function SpawnFires()
{
	SpawnParticle(flamethrower_particle)

	prop.EmitSound("Weapon_FlameThrower.FireStart")
	SpawnHurt(DMG_BURN)
}

function SpawnGuns()
{
	SpawnParticle(minigun_particle)

	prop.EmitSound("Weapon_Minigun.FireCrit")

	SpawnHurt(DMG_BULLET)
}

function OnEnd()
{
	prop.StopSound("Weapon_Minigun.FireCrit")
	prop.StopSound("Weapon_FlameThrower.FireStart")
}


function OnTakeDamage(params)
{
	if (params.const_entity.IsPlayer())
	{
		params.weapon = null
		params.attacker = World
		
		local inflictor = params.inflictor
		if (inflictor != null && inflictor.GetClassname() == "ware_projectile")
		{
			// prevents server crash because of attacker not being a player
			SetPropEntity(inflictor, "m_hLauncher", null)
		}
	}
}
