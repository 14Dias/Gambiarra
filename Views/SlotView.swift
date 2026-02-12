import SwiftUI
import AVFoundation

struct SlotView: View {
    var material: MaterialDescoberto?
    var placeholder: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 100, height: 100)
                .overlay(
                    Circle().stroke(Color.white, style: StrokeStyle(lineWidth: 2, dash: [5]))
                )
            
            if let mat = material {
                Image(mat.assetImagem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .transition(.scale)
            } else {
                Text(placeholder)
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

