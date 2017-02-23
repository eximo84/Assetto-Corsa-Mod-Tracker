<#
.SYNOPSIS
Shows a list of locally installed Assetto Corsa Car and Track mods

.DESCRIPTION
Script looks for a text file called "mod.txt" in the root of the mod folder, the text file contains specific information such as version number, comments and a URL to Race Department.
The list produced contains information from the local mod.txt file as well as information from the Race Department website if the check_updates parameter is provided.
All parameters can be supplied in the command line.

For more information and examples see: https://github.com/eximo84/Assetto-Corsa-Mod-Tracker

.NOTES
Title: Assetto Corsa Mod Tracker 
Usage: Powershell v5
Author: Dave Parkinson                              
Date Modified: 22/02/2017        
Changes: 0.1 - Initial Script Creation - Looks for mod.txt file in specified folder and shows output in a table
         0.2 - Script scrapes RD URL for Version and Last Updated date, scraped data added to table output
         0.3 - Moved script into a function called Get-ACMod, created initial parameters
         0.4 - Created New-ACMod function, this creates mod.txt folder in specified directory
         0.5 - New Params for better usability of the script, error handling on mod.txt file being invalid.  Output default to grid window, this looks better.  Option to export to csv via param.
         0.5.1 - Added $export_path variable, this is used when exporting the file to csv.  Can be set by user at a global level.
         0.6 - Added 1 hour limit to checking Race Department website, shows local mod.txt informaiton if last checked date is less than 1 hour from the current date.  New param -override_check_limit to override this 1 hour limit.
         0.6.1 - Bugfix #17 - Content Path incorrect
         0.7 - Created Set-ACMod function, this updates existing mod.txt files.  New-ACmod function only creates mod.txt files if they dont already exist.  Created helper functions for repeated tasks.  Added some error handling around reading the existing mod.txt files.
#>


#Set this to your Assetto Corsa installation path
$ac_install_path=""

#Set this to your desired output location, default is my documents
$export_path="$env:USERPROFILE\Documents"

