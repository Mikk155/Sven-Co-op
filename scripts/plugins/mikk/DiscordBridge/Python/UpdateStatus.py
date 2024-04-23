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

from __main__ import bot, CHANNEL_STATUS, STATUS_ID, METHOD
from GetMessage import GetMessage
import json
import discord
import socket

async def UpdateStatus( ToStatus ):

    BridgeChannel = bot.get_channel( CHANNEL_STATUS )

    if not BridgeChannel:
        return

    data = json.loads( ToStatus )

    try:
        s = socket.socket( socket.AF_INET, socket.SOCK_DGRAM )
        s.connect( ( "8.8.8.8", 80 ) )
        SERVER_IP = s.getsockname()[0]
        s.close()
    except socket.error as e:
        SERVER_IP = 'Server'

    embed = discord.Embed(
        title=SERVER_IP,
        description=data['hostname'],
        color=int(data.get('color', 16711680 ))
    )

    for nombre, info in data['campos'].items():
        valor = info['valor']
        inline = info.get( 'inline', False )
        if nombre != '' and valor != '':
            try:
                embed.add_field( name=nombre, value=valor, inline=inline )
            except Exception as e:
                print(f'There are so much embeeds to import into the server status!')

    if METHOD == 'fileload':
        async for message in BridgeChannel.history( limit=3 ):
            if message and message.author == bot.user:
                await message.edit(embed=embed)
                return
        await BridgeChannel.send(embed=embed)
    else:
        # Smth, need look into it when using webhook -TODO
        try:
            message = await BridgeChannel.fetch_message(STATUS_ID)
            message.edit(embed=embed)
        except discord.NotFound:
            message = await BridgeChannel.send(embed=embed)
            snd = GetMessage('UpdateStatusID')
            await BridgeChannel.send( f'{snd}\n```{message.id}```')