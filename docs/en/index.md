# SAS.Planet Documentation

## Download Links

* [Release](https://github.com/sasgis/sas.planet.src/releases/latest) - stable (release) version.
* [Nightly](https://github.com/sasgis/sas.planet.src/releases/tag/nightly) - nightly (testing) version.

## How to Install

1. Unpack the program archive into any folder on your drive. If you have [UAC](https://en.wikipedia.org/wiki/User_Account_Control) enabled on your system, do not unpack the archive into system directories! The program will not be able to run from there without Administrator rights, as it stores all its settings and data within the selected folder. It is recommended that the folder name does not contain spaces or non-Latin characters. A good folder name for installation is: `D:\SASPlanet\`

2. Add maps (also known as [zmp](zmp.md)) to the `Maps` folder (located inside the program's folder). You can find download links for maps and instructions [here](https://codeberg.org/sasgis/doc#readme) or in `\Maps\readme.html`.

3. Create a shortcut for SASPlanet.exe on your desktop and launch the program.

## How to Update

1. Unpack the archive with the new version of the program into the folder with the already installed version, replacing ALL files. All YOUR data (settings, placemarks, cache, etc.) will remain untouched.

2. Update the maps according to the instructions that come with them.

!!! info
    Maps and the program can be updated independently of each other. However, keep in mind that some maps may start using new program features that have appeared in the Nightly version but are not yet available in the stable Release. Consequently, such maps will not work in the release version of SAS or may even cause errors.

## Additional Settings

In addition to viewing maps, the program has some functions that require additional settings (only if you need these functions, of course):

1. [Setting up the display of elevation under the mouse pointer](setup-dem.md)
2. [Setting up additional geocoders](setup-geocoder.md) (searching for coordinates by place name)
3. [Setting up offline routing](https://github.com/zedxxx/libosmscout-route)
4. [Setting up reading cache from Google Earth and GeoCacher programs](https://greverse.bitbucket.io/sasplanet_ge_howto.htm)


## Program-Related Resources

1. [Forum](https://www.sasgis.org/forum/), [Bugtracker](https://www.sasgis.org/mantis/my_view_page.php), [Wiki](https://www.sasgis.org/wikisasiya/doku.php) on www.sasgis.org
2. [Forum](https://forum.ru-board.com/topic.cgi?forum=5&topic=31937) on ru-board.com
3. [Telegram Group](https://t.me/SAS_Planet)