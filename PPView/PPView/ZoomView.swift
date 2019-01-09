import UIKit


@IBDesignable
public class ZoomView: UIView
{
    @IBInspectable
    public var scale: CGFloat = 1.0
    {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    @IBInspectable
    public var image: UIImage? = nil
    {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    override public var intrinsicContentSize: CGSize
    {
        if let image = image {
            let s: CGFloat = scale * image.scale / self.contentScaleFactor
            return image.size * s
        }
        #if TARGET_INTERFACE_BUILDER
        return frame.size
        #endif
        return super.intrinsicContentSize
    }

    override public func draw(_ rect: CGRect)
    {
        super.draw(rect)

        guard let image = image else { return }

        // Draw image at native pixel resolution instead of point
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .none
        let s: CGFloat = scale * image.scale / self.contentScaleFactor
        image.draw(in: CGRect(origin: .zero, size: image.size * s))
    }

    override public func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()

        self.awakeFromNib()
    }
}

