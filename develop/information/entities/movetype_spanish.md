### movetype

| Valor | Codigo | Descripción |
|-------|--------|-------------|
| -1 | MOVETYPE_NONE_EXPLICIT | Jamas será movido |
| 0 | MOVETYPE_NONE | Tendrá gravedad |
| 3 | MOVETYPE_WALK | Tendrá gravedad y se moverá por el mundo (Jugadores solamente) |
| 4 | MOVETYPE_STEP | Tendrá gravedad y se moverá por el mundo (NPCS) |
| 5 | MOVETYPE_FLY | No tendrá gravedad pero aun colisióna con otros objetos |
| 6 | MOVETYPE_TOSS | Tendrá gravedad, Tendra colisión |
| 7 | MOVETYPE_PUSH | No tendrá colisión con el mundo, empujará y aplastará (trenes, puertas) |
| 8 | MOVETYPE_NOCLIP | No tendrá gravedad, No colisióna, pero aun tiene velocity/avelocity |
| 9 | MOVETYPE_FLYMISSILE | No tendrá gravedad pero aun colisióna con otros objetos |
| 10 | MOVETYPE_BOUNCE | Tendrá gravedad, Tendra colisión, reflejará velocidad cuando colisióne |
| 11 | MOVETYPE_BOUNCEMISSILE | Rebota con gravedad |
| 12 | MOVETYPE_FOLLOW | Movimiento pre definido (trenes) |
| 13 | MOVETYPE_PUSHSTEP | Colisión fisica del mundo o un modelo BSP |