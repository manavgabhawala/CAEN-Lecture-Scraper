# CAEN-Lecture-Scrapper
## Introduction
Scrapes and downloads all videos from CAEN Lecture Recordings for any class so that they are available offline. Before you begin you will want to ensure you have a solid fast internet connection.
## Installation
You can fork this project, clone it in your desktop or download the zip file. In either case, locate the locally downloaded project in Finder and open the project and run it with Xcode. If you do not have an Apple Developer Account you may need to fix the code signing issues that come up by selecting None under Code Sign in General Project settings. Then ⌘R should build and run the project for you successfully. Since this is built using Swift 2, you need to use Xcode 7 to open the app. (Available at https://developer.apple.com/xcode/downloads)
Coming soon is a direct download link where you can launch the app directly after downloading the app without requiring Xcode.

## How To Use
- Once you have successfully opened the app you will see a blank screen and a text field to enter a URL in the top left corner, with some instructions on the bottom. 
![Image of intro screen.]
(https://github.com/manavgabhawala/CAEN-Lecture-Scraper/blob/master/Images/First.png)
- Open your favorite browser and navigate to the cTools page for the class for which you want the lecture videos. Click the CAEN Lecture Recordings tab in the class. Scroll all the way to the bottom and make sure you are using the latest HTML 5 player otherwise, this will not work (coming soon is a fix where it works even if you forget to do this but for now you must make sure that you have the player enabled). 
- Now copy the entire link and paste it into the text box in the app.
- Click the Download button
- Now a new panel will open allowing you to select the folder where you want to save the downloaded files.
- Assuming you pasted the correct URL after you select the folder, you will be redirected to the weblogin screen for your umich account. Now, log into the same account that you used to acquire the cTools link that you pasted (if not it most probably will not work.)
- Now its time to be patient and not to touch anything. Don't click anything don't do anything just let us work our magic.
- You will be navigated to a screen where slowly, one by one, the videos will begin to appear with a status of waiting to queue.
[Image of Queueing]
(https://github.com/manavgabhawala/CAEN-Lecture-Scraper/blob/master/Images/Queueing.png
- Once we have found all the video URLs, you will be able to click the Download All button.
- But before you do that I made it possible to not download some videos if you don't want them. Just select the videos you don't want and click the - button on the bottom. Now their status should be updated to Deleted. If you accidentally deleted something click the + button to recover it.
- Click the clear deleted removes all the deleted rows and makes them unrecoverable so be warned (if you need to restart the process from the beginning).
- Now its time to start the downloads. Click the Download All button and all non-deleted videos will become queued. By default we only allow 3 concurrent downloads at a time. (See the advanced section for more information on how to tweak that) We restrict this to help optimize CPU and memory performance. Downloading all of them concurrently can become a major memory problem which can lead to overheating of your computer (I learnt that the hard way.)
- And voilá, all your videos should start appearing in the folder.

## Advanced
- To prevent too many downloads from occurring simultaneously I use a semaphore to coordinate the downloads since downloads occur on their own separate thread. If you don't know what that is, you probably don't want to be messing around with the limit on the number of simultaneous downloads. If you do know what that is, you can find the creation of the semaphore in the `DownloadVideosController.swift` file at the very top. 
```swift
let downloadsAllowed = dispatch_semaphore_create(3) // Change the value 3 to whatever you like. 
```

## FAQs
1. How does this work?
A. Coming soon.
2. Is it safe to enter my password to download the videos?
A. Most probably yes. It is directly authenticated with the weblogin, there is no interception of data so its exactly like logging in with a browser. If that's safe, this is safe.
3. Why is there minimal UI like no app icon?
A. If you want to help improve the UI send me the assets and I'll happily oblige by adding them to this tool.
4. I have a suggestion. How can I help improve this project?
A. If you know Swift make a pull request and submit your improvements. If you don't report an issue and I'll try and look at it.
