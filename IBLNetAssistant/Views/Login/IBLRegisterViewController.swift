//
//  IBLRegisterViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 03/08/2017.
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

class IBLRegisterViewController: PFSViewController, WKUIDelegate, WKNavigationDelegate {

    var domain: IBLRegisterDomain = IBLRegisterDomain()
    
    public var webView: WKWebView!
    
    var bridge: WebViewJavascriptBridge?
    
    var school: IBLSchool?
    
    public var webAPI: PFSTargetType?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        let frame = CGRect(x: 0,
                           y: 20,
                           width: UIScreen.main.applicationFrame.width,
                           height: UIScreen.main.applicationFrame.height - 20)

        webView.frame = frame
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
        guard let school = PFSDomain.cachedSchool()  else {
            self.alert(message: "无缓存学校！").drive().disposed(by: disposeBag)
            return
        }
        
        self.school = school
        
        WebViewJavascriptBridge.enableLogging()
        
        bridge = WebViewJavascriptBridge(forWebView: webView)
        
        bridge?.setWebViewDelegate(self)
        
        bridge?.registerHandler("toLogin", handler: {[weak self] data, responseCallback in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        IBLAPITarget.setBaseURL(URL: "http://\((school.serverInner)!)")
        
        self.webAPI = IBLAPITarget.registerAccount

        self.reload().drive().disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    open func reload()  {
//        guard let webAPI = self.webAPI else { return }
//        
//        let requestURL = self.url(for: webAPI)
//        
//        var request = URLRequest(url: requestURL)
//        
//        request.httpMethod = webAPI.method.rawValue
//        
//        request.allHTTPHeaderFields = webAPI.headers
//        
//        let encodingRequest = try? URLEncoding.default.encode(request, with: webAPI.parameters)
//        
//        webView.customUserAgent = "IBILLING_IOS_NETHELPER_APP"
//        
//        webView.load(encodingRequest!)
//    }
    
    open func reload() -> Driver<Bool>  {
        guard let webAPI = self.webAPI else { return Driver.just(false) }
        
        let baseURL = "http://\(self.school!.serverInner!)"
        
        return reachable(url: baseURL).flatMapLatest {
            if ($0) {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school!.serverInner!)")
            }else {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school!.serverOut!)")
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }

}
