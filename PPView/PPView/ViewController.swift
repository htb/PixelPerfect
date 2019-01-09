import UIKit


class ViewController: UIViewController
{
    @IBOutlet weak var _zoomView: ZoomView!
    @IBOutlet weak var _antialiasingSwitch: UISwitch!
    @IBOutlet weak var _zoomViewSwitch: UISwitch!

    private var _drawView: DrawView!
    private var _drawView2: DrawView!


    override func viewDidLoad()
    {
        super.viewDidLoad()

//        let rect2 = CGRect(origin: CGPoint(2, 100), size: CGSize(100/UIScreen.main.scale, 6))
//        let v = UIView(frame: rect2)
//        v.backgroundColor = UIColor.red
//        view.addSubview(v)

        let rect = CGRect(origin: CGPoint(2, 40), size: CGSize(375, 50))

        //let drawView = DrawView(frame: rect)
        //let drawView = LineView(frame: rect)
        //let drawView = BarView1(frame: rect)
        //let drawView = BarView2(frame: rect)
        //let drawView = BarView3(frame: rect)  // with hardcoded barcode
        let drawView = BarcodeView(frame: rect)
        drawView.code = "hello"


        _drawView = drawView

        _drawView.backgroundColor = UIColor.blue
        _drawView.contentMode = .topLeft
        _drawView.antialiasing = _antialiasingSwitch.isOn
        view.addSubview(_drawView)
    }

    @IBAction func _zoom(_ sender: UIButton)
    {
        if let image = (_zoomViewSwitch.isOn ? _drawView.capture() : _drawView.image) {
            _zoomView.image = image
            _zoomView.scale = CGFloat(sender.tag)
        }
    }

    @IBAction func _antialiasingSwitchChanged(_ sender: UISwitch)
    {
        _drawView.antialiasing = sender.isOn
    }

    // MARK: - Screenshot

    @IBAction func _screenShot(_ sender: Any)
    {
        if let image = view.capture() {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let error = error {
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }

    func showAlertWith(title: String, message: String)
    {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
