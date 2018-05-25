//
//  IBLSettingViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 25/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import RxCocoa
import PCCWFoundationSwift

protocol IBLSettingViewControllerDelegate: class {
    func `switch`(aotoLogin: Bool)
}

class IBLSettingViewController: PFSViewController, IBLSettingAction {
    
    var viewModel: IBLSettingViewModel?
    
    @IBOutlet weak var loginSwitch: UISwitch!
    @IBOutlet weak var schoolTextField: UITextField!
    
    weak var delegate: IBLSettingViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        self.loginSwitch.isEnabled = self.viewModel!.isEnableLoginSwitch()
        
        (self.loginSwitch.rx.isOn <-> (self.viewModel?.isAutoLogin)!).disposed(by: disposeBag)
        
        (self.schoolTextField.rx.textInput <-> (self.viewModel?.schoolName)!).disposed(by: disposeBag)
        
        self.loginSwitch.rx.isOn.asObservable().subscribe(onNext: {[weak self] isOn in
            
            if let delegate = self?.delegate {
                delegate.switch(aotoLogin: isOn)
            }
            
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    

    
    @IBAction func selectedSchoolTapped(_ sender: UITapGestureRecognizer) {
        self.startAnimating()
        self.viewModel?.fetchSchools().drive(onNext: {[weak self] result in
            self?.presentPicker(items: result, completeHandler: { item in
                self?.viewModel?.setSelectedSchool(school: item.school).drive(onNext: { success in
                    if success {
                        self?.performSegue(withIdentifier: "toLogin", sender: item.school)
                    }
                }).disposed(by: (self?.disposeBag)!)
            })
            }, onCompleted: {
                self.stopAnimating()
        }).disposed(by: disposeBag)

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
            let loginViewController = (segue.destination as! UINavigationController).topViewController  as! IBLLoginViewController
            
            loginViewController.viewModel = IBLLoginViewModel(action: loginViewController,
                                                              domain: IBLLoginDomain(),
                                                              school: sender as! IBLSchool)
        }

    }
    

}
