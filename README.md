# Fludex

A very basic manga reader made using flutter and mangadex API. It uses the [mangadex_library package](https://pub.dev/packages/mangadex_library).

# Help wanted

I'm looking for Mac and Linux users who can just build the release version of the app for their respective OSs so the app can support multiple platforms. If anyone could, it would be a great help.

# FAQ
## What happened to the rewrite?

I had planned a rewrite with better project structure and a better UI but unfortunately my hardisk crashed and I didn't have it comitted so I lost most of the progress.

As of now, the re-write is stalled since writing all of that will take even more time and so I'll just continue developing the current version.

## Why is the versioning so confusing?

This app is my first ever actual app that I have committed myself to and that is actually in long term development. Before, I had no idea how versioning worked and so I was totally a newbie.

Long story short, I didn't know how versioning worked and by the time I understood the correct way it as too late.

## A few things to remember

- The app only supports windows at the moment. Android and other platforms can be compiled too, just remember that it's never tested on those devices so, it might become a nightmare when you look at it. Good luck to your eyes, honestly.

- The app is in a very early stage of development and hence bugs are expected including some incomplete code that I still can't figure out. It also hasn't been tested for certain scenarios and therefore might crash on certain pages if the internet is not good, please file an issue if you found something like this.

- The app is open source and not to be used for any commercial purposes, it's just a project for both the flutter and the mangadex community to showcase it as a flutter app can bring in.

- I might not be able to always be there to keep adding features to this one, however everyone's welcome to contribute to the project.

## Releases

The latest releases can always be found on the [releases](https://github.com/Riktam-Santra/Fludex/releases) page, if you are looking ahead to try the app.

## Preview

**NOTE:** The preview videos below ARE NOT UPDATED and DO NOT show most features included in the app. They will be updated soon.

Light mode:

https://user-images.githubusercontent.com/32616925/144753046-f9d8acac-01a2-4af8-bdd2-eae449657c5e.mp4

https://user-images.githubusercontent.com/32616925/144753063-35047b18-299d-48b9-b8ac-398e3e61cdf0.mp4

Dark Mode:

https://user-images.githubusercontent.com/32616925/144753087-0a06bcbf-d56f-4fd8-8a24-2db03ad85355.mp4

https://user-images.githubusercontent.com/32616925/144753198-1b6fce9b-9941-415b-a306-c6d25683b17e.mp4

## App Controls

When reading the manga, click once on a page to go to the next page and click twice on a page to go the previous page.

## Known bugs

- The layout may seem buggy when resizing the app window at the about manga page of a manga.
- The message 'Nothing found >:3' may occur on your library even if the library isn't empty, in that case please re-login to your account or restart the app.
- The number of chapters are displayed incorrectly
- The current chapter number shown by the manga reader is not always accurate

## Running the App

Extract your release zip archive and open mangadex_app.exe (make sure that all the files and extracted and not only the exe.)

## Compiling the App (For devs)

- Add the /bin directory of your flutter installation to your system PATH
- Install both the [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) and the [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) plugin onto your IDE. Visual Studio Code was used for this project.

## Working features

- Login
- Adding/removing manga to/from library
- Accessing and reading manga
- Marking chapters as read
- Color filters for changing brightness of manga pages
- Light and dark mode
- Searching for manga

## Things coming next

- ~~Download manga~~ This seems to be involving the application of isolates which is a bit complicated to handle at the moment and so has been postponed. I would be a serious help if someone could reach out to me to help me understand isolates.
- Option to use the app without logging in.
- View library offline (This might take more time to get implemented).
- A manga source search option by use of the [SauceNao API](https://saucenao.com/) (Currently working on this using the [saucenao](https://pub.dev/packages/saucenao) package).
## Reach me

- Need to get in touch for something? I might not be always active on my github but im always there on Discord, if you need to ask for something (or maybe just talk) just dm me on Rick~#9387
