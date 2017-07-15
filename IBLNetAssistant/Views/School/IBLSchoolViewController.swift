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


class IBLSchoolViewController: PFSViewController, IBLSchoolAction {
    @IBOutlet var schoolTapGesture: UITapGestureRecognizer!

    @IBOutlet weak var schoolTextField: UITextField!
    
    var viewModel: IBLSchoolViewModel<IBLSchoolViewController>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewModel = IBLSchoolViewModel(action: self, domain: IBLSchoolDomain())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func schoolTapped(_ sender: UITapGestureRecognizer) {
//        self.view.isUserInteractionEnabled = false
        self.viewModel?.fetchSchools().drive(onNext: {[weak self] result in
            self?.presentPicker(items: result, completeHandler: { item in
                self?.viewModel?.selectedSchool = item.school
                self?.schoolTextField.text = item.title
            })
            
            }, onCompleted: {
                self.view.isUserInteractionEnabled = true;
                print("completed")
        }).disposed(by: disposeBag)
    }
    
    @IBAction func nextStapTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toLogin", sender: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
