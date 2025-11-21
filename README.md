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

<img width="450" height="920" alt="Home Screen" src="https://github.com/user-attachments/assets/d3c732fb-1765-4338-a639-254a7633a876" /> <img width="450" height="920" alt="Photo Info Sheet" src="https://github.com/user-attachments/assets/dc83240a-ccf1-48d2-b46a-6b81c0d8beae" />

---

## Installation

1. Clone the repository:
````markdown
git clone https://github.com/yourusername/UnsplashPhotoExplorer.git
cd UnsplashPhotoExplorer
````

2. Open the project in **Xcode 26** or later.
3. Sign the Xcode project if needed.
4. Add your Unsplash API key:

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
