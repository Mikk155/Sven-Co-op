from typing import Any

class Vector:

	x: float
	'''X position [0]'''
	y: float
	'''Y position [1]'''
	z: float
	'''Z position [2]'''
	vecZero: Any
	'''Get a Vector whose all values are zero'''
	def ToString(self) -> str:
		'''Return a string representing the x y z separated by a single space'''
