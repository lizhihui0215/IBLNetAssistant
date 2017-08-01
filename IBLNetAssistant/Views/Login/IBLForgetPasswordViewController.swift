//
//  IBLForgetPasswordViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 31/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import RxCocoa


class IBLForgetPasswordViewController: PFSViewController, IBLForgetPasswordAction {
    
    var viewModel: IBLForgetPasswordViewModel?
    
    @IBOutlet weak var accountTextField: UITextField!

    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        
        (self.accountTextField.rx.textInput <-> (self.viewModel?.account)!).disposed(by: disposeBag)
        (self.phoneTextField.rx.textInput <-> (self.viewModel?.phone)!).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendSMSButtonPressed(_ sender: UIButton) {

        self.viewModel?.sendSMS().drive(onNext: {[weak self] success in
            if (success) {
                self?.performSegue(withIdentifier: "toExchagePassword", sender: nil)
            }
        }).disposed(by: disposeBag)
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
