import Testing
import PDFKit
import UIKit
@testable import DocumentScannerView

@Suite("PDFDocument+Images")
struct PDFDocumentImagesTests {
    private func image(_ size: CGSize = CGSize(width: 8, height: 8)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    @Test("Creates one page per image, in order")
    func onePagePerImage() throws {
        let sizes = [CGSize(width: 8, height: 8), CGSize(width: 16, height: 32)]
        let document = PDFDocument(sizes.map(image))
        
        #expect(document.pageCount == sizes.count)
        for (index, size) in sizes.enumerated() {
            let bounds = try #require(document.page(at: index)).bounds(for: .mediaBox)
            #expect(bounds.size == size)
        }
    }
    
    @Test("An empty array makes an empty document")
    func emptyInput() {
        #expect(PDFDocument([]).pageCount == 0)
    }
}
