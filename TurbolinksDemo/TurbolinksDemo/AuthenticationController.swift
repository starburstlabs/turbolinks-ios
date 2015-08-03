import UIKit
import WebKit

protocol AuthenticationControllerDelegate: class {
    func prepareWebViewConfiguration(configuration: WKWebViewConfiguration, forAuthenticationController authenticationController: AuthenticationController)
    func authenticationControllerDidAuthenticate(authenticationController: AuthenticationController)
}

class AuthenticationController: UIViewController, WKNavigationDelegate {
    var accountLocation: NSURL?
    weak var delegate: AuthenticationControllerDelegate?

    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        self.delegate?.prepareWebViewConfiguration(configuration, forAuthenticationController: self)

        let webView = WKWebView(frame: CGRectZero, configuration: configuration)
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        webView.navigationDelegate = self

        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.opaque = false
        webView.backgroundColor = UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1)

        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: [ "view": webView ]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: [ "view": webView ]))

        if let newSessionLocation = accountLocation?.URLByAppendingPathComponent("session/new") {
            webView.loadRequest(NSURLRequest(URL: newSessionLocation))
        }
    }

    // MARK: WKNavigationDelegate

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let URL = navigationAction.request.URL where URL == accountLocation {
            decisionHandler(.Cancel)
            delegate?.authenticationControllerDidAuthenticate(self)
        } else {
            decisionHandler(.Allow)
        }
    }
}