import discord, os, json
from datetime import datetime
from __main__ import CCHangelogFile, ResName

Testing = False

intents = discord.Intents()

intents.guilds = True
intents.members = True
intents.bans = False
intents.emojis = True
intents.integrations = True
intents.webhooks = False
intents.invites = True
intents.voice_states = False
intents.presences = False
intents.messages = True
intents.guild_messages = True
intents.dm_messages = True
intents.reactions = True
intents.guild_reactions = True
intents.dm_reactions = True
intents.typing = True
intents.guild_typing = True
intents.dm_typing = False

bot = discord.Client(intents=intents)

abs = os.path.abspath( '' )

TOKEN = ''
JSON = {}

ResourceName = ''

with open( f'{abs}/BOT.json', 'r' ) as f:
    JSON = json.load( f )
    f.close()

async def SendMessage( guild, channel, message ):

    # If i want to test something before commiting to other servers
    if Testing and guild.id != 1145236064596918304:
        return

    try:
        msg = await channel.send( f'{message}')
        if msg:
            print( f'Sent to "{guild.name}"' )
            if JSON:
                for e in JSON.get( "reactions" ):
                    await msg.add_reaction( e )
    except Exception as e:
        pr=0

async def PrepareMessage( guild, channel ):

    guild: discord.guild
    channel: discord.channel
    Message = ''

    if ResName != 'bot':
        if CCHangelogFile and CCHangelogFile != '':

            # Check just in case, i'm dumb :$
            if not Testing:
                token = os.getenv( "BOT" )
                if token == "" or not token:
                    return

            fechan = datetime.now()
            fecha = fechan.strftime("%d/%m/%y")

            AnythingNew = False
            with open( CCHangelogFile, 'r' ) as f:
                lines = f.readlines()
                for line in lines:
                    if line.startswith( "<details><summary>" ):
                        line = line[ 18: ]
                        if line.startswith( fecha ):
                            AnythingNew = True
                            Message = f'# {ResName}\n### {fecha}'
                            continue
                    if AnythingNew:
                        if line.startswith('---'):
                            break
                        Message = f'{Message}{line}'
                f.close()

            if Message and Message != '':
                Message = f'{Message}\n[Download Here](https://github.com/Mikk155/Sven-Co-op/releases/tag/{ResName}/svencoop.zip)'
                await SendMessage( guild, channel, Message )
    else:
        with open( f'{abs}/BOT.md', 'r' ) as f:
            lines = f.readlines()
            for l in lines:
                Message = f'{Message}{l}'
            f.close()
        if Message and Message != '':
            await SendMessage( guild, channel, Message )

async def GetChannels( guild ):
    guild: discord.guild

    for channel in guild.channels:
        if channel and isinstance( channel, discord.TextChannel ):
            description = channel.topic
            if not description or description == None:
                continue
            if 'mikk155/sven-co-op' in description.lower():
                await PrepareMessage( guild, channel )

@bot.event
async def on_ready():
    print('Initialising BOT {0.user}'.format( bot ) )

    for guild in bot.guilds:
        print( f'Getting Server "{guild.name}"')
        await GetChannels( guild )

    await bot.close()

def InitBot():
    File = os.path.join( abs, 'BOT.txt' )

    if os.path.exists( File ):
        with open( f'{File}' ) as token:
            TOKEN = token.readline()
            bot.run( TOKEN )
    else:
        try:
            token = os.getenv( "BOT" )
            if token == "" or not token:
                raise Exception("Please add your token \"BOT\" to the Secrets panel.")
            bot.run(token)
        except discord.HTTPException as e:
            if e.status == 429:
                print( "The Discord servers denied the connection for making too many requests" )
            else:
                raise e
