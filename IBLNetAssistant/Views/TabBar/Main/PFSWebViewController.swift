//
//  PFSWebViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 25/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import WebViewJavascriptBridge
import struct Alamofire.URLEncoding
import class Moya.Endpoint
import RxCocoa
import Result
import Moya


class PFSWebViewController: PFSViewController, WKUIDelegate, WKNavigationDelegate {
    
    var domain: IBLWebDomain = IBLWebDomain()

    public var webView: WKWebView!
    
    var bridge: WebViewJavascriptBridge?
    
    var user: IBLUser?

    public var webAPI: PFSTargetType?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    private final func url(for target: PFSTargetType) -> URL {
        if target.path.isEmpty {
            return target.baseURL
        }
        
        return target.baseURL.appendingPathComponent(target.path)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let user = PFSDomain.login()  else {
            self.alert(message: "登陆用户为空！").drive().disposed(by: disposeBag)
            return
        }
        
        self.user = user
        
        WebViewJavascriptBridge.enableLogging()
        
        bridge = WebViewJavascriptBridge(forWebView: webView)
        
        bridge?.setWebViewDelegate(self)
        
        bridge?.registerHandler("logout", handler: {[weak self] data, responseCallback in
            self?.logout()
        })
        
        
        IBLAPITarget.setBaseURL(URL: "http://\((user.selectedSchool?.serverInner)!)")
        
        
        self.webAPI = IBLAPITarget.web(["account": user.account,
                                                        "accessToken": user.accessToken!])

        self.reload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func reload()  {
        guard let webAPI = self.webAPI else { return }
        
        let requestURL = self.url(for: webAPI)
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = webAPI.method.rawValue
        
        request.allHTTPHeaderFields = webAPI.headers
        
        let encodingRequest = try? URLEncoding.default.encode(request, with: webAPI.parameters)
        
        webView.customUserAgent = "IBILLING_IOS_NETHELPER_APP"
        
        webView.load(encodingRequest!)
    }
    
    
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        let response = navigationResponse.response as! HTTPURLResponse
        
        if response.statusCode == 500 {
            self.logout()
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Swift.Error) {
        print(error)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Swift.Error) {
        
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    }
    
    func logout()  {
        if self.user!.loginModel != "0" {
            self.domain.logout(account: self.user!.account, auth: self.user!.auth!).drive(onNext: { _ in
                self.performSegue(withIdentifier: "toLogin", sender: nil)
            }).disposed(by: disposeBag)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toLogin" {
            let loginViewController = segue.destination as! IBLLoginViewController
            
            loginViewController.viewModel = IBLLoginViewModel(action: loginViewController,
                                                              domain: IBLLoginDomain(),
                                                              school: (self.user!.selectedSchool)!)
        }
    }

}
