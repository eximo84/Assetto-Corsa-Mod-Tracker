<#
.SYNOPSIS
Shows a list of locally installed Assetto Corsa Car and Track mods

.DESCRIPTION
Script looks for a text file called "mod.txt" in the root of the mod folder, the text file contains specific information such as version number, comments and a URL to Race Department.
The list produced contains information from the local mod.txt file as well as information from the Race Department website if the check_updates parameter is provided.
All parameters can be supplied in the command line.

.PARAMETER check_updates
Checks Race Department URL located in mod.txt file and retrieves the latest version and last updated date for installed mods

.PARAMETER modname
Checks only installed mods with the supplied name
                 
.EXAMPLE
./something.ps1
Locates any mods installed locally and displays the local information

.EXAMPLE
./something.ps1 -modname <modname>
Locates any mods installed with a name similar to that specified, might return more than one entry.  Wildcards already included in the script.

.EXAMPLE
./something.ps1 -check_updates
Locates any mods installed locally and displays the local information as well as the latest version and last updated dates from Race Department.

.EXAMPLE
./something.ps1 -modname <modname> -check_updates
Locates any mods installed with a name similar to that specified as well as the latest version and last updated dates from Race Department.


.NOTES
Title: Something 
Usage: Powershell v5
Author: Dave Parkinson                              
Date Modified:        
Changes: 1.0 - Initial Script Creation

#>


Param(
  [switch]$check_updates,
  [string]$modname,
  [string]$modtype
)

function installed_mods {

    $table = @()

    if ($modtype -eq "cars" -or "car") {

        #Path of car mods
        $path="D:\TEMP\mods\cars"

    }
    elseif ($modtype -eq "tracks" -or "track") {

        #Path of track mods
        $path="D:\TEMP\mods\tracks"

    }
    else {

        #Path of car and track mods
        $path="D:\TEMP\mods\cars"
        $path2="D:\TEMP\mods\tracks"
        $searchallmods=1

    }


    if ($modname -ne "") {

        if ($searchallmods) {

            #Get only Directory Names specified in the param that contain mod.txt file
            $files = Get-ChildItem $path, $path2 -filter "mod.txt" -recurse | where {$_.DirectoryName -like "*$name*"}

        }
        else {

            #Get only Directory Names specified in the param that contain mod.txt file
            $files = Get-ChildItem $path -filter "mod.txt" -recurse | where {$_.DirectoryName -like "*$name*"}

        }
    }
    else {
        
        if ($searchallmods) {

            #Get all Directory Names that contain mod.txt file
            $files = Get-ChildItem $path, $path2 -filter "mod.txt" -recurse
        }
        else {
            #Get all Directory Names that contain mod.txt file
            $files = Get-ChildItem $path -filter "mod.txt" -recurse
        }

    }

    ForEach ($file in $files) {

        $dirname = $file.directory.name

        $content = (Get-Content -path $path\$dirname\$file).split(":")

        $version = $content[1].trim()
        $comment = $content[3].trim()

        if ($content[6]) {
            $url = "http:"+$content[6]
        }
        else {
            $url = ""
        }

        if ($check_updates) {

            if ($url) {
                $webresponse = invoke-webrequest -uri $url
                $availableversion = ($WebResponse.AllElements | where {$_.TagName -eq "span" -and $_.class -eq "muted"}).innerText[0]
                $lastupdated = ($WebResponse.AllElements | where {$_.TagName -eq "dl" -and $_.class -eq "lastUpdate"}).innerText.substring(12)
            }

        }
        else {
            $webresponse = ""
            $availableversion = ""
            $lastupdated = ""
        }

        $hash = New-Object PSObject
        $hash | Add-Member -Type NoteProperty -name "Name" -Value $dirname
        $hash | Add-Member -Type NoteProperty -name "Local Version" -Value $version
        $hash | Add-Member -Type NoteProperty -name "Comment" -Value $comment
        $hash | Add-Member -Type NoteProperty -name "RD URL" -Value $url
        $hash | Add-Member -Type NoteProperty -name "RD Version" -Value $availableversion
        $hash | Add-Member -Type NoteProperty -name "RD Last Updated" -Value $lastupdated

        $table += $hash

        $version = ""
        $comment = ""
        $webresponse = ""
        $availableversion = ""
        $lastupdated = ""

                    
    }

    $table | ft -AutoSize
    
}


installed_mods
