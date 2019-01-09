import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    public var identifiedTypes: [AVMetadataObject.ObjectType] = [.ean8, .ean13, .upce, .itf14, .code39, .code128]//[.qr, .ean8, .ean13, .upce, .itf14, .code39, .code128]
    public var acceptedTypes  : [AVMetadataObject.ObjectType] = [.qr, .code128]

    private var _captureDevice: AVCaptureDevice? = nil
    private let _captureSession = AVCaptureSession()
    private var _captureDeviceInput: AVCaptureDeviceInput? = nil
    private let _captureMetadataOutput = AVCaptureMetadataOutput()
    private var _videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var _overlayLayer = CAShapeLayer()
    private let _impact = UIImpactFeedbackGenerator(style: .heavy)
    private var _foundCode: String? = nil


    // MARK: UI outlets

    @IBOutlet weak var _scannerView: UIView!
    @IBOutlet weak var _codeLabel: UILabel!
    @IBOutlet weak var _codeTypeLabel: UILabel!
    @IBOutlet weak var _manualFocusInfoView: UIView!

    @IBAction func _rescan(_ sender: Any) { _rescan() }

    @IBAction func _unlockFocus(_ sender: Any)
    {
        _continuousAutoFocus()
        _manualFocusInfoView.isHidden = true
    }


    // MARK: - UIViewController

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        _startAV()
        _manualFocusInfoView.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool)
    {
        _shutdownAV()

        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        _videoPreviewLayer?.frame = _scannerView.bounds
        _overlayLayer.frame = _scannerView.bounds
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let screenSize = view.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: view).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: view).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)

            _manualFocus(at: focusPoint)
            _manualFocusInfoView.isHidden = false
        }
    }

    // MARK: AV stuff

    private func _rescan()
    {
        _foundCode = nil
        _codeLabel.text = nil
        _codeTypeLabel.text = nil

        // Start video capture
        if !_captureSession.isRunning {
            _captureSession.startRunning()
        }
    }

    func _codeFound(type: AVMetadataObject.ObjectType, code: String)
    {
        if !acceptedTypes.contains(type) || (_foundCode != nil && code != _foundCode)
        {
            // Code mismatch... should press "Rescan" first
            _overlayLayer.lineWidth = 2.0
            _overlayLayer.strokeColor = UIColor.red.cgColor
            return
        }


        _codeLabel.text = code
        _codeTypeLabel.text = "(\(type.rawValue))"
        _overlayLayer.lineWidth = 2.0
        _overlayLayer.strokeColor = UIColor.green.cgColor

        if code != _foundCode
        {
            // New code found
            _foundCode = code

            // Sound and impact
            _impact.impactOccurred()
            AudioServicesPlaySystemSound(SystemSoundID(1108))  // Camera shutter
        }
    }


    private func _askForCameraPermission()
    {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in

            guard let captureDevice = AVCaptureDevice.default(for: .video),
                AVCaptureDevice.DiscoverySession(deviceTypes: [captureDevice.deviceType], mediaType: .video, position: .back).devices.count != 0 else
            {
                self._presentAlert(title: "Camera missing")
                return
            }

            switch AVCaptureDevice.authorizationStatus(for: .video)
            {
            case .authorized:
                DispatchQueue.main.async { self._startAV() }
            case .denied, .restricted:
                DispatchQueue.main.async { self._shutdownAV() }
                let title = "Missing authorization to use camera"
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Go to settings", style: .default) { (alertAction) in
                    UIApplication.openApplicationSettings()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancelAction)
                alert.addAction(settingsAction)
                alert.preferredAction = settingsAction
                DispatchQueue.main.async { self.present(alert, animated: true) }
            case .notDetermined:
                self._askForCameraPermission()
            }
        }
    }

    private func _startAV()
    {
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            _presentAlert(title: "Failed to get camera device")
            return
        }
        _captureDevice = captureDevice

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session
            _captureSession.addInput(input)
            _captureDeviceInput = input

            // initialize an AVCaptureMetadataOutput object and set it as the output device to the capture session
            let captureMetadataOutput = AVCaptureMetadataOutput()
            _captureSession.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the callback
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = identifiedTypes

            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
            _videoPreviewLayer = AVCaptureVideoPreviewLayer(session: _captureSession)
            _videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            _videoPreviewLayer.frame = _scannerView.layer.bounds
            _overlayLayer.frame = _videoPreviewLayer.frame

            _scannerView.layer.insertSublayer(_overlayLayer, at: 0)
            _scannerView.layer.insertSublayer(_videoPreviewLayer, at: 0)

            _overlayLayer.fillColor = UIColor.clear.cgColor
            _overlayLayer.lineWidth = 2.0

            _rescan()

        } catch {
            _presentAlert(title: "Failed to get camera device")
            return
        }


    }

    private func _shutdownAV()
    {
        _captureSession.stopRunning()
        if let input = _captureDeviceInput { _captureSession.removeInput(input) }
        _captureSession.removeOutput(_captureMetadataOutput)
        _videoPreviewLayer?.removeFromSuperlayer()
        _overlayLayer.removeFromSuperlayer()
    }


    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        // Check if the metadataObjects array is not nil and it contains at least one object
        if metadataObjects.count == 0 {
            _overlayLayer.path = nil
//            _codeLabel.text = nil
//            _codeTypeLabel.text = nil
            return
        }

        // Get the metadata object

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if let code = metadataObj.stringValue {
            _codeFound(type: metadataObj.type, code: code)
        }

        // Draw a frame
        if
            let metaData = metadataObjects.first,
            let transformed = _videoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
        {
            let identifiedCorners = transformed.corners
            let path = _createShapePath(identifiedCorners)
            _overlayLayer.path = path.cgPath
        }
    }

    private func _createShapePath(_ points: [CGPoint]) -> UIBezierPath
    {
        let path = UIBezierPath()
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        path.close()
        return path
    }


    // MARK: - Camera focus

    private func _manualFocus(at focusPoint: CGPoint)
    {
        if let device = _captureDevice {
            do {
                try device.lockForConfiguration()

                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
                //device.focusMode = .locked
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            }
            catch {
                // just ignore
            }
        }
    }

    private func _continuousAutoFocus()
    {
        if let device = _captureDevice {
            do {
                try device.lockForConfiguration()

                device.focusMode = .continuousAutoFocus
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            }
            catch {
                // just ignore
            }
        }
    }


    // MARK: - Misc.

    private func _presentAlert(title: String, message: String? = nil)
    {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        DispatchQueue.main.async { self.present(alert, animated: true) }
    }
}


// MARK: - Some extensions

extension UIApplication
{
    static func openApplicationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if self.shared.canOpenURL(settingsUrl) {
            self.shared.open(settingsUrl, completionHandler: { (success) in
                //Logger.default.debug("Settings opened: \(success)")
            })
        }
    }
}
