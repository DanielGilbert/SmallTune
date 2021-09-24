# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1] - 2009-12-07
### Added
- ESC-Key closes Dialogs (Settings, URL Window)
- Settings Dialog has Cancel/OK Buttons
- When opening the Playlist Window, the focus is on the corresponding edit

### Changed
- Path to the DB is shown, if you have an old version db.

### Fixed
- Used wrong handle in OpenFileDlg
- Repeat mode couldn't be deactivated
- Language hasn't been saved
- Fixed bug in settings view
- Fixed bug in internal default language
- Huge leak in Display Class fixed (thx turboPASCAL!)
- Multimedia key hook didn't work
- Settings dialog could be open several times
- Some cosmetics in several dialogs

## [0.3.0] - 2009-12-01
### Added
- Drag and Drop added
- Hotkeys added
- Window can be moved
- Options Dialog added
- Added logging functionality
- Added URL management
- SmallTune now speaks German too. :)
- It selects the language automatically, can be changed on runtime.
- SmallTune comes with its own User Agent, "SmallTune/0.3"
- Playlist supports "Enter" Key.
- When filtering the playlist, pressing the "Enter" Key will result in playing the first item being selected.

### Changed
- Design changes if an Internet Stream is being played
- If the song title is way too long for the window, it "bounces" from right to left and back
- Switched to Mozilla Public License because of the use of BASS as the audio lib

### Fixed
- Crash fixed when clicking on "next" at activated Shuffle-Mode
- Opening the playlist after playing an internet stream result in all items being selected
- TNA-Tooltip didn't change

## [0.2.1] - 2009-11-15
### Fixed
- After restarting the explorer, the icon was lost.
- After adding files oder folders, clicking and removing items from the playlsist without restarting failed
- Different names for the same action
- Position didn't change when Taskbar was replaced

## [0.2.0] - 2009-11-13
### Added
- Showing the main window on startup - less confusing. :)
- Added more functionality to the playlist window
- Highlighting the current track in the Playlist
- Automatically scrolls the Playlist to the current track
- turboPASCAL added word ellipsis for title
- turboPASCAL added "Stay on top" functionality
- He also redesigned the "AddURL" - Dialog
- Title scrolls if the text is too long
- You can easily look for the artist on Google, Wikipedia (en) and MySpace
- Tooltips added

### Changed
- Removed the stop button (did anyone use it?)
- Switched to BASS 2.4.4
- Switched Title And Artist
- URLs are now stored in the main database
- Display shows different info if a stream is played.
- Small display redesign

### Fixed
- Memory leak fixed
- turboPASCAL fixed an error in his Open - Dialog.

## [0.1.1] - 2009-10-30
### Added
- Added Links to "Info..." and "Help..."
- Items from the playlist can be deleted

### Fixed
- Playing a new track without resuming from the pausing state caused an error

## [0.1.0] - 2009-10-30
- Initial Release