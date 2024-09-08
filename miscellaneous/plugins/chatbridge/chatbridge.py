import discord
from discord.ext import commands, tasks
import os
import asyncio
import json
import requests

# BOT Config
with open('chatbridge.json') as global_config:
    json_config = json.load( global_config )

js_BOT_config = json_config.get( "BOT", {} )

JS_BOT_TOKEN = js_BOT_config.get("TOKEN", "")

if not JS_BOT_TOKEN:
    print("Error: No BOT Token set, please config chatbridge.json.")
    exit(1)

js_BOT_PREFIX = js_BOT_config.get( "PREFIX", "!" )

JS_BOT_CHANNEL_BRIDGE = int( js_BOT_config.get( "CHANNEL_BRIDGE", "" ) )
JS_BOT_CHANNEL_STATUS = int( js_BOT_config.get( "CHANNEL_STATUS", "" ) )
JS_BOT_INTERVAL_READ = int( js_BOT_config.get( "INTERVAL_READ_SERVER", "2" ) )
JS_BOT_INTERVAL_STATUS = int( js_BOT_config.get( "INTERVAL_STATUS", "2" ) )
JS_BOT_SERVER_IP = js_BOT_config.get( "IP", "" )
JS_BOT_LANGUAGE = js_BOT_config.get( "LANGUAGE", "ENGLISH" )
JS_BOT_MODERATOR_ROLE = js_BOT_config.get( "MODERATOR_ROLE", "" )

JS_LOG_CONFIG = json_config.get( "LOG", {} )

JS_BOT_NOTICE = bool( JS_LOG_CONFIG.get( "BOT_NOTICE", "" ) )

lang_msg = json_config.get( JS_BOT_LANGUAGE, {} )

USER_DELETE_MESSAGE = bool( JS_LOG_CONFIG.get( "USER_DELETE_MESSAGE", False ) )

MSG_BRIDGE = lang_msg.get( "MSG_BRIDGE", "I'm now reading." )
MSG_STATUS = lang_msg.get( "MSG_STATUS", "I'm now updating." )

MSG_PLAYERS_CONNECTED = lang_msg.get( "MSG_PLAYERS_CONNECTED", "Connected players" )
MSG_PLAYER_STATE = lang_msg.get( "MSG_PLAYER_STATE", "State")
MSG_PLAYER_SCORE = lang_msg.get( "MSG_PLAYER_SCORE", "Score | Deaths" )
MSG_PLAYERS_ALIVE = lang_msg.get( "MSG_PLAYERS_ALIVE", "Alive players" )
MSG_PLAYERS = lang_msg.get( "MSG_PLAYERS", "Player name" )
MSG_MAP = lang_msg.get( "MSG_MAP", "Map" )
MSG_SERVER = lang_msg.get( "MSG_SERVER", "Server" )
MSG_OFFLINE = lang_msg.get( "MSG_OFFLINE", "Offline" )
MSG_RESTARTS = lang_msg.get( "MSG_RESTARTS", "Restarts" )
MSG_MAPTIME = lang_msg.get( "MSG_MAPTIME", "Time on this map" )
MSG_CHECKPOINTS = lang_msg.get( "MSG_CHECKPOINTS", "" )
MSG_ADMIN = lang_msg.get ("MSG_ADMIN", "The command has been sent." )
MSG_ADMIN_BLACKLIST = lang_msg.get( "MSG_ADMIN_BLACKLIST", "This command is blocked." )
MSG_NOADMIN = lang_msg.get( "MSG_NOADMIN", "You don't have access to this command." )

MSG_IPADDRESS = lang_msg.get( "IPADDRESS", "IP Address" )

intents = discord.Intents.default()
intents.messages = True
intents.message_content = True

# Relative path from this folder to store/
path_from_server  = '../../../../svencoop/scripts/plugins/store/discord_from_server.txt'
path_from_discord = '../../../../svencoop/scripts/plugins/store/discord_to_server.txt'
path_for_status   = '../../../../svencoop/scripts/plugins/store/discord_to_status.json'

bot = commands.Bot( command_prefix = js_BOT_PREFIX, intents=intents)

# Bridge messages from the server
toDiscord = os.path.join(os.path.dirname(__file__), path_from_server )

