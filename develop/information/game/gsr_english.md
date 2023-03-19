### Global Sound Replacemet

Global Sound replacemet es una forma de reemplazar algunos sonidos por otros.

al utilizar el cvar ``globalsoundlist`` el valor de este es la ruta a tu archivo GSR, Debes tener en cuenta que la ruta inicial ya esta pre escrita.

La ruta relativa es ``svencoop%/sound/nombre del mapa acutal/nombre del mapa actual.gsr``

Al utilizar el cvar, nosotros simplemente cambiariamos el nombre del archivo GSR, por lo tanto seguimos dentro de las mismas carpetas.

Ejemplo:
```
globalsoundlist ../mikk/soundlist.gsr
```
la ruta especificada seria ``svencoop%/sound/mikk/soundlist.gsr``

El archivo GSR contendrá dentro lo siguiente
```angelscript
"aslave/slv_alert1.wav" "hungerslave/slv_alert1.wav"
"aslave/slv_alert3.wav" "hungerslave/slv_alert3.wav"
"aslave/slv_alert4.wav" "hungerslave/slv_alert4.wav"
"aslave/slv_die1.wav" "hungerslave/slv_die1.wav"
"aslave/slv_die2.wav" "hungerslave/slv_die2.wav"
"aslave/slv_pain1.wav" "hungerslave/slv_pain1.wav"
"aslave/slv_pain2.wav" "hungerslave/slv_pain2.wav"
"aslave/slv_word1.wav" "hungerslave/slv_word1.wav"
"aslave/slv_word2.wav" "hungerslave/slv_word2.wav"
"aslave/slv_word3.wav" "hungerslave/slv_word3.wav"
"aslave/slv_word4.wav" "hungerslave/slv_word4.wav"
"aslave/slv_word5.wav" "hungerslave/slv_word5.wav"
"aslave/slv_word6.wav" "hungerslave/slv_word6.wav"
"aslave/slv_word7.wav" "hungerslave/slv_word7.wav"
"aslave/slv_word8.wav" "hungerslave/slv_word8.wav"
"!SLV_IDLE0" "hungerslave/slv_word1.wav"
"!SLV_ALERT0" "hungerslave/slv_alert1.wav"
"!SLV_ALERT3" "hungerslave/slv_word2.wav"
```
De esta forma, los sonidos ( y sentencias ) especificados a la izquierda, serán reemplazados por los de la derecha.

Lista de sonidos irremplazables: [unreplaceable_sounds](../issues/unreplaceable_sounds_spanish.md)