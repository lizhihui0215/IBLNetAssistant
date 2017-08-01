//
//  IBLLoginViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 05/06/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PCCWFoundationSwift

class IBLLoginViewController: PFSViewController, IBLLoginAction {
    
    var viewModel: IBLLoginViewModel?
    
    @IBOutlet weak var aotoCheckbox: PFSCheckbox!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        (self.aotoCheckbox.rx.isSelected <-> (self.viewModel?.isAutoLogin)!).disposed(by: disposeBag)
        
        (self.accountTextField.rx.text <-> (self.viewModel?.account)!).disposed(by: disposeBag)
        
        self.viewModel!.login().drive(onNext: {[weak self] isLogin in
            if (isLogin) {
                self?.performSegue(withIdentifier: "toMain", sender: nil)
            }
        }) .disposed(by: disposeBag)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.viewModel!.sigin(account: self.accountTextField.text!,
                                                       password: passwordTextField.text!).drive(onNext: {[weak self] success in
                                                        if (success) {
                                                            self?.performSegue(withIdentifier: "toMain", sender: nil)
                                                        }
                                                       }).disposed(by: disposeBag)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
    }

    @IBAction func forgetPasswordTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toForgetPassword", sender: nil)

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
        
        if segue.identifier == "toForgetPassword" {
            let forgetPasswordController = segue.destination as! IBLForgetPasswordViewController
            
            forgetPasswordController.viewModel = IBLForgetPasswordViewModel(action: forgetPasswordController,
                                                                            domain: IBLForgetPasswordDomain(),
                                                                            account: accountTextField.text ?? "")
        }
    }
    

}
