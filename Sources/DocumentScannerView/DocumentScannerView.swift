//
//  DocumentScannerView.swift
//
//
//  Created by Edon Valdman on 9/23/23.
//

import SwiftUI
import VisionKit
import PDFKit

/// A view that scans documents.
///
/// The scanner dismisses itself when the scan finishes, fails, or is cancelled, so present it
/// with ``SwiftUICore/View/documentScanner(isPresented:onCompletion:)`` or inside a
/// `fullScreenCover(isPresented:content:)`.
public struct DocumentScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss)
    private var dismiss
    
    private let onCompletion: @MainActor (Result<[UIImage], any Error>) -> Void
    
    /// Creates a scanner that scans documents into an image per scanned page.
    /// - Parameter onCompletion: A callback that will be invoked on the main actor when the
    ///   scanning operation has succeeded or failed.
    public init(onCompletion: @escaping @MainActor (Result<[UIImage], any Error>) -> Void) {
        self.onCompletion = onCompletion
    }
    
    /// Creates a scanner that scans documents into a single `PDFDocument`.
    /// - Parameter onPDFCompletion: A callback that will be invoked on the main actor when the
    ///   scanning operation has succeeded or failed.
    public init(onPDFCompletion: @escaping @MainActor (Result<PDFDocument, any Error>) -> Void) {
        self.onCompletion = { result in
            onPDFCompletion(result.map { PDFDocument($0) })
        }
    }
    
    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // Keep the coordinator pointed at the newest environment values (notably `dismiss`).
        context.coordinator.parent = self
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    fileprivate func finish(with result: Result<[UIImage], any Error>) {
        onCompletion(result)
        dismiss()
    }
    
    /// A Boolean variable that indicates whether or not the current device supports document scanning.
    ///
    /// This is `false` on hardware that doesn't support document scanning.
    @MainActor
    public static var isSupported: Bool {
        VNDocumentCameraViewController.isSupported
    }
}

extension DocumentScannerView {
    /// The delegate that forwards VisionKit's callbacks to the scanner's completion handler.
    ///
    /// VisionKit declares `VNDocumentCameraViewControllerDelegate` without main-actor isolation,
    /// but it only ever calls these methods from the main thread, on the view controller it owns.
    /// `@preconcurrency` states that invariant once — the compiler checks it at runtime — instead
    /// of repeating `nonisolated` and `MainActor.assumeIsolated` in every method. It can be dropped
    /// once VisionKit annotates the protocol as `@MainActor`.
    @MainActor
    public final class Coordinator: NSObject, @preconcurrency VNDocumentCameraViewControllerDelegate {
        fileprivate var parent: DocumentScannerView
        
        fileprivate init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.finish(with: .success((0..<scan.pageCount).map(scan.imageOfPage(at:))))
        }
        
        public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
            parent.finish(with: .failure(error))
        }
    }
}
