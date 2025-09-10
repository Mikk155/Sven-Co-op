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

class Vector3:

	E: Any
	Epsilon: Any
	NaN: Any
	NegativeInfinity: Any
	NegativeZero: Any
	One: Any
	Pi: Any
	PositiveInfinity: Any
	Tau: Any
	UnitX: Any
	UnitY: Any
	UnitZ: Any
	Zero: Any
	Item: float
	def CopyTo( self, array: Any ) -> None:
		pass;
	def CopyTo( self, array: Any, index: int ) -> None:
		pass;
	def CopyTo( self, destination: Any ) -> None:
		pass;
	def TryCopyTo( self, destination: Any ) -> bool:
		pass;
	def Equals( self, obj: Any ) -> bool:
		pass;
	def Equals( self, other: Any ) -> bool:
		pass;
	def GetHashCode( self ) -> int:
		pass;
	def Length( self ) -> float:
		pass;
	def LengthSquared( self ) -> float:
		pass;
	def ToString( self ) -> str:
		pass;
	def ToString( self, format: str ) -> str:
		pass;
	def ToString( self, format: str, formatProvider: Any ) -> str:
		pass;
