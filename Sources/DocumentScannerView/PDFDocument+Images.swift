//
//  PDFDocument+Images.swift
//  
//
//  Created by Edon Valdman on 9/23/23.
//

import UIKit
import PDFKit

extension PDFDocument {
    /// Creates a document with one page per image.
    ///
    /// Images that can't be represented as a `PDFPage` are skipped, so the resulting page count
    /// can be smaller than `images.count`.
    /// - Parameter images: The images to lay out, in order, one per page.
    public convenience init(_ images: [UIImage]) {
        self.init()
        var pageIndex = 0
        for image in images {
            guard let page = PDFPage(image: image) else { continue }
            insert(page, at: pageIndex)
            pageIndex += 1
        }
    }
}
