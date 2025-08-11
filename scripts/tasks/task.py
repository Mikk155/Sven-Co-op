from shared.Asset import Asset;

class Task:

    def Run( self, assets: list[Asset] ) -> int:
        '''Called when the code-runner has finished. the return value is the exit code for the program.'''
        pass;

    def __init__(self) -> None:
        pass;
