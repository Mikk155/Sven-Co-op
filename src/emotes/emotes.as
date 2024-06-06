#include "fft"
#include "json"
#include 'Language'

json pJson;

void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

void PluginInit() {
    g_Module.ScriptInfo.SetAuthor( "w00tguy" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/wootguy/emotes | https://github.com/Mikk155/Sven-Co-op" );

    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );

    pJson.load('plugins/mikk/emotes.json');

    loadEmotes();
    setSequencePriorities();
}

enum ANIM_MODES {
    MODE_ONCE, // play once
    MODE_FREEZE, // freeze on the last frame
    MODE_LOOP, // loop betwen start and end frames
    MODE_ILOOP // invert framerate when reaching the start/end frame
}

class EmotePart {
    int seq;
    int mode;
    float framerate;
    float startFrame;
    float endFrame;

    EmotePart() {}

    EmotePart(int seq, int mode, float framerate, float startFrame, float endFrame) {
        this.seq = seq;
        this.mode = mode;
        this.framerate = framerate;
        this.startFrame = startFrame;
        this.endFrame = endFrame;

        if (framerate == 0) {
            framerate = 0.0000001f;
        }
        if (startFrame <= 0) {
            startFrame = 0.00001f;
        }
        if (endFrame >= 255) {
            endFrame = 254.9999f;
        }
    }
}

class Emote {
    array<EmotePart> parts;
    bool loop;

    Emote() {}

    Emote(array<EmotePart> parts, bool loop) {
        this.parts = parts;
        this.loop = loop;
    }
}

array<bool> g_priority_sequences(200); // sequences that have priority over emotes
array<CScheduledFunction@> g_emote_loops(33);

dictionary g_emotes;

void loadEmotes() {
    g_emotes["alpha"] = Emote({
        EmotePart(187, MODE_FREEZE, 1.45, 180, 236)
    }, false);
    g_emotes["scan"] = Emote({
        EmotePart(188, MODE_ONCE, 1.0, 0, 255)
    }, false);
    g_emotes["flex"] = Emote({
        EmotePart(129, MODE_FREEZE, 0.2, 0, 52)
    }, false);
    g_emotes["lewd"] = Emote({
        EmotePart(88, MODE_ILOOP, 1, 40, 70)
    }, false);
    g_emotes["robot"] = Emote({
        EmotePart(71, MODE_FREEZE, 1, 0, 100)
    }, false);
    g_emotes["elbow"] = Emote({
        EmotePart(35, MODE_FREEZE, 1, 135, 135)
    }, false);
    g_emotes["hunch"] = Emote({
        EmotePart(16, MODE_FREEZE, 1, 40, 98)
    }, false);
    g_emotes["anal"] = Emote({
        EmotePart(14, MODE_FREEZE, 1, 0, 120)
    }, false);
    g_emotes["joy"] = Emote({
        EmotePart(9, MODE_FREEZE, 1, 90, 90)
    }, false);
    g_emotes["wave"] = Emote({
        EmotePart(190, MODE_ONCE, 1.0, 0, 255)
    }, false);
    g_emotes["type"] = Emote({
        EmotePart(186, MODE_LOOP, 1, 0, 255)
    }, false);
    g_emotes["type2"] = Emote({
        EmotePart(187, MODE_LOOP, 1.2, 0, 255)
    }, false);
    g_emotes["study"] = Emote({
        EmotePart(189, MODE_ONCE, 1, 0, 255)
    }, false);
    g_emotes["oof"] = Emote({
        EmotePart(13, MODE_ONCE, 1, 0, 255),
        EmotePart(14, MODE_ONCE, -1, 255, 0)
    }, false);
    g_emotes["dance"] = Emote({
        EmotePart(31, MODE_ILOOP, 1, 35, 255)
    }, false);
    g_emotes["dance2"] = Emote({
        EmotePart(71, MODE_ILOOP, 1, 0, 220)
    }, false);
    g_emotes["shake"] = Emote({
        EmotePart(106, MODE_FREEZE, 1, 0, 0)
    }, false);
    g_emotes["fidget"] = Emote({
        EmotePart(50, MODE_ILOOP, 1, 100, 245)
    }, false);
    g_emotes["barnacle"] = Emote({
        EmotePart(182, MODE_ONCE, 1, 0, 255),
        EmotePart(183, MODE_ONCE, 1, 0, 255),
        EmotePart(184, MODE_ONCE, 1, 0, 255),
        EmotePart(185, MODE_LOOP, 1, 0, 255)
    }, false);
    g_emotes["swim"] = Emote({
        EmotePart(11, MODE_LOOP, 1, 0, 255)
    }, false);
    g_emotes["swim2"] = Emote({
        EmotePart(10, MODE_LOOP, 1, 0, 255)
    }, false);
    g_emotes["run"] = Emote({
        EmotePart(3, MODE_LOOP, 1, 0, 255)
    }, false);
    g_emotes["crazy"] = Emote({
        EmotePart(183, MODE_LOOP, 4, 0, 255)
    }, false);
}

