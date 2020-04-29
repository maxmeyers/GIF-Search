# GIF-Search

GIF Search is a single-purpose app that uses the GIPHY API to search for GIFs based on user input.

## Features
- Search bar that allows for user input. Searches happen automatically when the user stops typing for 1 second, or when they tap the search button.
- Requests 25 images at a time. Automatically loads more after reaching the end of the list.
- Uses `CHTCollectionViewWaterfallLayout` for a nice waterfall style layout, displaying each GIF in its original aspect ratio with multiple columns.
- Uses `SwiftyGif` for high performance GIF rendering.
- Supports portrait and landscape mode on iPhone & iPad.
- Supports saving, copying, and sharing GIFs.
- Supports Dark Mode.

## Requirements
- Xcode 11.4
- iOS 13.4

## Setup
First, clone the repo:

```
git clone git@github.com:maxmeyers/GIF-Search.git
```

Then open `GIF Search.xcodeproj`. 
In `Info.plist`, add your GIPHY API Key to the key called `GiphyAPIKey`. The app will crash on launch until you do this.

## Future Improvements
- Add unit tests for `GIFSearchInteractor`
- Do a pass over the app using VoiceOver to ensure that the app is accessible for all users. Specifically accessibility labels should be added to image cells when appropriate.
- Add the ability to view GIFs fullscreen. Tapping a cell should bring the image fullscreen, and present a share button that exposes the existing save/copy/share functionality.
- Improve the share sheet implementation with a preview image.
- Add an iMessage app to allow searching for GIFs within Messages.app
