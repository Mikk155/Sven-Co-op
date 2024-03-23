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

from json_bot import MSG

import os

F1 = os.path.join(os.path.dirname(__file__), '../../../../../svencoop/scripts/plugins/store/chatbridge_to_python.txt' )

F2 = os.path.join(os.path.dirname(__file__), '../../../../../svencoop/scripts/plugins/store/chatbridge_to_angelscript.txt' )

@bot.command(name='clear')

async def _clearcommand_( ctx ):

    if os.path.exists( F1 ):

        msg = MSG.get( "cache_cleared", "" ).replace( '$name$', 'chatbridge_to_python' )

        await ctx.send( f'{msg}' )

        os.remove( F1 )

    if os.path.exists( F2 ):

        msg = MSG.get( "cache_cleared", "" ).replace( '$name$', 'chatbridge_to_angelscript' )

        await ctx.send( f'{msg}' )

        os.remove( F2 )
