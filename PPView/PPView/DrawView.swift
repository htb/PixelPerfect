import UIKit


public class DrawView : UIView
{
    public var antialiasing: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    public internal(set) var image: UIImage? = nil
}

