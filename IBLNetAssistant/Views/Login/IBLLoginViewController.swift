//
//  IBLLoginViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 05/06/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import RxCocoa
import PCCWFoundationSwift

class IBLLoginViewController: PFSViewController, IBLLoginAction {
    
    var viewModel: IBLLoginViewModel?
    
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.viewModel!.sigin(account: self.usernameTextField.text!,
                                                       password: passwordTextField.text!).drive(onNext: {
                                                        print($0)
                                                       }, onCompleted: {
                                                        print("completed")
                                                       }).disposed(by: disposeBag)

//        performSegue(withIdentifier: "toMain", sender: nil)
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
    }
    

}
