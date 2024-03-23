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

from json_bot import CHANNEL_BRIDGE, LOG

from SimplifyString import simplify

import os

ServerFile = os.path.join(os.path.dirname(__file__), '../../../../../svencoop/scripts/plugins/store/chatbridge_to_angelscript.txt' )

@bot.event

async def on_message( message ):

    if message.channel.id != CHANNEL_BRIDGE or message.author == bot.user or not message.content or message.content == '':

        return

    with open( ServerFile, 'a') as archivo:

        msg = message.content.split("\n")

        for linea in msg:

            if linea.strip():

                String = simplify( f'{message.author.name}: {linea}' )

                archivo.write( f'[Discord] {String}\n' )

        archivo.close()

    if bool( LOG.get( "delete discord messages", False ) ):

        await message.delete()
