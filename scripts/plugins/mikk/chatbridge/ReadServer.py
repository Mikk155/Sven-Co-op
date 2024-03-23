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

from __main__ import bot

import os

ServerFile = os.path.join(os.path.dirname(__file__), '../../../../../svencoop/scripts/plugins/store/chatbridge_to_python.txt' )

from discord.ext import tasks

from json_bot import READ_INTERVAL, CHANNEL_BRIDGE

@tasks.loop( seconds = READ_INTERVAL )

async def ReadMessages():

    await bot.wait_until_ready()

    if not os.path.exists( ServerFile ):

        return

    BridgeChannel = bot.get_channel( CHANNEL_BRIDGE )

    with open( ServerFile, 'r') as r:

        lines = r.readlines()

        r.close()

        with open( ServerFile, 'w') as w:
            w.writelines( '' )
            w.close()

        for l in lines:

            if l and not l.isspace():

                await BridgeChannel.send(l)

def ServerGetMessages():

    BridgeChannel = bot.get_channel( CHANNEL_BRIDGE )

    if BridgeChannel:

        ReadMessages.start()

        print( f'Reading server messages to \"{BridgeChannel}\"' )

    else:

        print( f'WARNING! No channel found with ID \"{CHANNEL_BRIDGE}\"' )