void setSequencePriorities() {
    //g_priority_sequences[8] = true; // jump
    g_priority_sequences[9] = true; // longjump

    g_priority_sequences[12] = true; // death
    g_priority_sequences[13] = true; // death
    g_priority_sequences[14] = true; // death
    g_priority_sequences[15] = true; // death
    g_priority_sequences[16] = true; // death
    g_priority_sequences[17] = true; // death
    g_priority_sequences[18] = true; // death

    g_priority_sequences[19] = true; // draw crowbar
    g_priority_sequences[21] = true; // shoot crowbar
    g_priority_sequences[22] = true; // draw crowbar (crouched)
    g_priority_sequences[24] = true; // shoot crowbar (crouched)

    g_priority_sequences[25] = true; // cock wrench
    g_priority_sequences[26] = true; // hold wrench
    g_priority_sequences[27] = true; // shoot wrench
    g_priority_sequences[28] = true; // cock wrench (crouched)
    g_priority_sequences[29] = true; // hold wrench (crouched)
    g_priority_sequences[30] = true; // shoot wrench (crouched)

    g_priority_sequences[31] = true; // draw grenade
    g_priority_sequences[33] = true; // cock grenade
    g_priority_sequences[34] = true; // hold grenade
    g_priority_sequences[35] = true; // throw grenade
    g_priority_sequences[36] = true; // draw grenade (crouched)
    g_priority_sequences[38] = true; // cock grenade (crouched)
    g_priority_sequences[39] = true; // hold grenade (crouched)
    g_priority_sequences[40] = true; // throw grenade (crouched)

    g_priority_sequences[41] = true; // draw tripmine
    g_priority_sequences[43] = true; // shoot tripmine
    g_priority_sequences[44] = true; // draw tripmine (crouched)
    g_priority_sequences[46] = true; // draw tripmine (crouched)

    g_priority_sequences[47] = true; // draw onehanded
    g_priority_sequences[49] = true; // shoot onehanded
    g_priority_sequences[50] = true; // reload onehanded
    g_priority_sequences[51] = true; // draw onehanded (crouched)
    g_priority_sequences[53] = true; // shoot onehanded (crouched)
    g_priority_sequences[54] = true; // reload onehanded (crouched)

    g_priority_sequences[55] = true; // draw python
    g_priority_sequences[57] = true; // shoot python
    g_priority_sequences[58] = true; // reload python
    g_priority_sequences[59] = true; // draw python (crouched)
    g_priority_sequences[61] = true; // shoot python (crouched)
    g_priority_sequences[62] = true; // reload python (crouched)

    g_priority_sequences[63] = true; // draw shotgun
    g_priority_sequences[65] = true; // shoot shotgun
    g_priority_sequences[66] = true; // reload shotgun
    g_priority_sequences[67] = true; // draw shotgun (crouched)
    g_priority_sequences[69] = true; // shoot shotgun (crouched)
    g_priority_sequences[70] = true; // reload shotgun (crouched)

    g_priority_sequences[71] = true; // draw gauss
    g_priority_sequences[73] = true; // shoot gauss
    g_priority_sequences[74] = true; // draw gauss (crouched)
    g_priority_sequences[76] = true; // shoot gauss (crouched)

    g_priority_sequences[77] = true; // draw mp5
    g_priority_sequences[79] = true; // shoot mp5
    g_priority_sequences[80] = true; // reload mp5
    g_priority_sequences[81] = true; // draw mp5 (crouched)
    g_priority_sequences[83] = true; // shoot mp5 (crouched)
    g_priority_sequences[84] = true; // reload mp5 (crouched)

    g_priority_sequences[85] = true; // draw mp5
    g_priority_sequences[87] = true; // shoot mp5
    g_priority_sequences[88] = true; // reload mp5
    g_priority_sequences[89] = true; // draw mp5 (crouched)
    g_priority_sequences[91] = true; // shoot mp5 (crouched)
    g_priority_sequences[92] = true; // reload mp5 (crouched)

    g_priority_sequences[93] = true; // draw egon
    g_priority_sequences[95] = true; // shoot egon
    g_priority_sequences[96] = true; // draw egon (crouched)
    g_priority_sequences[98] = true; // shoot egon (crouched)

    g_priority_sequences[99] = true; // draw squeak/snark
    g_priority_sequences[101] = true; // shoot squeak/snark
    g_priority_sequences[102] = true; // draw squeak/snark (crouched)
    g_priority_sequences[104] = true; // shoot squeak/snark (crouched)

    g_priority_sequences[105] = true; // draw hive/hornet
    g_priority_sequences[107] = true; // shoot hive/hornet
    g_priority_sequences[108] = true; // draw hive/hornet (crouched)
    g_priority_sequences[110] = true; // shoot hive/hornet (crouched)

    g_priority_sequences[111] = true; // draw bow
    g_priority_sequences[113] = true; // shoot bow
    g_priority_sequences[115] = true; // shoot bow (scoped)
    g_priority_sequences[116] = true; // reload
    g_priority_sequences[117] = true; // draw bow (crouched)
    g_priority_sequences[119] = true; // shoot bow (crouched)
    g_priority_sequences[121] = true; // shoot bow (crouched+scoped)
    g_priority_sequences[122] = true; // reload (crouched)

    g_priority_sequences[123] = true; // draw minigun
    g_priority_sequences[125] = true; // shoot minigun
    g_priority_sequences[126] = true; // draw minigun (crouched)
    g_priority_sequences[128] = true; // shoot minigun (crouched)

    g_priority_sequences[129] = true; // draw uzis
    g_priority_sequences[130] = true; // draw left uzi
    g_priority_sequences[132] = true; // shoot uzis
    g_priority_sequences[133] = true; // shoot right uzi
    g_priority_sequences[134] = true; // shoot left uzi
    g_priority_sequences[135] = true; // reload right uzi
    g_priority_sequences[136] = true; // reload left uzi
    g_priority_sequences[137] = true; // draw uzis
    g_priority_sequences[138] = true; // draw left uzi
    g_priority_sequences[140] = true; // shoot uzis
    g_priority_sequences[141] = true; // shoot right uzi
    g_priority_sequences[142] = true; // shoot left uzi
    g_priority_sequences[143] = true; // reload right uzi
    g_priority_sequences[144] = true; // reload left uzi

    g_priority_sequences[145] = true; // draw m16
    g_priority_sequences[147] = true; // shoot m16
    g_priority_sequences[148] = true; // shoot m203
    g_priority_sequences[149] = true; // reload m16
    g_priority_sequences[150] = true; // reload m203
    g_priority_sequences[151] = true; // draw m16
    g_priority_sequences[153] = true; // shoot m16
    g_priority_sequences[154] = true; // shoot m203
    g_priority_sequences[155] = true; // reload m16
    g_priority_sequences[156] = true; // reload m203

    g_priority_sequences[157] = true; // draw sniper
    g_priority_sequences[159] = true; // shoot sniper
    g_priority_sequences[161] = true; // shoot sniper (scoped)
    g_priority_sequences[162] = true; // reload sniper
    g_priority_sequences[163] = true; // draw sniper
    g_priority_sequences[165] = true; // shoot sniper
    g_priority_sequences[167] = true; // shoot sniper (scoped)
    g_priority_sequences[168] = true; // reload sniper

    g_priority_sequences[169] = true; // draw saw
    g_priority_sequences[171] = true; // shoot saw
    g_priority_sequences[172] = true; // reload saw
    g_priority_sequences[173] = true; // draw saw
    g_priority_sequences[175] = true; // shoot saw
    g_priority_sequences[176] = true; // reload saw

    g_priority_sequences[182] = true; // barnacle hit
    g_priority_sequences[183] = true; // barnacle pull
    g_priority_sequences[184] = true; // barnacle crunch
    g_priority_sequences[185] = true; // barnacle chew
}

