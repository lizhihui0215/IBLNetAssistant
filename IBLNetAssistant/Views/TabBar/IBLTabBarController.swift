//
//  IBLTabBarController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 02/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import RxCocoa

open class PFSTabBarController: UITabBarController {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func viewControllerAtIndex<T: UIViewController>(at index: Int) -> T {
        if let navigationController = self.viewControllers?[index] as? UINavigationController {
            return navigationController.topViewController as! T
        }
        
        return self.viewControllers![index] as! T
    }

    
}

class IBLTabBarController: PFSTabBarController {

    var domain = IBLMainDomain()
    
    let user = PFSDomain.login()!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupSettingViewController()
        
        self.setupWebViewController()
        
    }
    
    

    
    func setupWebViewController()  {
        let webViewController: IBLWebViewController = self.viewControllerAtIndex(at: 0)
        
        webViewController.user = self.user
        
    }
    
    func setupSettingViewController()  {
        let settingViewController: IBLSettingViewController  = self.viewControllerAtIndex(at: 1)
        
        settingViewController.viewModel = IBLSettingViewModel(action: settingViewController, domain: IBLSettingDomain(), isAutoLogin: user.isAutoLogin )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
