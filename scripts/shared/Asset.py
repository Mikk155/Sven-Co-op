import os;
from utils.Path import Path;

class Asset:

    def __init__( self, path: str, PathSources, PathSvenCoop ) -> None:
    #
        self.paths: list[str] = path.split( "/" );
        self.PathSources = PathSources;
        self.PathSvenCoop = PathSvenCoop;
    #

    @property
    def Relative( self ) -> str:
    #
        return os.path.relpath( self.Source, self.PathSources );
    #

    @property
    def Source( self ) -> str:
    #
        return Path.enter( *self.paths, CurrentDir=self.PathSources, CreateIfNoExists=True, SupressWarning=True );
    #

    @property
    def Destination( self ) -> str:
    #
        return Path.enter( *self.paths, CurrentDir=self.PathSvenCoop, CreateIfNoExists=True, SupressWarning=True );
    #

    @property
    def IsValid( self ) -> bool:
    #
        return os.path.exists( self.Source );
    #
