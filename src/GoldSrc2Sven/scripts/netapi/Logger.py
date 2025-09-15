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

from netapi.ConsoleColor import ConsoleColor;
from typing import Any, Optional;

class Logger:
	Name: str
	Color: ConsoleColor
	LogLevels: Any
	Level: Any
	IsLevelActive: bool
	trace: 'Logger'
	debug: 'Logger'
	info: 'Logger'
	warn: 'Logger'
	error: 'Logger'
	critical: 'Logger'
	def SetLogger( self, level: Any ) -> None:
		pass;
	def ClearLogger( self, level: Any ) -> None:
		pass;
	def ToggleLogger( self, level: Any ) -> None:
		pass;
	def Write( self, text: Optional[str], color: ConsoleColor = None ) -> 'Logger':
		pass;
	def Write( self, text: Optional[str], color: int ) -> 'Logger':
		pass;
	def WriteLine( self, text: Optional[str], color: ConsoleColor = None ) -> 'Logger':
		pass;
	def WriteLine( self, text: Optional[str], color: int ) -> 'Logger':
		pass;
	def NewLine( self ) -> 'Logger':
		pass;
	def Beep( self ) -> 'Logger':
		pass;
	def Pause( self ) -> 'Logger':
		pass;
	def Call( self, fnCallback: Any ) -> 'Logger':
		pass;
	def Exit( self, fnCallback: Optional[Any] ) -> None:
		pass;
