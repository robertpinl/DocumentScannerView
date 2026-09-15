# DocumentScannerView

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fedonv%2FDocumentScannerView%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/edonv/DocumentScannerView)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fedonv%2FDocumentScannerView%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/edonv/DocumentScannerView)

`DocumentScannerView` is a SwiftUI wrapper of [`VNDocumentCameraViewController`](https://developer.apple.com/documentation/visionkit/vndocumentcameraviewcontroller). Use it for scanning documents using the native document scanner.

## Requirements

- iOS 17+, Mac Catalyst 17+, visionOS 1+
- Swift 6 toolchain (Xcode 16 or later)

Scanning uses the camera, so your app's `Info.plist` needs an `NSCameraUsageDescription` entry.

## Installation

Add the package in Xcode via **File ▸ Add Package Dependencies…**, or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/edonv/DocumentScannerView.git", from: "1.0.0")
]
```

## Example

To use `DocumentScannerView`, you can either:

Present it inside the ViewBuilder of a `.fullScreenCover(isPresented:)` ViewModifier:
```swift
...

@ViewBuilder
var body: some View {
    // {Other View Content}
        .fullScreenCover(isPresented: $showScanner) {
            DocumentScannerView { scanResult in
                switch scanResult {
                case .success(let pages): // pages is [UIImage], one per scanned page
                    // Do something with the scan
                case .failure(let error):
                    // Deal with error
                }
            }
        }
}

...
```

OR

You can use the provided ViewModifier:

```swift
...

@ViewBuilder
var body: some View {
    // {Other View Content}
        .documentScanner(isPresented: $showScanner) { scanResult in
            switch scanResult {
            case .success(let pages): // pages is [UIImage], one per scanned page
                // Do something with the scan
            case .failure(let error):
                // Deal with error
            }
        }
}

...
```

### Scanning straight to a PDF

Both spellings have an `onPDFCompletion:` variant that collects every scanned page into a single
`PDFDocument`:

```swift
.documentScanner(isPresented: $showScanner, onPDFCompletion: { scanResult in
    switch scanResult {
    case .success(let pdf): // pdf is a PDFDocument
        // Do something with the scan
    case .failure(let error):
        // Deal with error
    }
})

// ...or, presenting it yourself:
.fullScreenCover(isPresented: $showScanner) {
    DocumentScannerView(onPDFCompletion: { scanResult in
        // ...
    })
}
```

> The image and PDF variants use different argument labels on purpose. When both were spelled
> `onCompletion:`, a trailing closure without an explicit parameter type was an *ambiguous use of
> `init(onCompletion:)`* compiler error.

### Completion handlers and the main actor

Both completion handlers are `@MainActor`, because that's where VisionKit delivers its callbacks.
You can update view state directly inside them, and pass a `@MainActor` method as the handler
without wrapping it in a closure.

### Checking hardware support

`VNDocumentCameraViewController` isn't available on every device. Check before offering the scanner:

```swift
if DocumentScannerView.isSupported {
    // Show your "Scan" button
}
```
