//
//  UserViewController.swift
//  payatease
//
//  Created by Andy Lin on 2020-06-30.
//  Copyright © 2020 Andy Lin. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var username: String = ""
    var password : String = ""
    var email : String = ""
    var balance : Float = 0 {
        didSet{
            if userBalance != nil {
                userBalance.text = "$ " + String(format: "%.2f", balance)
                
            }
        }
    }
    var bill : [Bill] = [] {
        
        didSet {
            if table != nil {
                table.reloadData()
            }
        }
    }

    @IBOutlet weak var table: UITableView!
    
    
    @IBOutlet weak var userBalance: UILabel!
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bill.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bills = bill.sorted(by: { $0.date > $1.date})
        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! BillTableViewCell
        let pay = bills[indexPath.row].receiver == username ? false : true
        
        cell.id.text = "\(bills[indexPath.row].billID)"
        cell.receiver.text = pay ?  bills[indexPath.row].receiver : bills[indexPath.row].payer
        cell.date.text = bills[indexPath.row].date
        
        if !bills[indexPath.row].paid {
            cell.amount.text = "$ \(String(format: "%.2f", bills[indexPath.row].amount))"
            cell.amount.textColor = #colorLiteral(red: 1, green: 0.6399404382, blue: 0.2166803039, alpha: 1)
            cell.receiver.text = "pending"
            cell.icon.image = UIImage(named: "pending")
        }
        else if pay {
            cell.amount.text = "- $ \(String(format: "%.2f", bills[indexPath.row].amount))"
            cell.amount.textColor = #colorLiteral(red: 1, green: 0.3438926126, blue: 0.3378218115, alpha: 1)
            cell.icon.image = UIImage(named: "pay")
        } else {
            cell.amount.text = "+ $ \(String(format: "%.2f", bills[indexPath.row].amount))"
            cell.amount.textColor = #colorLiteral(red: 0.1348951906, green: 0.9026610089, blue: 0.2370250076, alpha: 1)
            cell.icon.image = UIImage(named: "money")
        }
        return cell
        
        
    }
    
    override func viewDidLoad() {
        userBalance.text = "$ " + String(format: "%.2f", balance)
        self.navigationItem.title = username
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func scarQRCode(_ sender: Any) {
        self.performSegue(withIdentifier: "scanCode", sender: nil)
    }
    
     //MARK: - Navigation

     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanCode" {
            if let vc = segue.destination as? ScanCodeViewController {
                DispatchQueue.main.async {
                    vc.balance = self.balance
                    vc.username = self.username
                    vc.password = self.password
                    vc.payAmount = {[weak self] amount,bill in
                        self?.balance -= amount
                        if let index = self?.bill.firstIndex(where: { $0.billID == bill.billID }) {
                            self?.bill[index].paid = true
                        } else {
                            self?.bill.append(bill)
                        }
                    }
                }
            }
        }
    }
    

}
