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

from __main__ import bot, pJson, CHANNEL_BRIDGE, TO_DISCORD, TO_SERVER, TO_COMMAND, TO_STATUS
from GetMessage import GetMessage
from UpdateStatus import UpdateStatus
import os
import discord
from discord.ext import tasks

bot: discord.Client

PrintList = []

ServerFile = os.path.join(os.path.dirname(__file__), '../../../../../../svencoop/scripts/plugins/store/DiscordBridge.txt' )

@tasks.loop( seconds = int( pJson.get( 'interval', 20 ) ) )

async def ReadServer():

    await bot.wait_until_ready()

    BridgeChannel = bot.get_channel( CHANNEL_BRIDGE )

    if not os.path.exists( ServerFile ) or not BridgeChannel:
        return

    with open( ServerFile, 'r') as r:
        lines = r.readlines()
        r.close()

    if not lines:
        return

    ToDiscord = []
    ToServer = []
    ToStatus = ''

    for l in lines:
        if l and l != '':
            if l[0] == TO_DISCORD:
                l = l[1:len(l)]
                if l and l != '' and not l.isspace():
                    ToDiscord.append( l )
            elif l[0] == TO_SERVER or l[0] == TO_COMMAND:
                if l and l != '' and not l.isspace():
                    ToServer.append( l + '\n' )
            elif l[0] == TO_STATUS:
                l = l[1:len(l)]
                if l and l != '' and not l.isspace():
                    ToStatus = l

    while len(PrintList) > 0:
        ToServer.append( PrintList[0] + '\n' )
        PrintList.pop(0)

    if ToServer and len(ToServer) > 0:
        with open( ServerFile, 'w') as w:
            w.writelines( ToServer )
            ToServer.clear()
            w.close()

    for msg in ToDiscord:
        if msg and msg != '' and not msg.isspace():
            await BridgeChannel.send(msg)
        ToDiscord.pop(0)

    if ToStatus and ToStatus != '':
        UpdateStatus( ToStatus )

async def ToServerAppendFile( Print ):
    PrintList.append(Print)