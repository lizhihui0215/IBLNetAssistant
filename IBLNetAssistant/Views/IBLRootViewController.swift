//
//  IBLRootViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 31/05/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift

class IBLRootViewController: PFSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toLogin" {
            let loginViewController = segue.destination as! IBLLoginViewController
            
            loginViewController.viewModel = IBLLoginViewModel(action: loginViewController)
        }
    }
}

