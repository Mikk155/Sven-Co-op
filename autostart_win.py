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
import time
import json
import psutil
import subprocess

f = os.path.join(os.path.dirname(__file__), 'autostart.json' )

with open( f, 'r') as d:
    args = json.load( d )

def programa_corriendo():

    for proceso in psutil.process_iter(['name']):
        if proceso.info['name'] == "svenDS.exe":
            return True
    return False

while True:
    if not programa_corriendo():
        print("Sven Co-op not running. Ejecuting...")

        d = os.path.abspath('.')
        p = os.path.abspath(os.path.join('.', '..'))
        exe = f"\"{os.path.join( p, 'SvenDS.exe')}\""

        for i in args.get( 'arguments' ):
            exe = f'{exe} {i}'
        try:
            subprocess.Popen( exe, shell=True )
            print( f'{exe}' )
        except Exception as e:
            print( "A problem ocurred while ejecuting SvenDS:", e )
    time.sleep( int( args.get( 'interval', 60 ) ) )
