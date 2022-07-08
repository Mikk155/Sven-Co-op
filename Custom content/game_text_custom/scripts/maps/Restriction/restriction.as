#include "../point_checkpoint"
#include "controller"
#include "../multi_language/multi_language"

void MapInit()
{
	RegisterPointCheckPointEntity();
	ControllerMapInit();
	MultiLanguageInit();
}

void MapActivate()
{
	MultiLanguageActivate();
}