import UIKit


class BarView1: DrawView
{
    override public func draw(_ rect: CGRect)
    {
        super.draw(rect)

        let image = _drawBars(numBars: 10)

        // Draw image in the view
        if !antialiasing {
            UIGraphicsGetCurrentContext()?.interpolationQuality = .none
        }
        image.draw(at: CGPoint.zero)

        self.image = image
    }

    private func _drawBars(numBars: CGFloat) -> UIImage
    {
        let drawSize = CGSize(numBars * contentScaleFactor, bounds.size.height * contentScaleFactor)

        // Draw into a bitmap with size equal to number of pixels
        UIGraphicsBeginImageContextWithOptions(drawSize, false, contentScaleFactor)
        let context = UIGraphicsGetCurrentContext()!
        context.setShouldAntialias(antialiasing)

        // Clear the background with white
        let rectangle = CGRect(origin: CGPoint.zero, size: drawSize)
        context.setFillColor(UIColor.white.cgColor)
        context.addRect(rectangle)
        context.drawPath(using: .fill)

        // Prepare to draw black lines
        context.setFillColor(UIColor.black.cgColor)

        // Draw (black lines)
        for p in 0..<Int(numBars) {
            if p % 2 == 0 {
                // Draw bars at pixel width
                context.addRect(CGRect(x: CGFloat(p) * contentScaleFactor, y: 0, width: 1 * contentScaleFactor, height: drawSize.height))
               context.drawPath(using: .fill)
           }
        }

        // Make an image from the image context, but with the same scale value as the view
        let cgimage = context.makeImage()
        let uiimage = UIImage(cgImage: cgimage!, scale: contentScaleFactor, orientation: .up)

        UIGraphicsEndImageContext()

        return uiimage
    }
}


class BarView2: DrawView
{
    override public func draw(_ rect: CGRect)
    {
        super.draw(rect)

        let image = _drawBars(numBars: 100)

        // Draw image in the view
        if !antialiasing {
            UIGraphicsGetCurrentContext()?.interpolationQuality = .none
        }
        image.draw(at: CGPoint.zero)

        self.image = image
    }

    private func _drawBars(numBars: CGFloat) -> UIImage
    {
        let drawSize = CGSize(numBars, bounds.size.height * contentScaleFactor)

        // Draw into a bitmap with size equal to number of pixels
        UIGraphicsBeginImageContextWithOptions(drawSize, true, contentScaleFactor)
        let context = UIGraphicsGetCurrentContext()!
        context.setShouldAntialias(antialiasing)

        // Clear the background with white
        let rectangle = CGRect(origin: CGPoint.zero, size: drawSize)
        context.setFillColor(UIColor.white.cgColor)
        context.addRect(rectangle)
        context.drawPath(using: .fill)

        // Prepare to draw black lines
        context.setFillColor(UIColor.black.cgColor)

        // Draw (black lines)
        for p in 0..<Int(numBars) {
            if p % 2 == 0 {
                // Draw bars at pixel width
                context.addRect(CGRect(x: CGFloat(p), y: 0, width: 1, height: drawSize.height))
                context.drawPath(using: .fill)
            }
        }

        // Make an image from the image context, but with the same scale value as the view
        let cgimage = context.makeImage()
        let uiimage = UIImage(cgImage: cgimage!, scale: contentScaleFactor, orientation: .up)

        UIGraphicsEndImageContext()

        return uiimage
    }
}

class BarView3: DrawView
{
    override public func draw(_ rect: CGRect)
    {
        super.draw(rect)

        let patterns: [String] = [
            "00000000000",    // quiet zone
            "11010010000",    // start code B
            "10011000010",    // ‘h’
            "10110010000",    // ‘e’
            "11001010000",    // ‘l’
            "11001010000",    // ‘l’
            "10001111010",    // ‘o’
            "10001001100",    // modulo 103 checksum
            "1100011101011",  // stop character
            "00000000000"     // quiet zone
        ]
        let image = _drawBitString(patterns.joined(), barWidth: 1)

        // Draw image in the view
        if !antialiasing {
            UIGraphicsGetCurrentContext()?.interpolationQuality = .none
        }
        image.draw(at: CGPoint.zero)

        self.image = image
    }

    private func _drawBitString(_ bitString: String, barWidth: Int = 1) -> UIImage
    {
        let drawSize = CGSize(CGFloat(bitString.count * barWidth), self.bounds.size.height)

        // Draw into an image with scale 1, where 1 point is 1 pixel
        UIGraphicsBeginImageContextWithOptions(drawSize, true, 1.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setShouldAntialias(antialiasing)

        // Draw (black lines)
        for (i, c) in bitString.enumerated() {
            context.setFillColor((c == "1" ? UIColor.black : UIColor.white).cgColor)
            context.addRect(CGRect(x: CGFloat(i * barWidth), y: 0, width: CGFloat(barWidth), height: drawSize.height))
            context.drawPath(using: .fill)
        }

        // Make an image from the image context, with scale equal to the view.
        let cgimage = context.makeImage();
        let uiimage = UIImage(cgImage: cgimage!, scale: contentScaleFactor, orientation: .up)

        UIGraphicsEndImageContext()

        return uiimage
    }
}
