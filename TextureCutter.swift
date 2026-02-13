import SpriteKit
import UIKit

struct TextureCutter {
    static func cutTexture(sourceTexture: SKTexture, points: [CGPoint]) -> SKTexture? {
        guard !points.isEmpty else {
            return sourceTexture
        }
        
        let cgImage = sourceTexture.cgImage()
        
        let pixelWidth = cgImage.width
        let pixelHeight = cgImage.height
        
        let textureSize = sourceTexture.size()
        let sx = CGFloat(pixelWidth) / max(textureSize.width, 1)
        let sy = CGFloat(pixelHeight) / max(textureSize.height, 1)
        
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(pixelWidth), height: CGFloat(pixelHeight)), format: format)
        
        let image = renderer.image { ctx in
            let context = ctx.cgContext
            
            let rect = CGRect(x: 0, y: 0, width: CGFloat(pixelWidth), height: CGFloat(pixelHeight))
            context.draw(cgImage, in: rect)
            
            let transformedPoints = points.map { p in
                CGPoint(x: p.x * sx, y: CGFloat(pixelHeight) - (p.y * sy))
            }
            
            let path = UIBezierPath()
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            
            if let first = transformedPoints.first {
                path.move(to: first)
                for point in transformedPoints.dropFirst() {
                    path.addLine(to: point)
                }
            }
            
            let lineWidth = max(8 * max(sx, sy), 1)
            
            context.setBlendMode(.clear)
            context.setLineWidth(lineWidth)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            
            context.addPath(path.cgPath)
            context.strokePath()
        }
        
        return SKTexture(image: image)
    }
}
