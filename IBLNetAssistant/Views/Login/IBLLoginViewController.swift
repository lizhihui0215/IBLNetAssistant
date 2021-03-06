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
import PopupDialog



extension IBLLoginViewController: IBLOnlineTableViewControllerDelegate {
    func onlineTableView(_ onlineTableViewController: IBLOnlineTableViewController,
                         didTapped user: IBLUser, at indexPath: IndexPath) {
        let authJSON = Dictionary<String, Any>.toJSON(JSONObject: user.auth!.JSON!)!
        let kickUrl = authJSON["kickurl"] as! String
        let online = user.onlineList?[indexPath.row]
        let offline: Driver<Bool> = self.viewModel!.offline(kickurl: kickUrl, online: online!)
        let sigin = self.viewModel!.sigin(account: self.accountTextField.text!,
                                          password: passwordTextField.text!)
        self.startAnimating()
        offline.flatMapLatest{ _ -> Driver<Bool> in
            self.dismiss(animated: true, completion: nil)
            return sigin
        }.drive(onNext: {[weak self] success in
                self?.stopAnimating()
                if (success) {
                    self?.performSegue(withIdentifier: "toMain", sender: nil)
                }
        }).disposed(by: disposeBag)
    }
}

extension IBLLoginViewController: IBLLoginAction {
    
    func confirmToSelfAuth(message: String)  {
        self.stopAnimating()
        let confirm = self.confirm(content: ("\(message),是否自助登录？", ""))
        
        confirm.flatMapLatest{ (message, success, content) -> Driver<Bool> in
            if !success {  return Driver.never() }
            self.startAnimating()
            return (self.viewModel!.selfSigin(account: self.accountTextField.text!,
                                               password: self.passwordTextField.text!))
        }.drive(onNext: {[weak self] success in
            self?.stopAnimating()
            if (success) {
                self?.performSegue(withIdentifier: "toMain", sender: nil)
            }
        }).disposed(by: disposeBag)
    }
    
    func confirm(message: String) {
        self.stopAnimating()
        let  alertView = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertView.addAction(action)
        self.present(alertView, animated: true)
    }
    
    func showPanel(user: IBLUser) {
        let onlineTableViewController = IBLOnlineTableViewController(user: user)

        // Create the dialog
        let popup = PopupDialog(viewController: onlineTableViewController, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        // Create first button
        let buttonOne = CancelButton(title: "关闭", height: 40) {
            
        }
        
        onlineTableViewController.delegate = self
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])

        // Present dialog
        present(popup, animated: true, completion: nil)
        
    }
}

extension IBLLoginViewController: IBLSettingViewControllerDelegate{
    func `switch`(aotoLogin: Bool){
        self.aotoCheckbox.isSelected = aotoLogin
    }
}

class IBLLoginViewController: PFSViewController {
    
    var viewModel: IBLLoginViewModel?
    
    @IBOutlet weak var aotoCheckbox: PFSCheckbox!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    
    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        (self.aotoCheckbox.rx.isSelected <-> (self.viewModel?.isAutoLogin)!).disposed(by: disposeBag)
        
        (self.accountTextField.rx.text <-> (self.viewModel?.account)!).disposed(by: disposeBag)
        
        self.startAnimating()
        self.viewModel!.login().drive(onNext: {[weak self] isLogin in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(0)) {
                self?.stopAnimating()
            }
            if (isLogin) {
                self?.performSegue(withIdentifier: "toMain", sender: nil)
            }
        }) .disposed(by: disposeBag)
        
        
        if (self.viewModel?.school.supportRegister == "0") {
            let spetorView = self.stackView.arrangedSubviews[3]
            let registerButton = self.stackView.arrangedSubviews[4]
            self.stackView.removeArrangedSubview(spetorView)
            self.stackView.removeArrangedSubview(registerButton)
            spetorView.removeFromSuperview()
            registerButton.removeFromSuperview()
        }
    }
    
    @IBAction func loginButtonxPressed(_ sender: UIButton) {
        self.startAnimating()
        self.viewModel!.sigin(account: self.accountTextField.text!,
                                                       password: passwordTextField.text!).drive(onNext: {[weak self] success in
                                                        self?.stopAnimating()
                                                        if (success) {
                                                            self?.performSegue(withIdentifier: "toMain", sender: nil)
                                                        }
                                                       }).disposed(by: disposeBag)
    }
    
    
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toSetting", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toRegister", sender: nil)
    }

    @IBAction func forgetPasswordTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toForgetPassword", sender: nil)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        }else if segue.identifier == "toSetting" {
            let settingViewController = segue.destination as! IBLSettingViewController
            settingViewController.viewModel = IBLSettingViewModel(action: settingViewController, domain: IBLSettingDomain(), isAutoLogin: self.aotoCheckbox.isSelected)

            settingViewController.delegate = self
        }
    }
}
