import Testing
import PDFKit
import UIKit
@testable import DocumentScannerView

/// Page sizes to build documents from, covering no pages, one page, and several differing pages.
private let pageSizeCases: [[CGSize]] = [
    [],
    [CGSize(width: 8, height: 8)],
    [CGSize(width: 8, height: 8), CGSize(width: 16, height: 32)],
    [CGSize(width: 4, height: 4), CGSize(width: 4, height: 4), CGSize(width: 32, height: 16)],
]

/// Renders a blank image at `size`.
///
/// The scale is pinned to 1 so a point is a pixel, keeping the page bounds below comparable to the
/// size that went in.
@MainActor
private func makeImage(ofSize size: CGSize) -> UIImage {
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1
    return UIGraphicsImageRenderer(size: size, format: format).image { context in
        UIColor.white.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}

// The suite is main-actor isolated because it renders UIKit images.
@MainActor
@Suite("PDFDocument+Images")
struct PDFDocumentImagesTests {
    @Test("Creates one page per image, in order", arguments: pageSizeCases)
    func onePagePerImage(sizes: [CGSize]) throws {
        let document = PDFDocument(sizes.map(makeImage(ofSize:)))
        
        #expect(document.pageCount == sizes.count)
        
        for (index, size) in sizes.enumerated() {
            let page = try #require(document.page(at: index), "expected a page at index \(index)")
            #expect(page.bounds(for: .mediaBox).size == size)
        }
    }
}
