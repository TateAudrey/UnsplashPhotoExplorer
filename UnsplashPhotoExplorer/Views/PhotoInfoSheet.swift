//
//  PhotoInfoSheet.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

/// A sheet view displaying detailed information about a photo's EXIF metadata.
struct PhotoInfoSheet: View {

    /// The photo object containing metadata
    let photo: Photo

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                // Header
                HStack {
                    Text("Info")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                .padding(.bottom, 10)

                // Section title: Camera Details
                HStack(spacing: 10) {
                    Image(systemName: "camera")
                        .font(.title3)
                    Text("Camera Details")
                        .font(.headline)
                }

                // Camera metadata rows
                Group {
                    detailRow(label: "Make", value: photo.exif?.make ?? "N/A")
                    detailRow(label: "Model", value: photo.exif?.model ?? "N/A")
                    detailRow(label: "Aperture (f)", value: photo.exif?.aperture ?? "N/A")
                    detailRow(label: "Focal Length (mm)", value: photo.exif?.focalLength ?? "N/A")
                    detailRow(label: "ISO", value: photo.exif?.iso != nil ? "\(photo.exif!.iso!)" : "N/A")
                    detailRow(label: "Exposure Time", value: photo.exif?.exposureTime ?? "N/A")
                }

                Spacer()
            }
            .padding()
        }
    }

    /// Reusable row for displaying a label and its value
    @ViewBuilder
    func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}
