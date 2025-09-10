'''
MIT License

Copyright (c) 2025 Mikk155

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''

from typing import Any, Optional;

class UpgradeContext:
	'''Represents a context for upgrading'''

	Name: str
	'''The script filename without extension for this upgrade.'''
	description: str
	'''Optional description to display as an option.'''
	maps: list[str]
	'''Maps to upgrade. Leave empty to upgrade all maps.'''
	def GetModPath( self ) -> str:
		'''Get the mod's installation absolute path'''
		pass;
	def GetMaps( self ) -> list[str]:
		'''Get the list of defined maps or all the maps in the mod installation if the script left it empty.'''
		pass;
	def SteamInstallation( self ) -> str:
		'''Get the absolute path to a Steam installation'''
		pass;
	def GetHalfLifeInstallation( self ) -> str:
		'''Get the path to the Half-Life installation'''
		pass;
