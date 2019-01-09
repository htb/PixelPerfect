import UIKit


class BarcodeView: DrawView
{
    public var code: String? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func draw(_ rect: CGRect)
    {
        super.draw(rect)

        guard let code = code else { self.image = nil; return }

        // Get our barcode using CIFilter
        let image = UIImage.barcode128(from: code)!
        self.image = image

        // This created an image with a bar size of 1 pixel and at scale 1

        // First make sure we do not get any smoothing when resizing
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .none

        // Then draw to 1:1 pixel size
        image.draw(in: CGRect(origin: .zero, size: image.size / contentScaleFactor))

        // The image in the view should now have a bar width of one, corresponding to a full pixel
    }
}
