<#
.SYNOPSIS
Shows a list of locally installed Assetto Corsa Car and Track mods

.DESCRIPTION
Script looks for a text file called "mod.txt" in the root of the mod folder, the text file contains specific information such as version number, comments and a URL to Race Department.
The list produced contains information from the local mod.txt file as well as information from the Race Department website if the check_updates parameter is provided.
All parameters can be supplied in the command line.

.PARAMETER modtype
MANDITORY, sets the script to look for car or track mods.  Accepted inputs are Car, Cars, Track or Tracks

.PARAMETER check_updates
Checks Race Department URL located in mod.txt file and retrieves the latest version and last updated date for installed mods

.PARAMETER modname
Checks only installed mods with the supplied name
                 
.EXAMPLE
./something.ps1 -modtype car
Locates all car mods installed locally and displays the information from the mod.txt file

.EXAMPLE
./something.ps1 -modtype car -modname <modname>
Locates any car mods installed locally with a name similar to that specified and displays the information from the mod.txt file.  Wildcards already included in the script.

.EXAMPLE
./something.ps1 -modtype car -check_updates
Locates all car mods installed locally and displays the information from the mod.txt file as well as retrieving the latest version and last updated dates from Race Department.  The local mod.txt file is updated with the latest information.

.EXAMPLE
./something.ps1 -modtype car -modname <modname> -check_updates
Locates any mods installed locally with a name similar to that specified and displays the information from the mod.txt file as well as retrieving the latest version and last updated dates from Race Department.  The local mod.txt file is updated with the latest information.


.NOTES
Title: Assetto Corsa Mod Tracker 
Usage: Powershell v5
Author: Dave Parkinson                              
Date Modified: 20/02/2017        
Changes: 1.0 - Initial Script Creation

#>

    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$modtype,
        [string]$modname,
        [switch]$check_updates
        
    )



function installed_mods {



    $table = @()

    if ($modtype -eq "cars" -or $modtype -eq "car") {

        #Path of car mods
        $path="F:\SteamLibrary\steamapps\Common\assettocorsa\content\cars"

    }
    elseif ($modtype -eq "tracks" -or $modtype -eq "track") {

        #Path of track mods
        $path="F:\SteamLibrary\steamapps\Common\assettocorsa\content\tracks"
    }

    if ($modname -ne "") {

        #Get only Directory Names specified in the param that contain mod.txt file
        $files = Get-ChildItem $path -filter "mod.txt" -recurse | where {$_.DirectoryName -like "*$modname*"}

    }
    else {
        
        #Get all Directory Names that contain mod.txt file
        $files = Get-ChildItem $path -filter "mod.txt" -recurse


    }

ForEach ($file in $files) {

        $dirname = $file.directory.name

        $content = (Get-Content -path $path\$dirname\$file).split(":")

        $version = $content[1].trim()
        $comment = $content[3].trim()

        if ($content[6] -like "*racedepartment*") {
            $url = "http:"+$content[6]
        }
        else {
            $url = ""
        }

        $rd_version = $content[8].trim()
        $rd_last_updated = $content[10].trim()
        $last_update_check = $content[12].trim()+":"+$content[13]+":"+$content[14]

        if ($check_updates) {

            if ($url -ne "") {
                $webresponse = invoke-webrequest -uri $url
                $rd_version = ($WebResponse.AllElements | where {$_.TagName -eq "span" -and $_.class -eq "muted"}).innerText[0]
                $rd_last_updated = ($WebResponse.AllElements | where {$_.TagName -eq "dl" -and $_.class -eq "lastUpdate"}).innerText.substring(12)
                $last_update_check = Get-Date
            }
            
        }


        $hash = New-Object PSObject
        $hash | Add-Member -Type NoteProperty -name "Name" -Value $dirname
        $hash | Add-Member -Type NoteProperty -name "Local Version" -Value $version
        $hash | Add-Member -Type NoteProperty -name "Comment" -Value $comment
        $hash | Add-Member -Type NoteProperty -name "RD URL" -Value $url
        $hash | Add-Member -Type NoteProperty -name "RD Version" -Value $rd_version
        $hash | Add-Member -Type NoteProperty -name "RD Last Updated" -Value $rd_last_updated
        $hash | Add-Member -Type NoteProperty -name "Last Update Check" -Value $last_update_check

        $hash_to_mod_file=@(
        "version: $version"
        "comment: $comment"
        "url: $url"
        "RD Version: $rd_version"
        "RD Last Updated: $rd_last_updated"
        "Last Update Check: $last_update_check") | Out-File $path\$dirname\$file
        
        $table += $hash

        $version = ""
        $comment = ""
        $webresponse = ""
        $url = ""
        $rd_version = ""
        $rd_last_updated = ""
        $last_update_check = ""

                    
    }

    $table | ft -AutoSize
    
}


installed_mods
