import UIKit


extension UIView
{
    public func capture() -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .none
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


extension UIImage
{
    public func resized(scale: CGFloat, interpolationQuality: CGInterpolationQuality = .none) -> UIImage
    {
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = interpolationQuality
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
}


extension UIImage
{
    public static func barcode128(from code: String) -> UIImage?
    {
        let data = code.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            if let output = filter.outputImage {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}



extension CGPoint
{
    public init(_ x: CGFloat, _ y: CGFloat)
    {
        self.init(x: x, y: y)
    }
}

extension CGSize
{
    public init(_ width: CGFloat, _ height: CGFloat)
    {
        self.init(width: width, height: height)
    }

    public static func * (lhs: CGSize, rhs: CGFloat) -> CGSize
    {
        return CGSize(lhs.width * rhs, lhs.height * rhs)
    }

    public static func *= (lhs: inout CGSize, rhs: CGFloat)
    {
        lhs.width *= rhs
        lhs.height *= rhs
    }

    public static func / (lhs: CGSize, rhs: CGFloat) -> CGSize
    {
        return CGSize(lhs.width / rhs, lhs.height / rhs)
    }

    public static func /= (lhs: inout CGSize, rhs: CGFloat)
    {
        lhs.width /= rhs
        lhs.height /= rhs
    }
}