@tasks.loop( seconds = JS_BOT_INTERVAL_READ )
async def ReadScheduler():

    await bot.wait_until_ready()

    channel = bot.get_channel( JS_BOT_CHANNEL_BRIDGE )

    if channel:
        if not os.path.exists(toDiscord):
            return

        with open(toDiscord, 'r') as file:
            first_line = file.readline().strip()

        with open(toDiscord, 'r') as file:
            lines = file.readlines()

        with open(toDiscord, 'w') as file:
            file.writelines(lines[1:])

        if not first_line or first_line.isspace():
            return

        if first_line.startswith("$"):
            ConnectedHook = first_line.split( " " )

            if ConnectedHook and ConnectedHook[1]:
                country = GetCountryName(ConnectedHook[1])
                flag_emoji = GetCountryEmote(ConnectedHook[1])

                first_line = ""

                for msg in ConnectedHook:
                    if msg != ConnectedHook[1] and msg != ConnectedHook[0]:
                        first_line = first_line + msg + " "

                # Idk why it's empty
                if country:
                    first_line = first_line + country + " "
                if flag_emoji:
                    first_line = first_line + flag_emoji + " "

        await channel.send(first_line)

@bot.event
async def on_ready():
    print(f'BOT Connected as {bot.user}')

    if JS_BOT_CHANNEL_BRIDGE:
        ReadScheduler.start()

        #Cleanup
        if os.path.exists(toDiscord):
            os.remove(toDiscord)
        if os.path.exists(toServer):
            os.remove(toServer)
        if os.path.exists(ToStatus):
            os.remove(ToStatus)

        if JS_BOT_NOTICE:
            await bot.get_channel(JS_BOT_CHANNEL_BRIDGE).send( MSG_BRIDGE )

    if JS_BOT_CHANNEL_STATUS:
        StatusScheduler.start()

        async for message in bot.get_channel( JS_BOT_CHANNEL_STATUS ).history(limit=10):
            if message.author == bot.user:
                return

        if JS_BOT_NOTICE:
            await bot.get_channel(JS_BOT_CHANNEL_STATUS).send( MSG_STATUS )

# Bridge messages to the server
toServer = os.path.join(os.path.dirname(__file__), path_from_discord )

@bot.event
async def on_message(message):

    if JS_BOT_CHANNEL_BRIDGE and message.channel.id == JS_BOT_CHANNEL_BRIDGE and message.author != bot.user and message.content and message.content != '':

        if message.content.startswith( js_BOT_PREFIX ):
            author = message.author
            guild = message.guild

            if JS_BOT_MODERATOR_ROLE and guild and any( role.name == JS_BOT_MODERATOR_ROLE for role in author.roles ):
                comando = message.content[1:]
                array = comando.split()
                comando = array[0]

                COMMANDS = json_config.get( "COMMANDS", {} )
                COMMAND_ALLOW = bool( COMMANDS.get( comando, False ) )

                if COMMAND_ALLOW:
                    await bot.get_channel( JS_BOT_CHANNEL_BRIDGE ).send( MSG_ADMIN )
                    with open(path_from_discord, 'a') as archivo:
                        archivo.write( js_BOT_PREFIX + f'{message.content[1:]}\n' )
                else:
                    await bot.get_channel( JS_BOT_CHANNEL_BRIDGE ).send( MSG_ADMIN_BLACKLIST )
            else:
                await bot.get_channel( JS_BOT_CHANNEL_BRIDGE ).send( MSG_NOADMIN )

            if USER_DELETE_MESSAGE:
                await message.delete()
            return

        # To sven coop
        msg = message.content.split("\n")
        for linea in msg:
            if linea.strip():
                with open(path_from_discord, 'a') as archivo:
                    archivo.write('[Discord] ' + f'{message.author.name}: {linea}\n')

        if USER_DELETE_MESSAGE:
            await message.delete()

ToStatus = os.path.join(os.path.dirname(__file__), path_for_status )

