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
    
    private let onCompletion: (Result<[UIImage], any Error>) -> Void
    
    /// Creates a scanner that scans documents into a page image per scanned page.
    /// - Parameter onCompletion: A callback that will be invoked when the scanning operation has succeeded or failed.
    public init(onCompletion: @escaping (Result<[UIImage], any Error>) -> Void) {
        self.onCompletion = onCompletion
    }
    
    /// Creates a scanner that scans documents into a single `PDFDocument`.
    /// - Parameter onPDFCompletion: A callback that will be invoked when the scanning operation has succeeded or failed.
    public init(onPDFCompletion: @escaping (Result<PDFDocument, any Error>) -> Void) {
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
    /// This class method returns `false` for unsupported hardware.
    @MainActor
    public static var isSupported: Bool {
        VNDocumentCameraViewController.isSupported
    }
}

extension DocumentScannerView {
    @MainActor
    public final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        fileprivate var parent: DocumentScannerView
        
        fileprivate init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        // VisionKit's delegate protocol isn't annotated as main-actor bound, but UIKit only ever
        // calls it on the main thread, so these hop back to the actor the coordinator lives on.
        
        nonisolated public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let pages = (0..<scan.pageCount).map(scan.imageOfPage(at:))
            MainActor.assumeIsolated {
                parent.finish(with: .success(pages))
            }
        }
        
        nonisolated public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            MainActor.assumeIsolated {
                parent.dismiss()
            }
        }
        
        nonisolated public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
            MainActor.assumeIsolated {
                parent.finish(with: .failure(error))
            }
        }
    }
}
