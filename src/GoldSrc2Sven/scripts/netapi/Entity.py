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

from netapi.Vector import Vector;
from typing import Any, Optional;

class Entity:
	keyvalues: dict[str, str]
	def GetString( self, key: str ) -> str:
		pass;
	def SetString( self, key: str, value: str ) -> None:
		pass;
	def GetInteger( self, key: str ) -> int:
		pass;
	def SetInteger( self, key: str, value: int ) -> None:
		pass;
	def GetFloat( self, key: str ) -> float:
		pass;
	def SetFloat( self, key: str, value: float ) -> None:
		pass;
	def GetBool( self, key: str ) -> bool:
		pass;
	def SetBool( self, key: str, value: bool ) -> None:
		pass;
	def GetVector( self, key: str ) -> Vector:
		pass;
	def HasFlag( self, key: str, flag: int ) -> bool:
		pass;
	def ClearFlag( self, key: str, flag: int ) -> None:
		pass;
	def SetFlag( self, key: str, flag: int ) -> None:
		pass;
	def SetVector( self, key: str, value: Vector ) -> None:
		pass;
	def ToString( self ) -> str:
		pass;