string getModeString(int mode) {
    switch(mode) {
        case MODE_ONCE: return "ONCE";
        case MODE_FREEZE: return "FREEZE";
        case MODE_LOOP: return "LOOP";
        case MODE_ILOOP: return "ILOOP";
    }
    return "???";
}

// force animation even when doing other things
void emoteLoop(EHandle h_plr, EHandle h_target, Emote@ emote, int partIdx, float lastFrame) {
    if (!h_plr.IsValid()) {
        return;
    }

    CBasePlayer@ plr = cast<CBasePlayer@>(h_plr.GetEntity());
    if (plr is null or !plr.IsConnected()) {
        return;
    }

    CBaseMonster@ target = cast<CBaseMonster@>(h_target.GetEntity());
    if (target is null) {
        return;
    }

    bool targetIsGhost = target.entindex() != plr.entindex();
    if (!plr.IsAlive() && !targetIsGhost) { // stop if player was killed
        return;
    }

    EmotePart e = emote.parts[partIdx];

    bool emoteIsPlaying = target.pev.sequence == e.seq;

    if (!emoteIsPlaying) // player shooting or jumping or something
    {
        if (!g_priority_sequences[target.pev.sequence]) // sequence that's less important than the emote?
        {
            if (e.mode == MODE_ILOOP)
            {
                if (lastFrame >= e.endFrame-0.1f)
                {
                    lastFrame = e.endFrame;
                    e.framerate = -abs(e.framerate);
                }
                else if (lastFrame <= e.startFrame+0.1f)
                {
                    lastFrame = e.startFrame;
                    e.framerate = abs(e.framerate);
                }
            }
            else if (e.mode == MODE_LOOP)
            {
                lastFrame = e.startFrame;
            }
            else if (e.mode == MODE_ONCE)
            {
                if ((e.framerate >= 0 and lastFrame > e.endFrame - 0.1f) or
                    (e.framerate < 0 and lastFrame < e.endFrame + 0.1f) or
                    (e.framerate >= 0 and target.pev.frame < lastFrame) or
                    (e.framerate < 0 and target.pev.frame > lastFrame)) {
                    //println("OK GIVE UP " + lastFrame);
                    doEmote(plr, emote, partIdx+1);
                    return;
                }
            }
            else if (e.mode == MODE_FREEZE)
            {
                if ((e.framerate >= 0 and lastFrame >= e.endFrame - 0.1f) or
                    (e.framerate < 0 and lastFrame <= e.endFrame + 0.1f)) {
                    lastFrame = e.endFrame;
                    e.framerate = target.pev.framerate = 0.0000001f;
                }
            }

            //println("OMG RESET: " + target.pev.sequence + "[" + target.pev.frame + "] -> " + e.seq + "[" + lastFrame + "] " + e.framerate);

            target.m_Activity = ACT_RELOAD;
            target.pev.sequence = e.seq;
            target.pev.frame = lastFrame;
            target.ResetSequenceInfo();
            target.pev.framerate = e.framerate;
        } else {
            //println("Sequence " + plr.pev.sequence + " has priority over emotes");
        }
    }
    else // emote sequence playing
    {
        bool loopFinished = false;
        if (e.mode == MODE_ILOOP)
            loopFinished = (target.pev.frame - e.endFrame > 0.01f) or (e.startFrame - target.pev.frame > 0.01f);
        else
            loopFinished = e.framerate > 0 ? (target.pev.frame - e.endFrame > 0.01f) : (e.endFrame - target.pev.frame > 0.01f);

        if (loopFinished)
        {
            if (e.mode == MODE_ONCE) {
                //println("Emote finished");
                doEmote(plr, emote, partIdx+1);
                return;
            }
            else if (e.mode == MODE_FREEZE) {
                //println("Emote freezing " + plr.pev.frame);
                target.pev.frame = e.endFrame;
                e.framerate = target.pev.framerate = 0.0000001f;
            }
            else if (e.mode == MODE_LOOP)
            {
                //println("RESTART SEQ " + plr.pev.frame + " " + framerate);
                target.pev.frame = e.startFrame;
            }
            else if (e.mode == MODE_ILOOP)
            {
                //println("RESTART SEQ " + plr.pev.frame + " " + e.framerate);
                lastFrame = target.pev.frame;
                if (lastFrame >= e.endFrame-0.1f)
                {
                    lastFrame = e.endFrame;
                    e.framerate = -abs(e.framerate);
                }
                else if (lastFrame <= e.startFrame+0.1f)
                {
                    lastFrame = e.startFrame;
                    e.framerate = abs(e.framerate);
                }

                target.pev.framerate = e.framerate;
            }
        }
        else
        {
            lastFrame = target.pev.frame;

            target.m_flLastEventCheck = g_Engine.time + 1.0f;
            target.m_flLastGaitEventCheck = g_Engine.time + 1.0f;

            // animation stops at the absolute start/end frames
            if (lastFrame <= 0)
                lastFrame = 0.00001f;
            if (lastFrame >= 255)
                lastFrame = 254.9999f;
        }
    }

    @g_emote_loops[plr.entindex()] = g_Scheduler.SetTimeout("emoteLoop", 0, h_plr, h_target, @emote, partIdx, lastFrame);
}

