## 0.0.1

- First ever commit

## 0.0.2

- Login page error handling.

## 0.0.3

- Made the search results look a bit better (The text might overflow if the resolution of the window is changed.)
- Tags are now shown on each manga search result

## 0.0.4

- added options to change chapters

## 0.0.5

- major bug fixes
- pages are no longer in a list, images are changed when clicked or double clicked.
- the baseurl for all manga has been hardcoded to https://uploads.mangadex.org since it has a very strict rate limit when requesting for the baseurl for each chapter.

## 0.0.6

- Major Feature updates and bug fixes
- Added auto login function.
- Changed the UI theme to dark, a light mode will be added later on.
- added an about manga page.
- mangaReader no longer bound to the index of the ChapterData it's supplied to.
- Fixed bug with the search bar

## 0.0.7

- User is now greeted with his library on login
- Fixed issues where the app would just not respond if it's processing a network request
- Added 'Add to library' button on the about manga page, the button maybe be buggy due to poorly implemented code, it will be fixed soon.
- Temporarily removed auto login feature.

## 0.0.8

- Update all components according to the mangadex_library ver 1.2.9+7 and Mangadex API Update 5.2.35

## 0.0.9

- Added a settings page, can be accessed from the user library
- Added options to switch between light mode and dark mode to settings page
- Added options to switch datasaver on and off to settings page
- User's username is now shown in the navigation drawer
- Added option to logout of fludex in navigation menu
- Added about fludex page in the navigation menu
- Updated to mangadex_library ver 1.2.14
- Chapter are now auto marked as read when going to the next chapter
- If next page is triggered when user is on the last page of a chapter, chapter is auto changed.
- Fixed problems with token refresh which caused the app to crash, if it still happens relaunching the app will fix it.
- 'Added to Library' button remains buggy and unaligned, the style for the button is to be changed along with a proper fix for it

## 0.1.0

- Finally added an App Theme, it should look much better now.
- Replaced colored containers with cards.
- Added 'mark chapter as read' options to all chapter mark tiles
  **'Add to library' and 'Mark chapter as read' are both not currently working due to issues from Mangadex's side, they will fix it someday so gotta wait.**

## 0.1.1

- adding to library button now works, however removing from library **does not work**. You will have to manually remove mangas from the website.
- fixed a bug where the login page would be stuck at the animation if the login timed out.
- search results now use 256px manga covers arts rather than the original, as a result the thumbnails should look less distorted.

## 0.1.2

- added a color filter option to the manga reader for adjusting the brightness of the pages.
- added an option to filter manga based on reading status in the library.
- fixed a bug where the chapter changed but the manga page didn't.

## 0.1.3

- fixed a bug where user couldn't unfollow a manga.
- fixed a bug where user couldn't mark a chapter as read or unread.
- fixed a bug where the library layout got disoriented on resizing window to small sizes.
- going from one chapter to another while reading a manga now automatically marks the chapter as read.

## 0.1.4

- added option to change manga reading status for a manga.
- added option to change translated language for a manga.
- added option to change the tile view in the library.
- added refresh button in the library to refresh library entries.

- changed the padding for 'Add to library' button.
- changed class name 'readManga.dart' to 'mangaReader.dart'.

- removed 'background.dart' class.

## 0.2.1
- fixed a bug where the app stopped working when loading the library
- fixed a bug where the manga reader messed up the volume indexes for certain mangas

## 0.2.2
- fixed a bug where some mangas failed to load up.
- moved a few functions to separate dart files to organize things