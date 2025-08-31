#pragma warning disable IDE1006 // Naming Styles
/// <summary>Represents a context for upgrading</summary>
public class UpgradeContext()
{
    /// <summary>
    /// Title to display as an option
    /// </summary>
    public required string Name { get; set; }

    /// <summary>
    /// Description to display as an option
    /// </summary>
    public required string Description { get; set; }

    /// <summary>
    /// Mod folder to install assets
    /// </summary>
    public required string Mod { get; set; }

    /// <summary>
    /// Mod download URL or multiple url for mirroring
    /// </summary>
    public required string[] urls { get; set; }

    /// <summary>
    /// Maps to upgrade. Leave empty to upgrade all maps
    /// </summary>
    public string[]? maps { get; set; }
}
#pragma warning restore IDE1006 // Naming Styles