#helper functions
function install_path_validation {

    if ($ac_install_path -eq "") {

        write-host `n"Assetto Corsa install path not configured in module, please close PowerShell and fix this error before importing the module" -ForegroundColor Red
        break

    }

}

function content_track {

    #Path of track mods
    $global:contentpath="$ac_install_path\content\tracks"
    $global:modtype="Track"

}

function content_car {

    #Path of car mods
    $global:contentpath="$ac_install_path\content\cars"
    $global:modtype="Car"

}

function output_modfile {

    try {

        $hash_to_mod_file=@(
        "version=$version"
        "comment=$comment"
        "url=$url"
        "RD Version=$rd_version"
        "RD Last Updated=$rd_last_updated"
        "Last Update Check=$last_update_check") | Out-File $contentpath\$dirname\$file

    }
    catch {

        write-host "error outputting data into file"

    }

}

################################

#main functions
function Get-ACMod {

    Param(

        [Parameter(ParameterSetName='trackall',Mandatory=$true,Position=0)][Parameter(ParameterSetName='trackname',Mandatory=$true,Position=0)][switch]$track,
        [Parameter(ParameterSetName='carall',Mandatory=$true,Position=0)][Parameter(ParameterSetName='carname',Mandatory=$true,Position=0)][switch]$car,
        [Parameter(ParameterSetName='trackall',Mandatory=$true,Position=1)][Parameter(ParameterSetName='carall',Mandatory=$true,Position=1)][switch]$all,
        [Parameter(ParameterSetName='trackname',Mandatory=$true,Position=1)][Parameter(ParameterSetName='carname',Mandatory=$true,Position=1)][string]$name,
        [Parameter(ParameterSetName='trackall')][Parameter(ParameterSetName='carall')][Parameter(ParameterSetName='trackname')][Parameter(ParameterSetName='carname')][switch]$check_updates,
        [Parameter(ParameterSetName='trackall')][Parameter(ParameterSetName='carall')][Parameter(ParameterSetName='trackname')][Parameter(ParameterSetName='carname')][switch]$override_check_limit,
        [Parameter(ParameterSetName='trackall')][Parameter(ParameterSetName='carall')][Parameter(ParameterSetName='trackname')][Parameter(ParameterSetName='carname')][switch]$export      

    )

    install_path_validation

    $table = @()

    if ($track -eq $true) {

        content_track

    }
    
    if ($car -eq $true) {

        content_car

    }

    if ($name -ne "") {

        #Get only Directory Names specified in the param that contain mod.txt file
        $files = Get-ChildItem $contentpath -filter "mod.txt" -recurse | where {$_.DirectoryName -like "*$name*"}

    }

    if ($all -eq $true) {
        
        #Get all Directory Names that contain mod.txt file
        $files = Get-ChildItem $contentpath -filter "mod.txt" -recurse

    }

ForEach ($global:file in $files) {

        $global:dirname = $file.directory.name

        $global:content = (Get-Content -path $contentpath\$dirname\$file).split("=")

        try {

            $global:version = $content[1]
            $global:comment = $content[3]

            if ($content[5] -like "*racedepartment*") {

                $global:url = $content[5]

            }

            else {

                $global:url = ""

            }

            $global:rd_version = $content[7]
            $global:rd_last_updated = $content[9]
            $global:last_update_check = $content[11]

        }

        catch {
        
            write-host `n"Invalid $modtype mod.txt found in mod directory $contentpath\$dirname, no information will be shown for this mod." -ForegroundColor Red
            break

        }
       
        if ($check_updates) {

            if (($last_update_check -eq "") -or ([datetime]$last_update_check -lt (get-date).AddHours(-1)) -or ($override_check_limit -eq $true)) {

                if ($url -ne "") {

                    write-host `n"Checking Race Deparment for changes..."
                    $webresponse = invoke-webrequest -uri $url
                    $global:rd_version = ($WebResponse.AllElements | where {$_.TagName -eq "span" -and $_.class -eq "muted"}).innerText[0]
                    $global:rd_last_updated = ($WebResponse.AllElements | where {$_.TagName -eq "dl" -and $_.class -eq "lastUpdate"}).innerText.substring(12)
                    $global:last_update_check = Get-Date

                }

            }
            else {

                write-host `n"Last Update Check for $modtype mod $dirname was at $last_update_check, this is less than the 1 hour limit. Displaying local mod.txt information for this mod, to force an update from Race Department use -override_check_limit parameter." -ForegroundColor Yellow

            }
                        
        }

        if ($version -ne $rd_version) {

            $version_mismatch = $true

        }
        else {

            $version_mismatch = $false
        }


        $hash = New-Object PSObject
        $hash | Add-Member -Type NoteProperty -name "Name" -Value $dirname
        $hash | Add-Member -Type NoteProperty -name "Local Version" -Value $version
        $hash | Add-Member -Type NoteProperty -name "RD Version" -Value $rd_version
        $hash | Add-Member -Type NoteProperty -name "Version Mismatch" -Value $version_mismatch
        $hash | Add-Member -Type NoteProperty -name "RD Last Updated" -Value $rd_last_updated 
        $hash | Add-Member -Type NoteProperty -name "Comment" -Value $comment
        $hash | Add-Member -Type NoteProperty -name "RD URL" -Value $url
        $hash | Add-Member -Type NoteProperty -name "Last Update Check" -Value $last_update_check

        output_modfile
        
        $table += $hash

#        $version = ""
#        $comment = ""
#        $webresponse = ""
#        $url = ""
#        $rd_version = ""
#        $rd_last_updated = ""
#        $last_update_check = ""

                    
    }

    $table | Out-GridView -Title "Assetto Corsa $modtype Mods"

    if ($export -eq $true) {

        try {

            $table | Export-Csv $export_path\AC-Mods-Export.csv -notype
            write-host `n"Exported values to $export_path\AC-Mods-Export.csv" -ForegroundColor Green
        }
        catch {

            write-host `n"$_.Exception.Message" -ForegroundColor Red

        }

    }
    
}

