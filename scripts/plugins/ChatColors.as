void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

dictionary g_player_states;

class PlayerState {
	int color = -1; // classify value
}

bool g_disabled = false;

// Will create a new state if the requested one does not exit
PlayerState@ getPlayerState(CBasePlayer@ plr)
{
	if (plr is null or !plr.IsConnected())
		return null;
		
	string steamId = g_EngineFuncs.GetPlayerAuthId( plr.edict() );
	if (steamId == 'STEAM_ID_LAN' or steamId == 'BOT') {
		steamId = plr.pev.netname;
	}
	
	if ( !g_player_states.exists(steamId) )
	{
		PlayerState state;
		g_player_states[steamId] = state;
	}
	return cast<PlayerState@>( g_player_states[steamId] );
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "w00tguy" );
	g_Module.ScriptInfo.SetContactInfo( "https://github.com/wootguy" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

void MapInit()
{
	g_disabled = false;
}

bool doCommand(CBasePlayer@ plr, const CCommand@ args, bool inConsole) {
	bool isAdmin = g_PlayerFuncs.AdminLevel(plr) >= ADMIN_YES;
	PlayerState@ state = getPlayerState(plr);
	
	if (args.ArgC() > 0 && args[0] == ".color" || args[0] == ".c") {
		if (g_disabled) {
			g_PlayerFuncs.SayTextAll(plr, "Chat colors are disabled on this map.");
			return true;
		}
	
		if (args.ArgC() >= 2) {
			string color = args[1].ToLowercase();
			
			string newColor;
			if (color == "red" or color == "r") {
				state.color = 17;
				newColor = "red";
			} else if (color == "green" or color == "g") {
				state.color = 19;
				newColor = "green";
			} else if (color == "blue" or color == "b") {
				state.color = 16;
				newColor = "blue";
			} else if (color == "yellow" or color == "y") {
				state.color = 18;
				newColor = "yellow";
			} else if (color == "off" or color == "o") {
				state.color = -1;
				newColor = "disabled";
			}
			else {
				g_PlayerFuncs.SayText(plr, "Valid colors are: red, green, blue, yellow (or just r, g, b, y)");
				return true;
			}
			g_PlayerFuncs.SayText(plr, "Your name color is now " + newColor);
		} else {
			g_PlayerFuncs.SayText(plr, "Usage: .color <red/green/blue/yellow/off>  OR  .c <r/g/b/y/o>");
		}
		
		return true;
	}
	
	if (g_disabled) {
		return false;
	}

	if (args.ArgC() > 0 && state.color > 0) {
		int oldClassify = plr.Classify();
		if (oldClassify >= 16 && oldClassify <= 19) {
			g_disabled = true;
			g_PlayerFuncs.SayTextAll(plr, "Chat colors disabled. This map appears to use teams.");
			return false;
		}
		
		plr.SetClassification(state.color);
		plr.SendScoreInfo();
		plr.SetClassification(oldClassify);
		g_Scheduler.SetTimeout("revert_scoreboard_color", 0.5f, EHandle(plr));
	}
	
	return false;
}

// keeping the scoreboard color would be neat too, but then you can't see hp/armor
void revert_scoreboard_color(EHandle h_plr) {
	CBasePlayer@ plr = cast<CBasePlayer@>(h_plr.GetEntity());
	if (plr is null or !plr.IsConnected()) {
		return;
	}
	
	plr.SendScoreInfo();
}

HookReturnCode ClientSay( SayParameters@ pParams ) {
	CBasePlayer@ plr = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	if (doCommand(plr, args, false))
	{
		pParams.ShouldHide = true;
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}

CClientCommand _ghost("color", "chat color commands", @consoleCmd );
CClientCommand _ghost2("c", "chat color commands", @consoleCmd );

void consoleCmd( const CCommand@ args ) {
	CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();
	doCommand(plr, args, true);
}