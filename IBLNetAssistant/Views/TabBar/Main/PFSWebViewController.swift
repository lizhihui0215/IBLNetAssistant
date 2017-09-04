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
        webConfiguration.ignoresViewportScaleLimits = true
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
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
        
        self.navigationController?.isNavigationBarHidden = true

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
        
        
        
        
        self.webAPI = IBLAPITarget.web(["account": user.account,
                                                        "accessToken": user.accessToken!])

        self.reload().drive().disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func reload() -> Driver<Bool>  {
        guard let webAPI = self.webAPI else { return Driver.just(false) }
        
        let baseURL = "http://\(self.user!.selectedSchool!.serverInner!)"
        
        return reachable(url: baseURL).flatMapLatest {
            if ($0) {
                IBLAPITarget.setBaseURL(URL: "http://\(self.user!.selectedSchool!.serverInner!)")
            }else {
                IBLAPITarget.setBaseURL(URL: "http://\(self.user!.selectedSchool!.serverOut!)")
            }
            
            let requestURL = self.url(for: webAPI)
            
            var request = URLRequest(url: requestURL)
            
            request.httpMethod = webAPI.method.rawValue
            
            request.allHTTPHeaderFields = webAPI.headers
            
            let encodingRequest = try? URLEncoding.default.encode(request, with: webAPI.parameters)
            
            self.webView.customUserAgent = "IBILLING_IOS_NETHELPER_APP"
            
            self.webView.load(encodingRequest!)
            
            return Driver.just(true)
        }
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
        self.startAnimating()
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Swift.Error) {
        print(error)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.stopAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Swift.Error) {
        self.stopAnimating()
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    }
    
    func logout()  {
        if self.user!.loginModel != "0" {
            self.domain.logout(account: self.user!.account, auth: self.user!.auth!).drive()
        }
        PFSRealm.shared.update(obj: PFSDomain.login()!, {
            $0.isLogin = false
        })
        self.performSegue(withIdentifier: "toLogin", sender: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toLogin" {
            let loginViewController = (segue.destination as! UINavigationController).topViewController  as! IBLLoginViewController
            
            loginViewController.viewModel = IBLLoginViewModel(action: loginViewController,
                                                              domain: IBLLoginDomain(),
                                                              school: (self.user!.selectedSchool)!)
        }
    }

}
