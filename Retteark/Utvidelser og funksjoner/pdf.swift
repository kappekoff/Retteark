//
//  pdf.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 16/04/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
func lagPDF (innhold: some View, filplassering: URL) {
  let renderer = ImageRenderer(content: innhold)
  renderer.render { size, context in
    // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
    var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    // 5: Create the CGContext for our PDF pages
    guard let pdf = CGContext(filplassering as CFURL, mediaBox: &box, nil) else {
      return
    }
    
    // 6: Start a new PDF page
    pdf.beginPDFPage(nil)
    
    // 7: Render the SwiftUI view data onto the page
    context(pdf)
    
    // 8: End the page and close the file
    pdf.endPDFPage()
    pdf.closePDF()
  }
  print(filplassering)
}

struct PDFDocument: FileDocument {
  
  var pdfData: Data
  static let readableContentTypes: [UTType] = [.pdf, .directory]
  
  init(configuration: ReadConfiguration) throws {
    self.init()
  }

  init(pdfData: Data = Data()) {
    self.pdfData = pdfData
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    return FileWrapper(regularFileWithContents: pdfData)
  }
  
  
}
