from typing import Any

class UpgradeContext:

	Name: str
	'''The script filename without extension for this upgrade.'''
	description: str
	'''Optional description to display as an option.'''
	maps: Any
	'''Maps to upgrade. Leave empty to upgrade all maps.'''