string getPlayerUniqueId(CBasePlayer@ plr)
{
    string steamId = g_EngineFuncs.GetPlayerAuthId( plr.edict() );
    if (steamId == 'STEAM_ID_LAN' or steamId == 'STEAM_ID_BOT' or steamId == 'BOT') {
        steamId = plr.pev.netname;
    }
    return steamId;
}

// compatibililty with the ghosts plugin
CBaseMonster@ getGhostEnt(CBasePlayer@ plr) {
    string id = getPlayerUniqueId(plr);

    CBaseEntity@ ent = null;
    do {
        @ent = g_EntityFuncs.FindEntityByClassname(ent, "monster_ghost");
        if (ent !is null)
        {
            if (string(ent.pev.noise) == id) {
                return cast<CBaseMonster@>(ent);
            }
        }
    } while (ent !is null);

    return null;
}

void doEmote(CBasePlayer@ plr, Emote emote, int partIdx) {
    CBaseMonster@ emoteEnt = cast<CBaseMonster@>(plr);

    if (!plr.IsAlive()) {
        @emoteEnt = getGhostEnt(plr);
        if (emoteEnt is null)
        {
            Language::Print( plr, pJson[ "DEAD", {} ] );
            return;
        } else {
            emoteEnt.pev.noise1 = "emote"; // tell the ghosts plugin that an emote is playing
        }
    }
    if (partIdx >= int(emote.parts.size())) {
        if (emote.loop) {
            partIdx = 0;
        } else {
            return;
        }
    }

    EmotePart e = emote.parts[partIdx];
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, 'Part: ' + partIdx + ', Sequence: ' + e.seq + " (" + getModeString(e.mode) + ")" +
        ", Speed " + e.framerate + ", Frames: " + int(e.startFrame + 0.5f) + "-" + int(e.endFrame + 0.5f) + "\n");

    emoteEnt.m_Activity = ACT_RELOAD;
    emoteEnt.pev.frame = e.startFrame;
    emoteEnt.pev.sequence = e.seq;
    emoteEnt.ResetSequenceInfo();
    emoteEnt.pev.framerate = e.framerate;

    CScheduledFunction@ func = g_emote_loops[plr.entindex()];
    if (func !is null) { // stop previous emote
        g_Scheduler.RemoveTimer(func);
    }
    @g_emote_loops[plr.entindex()] = g_Scheduler.SetTimeout("emoteLoop", 0, EHandle(plr), EHandle(emoteEnt), emote, partIdx, e.startFrame);
}