function New-ACMod {

    Param(

        [Parameter(ParameterSetName='track',Mandatory=$true,Position=0)][switch]$track,
        [Parameter(ParameterSetName='car',Mandatory=$true,Position=0)][switch]$car,
        [Parameter(ParameterSetName='track',Mandatory=$true,Position=1)][Parameter(ParameterSetName='car',Mandatory=$true,Position=1)][string]$name,
        [Parameter(ParameterSetName='track')][Parameter(ParameterSetName='car')][string]$version,
        [Parameter(ParameterSetName='track')][Parameter(ParameterSetName='car')][string]$comment,
        [Parameter(ParameterSetName='track')][Parameter(ParameterSetName='car')][string][string]$url
               
    )

    install_path_validation

    if ($track -eq $true) {

        content_track

    }
    
    if ($car -eq $true) {

        content_car

    }
    
    #Get only Directory Names specified in the param that contain mod.txt file
    $directories = Get-ChildItem $contentpath -Directory | where {$_.Name -like "*$name*"}
   
    if ($directories.count -lt 1) {
    
        write-host `n"Unable to find any directories with the name $name"
    
    }
    elseif ($directories.count -eq 1) {

        $modfile = Get-ChildItem $directories.FullName -filter "mod.txt" -recurse

        if ($modfile) {

            write-host `n"mod.txt file already exists in mod directory $directories.FullName" -ForegroundColor Yellow

        }
        else {

            $title = 'Create Mod File'
            $prompt = 'Found directory called ' + $directories.Name +', do you want to create mod.txt file here, [Y]es or [N]o?'
            $promptyes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes','Creates the mod.txt'
            $promptno = New-Object System.Management.Automation.Host.ChoiceDescription '&No','Doesnt create mod.txt'
            $options = [System.Management.Automation.Host.ChoiceDescription[]] ($promptyes,$promptno)
            $choice = $host.ui.PromptForChoice($title,$prompt,$options,0)

        }

    }
    elseif ($directories.count -gt 1) {

        write-host `n"Found more than one directory with the name $name"

        $directories.Name

    }


    if ($choice -eq 0) {

        $new_mod_file=@(
        "version=$version"
        "comment=$comment"
        "url=$url"
        "RD Version="
        "RD Last Updated="
        "Last Update Check=") | Out-File $contentpath\$directories\mod.txt

    }

}

function Set-ACMod {

    Param(

        [Parameter(ParameterSetName='track',Mandatory=$true,Position=0)][switch]$track,
        [Parameter(ParameterSetName='car',Mandatory=$true,Position=0)][switch]$car,
        [Parameter(ParameterSetName='track',Mandatory=$true,Position=1)][Parameter(ParameterSetName='car',Mandatory=$true,Position=1)][string]$name,
        [Parameter(ParameterSetName='track')][Parameter(ParameterSetName='car')][string]$version,
        [Parameter(ParameterSetName='track')][Parameter(ParameterSetName='car')][string]$comment,
        [Parameter(ParameterSetName='track')][Parameter(ParameterSetName='car')][string]$url
               
    )

    install_path_validation

    if ($track -eq $true) {

        content_track

    }
    
    if ($car -eq $true) {

        content_car

    }

    #Get only Directory Names specified in the param that contain mod.txt file
    $directories = Get-ChildItem $contentpath -filter "mod.txt" -recurse | where {$_.DirectoryName -like "*$name*"}

    if ($directories.count -lt 1) {
    
        write-host `n"Unable to find any directories with the name $name"
    
    }

    elseif ($directories.count -eq 1) {
        
        $dirname = $directories.directory.name
        $file = $directories.name 

        if ((!$version) -and (!$comment) -and (!$url)) {

            write-host `n"No changes provided, mod file for $dirname will not be updated." -ForegroundColor Yellow

        }

        else {
        
            $content = (Get-Content -path $contentpath\$dirname\$file).split("=")

            try {

                $prev_version = $content[1]
                $prev_comment = $content[3]

                if ($content[5] -like "*racedepartment*") {

                    $prev_url = $content[5]

                }
                else {

                    $prev_url = ""

                }

                $rd_version = $content[7]
                $rd_last_updated = $content[9]
                $last_update_check = $content[11]

                if (!$version) {
            
                    $version = $prev_version

                }

                if (!$comment) {
            
                    $comment = $prev_comment

                }

                if (!$url) {
                
                    $url = $prev_url

                }

            }
            catch {
        
                write-host `n"Invalid $modtype mod.txt found in mod directory $contentpath\$dirname, unable to update mod file for this mod." -ForegroundColor Red
                break

            }

            write-host "version=$version"
            write-host "comment=$comment" 
            write-host "url=$url"


            $title = "Update Mod File - " + $modtype + " - " + $dirname + ""
            $prompt = "The following information will written to the mod file for " + $modtype + " mod " + $dirname + ":`n`nVersion: " + $version + "`nComment: " + $comment + "`nURL: " + $url + "`n`nDo you want to continue, [Y]es or [N]o?"
            $promptyes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes','Updates the mod.txt'
            $promptno = New-Object System.Management.Automation.Host.ChoiceDescription '&No','Doesnt Update the mod.txt'
            $options = [System.Management.Automation.Host.ChoiceDescription[]] ($promptyes,$promptno)
            $choice = $host.ui.PromptForChoice($title,$prompt,$options,0)

        }
    }

    elseif ($directories.count -gt 1) {

        write-host `n"Found more than one directory with the name $name"

        $directories.Name

    }

    if ($choice -eq 0) {

        output_modfile    

    }

}

Export-ModuleMember -function Get-ACMod
Export-ModuleMember -function New-ACMod
Export-ModuleMember -function Set-ACMod
