from typing import Any

class UpgradeContext:
	@property
	def Serialize( self ) -> str:
		import json;
		return json.dumps( {
			"title": self.Title,
			"description": self.Description,
			"mod": self.Mod,
			"urls": self.urls,
			"maps": self.maps
		} );
	Name: str
	'''The script filename without extension for this upgrade.'''
	Title: str
	'''Title to display as an option.'''
	Description: str
	'''Description to display as an option.'''
	Mod: str
	'''Mod folder to install assets. This is required.'''
	urls: list[str]
	'''Mod download URL or multiple url for mirroring. This is required.'''
	maps: list[str]
	'''Maps to upgrade. Leave empty to upgrade all maps.'''
