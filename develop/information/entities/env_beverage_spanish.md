# env_beverage

Cuando es activada, Crea una deliciosa Coca-Cola u otros sabores de refrescos.

| Key | Descripción |
|-----|-------------|
| health | Cuantas latas de refrescos pueden ser creadas, no puede ser infinito pero puedes darle un valor muy alto |
| skin | skin del modelo que será utilizado en el refresco |
| model | agrega un modelo personalizado |
| weapons | Cuantos puntos de vida este refresco va a recuperar, vacio = 1 |

- Notas
	- Activando esta entidad mientras el refresco aun sigue en el origin del env_beverage termina en que no pasará nada.

- Comportamiento de [activación](triggering_system_english.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|------------|--------|
| Crea un refresco | Crea un refresco | Crea un refresco | Crea un refresco |  |  |