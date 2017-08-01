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

class IBLSettingViewController: PFSViewController, IBLSettingAction {
    
    var viewModel: IBLSettingViewModel?
    
    @IBOutlet weak var loginSwitch: UISwitch!
    @IBOutlet weak var schoolTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.viewModel = IBLSettingViewModel(action: self, domain: IBLSettingDomain())
        
        (self.loginSwitch.rx.isOn <-> (self.viewModel?.isAutoLogin)!).disposed(by: disposeBag)
        (self.schoolTextField.rx.textInput <-> (self.viewModel?.schoolName)!).disposed(by: disposeBag)
        
    }
    
    @IBAction func selectedSchoolTapped(_ sender: UITapGestureRecognizer) {
        self.viewModel?.fetchSchools().drive(onNext: {[weak self] result in
            self?.presentPicker(items: result, completeHandler: { item in
                self?.viewModel?.setSelectedSchool(school: item.school).drive(onNext: { school in
                    self?.performSegue(withIdentifier: "toLogin", sender: school)
                }).disposed(by: (self?.disposeBag)!)
            })
            }, onCompleted: {
                self.view.isUserInteractionEnabled = true;
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
