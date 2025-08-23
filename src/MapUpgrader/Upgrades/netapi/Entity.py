from typing import Any

class Entity:
	EntIndex: int
	'''Represents the current index of this entity in the BSP entity data'''
	classname: str
	'''Classname of the entity. if this is not a valid entity in the FGD the program will only warn.'''
	def GetString(self, key: str) -> str: '''Get a key's value in string form'''
	def SetString(self, key: str, value: str) -> None: '''Set a key's value in string form'''
	def GetInteger(self, key: str) -> int: '''Get a key's value in integer form'''
	def SetInteger(self, key: str, value: int) -> None: '''Set a key's value in integer form'''
	def GetFloat(self, key: str) -> float: '''Get a key's value in float form'''
	def SetFloat(self, key: str, value: float) -> None: '''Set a key's value in float form'''
	def GetBool(self, key: str) -> bool: '''Get a key's value in bool form (0/1)'''
	def SetBool(self, key: str, value: bool) -> None: '''Set a key's value in bool form (0/1)'''
	def GetVector(self, key: str) -> Any: '''Get a key's value in bool form (0/1)'''
	def SetVector(self, key: str, value: Any) -> None: '''Set a key's value in bool form (0/1)'''
	def ToString(self) -> str: '''Return the entity in the .ent format'''
