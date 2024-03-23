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

from json_bot import COMMANDS

from json_bot import MSG

from WriteServer import ServerFile

@bot.command(name='exe')

async def _execommand_( ctx, args ):

    if not any( role.name == COMMANDS.get( "role", "" ) for role in ctx.author.roles ):

        await ctx.send( f'{MSG.get( "no_command_access", "" )}' )

        return

    if ';' in args:

        await ctx.send( f'{MSG.get( "command_hack", "" )}' )

        return

    cmd = args.split( ' ' )

    whitelist = bool( COMMANDS.get( "whitelist", False ) )

    if cmd[0] in COMMANDS and bool( COMMANDS.get( cmd[0], False ) and whitelist ):

        message = MSG.get( "command_exec", "" ).replace( '$name$', f'\"{args}\"' )

        await ctx.send( f'{message}' )

    else:

        message = MSG.get( "command_blacklisted", "" ).replace( '$name$', f'\"{cmd[0]}\"' )

        await ctx.send( f'{message}' )

        return

    with open( ServerFile, 'a') as archivo:

        archivo.write( f'$command${args}\n')

        archivo.close()