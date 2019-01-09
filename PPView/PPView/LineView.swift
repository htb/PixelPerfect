import UIKit


class LineView: DrawView
{
    override public func draw(_ rect: CGRect)
    {
        super.draw(rect)

        let size = rect.size

        // Start a new image graphics content to draw our line to
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setShouldAntialias(antialiasing)

        // Clear the background with white
        context.setFillColor(UIColor.white.cgColor)
        context.addRect(CGRect(origin: CGPoint.zero, size: size))
        context.drawPath(using: .fill)

        // Draw a black line from the bottom left to top right
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: 0, y: size.height))
        context.addLine(to: CGPoint(x: size.width, y: 0))
        context.strokePath()

        // Make an image from the image context
        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        // Draw image in the view (using the now current graphics context)
        if !antialiasing {
            UIGraphicsGetCurrentContext()?.interpolationQuality = .none
        }
        image.draw(at: CGPoint.zero)

        // Set the image we will use for zooming
        self.image = image
    }
}
