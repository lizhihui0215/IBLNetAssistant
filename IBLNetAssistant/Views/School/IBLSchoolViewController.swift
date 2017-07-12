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
        self.viewModel?.fetchSchools().drive(onNext: {
            
            
            print($0)
        }).disposed(by: disposeBag)
    }
    
    @IBAction func nextStapTapped(_ sender: UIButton) {
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
