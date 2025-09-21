using Mikk.Logger;

public class CloneRepository() : IProject
{
    public bool Required() => true;

    public string GetName() => "Repository";

    public string GetHeader() => string.Empty;

    public bool Exists() => LibGit2Sharp.Repository.IsValid( App.Github.GitDirectory );

    public void Initialize( Logger log )
    {
        log.info
            .Write( "Cloning " )
            .WriteLine( App.Github.Url, ConsoleColor.Green )
            .Write( "Into " )
            .WriteLine( App.Github.GitDirectory, ConsoleColor.Cyan );

        LibGit2Sharp.Repository.Clone(
            App.Github.Url,
            App.Github.GitDirectory,
            new LibGit2Sharp.CloneOptions {
                RecurseSubmodules = false
            }
        );
    }
}
