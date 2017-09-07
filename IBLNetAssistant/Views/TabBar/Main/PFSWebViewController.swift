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
//        webConfiguration.ignoresViewportScaleLimits = true
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

        let baseURL = "http://\(self.user!.selectedSchool!.serverInner!)/ibillingportal/userservice/index.do"

        self.resetURL(url: baseURL, isSwitchToOut: true).flatMapLatest { _ -> Driver<Bool> in
            return self.reload(webAPI: self.webAPI!)
        }.drive().disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetURL(url: String, isSwitchToOut: Bool) -> Driver<Bool> {
        IBLAPITarget.setBaseURL(URL: url)

        guard isSwitchToOut else {
            
            return Driver.just(true)
        }
        
        return reachable(url: url).flatMapLatest {
            if !$0 {
                IBLAPITarget.setBaseURL(URL: "http://\(self.user!.selectedSchool!.serverOut!)/ibillingportal/userservice/index.do")

                return Driver.just(true)
            }
            
            return Driver.just(false)
        }
    }
    
    
    open func reload(webAPI: PFSTargetType) -> Driver<Bool>  {
        
        var request = URLRequest(url: webAPI.baseURL)
        
        request.httpMethod = webAPI.method.rawValue
        
        request.allHTTPHeaderFields = webAPI.headers
        
        let encodingRequest = try? URLEncoding.default.encode(request, with: webAPI.parameters)
        
        self.webView.customUserAgent = "IBILLING_IOS_NETHELPER_APP"
        
        self.webView.load(encodingRequest!)
        
        return Driver.just(true)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("\n=========================================\n decidePolicyFor:navigationAction \(navigationAction) \n=========================================\n ")
        
        if navigationAction.navigationType == .linkActivated {
            let url = navigationAction.request.url!
            
            
            let baseURL = url.absoluteString.components(separatedBy: ";")[0]
            
            var API = self.webAPI!
            if var query = url.queryParameters {
                let parameters = ["account": user!.account,
                                  "accessToken": user!.accessToken!]
                query += parameters
                API = IBLAPITarget.web(query)
            }
            
            let requestURL = "\(baseURL)"
            
            self.resetURL(url: requestURL, isSwitchToOut: false).flatMapLatest { _ -> Driver<Bool> in
                return self.reload(webAPI: API)
                }.drive().disposed(by: disposeBag)
            decisionHandler(.cancel)
        }else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        let response = navigationResponse.response as! HTTPURLResponse
        
        if response.statusCode == 500 {
            self.logout()
            decisionHandler(.cancel)
            return
        }
        print("\n=========================================\n decidePolicyFor:navigationResponse \(navigationResponse) \n=========================================\n ")

        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.startAnimating()
        print("\n=========================================\n didStartProvisionalNavigation:navigation \(navigation) \n=========================================\n ")

    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("\n=========================================\n didReceiveServerRedirectForProvisionalNavigation:navigation \(navigation) \n=========================================\n ")
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Swift.Error) {
        print("\n=========================================\n didFailProvisionalNavigation:navigation\(navigation) :error\(error) \n=========================================\n ")

    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("\n=========================================\n didCommit: navigation\(navigation) \n=========================================\n ")

    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.stopAnimating()
        print("\n=========================================\n didFinish: navigation\(navigation) \n=========================================\n ")

    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Swift.Error) {
        self.stopAnimating()
        print("\n=========================================\n didFail: navigation\(navigation) :error\(error) \n=========================================\n ")

    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("\n=========================================\n didReceive: challenge\(challenge) \n=========================================\n ")

    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("\n=========================================\n webViewWebContentProcessDidTerminate \n=========================================\n ")
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

extension URL {
    var queryParameters: [String : String]? {
        if let query = self.query {
            var parameters = [String : String]()
            let parameterPires = query.components(separatedBy: "&")
            
            for parameterPire in parameterPires {
                let keyValue = parameterPire.components(separatedBy: "=")
                
                let key = keyValue[0]
                
                let value = keyValue[1]
                
                parameters += [key : value]
            }
            
            return parameters
        }
        
        return nil
    }
}
