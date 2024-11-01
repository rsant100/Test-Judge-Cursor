import SwiftUI
import VisionKit
import PDFKit

struct DocumentScannerView: UIViewControllerRepresentable {
    let completion: (Result<ScanResult, Error>) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let completion: (Result<ScanResult, Error>) -> Void
        
        init(completion: @escaping (Result<ScanResult, Error>) -> Void) {
            self.completion = completion
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let result = ScanResult(scan: scan)
            completion(.success(result))
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            completion(.failure(error))
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            completion(.failure(ScanError.cancelled))
        }
    }
}

struct ScanResult {
    let scan: VNDocumentCameraScan
    
    var pdfData: Data? {
        let pdfGenerator = PDFGenerator(scan: scan)
        return pdfGenerator.generatePDF()
    }
}

enum ScanError: Error {
    case cancelled
}

private class PDFGenerator {
    let scan: VNDocumentCameraScan
    
    init(scan: VNDocumentCameraScan) {
        self.scan = scan
    }
    
    func generatePDF() -> Data? {
        let pdfDocument = PDFDocument()
        
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            guard let page = PDFPage(image: image) else { continue }
            pdfDocument.insert(page, at: pageIndex)
        }
        
        return pdfDocument.dataRepresentation()
    }
} 