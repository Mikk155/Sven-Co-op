using Mikk.Logger;

public interface IProject
{
    /// <summary>
    /// Whatever this is required or the user can skip the project setup
    /// </summary>
    /// <returns></returns>
    public bool Required();

    /// <summary>
    /// Return true if the project is already set up
    /// </summary>
    public bool Exists();

    /// <summary>
    /// Called when the user selects the option. or if Required is true this is called when the program launch.
    /// </summary>
    public void Initialize( Logger log );

    /// <summary>
    /// Name of the project
    /// </summary>
    public string GetName();

    /// <summary>
    /// Description of the project
    /// </summary>
    public string GetHeader();
}
