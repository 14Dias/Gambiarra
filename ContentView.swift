//
// Playground Template developed by Apple Developer Academy | PUC-Rio
// Version 1.0
//
// This template playground is built based on the 10th Submission Requirement of
// the Swift Student Challenge WWDC26: "Your app playground must either [...] or
// be based on a Swift Playground template modified entirely by you as an individual."
//

import SwiftUI

struct ContentView: View {
    
    let pianoAudioController = BasicAudioController(filename: "piano-loops_josefpres.wav")
    
    var body: some View {
        VStack {
            Image(systemName: "globe")          // You can press ⌘ + Shift + L in Xcode and select the star to see all symbols
                .font(.largeTitle)              // You can use font sizes to control the size of symbols
                .foregroundColor(.accentColor)  // The accent color is set in the project settings
            
            Text("**Hello**, *world*!")                  // Two * makes it bold and one * makes it italic
                .font(.custom("Merriweather", size: 40)) // The name of the custom font is not the same as the file name
            
            Image("ssc-logo")  // This image was added to the Assets
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            audioPlayerButtons // This is how you should orgnize your code
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // This makes the view take up all the available space
        .background(.blue.opacity(0.1)) // This puts the entire background green because of the previous line
    }
    
    @ViewBuilder
    var audioPlayerButtons: some View {
        HStack(spacing: 32) {
            Button {
                pianoAudioController?.play()
            } label: {
                Label("Play", systemImage: "play.circle.fill")
            }
            
            Button {
                pianoAudioController?.pause()
            } label: {
                Label("Pause", systemImage: "pause.circle.fill")
            }
            
            Button {
                pianoAudioController?.stop()
            } label: {
                Label("Stop", systemImage: "stop.circle.fill")
            }
        }
        .font(.title)
    }
}
