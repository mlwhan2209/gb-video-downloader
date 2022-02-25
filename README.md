
## Overview
This is a simple way to download your favorite videos from the classic website videogamemountain

There are 2 ways to use this module, you can run the .ps1 and have it list shows for you and select between them. Or you can run a search for keywords with a function and select your videos from the search results. 

## Setup
 - Need to install Powershell 7. 
 - go to https://www.giantbomb.com/api/ and grab your API key 
 - rename  `config-example.xml` to `config.xml` and paste your API key where it says `<API-Key-Here>`

## Usage
If you want to do the basic script, have it list all the Giant Bomb shows and you pick the show then the episodes you want from the list you want to just run `gb-video-downloader.ps1` 

If you want to do a search for a specific video name, you have to run

    Import-Module ./gb-video-downloader.psm1 -Force
    Invoke-GiantBombVideoSearch -Search "<your-search-here>"






