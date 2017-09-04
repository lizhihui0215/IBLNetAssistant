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
        (self.accountTextField.rx.textInput <-> (self.viewModel?.account)!).disposed(by: disposeBag)
        
        self.phoneTextField.keyboardType = .phonePad
        (self.phoneTextField.rx.textInput <-> (self.viewModel?.phone)!).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func sendSMSButtonPressed(_ sender: UIButton) {
        self.startAnimating()
        self.viewModel?.sendSMS().drive(onNext: {[weak self] success in
            self?.stopAnimating()
            if (success) {
                self?.performSegue(withIdentifier: "toExchagePassword", sender: nil)
            }
        }).disposed(by: disposeBag)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toExchagePassword" {

            let exchangePasswordController = segue.destination as! IBLExchagePasswordViewController
            
            exchangePasswordController.viewModel = IBLExchangePasswordViewModel(action: exchangePasswordController,
                    domain: IBLExchangePasswordDomain(),
                    account: self.accountTextField.text!,
                    phone: self.phoneTextField.text!)            
        }
    }
    

}
