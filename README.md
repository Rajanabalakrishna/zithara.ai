News & Weather Hub
A Flutter mobile application that combines weather updates, top news headlines, and an about/settings experience in one app. The app is built with a modern UI approach, uses Riverpod for state management, Hive for local persistence, and integrates external APIs for live weather and news data. The attached assignment PDF is the source document referenced for the project brief.

Project overview
This application starts on the Weather screen and uses a bottom navigation layout with three main sections: Weather, News, and About. The News section includes additional menu-driven navigation for items such as headlines, bookmarks, and settings, while the About section includes app information and theme switching support.

Features implemented
Weather
Current weather based on the user’s location.

Forecast data for upcoming days.

Location permission handling before loading weather.

Cached weather data stored locally using Hive for offline use.

News
Top headlines fetched from a live News API.

News listing with article image, source name, and publish date.

Article details page with share and open-in-browser actions.

Bookmark save/remove support.

Bookmarks stored locally using Hive.

News screen with menu navigation for headlines, bookmarks, and settings.

About and settings
About screen with app information.

Light theme / dark theme toggle.

Theme changes applied across Weather, News, About, and related screens.

Architecture and state management
The app uses Riverpod for application state management, which keeps the UI reactive and organized across weather, news, bookmarks, and theme changes. Riverpod helps separate UI, controller logic, and data access so the application remains easier to maintain and extend.

Local database
The app uses Hive as the local database for persistence. Hive stores cached weather data and saved news bookmarks locally on the device so the app can continue to display previously fetched content even when internet access is unavailable.

Offline behavior
A key part of the implementation is offline support.

When internet is available, the app fetches fresh weather and news data from the respective APIs.

When internet is not available, the app reads previously cached content from Hive.

Cached weather data is shown to the user instead of a blank screen.

Saved bookmarks remain available offline because they are stored locally.

If the latest remote data cannot be received, the app falls back to the last successful local data stored in Hive.

This means the app still provides a usable experience without network connectivity, especially for previously loaded weather information and bookmarked news articles.

UI and design
The interface follows a modern visual style with glassmorphism-inspired UI elements and a custom bottom navigation shell. The navigation structure is designed so users can move between Weather, News, and About quickly, while preserving state between screens.

APIs used
Feature	API / Source	Purpose
Weather	Weather API	Fetch live weather and forecast data
News	News API	Fetch top headlines and article metadata
Local storage	Hive	Cache weather data and store bookmarks
Tech stack
Flutter

Dart

Riverpod

Hive

News API

Weather API

Material Design UI

User flow
App opens on the Weather screen.

User can switch between Weather, News, and About using the bottom navigation bar.

In News, the user can open the menu and navigate to headlines, bookmarks, or settings.

The user can open article details, save bookmarks, and access them later.

If internet is lost, the app shows the last available Hive-cached data instead of failing completely.

Notes
Weather and news are powered by live API responses.

Hive is used for local caching and bookmark persistence.

Riverpod manages reactive app state.

Theme switching is available from the About screen.

Offline fallback improves usability when network access is unstable or unavailable.

Conclusion
This project delivers a Flutter-based News and Weather application with a polished UI, structured state management, persistent local storage, and offline-friendly behavior. The main implemented pieces are Riverpod state management, Hive local database support, glassmorphism-style UI, live News and Weather API integration, bookmark persistence, theme switching, and fallback to cached Hive data when internet is unavailable.
