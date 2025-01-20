minigame <- Ware_MinigameData
({
	name           = "Shoot 10 Gifts"
	author         = "ficool2"
	description    = "Shoot the Gift 10 times!"
	duration       = 29.9
	music          = "pumpit"
	location       = "targetrange"
	custom_overlay = "shoot_gift_10"
	convars        =
	{
		// make this easier on higher timescales or its near impossible
		phys_timescale = RemapValClamped(Ware_GetTimeScale(), 1.0, 2.0, 0.9, 0.6),	
	}
})

gift_model <- "models/tf2ware_ultimate/gift.mdl"
hit_sound  <- "Player.HitSoundBeepo"

gifts_active <- []

function OnPrecache()
{
	PrecacheModel(gift_model)
	PrecacheScriptSound(hit_sound)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Sniper Rifle")

	foreach (player in Ware_MinigamePlayers)
		Ware_GetPlayerMiniData(player).points <- 0
			
	Ware_CreateTimer(@() SpawnGift(), 1.0)
}

function SpawnGift()
{
	local line = RandomElement(Ware_MinigameLocation.lines)
	local origin = Lerp(RandomFloat(0.0, 1.0), line[0], line[1])
	local angles = QAngle(0, -90, 0)
	local gift = Ware_SpawnEntity("prop_physics_override",
	{	
		model  = gift_model
		origin = origin
		angles = angles
	})
	gift.AddEFlags(EFL_NO_DAMAGE_FORCES)
	gift.SetPhysVelocity(Vector(RandomFloat(-500, 500), 0, RandomFloat(1000, 1200)))
	gift.ValidateScriptScope()
	local gift_scope = gift.GetScriptScope()
	gift_scope.lag_record <- [origin]
	gift_scope.mins <- gift.GetBoundingMins()
	gift_scope.maxs <- gift.GetBoundingMaxs()
	gift_scope.GiftThink <- function()
	{
		lag_record.append(self.GetOrigin())
		return -1
	}
	AddThinkToEnt(gift, "GiftThink")
	local gifts = gifts_active
	gifts.append(gift_scope)
	Ware_CreateTimer(function()
	{
		gifts.remove(gifts.find(gift_scope))
		gift.Kill()
	}, RemapValClamped(Ware_GetTimeScale(), 1.0, 2.0, 1.7, 2.6))
	
	return RandomFloat(1.7, 2.1)
}

function OnPlayerAttack(player)
{		
	local eye_position = player.EyePosition()
	local eye_fwd = player.EyeAngles().Forward()
	
	// backtrack gift positions (lag compensation)
	local latency = GetPlayerLatency(player)
	if (player != Ware_ListenHost)
		latency += Ware_GetPlayerData(player).lerp_time
	local tick = TimeToTicks(latency)
	
	foreach (gift in gifts_active)
	{
		local records = gift.lag_record
		local record_tick = Max(records.len() - 1 - tick, 0)
		local lag_origin = gift.lag_record[record_tick]
		
		//DebugDrawBox(gift.self.GetOrigin(), gift.mins, gift.maxs, 255, 0, 0, 20, 3.0)
		//DebugDrawBox(lag_origin, gift.mins, gift.maxs, 0, 255, 0, 20, 3.0)
		//DebugDrawLine(eye_position, eye_position + eye_fwd * 2048.0, 255, 0, 0, false, 3.0)
		
		if (IntersectRayWithBox(eye_position, eye_fwd, 
			lag_origin + gift.mins,
			lag_origin + gift.maxs, 
			0.0, 8192.0) > 0.0)
		{
			local minidata = Ware_GetPlayerMiniData(player)
			minidata.points++
			
			EmitSoundOnClient(hit_sound, player)			
			Ware_ShowText(player, CHANNEL_MINIGAME, "x", 0.25, "255 255 255", -1, -1)
			
			if (minidata.points >= 10)
				Ware_PassPlayer(player, true)			
		}
	}
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (Ware_GetPlayerAmmo(player, TF_AMMO_PRIMARY) == 0)
			SetPropInt(player, "m_nImpulse", 101)
	}
}
