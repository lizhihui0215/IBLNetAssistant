//
//  IBLOnlineTableViewController.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 17/08/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import PCCWFoundationSwift

open class PFSTableViewController: PFSViewController {
    @IBOutlet var tableViews: [UITableView]!
    
    var tableView: UITableView {
        return self.tableViews[0]
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        for tableView in self.tableViews {
            tableView.tableFooterView = UIView()
        }
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIButton {
    private struct AssociatedKeys {
        static var indexPathKey = "com.pccw.foundation.uibutton.indexPathKey"
    }
    
    public var indexPath: IndexPath {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.indexPathKey) as! IndexPath
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.indexPathKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

extension IBLOnlineTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

extension IBLOnlineTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.onlines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IBLOnlineTableViewCell", for: indexPath) as! IBLOnlineTableViewCell
        
        let online = self.onlines[indexPath.row]
        
        cell.titleLabel.text = online.clientname ?? online.clienttype
        
        cell.dateLabel.text = "登陆时间：\(online.accesstime ?? "")"
        
        cell.offlineButton.indexPath = indexPath

        return cell
    }
}

protocol IBLOnlineTableViewControllerDelegate: class {
    func onlineTableView(_ onlineTableViewController: IBLOnlineTableViewController,
                         didTapped user: IBLUser, at indexPath: IndexPath)
}

class IBLOnlineTableViewController: PFSTableViewController {
    
    var user: IBLUser

    var onlines: [IBLOnline] {
        return self.user.onlineList ?? []
    }
    
    weak var delegate: IBLOnlineTableViewControllerDelegate?

    init(user: IBLUser) {
        self.user = user
        super.init(nibName: "IBLOnlineTableViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "IBLOnlineTableViewCell", bundle: nil)

        self.tableView.register(nib, forCellReuseIdentifier: "IBLOnlineTableViewCell")
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func offlineButtonTapped(_ sender: UIButton) {
        self.delegate?.onlineTableView(self, didTapped: self.user, at: sender.indexPath)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