void doEmoteCommand(CBasePlayer@ plr, const CCommand@ args, bool inConsole)
{
    if (args.ArgC() >= 2)
    {
        string emoteName = args[1].ToLowercase();

        if( emoteName == 'anal' || atoi( emoteName ) == 14 )
        {
            Language::Print( plr, pJson[ "ANAL", {} ] );
            return;
        }

        bool isNumeric = true;
        for (uint i = 0; i < emoteName.Length(); i++) {
            if (!isdigit(emoteName[i])) {
                isNumeric = false;
                break;
            }
        }

        if (emoteName == "version") {
            g_PlayerFuncs.SayText(plr, "emotes plugin v2\n");
        }
        else if (emoteName == "chain") // super custom emote
        {
            float speedMod = atof(args[2]);
            string loopMode = args[3].ToLowercase();

            int lastSeqMode = MODE_ONCE;
            if (loopMode == "loopend") {
                lastSeqMode = MODE_LOOP;
            }
            if (loopMode == "iloopend") {
                lastSeqMode = MODE_ILOOP;
            }
            if (loopMode == "freezeend") {
                lastSeqMode = MODE_FREEZE;
            }

            array<EmotePart> parts;

            for (int i = 4; i < args.ArgC(); i++) {
                array<string> seqOpts = args[i].Split("_");

                int seq = atoi(seqOpts[0]);
                float speed = (seqOpts.size() > 1 ? atof(seqOpts[1]) : 1) * speedMod;

                float startFrame = (speed >= 0 ? 0.0001f : 254.9999f);
                float endFrame = (speed >= 0 ? 254.9999f : 0.0001f);
                startFrame = seqOpts.size() > 2 ? atof(seqOpts[2]) : startFrame;
                endFrame = seqOpts.size() > 3 ? atof(seqOpts[3]) : endFrame;

                if (seq > 255) {
                    seq = 255;
                }

                bool isLast = i == args.ArgC()-1;
                int mode = isLast ? lastSeqMode : MODE_ONCE;

                parts.insertLast(EmotePart(seq, mode, speed, startFrame, endFrame));
            }

            doEmote(plr, Emote(parts, loopMode == "loop"), 0);
        }
        else if (isNumeric) // custom emote
        {
            int seq = atoi(args[1]);

            int mode = MODE_ONCE;
            string smode = args[2];
            if (smode.ToLowercase() == "loop") {
                mode = MODE_LOOP;
            } else if (smode.ToLowercase() == "iloop") {
                mode = MODE_ILOOP;
            } else if (smode.ToLowercase() == "freeze") {
                mode = MODE_FREEZE;
            }

            float framerate = args.ArgC() >= 4 ? atof(args[3]) : 1.0f;
            float startFrame = (framerate >= 0 ? 0.0001f : 254.9999f);
            float endFrame = (framerate >= 0 ? 254.9999f : 0.0001f);
            if (seq > 255) {
                seq = 255;
            }

            startFrame = args.ArgC() >= 5 ? atof(args[4]) : startFrame;
            endFrame = args.ArgC() >= 6 ? atof(args[5]) : endFrame;

            doEmote(plr, Emote( {EmotePart(seq, mode, framerate, startFrame, endFrame)}, false ), 0);
        }
        else if (emoteName == "list")
        {
            array<string>@ emoteNames = g_emotes.getKeys();
            emoteNames.sortAsc();
            string emoteText;
            for (uint i = 0; i < emoteNames.length(); i++)
            {
                emoteText += " | " + emoteNames[i];
            }
            emoteText = "Emotes: " + emoteText.SubString(3);

            if (inConsole)
                g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, emoteText + "\n");
            else
                g_PlayerFuncs.SayText(plr, emoteText + "\n");
        }
        else if (emoteName == "off" or emoteName == "stop")
        {
            CScheduledFunction@ func = g_emote_loops[plr.entindex()];
            if (func !is null and !func.HasBeenRemoved()) {
                g_Scheduler.RemoveTimer(func);
                plr.m_Activity = ACT_IDLE;
                plr.ResetSequenceInfo();

                CBaseEntity@ ghostEnt = getGhostEnt(plr);
                if (ghostEnt !is null) {
                    ghostEnt.pev.noise1 = ""; // tell the ghsots plugin that the emote was stopped
                }
                Language::Print( plr, pJson[ "STOPPED", {} ] );
            }
            else
            {
                Language::Print( plr, pJson[ "NOEMOTE", {} ] );
            }
        }
        else // named emote
        {
            if (g_emotes.exists(emoteName)) {
                Emote emote = cast<Emote@>( g_emotes[emoteName] );

                float speed = args.ArgC() >= 3 ? atof(args[2]) : 1.0f;
                for (uint i = 0; i < emote.parts.size(); i++) {
                    emote.parts[i].framerate *= speed;
                }

                doEmote(plr, emote, 0);
            }
            else
            {
                Language::Print( plr, pJson[ "NOTFOUND", {} ], MKLANG::CHAT, { { 'name', emoteName } } );
            }
        }
    }
    else
    {
        if( inConsole )
        {
            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '----------------------------------Emotes----------------------------------\n\n');
        }

        Language::Print( plr, pJson[ "HOWTO", {} ], ( !inConsole ? MKLANG::CHAT : MKLANG::CONSOLE ) );
        Language::Print( plr, pJson[ "TOOFF", {} ], ( !inConsole ? MKLANG::CHAT : MKLANG::CONSOLE ) );
        Language::Print( plr, pJson[ "TOPLAY", {} ], ( !inConsole ? MKLANG::CHAT : MKLANG::CONSOLE ) );
        Language::Print( plr, pJson[ "TOCONTROL", {} ], ( !inConsole ? MKLANG::CHAT : MKLANG::CONSOLE ) );


        if( !inConsole )
        {
            Language::Print( plr, pJson[ "MOREINFO", {} ] );
        }

        if( inConsole )
        {
            Language::Print( plr, pJson[ "ADVANCED", {} ], MKLANG::CONSOLE );
            Language::Print( plr, pJson[ "TOARGS", {} ], MKLANG::CONSOLE );
            Language::Print( plr, pJson[ "SEQUENCE", {} ], MKLANG::CONSOLE );
            Language::Print( plr, pJson[ "MODE", {} ], MKLANG::CONSOLE );
            Language::Print( plr, pJson[ "CHAIN", {} ], MKLANG::CONSOLE );
            Language::Print( plr, pJson[ "SPEED", {} ], MKLANG::CONSOLE );
            Language::Print( plr, pJson[ "FRAMES", {} ], MKLANG::CONSOLE );
            Language::Print( plr, pJson[ "SAMPLES", {} ], MKLANG::CONSOLE );

            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '.e oof\n');
            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '.e oof 2\n');
            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '.e 15 iloop\n');
            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '.e 15 iloop 0.5\n');
            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '.e 15 iloop 0.5 0 50\n');
            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '.e chain 2 loop 13 14 15\n');
            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '.e chain 1 once 13 14_-1\n');
            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '.e chain 1 iloopend 182 183 184 185\n');
            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '.e chain 1 freezeend 15_0.1_0_50 16_-1_100_10\n');

            g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, '\n----------------------------------------------------------------------------------\n');
        }

    }
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ plr = pParams.GetPlayer();
    const CCommand@ args = pParams.GetArguments();
    if (args.ArgC() > 0 and (args[0].Find(".emote") == 0 or args[0] == '.e'))
    {
        doEmoteCommand(plr, args, false);
        pParams.ShouldHide = true;
        return HOOK_HANDLED;
    }
    return HOOK_CONTINUE;
}

CClientCommand _emote("e", "Emote commands", @emoteCmd );

void emoteCmd( const CCommand@ args )
{
    CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();
    doEmoteCommand(plr, args, true);
}