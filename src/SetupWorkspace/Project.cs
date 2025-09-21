public interface IProject
{
    /// <summary>
    /// Whatever this is required or the user can skip the project setup
    /// </summary>
    /// <returns></returns>
    public bool Required() => false;

    /// <summary>
    /// Called when the user selects the option. or if Required is true this is called when the program launch.
    /// </summary>
    public void Initialize( Mikk.Logger.Logger log );

    /// <summary>
    /// Called when the program is shutting down or this project is been already setup
    /// </summary>
    public void Shutdown( Mikk.Logger.Logger log ) { }

    /// <summary>
    /// Name of the project
    /// </summary>
    public string GetName();

    /// <summary>
    /// Description of the project
    /// </summary>
    public string GetHeader();
}
