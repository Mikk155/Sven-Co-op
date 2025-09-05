from typing import Any

class UpgradeContext:

	Name: str
	'''The script filename without extension for this upgrade.'''
	description: str
	'''Optional description to display as an option.'''
	maps: Any
	'''Maps to upgrade. Leave empty to upgrade all maps.'''
	def GetModPath(self) -> str:
		'''Get the mod's installation absolute path'''
	def GetMaps(self) -> Any:
		'''Get the list of defined maps or all the maps in the mod installation if the script left it empty.'''
	def SteamInstallation(self) -> str:
		'''Get the absolute path to a Steam installation'''
	def GetHalfLifeInstallation(self) -> str:
		'''Get the path to the Half-Life installation'''
