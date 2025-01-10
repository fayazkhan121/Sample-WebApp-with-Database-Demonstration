# This script adds a Project GUID to .csproj files for SonarCloud or SonarQube analysis.
# Required only for .NET Core .csproj projects. 
# .NET Framework already includes a Project GUID.

# Get all .csproj files recursively from the current directory
$csprojFiles = Get-ChildItem -Include *.csproj -Recurse

foreach ($file in $csprojFiles) {
    try {
        $path = $file.FullName
        Write-Output "Processing file: $path"

        # Load the .csproj file as an XML document
        $doc = New-Object System.Xml.XmlDocument
        $doc.Load($path)

        # Check if the ProjectGuid element already exists
        $existingGuid = $doc.SelectSingleNode("//Project/PropertyGroup/ProjectGuid")
        if ($existingGuid) {
            Write-Output "ProjectGuid already exists in $path. Skipping..."
            continue
        }

        # Create a new ProjectGuid element
        $newGuid = [guid]::NewGuid().ToString().ToUpper()
        $projectGuidElement = $doc.CreateElement("ProjectGuid")
        $projectGuidElement.InnerText = $newGuid

        # Find the PropertyGroup node to append the new element
        $propertyGroupNode = $doc.SelectSingleNode("//Project/PropertyGroup")
        if ($propertyGroupNode -ne $null) {
            $propertyGroupNode.AppendChild($projectGuidElement)
            $doc.Save($path)
            Write-Output "Added ProjectGuid ($newGuid) to $path"
        } else {
            Write-Output "No PropertyGroup node found in $path. Skipping..."
        }
    } catch {
        Write-Output "An error occurred while processing $path: $_"
    }
}

Write-Output "Script execution completed."
