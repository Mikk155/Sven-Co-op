# env_funnel

env_funnel es una entidad que al activarse genera unas particulas de efectos verdes siendo succionadas desdde una distancia en redonda hacia el punto de la entidad.

Pueden ser vistos en la camara de pruebas de Half-Life.

Esto crea varias entidades temporales y env_funnel es removido de el mundo luego de usarlo.

Las particulas van a aparecer en un area larga por encima de env_funnel y serán succionadas hacia el centro, puedes cambiar la rotación del efecto manipulando su ``angles``

- ``sprite`` si esta en uso se utilizaran estos sprites ademas de las particulas verdes.

- Spawnflag 1 ``Reverse`` Las particulas iniciarán desde la entidad y se exparsen hacia afuera.

- Spawnflag 2 ``Reusable`` Esta entidad no será removida y puede usarse multiples veces.