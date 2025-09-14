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
	entity: Any
	def GetString( self, key: str ) -> str:
		'''Get a key's value in string form'''
		pass;
	def SetString( self, key: str, value: str ) -> None:
		'''Set a key's value in string form'''
		pass;
	def GetInteger( self, key: str ) -> int:
		'''Get a key's value in integer form'''
		pass;
	def SetInteger( self, key: str, value: int ) -> None:
		'''Set a key's value in integer form'''
		pass;
	def GetFloat( self, key: str ) -> float:
		'''Get a key's value in float form'''
		pass;
	def SetFloat( self, key: str, value: float ) -> None:
		'''Set a key's value in float form'''
		pass;
	def GetBool( self, key: str ) -> bool:
		'''Get a key's value in bool form (0/1)'''
		pass;
	def SetBool( self, key: str, value: bool ) -> None:
		'''Set a key's value in bool form (0/1)'''
		pass;
	def GetVector( self, key: str ) -> Vector:
		'''Get a key's value in Vector form (0/1)'''
		pass;
	def SetVector( self, key: str, value: Vector ) -> None:
		'''Set a key's value in Vector form (0/1)'''
		pass;
	def ToString( self ) -> str:
		'''Return the entity in the .ent format'''
		pass;
