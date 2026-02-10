//
// Playground Template developed by Apple Developer Academy | PUC-Rio
// Version 1.0
//
// This template playground is built based on the 10th Submission Requirement of
// the Swift Student Challenge WWDC26: "Your app playground must either [...] or
// be based on a Swift Playground template modified entirely by you as an individual."
//

import SwiftUI
import AVFoundation

@main
@available(iOS 26.0, *)
struct MyApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    /// You must put  every font file you want to use in the Resouces folder in
    /// your project and then put its name on the array below
    let myCustomFontFileNames = [
        "Merriweather-VariableFont_opsz,wdth,wght.ttf",
        "Merriweather-Italic-VariableFont_opsz,wdth,wght.ttf",
        // "some other name"...
    ]
    
    init() {
        FontLoader.loadCustomFonts(myCustomFontFileNames)
    }
    
    
}

