//
//  IBLTabBarController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 02/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift

class IBLTabBarController: UITabBarController {

    var domain = IBLMainDomain()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let navigationController = self.viewControllers?[2] as! UINavigationController
        
        let settingViewController = navigationController.topViewController as! IBLSettingViewController
        
        let user = PFSDomain.login()
        
        settingViewController.viewModel = IBLSettingViewModel(action: settingViewController, domain: IBLSettingDomain(), isAutoLogin: user?.isAutoLogin ?? false)

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
