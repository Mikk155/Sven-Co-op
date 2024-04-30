import os

def ListScripts():

    for ruta, directorios, archivos in os.walk( 'scripts\mikk' ):

        for nombre_archivo in archivos:

            ruta_completa = os.path.join(ruta, nombre_archivo)

            yield ruta_completa
