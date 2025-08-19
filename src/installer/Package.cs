/**
*    MIT License
*
*    Copyright (c) 2025 Mikk155
*
*    Permission is hereby granted, free of charge, to any person obtaining a copy
*    of this software and associated documentation files (the "Software"), to deal
*    in the Software without restriction, including without limitation the rights
*    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*    copies of the Software, and to permit persons to whom the Software is
*    furnished to do so, subject to the following conditions:
*
*    The above copyright notice and this permission notice shall be included in all
*    copies or substantial portions of the Software.
*
*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*    SOFTWARE.
**/

using Newtonsoft.Json.Linq;

internal class Project( string Name, string Title, string Description, string AssetFile )
{
    public readonly string Name = Name;
    public readonly string Title = Title;
    public readonly string Description = Description;
    public readonly string AssetFile = AssetFile;
}

internal class Package( string Name, string Description, List<Project> Projects )
{
    public readonly string Name = Name;
    public readonly string Description = Description;
    public readonly List<Project> Projects = Projects;
}

internal class Category
{
    /// <summary>
    /// Current version on the repository's package
    /// </summary>
    public readonly Version version;

    /// <summary>
    /// Package containing installable angelscript server plugins
    /// </summary>
    public readonly Package Plugins;
    public readonly Package MapScripts;
    public readonly Package Tools;
    public readonly Package UtilityScripts;

#pragma warning disable CS8602, CS8600

    /// <summary>
    /// Format a JToken into a list of Project
    /// </summary>
    private Package GetPackages( JToken? token )
    {
        List<Project> ProjectsInJson = new List<Project>();

        foreach( KeyValuePair<string, JToken?> project in (JObject)token[ "projects" ] )
        {
            ProjectsInJson.Add( new Project(
                Name: project.Key.ToString(),
                Title: project.Value["name"].ToString(),
                Description: project.Value["description"]?.ToString() ?? "",
                AssetFile: project.Value["assets"].ToString()
            ) );
        }

        return new Package( token["name"].ToString(), token["description"].ToString(), ProjectsInJson );
    }

    public Category( JObject? package )
    {
        JArray semantic = (JArray)package.GetValue( "version" );
        version = new Version( (uint)semantic[0], (uint)semantic[1], (uint)semantic[2] );

        Plugins = GetPackages( package.GetValue( "plugins" ) );
        MapScripts = GetPackages( package.GetValue( "map.scripts" ) );
        Tools = GetPackages( package.GetValue( "tools" ) );
        UtilityScripts = GetPackages( package.GetValue( "scripting" ) );
    }
#pragma warning restore CS8602, CS8600
}
