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

# fileload, sockets, http

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

from fileload import ReadServer, SendServer

@bot.event
async def on_message( message ):

    if not message or not message.content or message.content == '' or message.author == bot.user or message.channel.id != CHANNEL_BRIDGE:
        return

    await SendServer( message )

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