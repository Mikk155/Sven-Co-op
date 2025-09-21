using Mikk.Logger;

public class CloneRepository() : IProject
{
    public bool Required() => true;

    public string GetName() => "Repository";

    public string GetHeader() => string.Empty;

    public bool Exists() => false;

    public void Initialize( Mikk.Logger.Logger log )
    {
        log.info.Write( "Initialized " )
            .Write( this.GetName(), ConsoleColor.Green )
            .NewLine();
    }
}