@tasks.loop( seconds = JS_BOT_INTERVAL_STATUS + 1 )
async def StatusScheduler():

    await bot.wait_until_ready()

    channel = bot.get_channel( JS_BOT_CHANNEL_STATUS )

    if not os.path.exists(ToStatus):

        embed = discord.Embed(
            title = MSG_SERVER,
            description = MSG_OFFLINE,
            color=0xd40004
        )

        async for message in channel.history(limit=10):

            if message.author == bot.user:
                await message.edit( embed=embed )
        return

    with open(ToStatus) as archivo:
        status = json.load(archivo)

    if not status:
        return

    HOSTNAME = status.get( "HOSTNAME", "Sven Co-op Dedicated Server" )
    MAP = status.get( "MAP", "" )
    PLAYERS_CURRENT = status.get( "PLAYERS", "0" )
    STATUS_ALIVEPLAYERS = status.get("STATUS_ALIVEPLAYERS", "")
    CURRENT_CHECKPOINTS = status.get("CURRENT_CHECKPOINTS", "")
    SERVER_IP = status.get("IP", "")
    RESTARTS = status.get( "RESTARTS", "" )
    MAPTIME = status.get("MAPTIME", "")

    status_data = status.get('STATUS', {})

    PLAYER_NAMES = ""
    PLAYER_SCORES = ""
    PLAYER_STATES = ""

    for player_id, player_data in status_data.items():
        name = player_data.get('name', '')
        score = player_data.get('score', '')
        state = player_data.get('state', '')

        PLAYER_NAMES = PLAYER_NAMES + '\n' + name
        PLAYER_SCORES = PLAYER_SCORES + '\n' + score
        PLAYER_STATES = PLAYER_STATES + '\n' + state


    embed = discord.Embed(
        title = MSG_SERVER,
        description = HOSTNAME,
        color=0xcc3cda
    )

    if MSG_PLAYERS_CONNECTED:
        embed.add_field( name = MSG_PLAYERS_CONNECTED + ':', value = PLAYERS_CURRENT, inline = True )

    if MSG_PLAYERS_ALIVE and STATUS_ALIVEPLAYERS:
        embed.add_field( name = MSG_PLAYERS_ALIVE + ':', value = STATUS_ALIVEPLAYERS, inline=True)

    if MSG_CHECKPOINTS and CURRENT_CHECKPOINTS:
        embed.add_field( name = MSG_CHECKPOINTS + ':', value=CURRENT_CHECKPOINTS, inline=True)

    if MSG_RESTARTS and RESTARTS:
        embed.add_field( name = MSG_RESTARTS + ':', value=RESTARTS, inline=True)

    if MSG_MAPTIME and MAPTIME:
        embed.add_field( name = MSG_MAPTIME + ':', value=MAPTIME, inline=True)

    if MSG_MAP and MAP:
        embed.add_field( name=MSG_MAP + ':', value= MAP, inline= True )

    embed.add_field( name = MSG_IPADDRESS, value = SERVER_IP, inline = False )

    if status_data:

        if MSG_PLAYERS and PLAYER_NAMES:

            embed.add_field( name = MSG_PLAYERS, value = PLAYER_NAMES, inline = True )

        if MSG_PLAYER_STATE and PLAYER_STATES:

            embed.add_field( name = MSG_PLAYER_STATE, value = PLAYER_STATES, inline = True )

        if MSG_PLAYER_SCORE and PLAYER_SCORES:

            embed.add_field( name = MSG_PLAYER_SCORE, value = PLAYER_SCORES, inline = True )

    os.remove(ToStatus)

    # Generate a new message if we're not in JS_BOT_CHANNEL_BRIDGE and if can't find any valid message
    if JS_BOT_CHANNEL_STATUS != JS_BOT_CHANNEL_BRIDGE:

        async for message in channel.history(limit=10):

            if message.author == bot.user:
                await message.edit( embed=embed )
                return

    mensaje = await channel.send(embed=embed)

    # If we're on the same channel then delete and re send
    if JS_BOT_CHANNEL_STATUS == JS_BOT_CHANNEL_BRIDGE:

        await asyncio.sleep( JS_BOT_INTERVAL_STATUS + 1)

        if mensaje:
            await mensaje.delete()

def GetCountryEmote(ip):
    response = requests.get(f"https://ipinfo.io/{ip}/json")
    data = response.json()
    country_code = data.get("country")
    if country_code:
        return chr(ord(country_code[0]) + 127397) + chr(ord(country_code[1]) + 127397)
    else:
        return None

def GetCountryName(ip):
    response = requests.get(f"https://ipinfo.io/{ip}/json")
    data = response.json()
    country_name = data.get("country_name")
    return country_name

bot.run( JS_BOT_TOKEN )


#$ 152.171.75.115 .mk is connecting.