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

open class PFSWebViewController: PFSViewController, WKUIDelegate, WKNavigationDelegate {
    
    public var webView: WKWebView!
    
    public var bridge: WebViewJavascriptBridge!
    

    
    public var webAPI: PFSTargetType?
    
    var progressView: UIProgressView!
    
    var bridgeURL = [kOldProtocolScheme,
                     kNewProtocolScheme,
                     kQueueHasMessage,
                     kBridgeLoaded]
    
    public var url: String?
    
    override open func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        
        WebViewJavascriptBridge.enableLogging()
        
        bridge = WebViewJavascriptBridge(forWebView: webView)
        
        bridge?.setWebViewDelegate(self)
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        progressView.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        navigationController?.navigationBar.addSubview(progressView)
        let navigationBarBounds = self.navigationController?.navigationBar.bounds
        progressView.frame = CGRect(x: 0, y: navigationBarBounds!.size.height - 2, width: navigationBarBounds!.size.width, height: 2)
    }
    
    public func isWebViewJavascriptBridgeURL(url: URL) -> Bool {
        guard self.isSchemeMatch(url: url) else {
            return false
        }
        return self.isBridgeLoadedURL(url: url) || self.isQueueMessageURL(url: url)
    }
    
    public func isSchemeMatch(url: URL) -> Bool {
        let scheme = url.scheme?.lowercased()
        return scheme == kNewProtocolScheme || scheme == kOldProtocolScheme
    }
    
    public func isQueueMessageURL(url: URL) -> Bool {
        let host = url.host?.lowercased()
        return self.isSchemeMatch(url: url) && host == kQueueHasMessage
    }
    
    public func isBridgeLoadedURL(url: URL) -> Bool {
        let host = url.host?.lowercased()
        return self.isSchemeMatch(url: url) && host == kBridgeLoaded
    }
    
    private final func url(for target: PFSTargetType) -> URL {
        if target.path.isEmpty {
            return target.baseURL
        }
        
        return target.baseURL.appendingPathComponent(target.path)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)        
    }
    
    //observer
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let change = change else { return }
//        if context != &myContext {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//            return
//        }
        
//        if keyPath == "title" {
//            if let title = change[NSKeyValueChangeKey.newKey] as? String {
//                self.navigationItem.title = title
//            }
//            return
//        }
        if keyPath == "estimatedProgress" {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                progressView.progress = progress;
            }
            return
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, self.isWebViewJavascriptBridgeURL(url: url) {
            decisionHandler(.cancel)
        }
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
       
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }
    
    open func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    }
    
    open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Swift.Error) {

    }
    
    open func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {

    }
    
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true

    }
    
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Swift.Error) {
        progressView.isHidden = true
    }
    
    open func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

    }
    
    open func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    }
    
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    deinit {
//        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        
        //remove progress bar from navigation bar
        progressView.removeFromSuperview()

    }

}
