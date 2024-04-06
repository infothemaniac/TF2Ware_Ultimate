minigame <- Ware_MinigameData();
minigame.name = "Say the Word";
minigame.description = "Say the word below!"
minigame.duration = 4.0;
minigame.music = "getready";
minigame.custom_overlay2 = "../chalkboard";
minigame.end_delay = 0.5;
minigame.suicide_on_end = true;

local first = false;
local word;
words <-
[
	"Heavy",
	"Scout",
	"Jarate",
	"Wrench",
	"Spy",
	"Soldier",
	"Medic",
	"Sniper",
	"Sasha",
	"Engy",
	"Saxton",
	"Sandman",
	"Pyro",
	"Demoman",
	"Engineer",
	"Bat",
	"Bear",
	"Fists",
	"White",
	"Wario",
	"Valve",
	"Black",
	"Yellow",
	"Green",
	"Blue",
	"Flowey", // :)
	"Mann Co",
	"Sentry",
	"Rocket",
	"Sticky",
	"Uber",
	"Cloak",
	"Sandvich",
	"Bonk",
	"Hale",
	"Crate",
	"Key",
	"Taunt",
	"Spycrab",
	"Crits",
	"Payload",
	"Capture",
	"Arena",
	"Comics",
	"Unusual",
	"Strange",
	"Gaben",
	"Steam",
	"Scrap",
	"Sheen",
	"Point",
	"Tank",
	"Sapper",
	"Conga",
	"Yeti",
	"Intel",
	"Contract",
	"Aussie",
	"Earbud",
	"Disguise",
	"Aimbot",
	"2Fort",
	"Dustbowl",
	"Granary",
	"Gravelpit",
	"Hydro",
	"Well",
	"Krampus",
	"Phlog",
	"Prophunt",
	"Smash",
	"TF2Ware",
	"Redsun",
	"Frog",
	
	// these two are evil but rare
	"Bombinomicon",
	"Shahanshah",
];

function OnStart()
{
	word = words[RandomIndex(words)];
	foreach (data in Ware_MinigamePlayers)
		Ware_ShowMinigameText(data.player, word);
	
	word = word.tolower();
}

function OnPlayerSay(player, text)
{	
	if (text.tolower() == word)
	{
		if (!IsEntityAlive(player))
			return false;
		
		Ware_PassPlayer(player, true);
		if (first)
		{
			Ware_ChatPrint(null, "{player} {color}said the word first!", player, TF_COLOR_DEFAULT);
			first = false;
		}
		return false;
	}
	else
	{
		if (Ware_IsPlayerPassed(player) || !IsEntityAlive(player))
			return true;
		
		Ware_SuicidePlayer(player);
	}
}