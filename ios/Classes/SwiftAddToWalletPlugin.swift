import Flutter
import PassKit
import UIKit

import Flutter
import UIKit

class PKAddPassButtonNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, channel: FlutterMethodChannel) {
        self.messenger = messenger
        self.channel = channel
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return PKAddPassButtonNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args as! [String: Any],
            binaryMessenger: messenger,
            channel: channel)
    }
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

class PKAddPassButtonNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _pass: FlutterStandardTypedData?
    private var _issuerData: String?
    private var _signature: String?
    private var _width: CGFloat
    private var _height: CGFloat
    private var _key: String
    private var _channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any],
        binaryMessenger messenger: FlutterBinaryMessenger?,
        channel: FlutterMethodChannel
    ) {
        _view = UIView()
        _pass = args["pass"] as? FlutterStandardTypedData
        _issuerData = args["issuerData"] as? String
        _signature = args["signature"] as? String
        _width = args["width"] as? CGFloat ?? 140
        _height = args["height"] as? CGFloat ?? 30
        _key = args["key"] as! String
        _channel = channel
        super.init()
        createAddPassButton()
    }

    func view() -> UIView {
        _view
    }

    func createAddPassButton() {
        let passButton = PKAddPassButton(addPassButtonStyle: PKAddPassButtonStyle.black)
        passButton.frame = CGRect(x: 0, y: 0, width: _width, height: _height)
        passButton.addTarget(self, action: #selector(passButtonAction), for: .touchUpInside)
        _view.addSubview(passButton)
    }

    @objc func passButtonAction() {
        if (_pass != nil) {
            var newPass: PKPass
            do {
                newPass = try PKPass(data: _pass!.data)
            } catch {
                print("No valid Pass data passed")
                return
            }
            guard let controller = PKAddPassesViewController(pass: newPass) else {
                print("View controller messed up")
                return
            }
            guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
                print("Root VC unavailable")
                return
            }
            rootVC.present(controller, animated: true)
            _invokeAddButtonPressed()
        }
        else if(_issuerData != nil && _signature != nil) {
            if #available(iOS 16.4, *) {
                let issuerData: Data = _issuerData!.data(using: .utf8)!
                let signature: Data = _signature!.data(using: .utf8)!
                if let controllerWithIssuerData = ExceptionHandler.safeAddPassesViewController(withIssuerData: issuerData, signature: signature) {
                    guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
                        print("Root VC unavailable")
                        return
                    }
                    rootVC.present(controllerWithIssuerData, animated: true)
                    _invokeAddButtonPressed()
                }
                else {
                    print("No valid issuer data and signature passed")
                    return
                }
            } else {
                print("icloud binding only available from iOS 16.4")
                return
            }
        }
        else {
            print("Pass or issuerData and signature must not null")
            return
        }
    }
    
    func _invokeAddButtonPressed() {
        _channel.invokeMethod(AddToWalletEvent.addButtonPressed.rawValue, arguments: ["key": _key])
    }
}

public class SwiftAddToWalletPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "add_to_wallet", binaryMessenger: registrar.messenger())
    let instance = SwiftAddToWalletPlugin()
    let factory = PKAddPassButtonNativeViewFactory(messenger: registrar.messenger(), channel: channel)
    registrar.register(factory, withId: "PKAddPassButton")
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        return result(FlutterMethodNotImplemented)
    }
}
