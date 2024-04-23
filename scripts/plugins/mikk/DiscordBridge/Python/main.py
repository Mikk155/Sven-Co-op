#=======================================================================================================================================#
#                                                                                                                                       #
#                               Creative Commons Attribution-NonCommercial 4.0 International                                            #
#                               https://creativecommons.org/licenses/by-nc/4.0/                                                         #
#                                                                                                                                       #
#   * You are free to:                                                                                                                  #
#      * Copy and redistribute the material in any medium or format.                                                                    #
#      * Remix, transform, and build upon the material.                                                                                 #
#                                                                                                                                       #
#   * Under the following terms:                                                                                                        #
#      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                            #
#      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                #
#      * You may not use the material for commercial purposes.                                                                          #
#      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.  #
#                                                                                                                                       #
#=======================================================================================================================================#

import os
import discord

TO_DISCORD = '<'
TO_SERVER  = '>'
TO_COMMAND = '-'
TO_STATUS  = '='

from config import pJson

bot = discord.Client( intents = discord.Intents.all() )

# Vars
CHANNEL_BRIDGE = int( pJson.get( 'channel bridge', '' ) )
METHOD = pJson.get( 'method', 'fileload' )

from fileload import ReadServer, ToServerAppendFile, ServerFile
from GetMessage import GetMessage

@bot.event
async def on_message( message ):

    BridgeChannel = bot.get_channel( CHANNEL_BRIDGE )

    if not BridgeChannel or not message or not message.content or message.content == '' or message.author == bot.user or message.channel.id != CHANNEL_BRIDGE:
        return

    Print = ''

    message: discord.Message

    user = message.author
    user: discord.Member

    name = user.name

    SendMessage = message.content

    if message.content.startswith( pJson.get( 'bot prefix', '!' ) ):
        SendMessage = SendMessage[ (len( pJson.get( 'bot prefix', '!' ) ) ): len(SendMessage)]

        commands = pJson.get( 'commands', {} )

        if not any( role.name in commands.get( "roles", [] ) for role in user.roles ):
            snd = GetMessage( "NoAccess" )
            await BridgeChannel.send( f'{user.mention} {snd}')
            return

        if SendMessage.find( ";" ) != -1:
            snd = GetMessage( "NoFuckedCmd" )
            await BridgeChannel.send( f'{user.mention} {snd}\n```{SendMessage}```')
            return

        cmds = SendMessage.split()
        list = commands.get( 'list', {} )
        if list[0] == 'white' and cmds[0] in list or list[0] == 'black' and not cmds[0] in list:
            Print =  f'{TO_COMMAND}{SendMessage}'
            snd = GetMessage( "CommandSent" )
            await BridgeChannel.send( f'{user.mention} {snd}\n```{SendMessage}```')
        elif cmds[0] == 'help':
            z = '```json\n[\n'
            for i in list:
                if i in [ 'white', 'black' ]:
                    continue
                z = f'{z}\t"{i}"'
                if list.index( i ) != len(list) -1:
                    z = f'{z},'
                z = f'{z}\n'
            z = f'{z}]```'
            snd = GetMessage( "GetHelp" )
            await BridgeChannel.send( f'{user.mention} {snd}\n{z}')
        else:
            snd = GetMessage( "NotInList" )
            await BridgeChannel.send( f'{user.mention} ``{SendMessage}`` {snd}')

    elif message.content.startswith( '//' ):
        return
    else:
        Print = f'{TO_SERVER}[Discord] {name} : {SendMessage}'

    if Print and Print != '':
        if METHOD == 'fileload' and os.path.exists( ServerFile ):
            await ToServerAppendFile( Print )

        elif METHOD == 'sockets':
            SendSockets = ''
        elif METHOD == 'http':
            SendSockets = ''

@bot.event
async def on_ready():
    print('We have logged in as {0.user}'.format( bot ) )

    BridgeChannel = bot.get_channel( CHANNEL_BRIDGE )

    if BridgeChannel:
        if METHOD == 'fileload':
            ReadServer.start()
        elif METHOD == 'sockets':
            ListenSockets = ''
        elif METHOD == 'http':
            ListenRequests = ''
        else:
            print( f'Wrong method on bot! Check key "bot method" on DiscordBridge.json, Exiting.' )
            exit(1)

        print( f'Reading server messages to \"{BridgeChannel}\"' )
    else:
        print( f'WARNING! No channel found with ID \"{CHANNEL_BRIDGE}\"' )

from RunBot import RunBot
RunBot()