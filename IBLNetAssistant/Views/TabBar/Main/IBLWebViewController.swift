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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count == 1 {
            self.navigationController?.isNavigationBarHidden = true
        }else {
            self.navigationController?.isNavigationBarHidden = false
        }
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
    
    public override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        
        guard let url = navigationAction.request.url, !self.isWebViewJavascriptBridgeURL(url: url) else {
            decisionHandler(.cancel)
            return
        }
        
        print("\(url)")
        if url.queryParameters?["allow"] != "true" {
                
            let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "IBLWebViewController") as! IBLWebViewController
            
            webViewController.user = self.user
            
            var parameters = ["account": user.account,
                              "accessToken": user.accessToken!,
                              "allow" : "true"]
            
            let baseURL = url.absoluteString.components(separatedBy: ";")[0]
            
            if var query = url.queryParameters {
                if let title = query["ibl_title"] {
                    let decodedTitle = title.removingPercentEncoding
                    query["ibl_title"] = nil
                    webViewController.title = decodedTitle
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
