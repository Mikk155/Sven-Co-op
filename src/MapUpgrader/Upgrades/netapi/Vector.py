from typing import Any

class Vector:
    x: float
    y: float
    z: float
    Item: float
    def ToString(self) -> str: ...
    def Equals(self, obj: Any) -> bool: ...
    def GetHashCode(self) -> int: ...
