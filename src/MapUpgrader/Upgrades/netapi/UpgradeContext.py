from typing import Any

class UpgradeContext:
	Name: str
	'''Title to display as an option'''
	Description: str
	'''Description to display as an option'''
	Mod: str
	'''Mod folder to install assets'''
	urls: list[str]
	'''Mod download URL or multiple url for mirroring'''
	maps: list[str]
	'''Maps to upgrade. Leave empty to upgrade all maps'''
