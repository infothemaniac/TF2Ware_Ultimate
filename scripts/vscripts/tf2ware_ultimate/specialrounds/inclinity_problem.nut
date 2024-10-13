roll <- RandomBool() ? 40.0 : -40.0

special_round <- Ware_SpecialRoundData
({
	name = "Inclinity Problem"
	author = "ficool2"
	description = "The world has tilted!"
})

function OnStart()
{
	foreach (player in Ware_Players)
	{
		if (player.IsAlive())
		{
			local eye_angles = player.EyeAngles()
			eye_angles.z = GetPlayerRollAngle(player)
			player.ViewPunch(QAngle(0, 0, -roll))
			player.SnapEyeAngles(eye_angles)
		}
	}
}

function GetPlayerRollAngle(player)
{
	return roll
}
