//
//  IBLExchagePasswordViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 31/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift

class IBLExchagePasswordViewController: PFSViewController, IBLExchangePasswordAction {

    var viewModel: IBLExchangePasswordViewModel?
    
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBOutlet weak var sendSMSButton: UIButton!
    
    @IBOutlet weak var secondHightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var smsCodeTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var confirmTextField: UITextField!
    
    var timer: Timer?

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        self.startAnimating()
        self.viewModel?.exchangePassword().drive(onNext: { success in
            self.stopAnimating()
            if success {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }).disposed(by: disposeBag)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.startTimer()
        
        (self.smsCodeTextField.rx.textInput <-> (self.viewModel?.smsCode)!).disposed(by: disposeBag)
        
        (self.passwordTextField.rx.textInput <-> (self.viewModel?.password)!).disposed(by: disposeBag)
        (self.confirmTextField.rx.textInput <-> (self.viewModel?.confirm)!).disposed(by: disposeBag)
    }
    
    func check(timer: Timer)  {
        print("Timer timeInventorcal \(timer.timeInterval)")
        print("Timer tolerance \(timer.tolerance)")

        let date = timer.userInfo as! Date
        
        let timeInterval = Int(-date.timeIntervalSinceNow)
        
        print("timeInterval \(timeInterval)")

        if (timeInterval - 60 > 0) {
            timer.invalidate()
            self.secondHightConstraint.constant = 0;
            self.sendSMSButton.isEnabled = true
        }else {
            self.secondLabel.text = "\(60 - timeInterval)秒后可重新发送"
        }
    }
    
    func startTimer() {
        self.sendSMSButton.isEnabled = false
        self.secondHightConstraint.constant = 16;
        
        let selector = #selector(IBLExchagePasswordViewController.check(timer:))
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: selector, userInfo: Date(), repeats: true)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sendSMSButtonPressed(_ sender: UIButton) {
        self.sendSMSButton.isEnabled = false
        self.viewModel?.sendSMS().drive(onNext: {[weak self] success in
            if (success) {
                self?.startTimer()
            }
        }).disposed(by: disposeBag)
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
