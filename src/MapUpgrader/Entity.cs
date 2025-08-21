/// <summary>
/// Represents a entity in the BSP
/// </summary>
public class Entity
{
    /// <summary>
    /// Classname of the entity. if this is not a valid entity in the FGD the program will only warn.
    /// </summary>
    public string classname { get; set; }

    public Entity( string classname )
    {
        this.classname = classname;
    }

    /// <summary>
    /// Return the entity in the .ent format
    /// </summary>
    public override string ToString() => $"Entity({classname})";

    /// <summary>
    /// Return the entity converted into a json object
    /// </summary>
    public Dictionary<string, string> ToJson() => new Dictionary<string, string>();
}
