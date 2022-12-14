//
//  CheckoutVC.swift
//  TheMallApp
//
//  Created by Macbook Air (ios) on 06/05/22.
//

import UIKit
import ARSLineProgress

class CheckoutVC: UIViewController {

    @IBOutlet weak var taxes: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var mobileNumber: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var deliveryCharge: UILabel!
    @IBOutlet weak var totalPayable: UILabel!
    @IBOutlet weak var addressView: UIView!
    
    
    var key = ""
    var addressId = ""
    var addressData = NSDictionary()
    var amount = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressView.layer.cornerRadius = 10
        addressView.layer.borderWidth = 1
        addressView.layer.borderColor = UIColor.lightGray.cgColor
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getAddress()
        let mm = UserDefaults.standard.value(forKey: "price") as? Double ?? 0.0
        price.text = "$ \(mm)"
        
        let del = UserDefaults.standard.value(forKey: "DeliveryCharges") as? Double ?? 10.0
        deliveryCharge.text = "$ \(del)"
        let tax = UserDefaults.standard.value(forKey: "taxx") as? Double ?? 10.0
//        print(UserDefaults.standard.value(forKey: "taxx") as! Double)
        taxes.text = "$ \(tax)"
        amount = mm + del + tax
        totalPayable.text = "$ \(mm + del + tax)"
    }
    
    @IBAction func mallHomeTapped(_ sender: Any) {
        NavigateToHome.sharedd.navigate(naviagtionC: self.navigationController!)
    }
    @IBAction func backTapped(_ sender: UIButton){
//        UserDefaults.standard.removeObject(forKey: "DeliveryCharges")
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkout(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CardVC") as! CardVC
        vc.key = "Checkout"
        vc.addressId = self.addressId
        vc.amount = Double(round(100*self.amount))/100
        self.navigationController?.pushViewController(vc, animated: true)
    }

}


extension CheckoutVC{
    
    func getAddress(){
        ARSLineProgress.show()
        ApiManager.shared.addressById(addressId: self.addressId) { [self] isSuccess in
            ARSLineProgress.hide()
            if isSuccess{
                ARSLineProgress.hide()
                self.addressData = ApiManager.shared.dataDict
                customerName.text = addressData.object(forKey: "fullName") as? String ?? ""
                address.text = "\(addressData.object(forKey: "buildingNo") as! String),\(addressData.object(forKey: "street") as! String),\(addressData.object(forKey: "city") as! String),\(addressData.object(forKey: "state") as! String),\(addressData.object(forKey: "pinCode") as! String),Near \(addressData.object(forKey: "area") as! String)"
                
            }else{
                ARSLineProgress.hide()
                self.alert(message: ApiManager.shared.msg)
            }
        }
    }
    
}
