# Assetto Corsa Mod Tracker
PowerShell Module to output the current version of Track and Car mods installed and compare them to Race Department.

Current Release Version: 0.6

----------


**Installation**

 1. Download latest version of module from the releases directory
 2. Find your PowerShell module directory - this is normally in your documents folder > WindowsPowerShell\Modules.  However you can find this by opening PowerShell and entering:

 `$Env:PSModulePath`

 3. Extract contents of release.zip file into your PowerShell modules folder
 4. You should now have a new folder in your modules folder called "ACModTracker"
 5. The script requires some manual additions to work with your Assetto Corsa installation, right click and edit the psm1 file located in the module folder "ACModTracker".  Update the following line of code: 

 `$ac_install_path="Enter the full path of the Assetto Corsa install folder"`


----------

**Usage**

The module works by looking inside your Assetto Corsa Tracks or Cars folders for a file called mod.txt.  This txt file is a custom file that must be manually created to allow the module to track the mod.   As an example the mod.txt file contains the following information:

> version=0.4

> comment=

> url=http://www.racedepartment.com/downloads/pacific-coast.12087/

> RD Version=0.699a

> RD Last Updated=Sunday at 17:49 

> Last Update Check=02/22/2017 13:19:34

Included in the module is a function to create the mod.txt file, however you will still need to collect and pass the relevant information for the version you have installed and the Race Department URL to enable full tracking.  You can also add comments to the mod.txt file to help you know more about the mod e.g. "No sound in version 0.9"

Before we start with this we first need to check the module has been installed and can be imported into PowerShell.
 
 1. Open PowerShell and type (Note you will have to do this each time you want to use the module)

 `Import-Module ACModTracker`

 2. If the installation has been done correctly the module will import without any errors
 3. You can now use the module, see below for functions included in the module.

----------

Module Functions
----------------

**Get-ACMod**

This is the primary function of the module, it will search the Tracks or Cars folder for any mod.txt files and output the information into a grid view.  To see the correct function syntax type the following command into your PowerShell window: 

 `Get-Help Get-ACMod`

The output will show you the available syntax that makes up this function.   The function contains two mandatory switches to determine if you are looking for Track or Car mods as well as outputting all or only certain mods where a name matches your entry. 

By default the function outputs local information found in the mod.txt files, you can tell the function to check for updates from Race Department for the mods found and the function will update the local mod.txt with the information found. (Note there is 1 hour time limit to checking to avoid spamming the Race Department website).  

You can also export the information into a CSV which can be uploaded to Dropbox or Google Drive.  By default the export goes into your Documents folder however you can change the location of this by editing the following line in the psm1 file:

 `$export_path="D:\Temp"`

*Example Commands:*

Output all Track Mods currently installed:

 `Get-ACMod -track -all`

Output any Car Mods currently installed with a name like "Honda": 

 `Get-ACMod -car -name "honda"`

Output any Car Mods currently installed with a name like "Honda" and check for latest version:

 `Get-ACMod -car -name "honda" -check_updates`

Output and Export any Track Mods currently installed with a name like "Pacific Coast" and check for latest version: 

 `Get-ACMod -track -name "Pacific Coast" -check_updates -export`


----------

**New-ACMod**

Before we can use the Get-ACMod function you need to create some mod.txt files for the mods you have installed.

Unfortunately this requires some manual leg work as to fully utilise the Get-ADMod function you will need to have the version number and the Race Department URL for the mod you have installed.  Once you have installed the mod into your Assetto Corsa install directory we can then create a mod.txt file to track the mod version.

To see the correct function syntax type the following command into your PowerShell window: 

 `Get-Help New-ACMod`

The output will show you the available syntax that makes up this function.   The function contains two mandatory switches to determine if you are creating a mod.txt for Track or Car mods as well as the name of the mod.

Only a single mod.txt file can be created at a time per mod, ideally try and use the name of the mod as the correct directory name e.g. "GINETTA G55 GT4" however if you cant remember you can enter a something similar e.g. "GINNETA" and the function will try and find the mod directory for you. 

If the function finds more than one directory with the name specified it will output the list of the directories found and ask you to run the command again with the full directory name of the mod. 

The function will always ask if you want to create the file before it does to verify you have the correct directory.

The values for Current Version, Race Department URL and Comment are optional however i would strongly advise adding them in when running this function to save you having to do it later.

*Example Commands:*

Create a mod.txt for a car mod called Ginetta G55 GT4:

 `New-ACMod -car -name "GINETTA G55 GT4" -comment "Mod works fine" -url "http://www.racedepartment.com/downloads/ginetta-g55-gt4.13658/"`

Create a mod.txt for a track mod called Thruxton (but cant remember the directory name):

`New-ACMod -track -name "Thrux" -url  "http://www.racedepartment.com/downloads/thruxton.6192/"`
