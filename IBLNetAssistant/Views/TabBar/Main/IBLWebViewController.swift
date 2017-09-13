//
//  IBLWebViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 10/09/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import WebKit
import RxCocoa

class IBLWebViewController: PFSWebViewController {
    var domain: IBLWebDomain = IBLWebDomain()

    var user: IBLUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        bridge.registerHandler("logout", handler: {[weak self] data, responseCallback in
            self?.logout()
        })
        
        bridge.registerHandler("ibl_web_back", handler: {[weak self] data, responseCallback in
            let viewControllers = self?.navigationController?.viewControllers
            let count = (viewControllers?.count)! - 2
            let isRefresh = data as? String
            if  count > 0, isRefresh == "1" {
                let webViewController = viewControllers?[count] as! IBLWebViewController
                
                webViewController.reload()
            }
            
            self?.navigationController?.popViewController(animated: true)
            
        })
        
        if let webAPI = self.webAPI {
            self.reload(webAPI: webAPI).drive().disposed(by: disposeBag)
        }else {
            self.webAPI = IBLAPITarget.web(["account": user.account,
                                            "accessToken": user.accessToken!,
                                            "allow": "true"])
            
            let baseURL = "http://\(self.user!.selectedSchool!.serverInner!)/ibillingportal/userservice/index.do"
            self.resetURL(url: baseURL, isSwitchToOut: true).flatMapLatest { _ -> Driver<Bool> in
                return self.reload(webAPI: self.webAPI!)
                }.drive().disposed(by: disposeBag)
        }
        
        self.url = self.webAPI?.baseURL.absoluteString
    }
    
    func isRootController() -> Bool {
        return  self.navigationController?.viewControllers.count == 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = self.isRootController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func reload() {
        self.resetURL(url: self.url!, isSwitchToOut: false).flatMapLatest { [weak self] _ in
            return (self?.reload(webAPI: (self?.webAPI)!))!
        }.drive().disposed(by: disposeBag)
    }
    
    func resetURL(url: String, isSwitchToOut: Bool) -> Driver<Bool> {
        IBLAPITarget.setBaseURL(URL: url)
        
        guard isSwitchToOut else {
            
            return Driver.just(true)
        }
        
        return reachable(url: url).flatMapLatest {
            if !$0 {
                IBLAPITarget.setBaseURL(URL: "http://\(self.user.selectedSchool!.serverOut!)/ibillingportal/userservice/index.do")
                
                return Driver.just(true)
            }
            
            return Driver.just(false)
        }
    }
    
    func logout()  {
        if self.user.loginModel != "0" {
            self.domain.logout(account: self.user!.account, auth: self.user!.auth!).drive()
        }
        PFSRealm.shared.update(obj: PFSDomain.login()!, {
            $0.isLogin = false
        })
        
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "IBLLoginViewController") as! IBLLoginViewController
        
        loginViewController.viewModel = IBLLoginViewModel(action: loginViewController,
                                                          domain: IBLLoginDomain(),
                                                          school: (self.user!.selectedSchool)!)

        
        UIApplication.shared.delegate?.window??.rootViewController = loginViewController
    }
    
    func baseURLString(url: URL) -> String {
        var baseURL = url.absoluteString
        if url.absoluteString.components(separatedBy: ";").count > 1 {
            baseURL = url.absoluteString.components(separatedBy: ";")[0]
        }else {
            baseURL = url.absoluteString.components(separatedBy: "?")[0]
        }
        return baseURL
    }
    
    public override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        
        guard let url = navigationAction.request.url, !self.isWebViewJavascriptBridgeURL(url: url) else {
            decisionHandler(.cancel)
            return
        }
        
        if self.isRootController() {
            self.startAnimating()
        }
        
        print("\(url)")
        if url.queryParameters?["allow"] != "true" {
                
            let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "IBLWebViewController") as! IBLWebViewController
            
            webViewController.user = self.user
            
            var parameters = ["account": user.account,
                              "accessToken": user.accessToken!,
                              "allow" : "true"]
            
            
            let baseURL = self.baseURLString(url: url)
            
            
            if var query = url.queryParameters {
                if let title = query["ibl_title"] {
                    webViewController.title = title
                    query["ibl_title"] = nil
                }
                
                parameters += query
            }

            self.resetURL(url: baseURL, isSwitchToOut: false).drive().disposed(by: disposeBag)
            
            webViewController.webAPI = IBLAPITarget.web(parameters)
            
            webViewController.hidesBottomBarWhenPushed = true

            
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
        
        let navigationActionPolicy: WKNavigationActionPolicy = url.queryParameters?["allow"] == "true" ? .allow : .cancel
        
        decisionHandler(navigationActionPolicy)
    }
    
    open override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        self.stopAnimating()
    }

    public override func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        let response = navigationResponse.response as! HTTPURLResponse
        
        if response.statusCode == 500 {
            self.logout()
        }
        
        let navigationResponsePolicy: WKNavigationResponsePolicy = response.statusCode == 500 ? .cancel : .allow
        
        decisionHandler(navigationResponsePolicy)
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
