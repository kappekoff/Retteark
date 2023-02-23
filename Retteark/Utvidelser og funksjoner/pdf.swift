//
//  pdf.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 17/09/2022.
//

#if os(iOS)
import SwiftUI
import UIKit

extension View {
    
    func convertToScrollView<Content: View>(@ViewBuilder content: @escaping ()->Content)->UIScrollView {
        
        let scrollView = UIScrollView()
        
        let hostingController = UIHostingController(rootView: content()).view!
        hostingController.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            hostingController.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.widthAnchor.constraint(equalToConstant: screenBounds().width)
        ]
        
        scrollView.addSubview(hostingController)
        scrollView.addConstraints(constraints)
        scrollView.layoutIfNeeded()
        
        return scrollView
    }
    
    func exportPDF<Content: View>(outputfileURL: URL?, @ViewBuilder content: @escaping ()->Content,completion: @escaping (Bool, URL?)->()){

        let pdfView = convertToScrollView {
            content()
        }
        pdfView.tag = 1009
        let size = pdfView.contentSize
        pdfView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        
        getRootController().view.insertSubview(pdfView, at: 0)
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        do{
            try renderer.writePDF(to: outputfileURL!, withActions: { context in
                context.beginPage()
                pdfView.layer.render(in: context.cgContext)

            })
            completion(true, outputfileURL)
        }
        catch {
            completion(false,nil)
            print(error.localizedDescription)
        }
        
        getRootController().view.subviews.forEach({ view in
            if view.tag == 1009 {
                view.removeFromSuperview()
            }
            
        })
    }
    
    func screenBounds()->CGRect {
        return UIScreen.main.bounds
    }
    
    func getRootController()->UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
    
}

#elseif os(macOS)
import SwiftUI
import AppKit

extension View {
    
    func exportPDF<Content: View>(filnavn: String, @ViewBuilder content: @escaping ()->Content,completion: @escaping (Bool, URL?)->()) {
        let pi = NSPrintInfo.shared
        pi.topMargin = 0.0
        pi.bottomMargin = 0.0
        pi.leftMargin = 0.0
        pi.rightMargin = 0.0
        pi.orientation = .landscape
        pi.isHorizontallyCentered = false
        pi.isVerticallyCentered = false
        pi.scalingFactor = 1.0
                        
        let rootView = content()
        let view = NSHostingView(rootView: rootView)
        let contentRect = NSRect(x: 0, y: 0, width: 300, height: 300)
        view.frame.size = contentRect.size

        let newWindow = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        newWindow.contentView = view

        let myNSBitMapRep = newWindow.contentView!.bitmapImageRepForCachingDisplay(in: contentRect)!
        newWindow.contentView!.cacheDisplay(in: contentRect, to: myNSBitMapRep)

        let myNSImage = NSImage(size: myNSBitMapRep.size)
        myNSImage.addRepresentation(myNSBitMapRep)

        let nsImageView = NSImageView(frame: contentRect)
        nsImageView.image = myNSImage

        let po = NSPrintOperation(view: nsImageView, printInfo: pi)
        po.printInfo.orientation = .landscape
        po.showsPrintPanel = true
        po.showsProgressPanel = true
        
        po.printPanel.options.insert(NSPrintPanel.Options.showsPaperSize)
        po.printPanel.options.insert(NSPrintPanel.Options.showsOrientation)
        
        if po.run() {
            print("In Print completion")
        }
        
    }
    
}
#endif
