from typing import Any

class UpgradeContext:

	Name: str
	'''The script filename without extension for this upgrade.'''
	Title: str
	'''Title to display as an option.'''
	Description: str
	'''Description to display as an option.'''
	Mod: str
	'''Mod folder to install assets. This is required.'''
	urls: Any
	'''Mod download URL or multiple url for mirroring. This is required.'''
	maps: Any
	'''Maps to upgrade. Leave empty to upgrade all maps.'''
