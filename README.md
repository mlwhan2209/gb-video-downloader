
## Overview
This is a simple way to download your favorite videos from the classic website videogamemountain

There are 2 ways to use this module, you can run the .ps1 and have it list shows for you and select between them. Or you can run a search for keywords with a function and select your videos from the search results. 

## Setup
 - must have Powershell 7 installed
 - get your api key from https://www.giantbomb.com/api/ 
 - rename `config-example.xml` to `config.xml` and paste your API key where it says `<API-Key-Here>`

## Usage
If you want to do the basic script, have it list all the Giant Bomb shows and you pick the show then the episodes you want from the list you want to just run `gb-video-downloader.ps1` 

If you want to do a search for a specific video, you have to run

    Import-Module ./gb-video-downloader.psm1 -Force
    Invoke-GiantBombVideoSearch -Search "<your-search-here>"






