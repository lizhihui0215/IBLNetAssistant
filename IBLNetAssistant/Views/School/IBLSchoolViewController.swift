//
//  IBLSchoolViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 11/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import RxSwift
import RxCocoa


class IBLSchoolViewController: PFSViewController, IBLSchoolAction {
    @IBOutlet var schoolTapGesture: UITapGestureRecognizer!

    @IBOutlet weak var schoolTextField: UITextField!
    
    var viewModel: IBLSchoolViewModel<IBLSchoolViewController>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.viewModel = IBLSchoolViewModel(action: self, domain: IBLSchoolDomain())
        
        self.startAnimating()
        self.viewModel?.fetchSchools().drive(onNext: {[weak self] result in
            self?.stopAnimating()
            let item = result.first(where: { $0.school.selected })
            if let school = item?.school {
                self?.viewModel?.setSelectedSchool(school: school)
                self?.schoolTextField.text = item?.title
            }
            
        }).disposed(by: disposeBag)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func schoolTapped(_ sender: UITapGestureRecognizer) {
        self.startAnimating()
        self.viewModel?.fetchSchools().drive(onNext: {[weak self] result in
            self?.stopAnimating()
            self?.presentPicker(items: result, completeHandler: { item in
                self?.viewModel?.setSelectedSchool(school: item.school)
                self?.schoolTextField.text = item.title
            })
            }).disposed(by: disposeBag)
    }
    
    @IBAction func nextStapTapped(_ sender: UIButton) {
        guard self.viewModel?.selectedSchool != nil else {
            self.alert(message: "请选择校园!").drive().disposed(by: disposeBag)
            return;
        }
        
        let _: Driver<Bool> =  self.viewModel!.cacheSchool();
        
        self.performSegue(withIdentifier: "toLogin", sender: nil)
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
                                                              school: (self.viewModel?.selectedSchool)!)
        }
    }
}
