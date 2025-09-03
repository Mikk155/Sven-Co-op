from typing import Any

class UpgradeContext:

	def __init__( self ):
		self.Title = None;
		self.Description = None;
		self.maps = None;

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
	urls: Any
	'''Mod download URL or multiple url for mirroring. This is required.'''
	maps: Any
	'''Maps to upgrade. Leave empty to upgrade all maps.'''
