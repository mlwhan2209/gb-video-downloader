## Overview
This is a simple way to download your favorite videos from the classic website videogamemountain

Keep in mind, according to their API they don't want anyone to download more than 20 videos a day. 

## Setup
 - Need to install Powershell 7. 
    - on Windows, you can do that here: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows
    - on Mac, setup homebrew and then you can just run ````brew install --cask powershell````
 - go to https://www.giantbomb.com/api/ and grab your API key 
 - clone the repo and navigate to  it in your terminal
 - rename  `config-example.xml` to `config.xml` and paste your API key where it says `<API-Key-Here>`
 - You are going to want to have infinite scroll setup on your terminal. There are over 3000 Quick Looks for example and the name and deck are being displayed for each. 

## Usage

- Run `gb-video-downloader.ps1` with Powershell 7. 
   - On Mac, in your terminal you'll want ````pwsh ./gb-video-downloader.ps1````
   - On Windows, look for the Powershell 7 terminal and run ````./gb-video-downloader.ps1```` from it

- You'll be asked which show from the numbered list you want to download. Just select the number that corresponds to the show you want. 

- Once you select a show, you'll be shown a numbered list of every episode in that show. The script will now allow you to select a range of episodes you want to download. 
- ex: If you select episode #3 as the one you want to start at and episode #8 as where you want to end, the script will download episodes 3 through 8 (so it will include both the 3rd and the 8th episode)
- If you only want a single episode, just type the same number for both inputs. 

- Set the filepath you want to download to. Make sure your path ends on a slash. 
- It doesn't matter if you use / or \. One of the better things about powershell. 

- Both of these examples are fine. Direction of slashes doesn't matter, important aspect is you end with a ````/```` or ````\````. 
  - ex: ````C:/Users/CharlieTunoku/Desktop/Persona4EnduranceRun/```` or ````C:\Users\CharlieTunoku\Desktop\Persona4EnduranceRun\````





