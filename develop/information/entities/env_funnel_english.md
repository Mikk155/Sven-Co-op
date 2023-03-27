# env_funnel

env_funnel is an entity that upon activation it generates green particle effects being sucked from a distance in a circumference form towards the entity's point.

It can be seen in the test chamber from Half-Life.

This creates many temporal entities and nev_funnel is removed from the world after being used.

The particles will appear in a large area above the env_funnel and are going to be sucked towards the center, you can change the rotation effect by manipulating it's ``angles``

- If ``sprite`` is in use then it will use that sprite in addition to the green particles.

- Spawnflag 1 ``Reverse`` The particles will start from the entity and will spread outwards.

- Spawnflag 2 ``Reusable`` This entity will not be removed and can be used multiple times.
