//
//  View+Extensions.swift
//
//
//  Created by Edon Valdman on 9/23/23.
//

import SwiftUI
import PDFKit

extension View {
    /// Presents a document scanner that returns an image per scanned page.
    /// - Parameters:
    ///   - isPresented: A binding that determines whether the scanner is presented.
    ///   - onCompletion: A callback that will be invoked on the main actor when the scanning
    ///     operation has succeeded or failed.
    public func documentScanner(
        isPresented: Binding<Bool>,
        onCompletion: @escaping @MainActor (Result<[UIImage], any Error>) -> Void
    ) -> some View {
        fullScreenCover(isPresented: isPresented) {
            DocumentScannerView(onCompletion: onCompletion)
        }
    }
    
    /// Presents a document scanner that returns all scanned pages as a single `PDFDocument`.
    /// - Parameters:
    ///   - isPresented: A binding that determines whether the scanner is presented.
    ///   - onPDFCompletion: A callback that will be invoked on the main actor when the scanning
    ///     operation has succeeded or failed.
    public func documentScanner(
        isPresented: Binding<Bool>,
        onPDFCompletion: @escaping @MainActor (Result<PDFDocument, any Error>) -> Void
    ) -> some View {
        fullScreenCover(isPresented: isPresented) {
            DocumentScannerView(onPDFCompletion: onPDFCompletion)
        }
    }
}
