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

import discord

from discord.ext import commands

from token_bot import TOKEN

from json_bot import PREFIX, CHANNEL_BRIDGE

bot = commands.Bot( command_prefix = PREFIX, intents = discord.Intents.all() )

import ExecuteCommands

import ClearCache

import WriteServer

from ReadServer import ServerGetMessages

@bot.event

async def on_ready():

    print( f'BOT Connected as {bot.user}' )

    ServerGetMessages()

bot.run( TOKEN )