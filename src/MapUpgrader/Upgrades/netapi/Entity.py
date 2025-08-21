from typing import Any

class Entity:
	classname: str
	'''Classname of the entity. if this is not a valid entity in the FGD the program will only warn.'''
	def ToString(self) -> str: '''Return the entity in the .ent format'''
	def ToJson(self) -> Any: '''Return the entity converted into a json object'''
