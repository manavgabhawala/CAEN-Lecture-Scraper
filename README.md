# CAEN-Lecture-Scrapper
## Introduction
Scrapes and downloads all videos from CAEN Lecture Recordings for any class so that they are available offline. Before you begin you will want to ensure you have a solid fast internet connection.
## Installation
You can fork this project, clone it in your desktop or download the zip file. In either case, locate the locally downloaded project in Finder and open the project and run it with Xcode. If you do not have an Apple Developer Account you may need to fix the code signing issues that come up by selecting None under Code Sign in General Project settings. Then ⌘R should build and run the project for you successfully. Since this is built using Swift 2, you need to use Xcode 7 to open the app. (Available at https://developer.apple.com/xcode/downloads)
Coming soon is a direct download link where you can launch the app directly after downloading the app without requiring Xcode.

## How To Use
- Once you have successfully opened the app you will see a blank screen and a text field to enter a URL in the top left corner, with some instructions on the bottom. 
- Open your favorite browser and navigate to the cTools page for the class for which you want the lecture videos. Click the CAEN Lecture Recordings tab in the class. Scroll all the way to the bottom and make sure you are using the latest HTML 5 player otherwise, this will not work (coming soon is a fix where it works even if you forget to do this but for now you must make sure that you have the player enabled). 
- Now copy the entire link and paste it into the text box in the app.
- Click the Download button
- Assuming you pasted the correct URL you will be redirected to the weblogin screen for your umich account. Now, log into the same account that you used to acquire the cTools link that you pasted (if not it most probably will not work.)
- Now its time to be patient.
- You will be navigated to a screen where slowly, one by one, the videos will begin to appear with a status of waiting to queue.
- Once we have found all the video URLs, you will be able to click
