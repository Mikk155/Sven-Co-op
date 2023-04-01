# env_bubbles

Una entidad solida que genera burbujas en una posición aleatoria dentro de esta misma.

- Las burbujas flotarán siempre hacia arriba sin importar si estan en agua o aire.

- Las burbujas solo desaparecen cuando golpean una superficie de agua o un solido.

- Las burbujas varian aleatoriamente en su tamaño y velocidad.

| Key | Descripción |
|-----|-------------|
| density | Cantidad de burbujas a crear por intervalos |
| frequency | Con que tanta frecuencia las burbujas especificadas por 'density' deben ser creadas por segundo, maximo de 20 |
| current | Especifica la velocidad horizontal de las burbujas, para simular que estan en una corriente, la direccion se especifica por la keyvalue 'angles' de la entidad. |
| spawnflag = 1 | Start Off, La entidad inicia apagada y no genera burbujas hasta que no sea activada |