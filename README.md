## Unsplash Photo Explorer
Unsplash Photo Explorer is a SwiftUI app that displays beautiful photos from Unsplash. Users can browse photos in a grid, view details, see camera info, and like their favorite images.

## Features

- Fetch random photos from the Unsplash API.  
- Adaptive grid layout for iPhone and iPad.  
- Full-screen photo detail view.  
- Camera metadata info sheet.  
- Like/unlike functionality with state persistence.  
- Efficient image loading and caching using [Kingfisher](https://github.com/onevcat/Kingfisher).  

---

## Screenshots

<img width="450" height="920" alt="Home Screen" src="https://github.com/user-attachments/assets/9762f46c-0b53-4998-8f59-d7a7fd800e46" /> <img width="450" height="920" alt="Photo Info Sheet" src="https://github.com/user-attachments/assets/e7bba1a4-ff3f-46b3-a9f4-858c16cd8739" />

---

## Installation

1. Clone the repository:
````markdown
git clone https://github.com/yourusername/UnsplashPhotoExplorer.git
cd UnsplashPhotoExplorer
````

2. Open the project in **Xcode 26** or later.
3. Sign the Xcode project if needed.
4. Navigate to UnsplashPhotoExplorer/UnsplashPhotoExplorer/APIConfig -> open Secrets.xconfig file
5. Add your Unsplash API key: NOTE: Make sure to create your API Key from the Official Unsplash API: https://unsplash.com/developers

* **Preferred (Secrets.xconfig):**

```
API_KEY = YOUR_API_KEY_HERE
```

* **Alternative:** If `Secrets.xconfig` does not work, open `UnsplashAPIClient.swift` and uncomment the code as instructed in the file to manually enter your API key.

5. Build and run on iPhone or iPad.

---

## Usage

* Launch the app to see a grid of random photos.
* Tap a photo to view it in full screen.
* Tap the **info button** to see camera details.
* Tap the **heart icon** to like or unlike a photo.
* Search for your favourite photos

---

## Dependencies

* [Kingfisher](https://github.com/onevcat/Kingfisher) – for async image loading, caching, and placeholders.

---

## Architecture

* **SwiftUI + MVVM**

  * `PhotoListViewModel` handles fetching and caching photos.
  * `PhotoGridItemView` displays each photo in a uniform grid.
  * `PhotoDetailView` displays full photo with info sheet.

* **Models:**

  * `Photo`, `User`, `PhotoURLs`, `Exif` – Codable structures for API decoding.

* **State Management:**

  * `AppState` – manages liked photos and global app state.

---

## Planned Features

* Infinite scroll to load more photos.
* Search photos by keyword.
* Download and share photos.
* User authentication for saving favorites across devices.
* Dark mode optimizations.
