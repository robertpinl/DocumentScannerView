# DocumentScannerView

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fedonv%2FDocumentScannerView%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/edonv/DocumentScannerView)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fedonv%2FDocumentScannerView%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/edonv/DocumentScannerView)

`DocumentScannerView` is a SwiftUI wrapper of [`VNDocumentCameraViewController`](https://developer.apple.com/documentation/visionkit/vndocumentcameraviewcontroller). Use it for scanning documents using the native document scanner.

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
                case .success(let pages): // pages can either be [UIImage] or a PDFDocument
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
            case .success(let pages): // pages can either be [UIImage] or a PDFDocument
                // Do something with the scan
            case .failure(let error):
                // Deal with error
            }
        }
}

...
```
