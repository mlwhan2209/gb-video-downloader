## Overview
This is a simple way to download your favorite videos from the classic website videogamemountain

Keep in mind, according to their API they don't want anyone to download more than 20 videos a day. 

## Setup
 - Need to install Powershell 7. 
    - on Windows, you can do that here: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2
    - on Mac, setup homebrew and then you can just run ````brew install --cask powershell````
 - go to https://www.giantbomb.com/api/ and grab your API key 
 - clone the repo and navigate to  it in your terminal
 - rename  `config-example.xml` to `config.xml` and paste your API key where it says `<API-Key-Here>`
 - You are going to want to have infinite scroll setup on your terminal. There are over 3000 Quick Looks for example and the name and deck are being displayed for each. 

## Usage

- Run `gb-video-downloader.ps1`
- When asked, type the number of the show you want to start downloading from 
- When asked, type the number of the episode you want to stop downloading from

- NOTE: if you want a single video, just put the same number in both entries
- Set the filepath you want to download to. Make sure your path ends on a slash
ex: C:/Users/CharlieTunoku/Desktop/Persona4EnduranceRun/



