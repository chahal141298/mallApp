//
//  CartVC.swift
//  TheMallApp
//
//  Created by mac on 09/02/2022.
//

import UIKit
import Stripe

import ARSLineProgress

class CartVC: UIViewController {
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var emptyCartView: UIView!
    @IBOutlet weak var cartTable: UITableView!{
        didSet{
            cartTable.tableFooterView = UIView(frame: .zero)
        }
    }
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    ///
    var userId = ""
    var key = ""
    var paymentSheet : PaymentSheet?
    var cartData = [AnyObject]()
    var backendCheckoutUrl = URL(string: "http://127.0.0.1:4242")
    var paymentIntentClientSecret: String?
    var dicountTotal = Double()
    var totalArray = [Double]()
    var totalPrice = Double()
    var cartIdArray = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StripeAPI.defaultPublishableKey = "pk_test_51BTUDGJAJfZb9HEBwDg86TN1KNprHjkfipXmEDMb0gSCassK5T3ZfxsAbcgKVmAIXF7oZ6ItlZZbXO6idTHE67IM007EwQ4uN3"
        fetchPaymentIntent()
        // MARK: Fetch the PaymentIntent client secret, Ephemeral Key secret, Customer ID, and publishable key
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userId = UserDefaults.standard.value(forKey: "id") as? String ?? ""
        if userId != "" {
            getCart()
            if key == "s"{
                backBtn.isHidden = false
            }else{
                backBtn.isHidden = true
            }
            
        }else{
            self.showAlertWithOneAction(alertTitle: "Oops!", message: "You are not logged in please login to continue", action1Title: "OK") { isSuccess in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        
        
    }
    ///
    func fetchPaymentIntent() {
        let url = self.backendCheckoutUrl!.appendingPathComponent("/create-payment-intent")
        
        let shoppingCartContent: [String: Any] = [
            "items": [
                ["id": "xl-shirt"]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: shoppingCartContent)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let clientSecret = json["clientSecret"] as? String
            else {
                let message = error?.localizedDescription ?? "Failed to decode response from server."
                //                    self?.displayAlert(title: "Error loading page", message: message)
                return
            }
            
            print("Created PaymentIntent")
            self?.paymentIntentClientSecret = clientSecret
            
            DispatchQueue.main.async {
                self?.checkoutButton.isEnabled = true
            }
        })
        
        task.resume()
    }
    ///
    func pay() {
        guard let paymentIntentClientSecret = self.paymentIntentClientSecret else {
            return
        }
        
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Example, Inc."
        configuration.applePay = .init(
            merchantId: "com.example.appname",
            merchantCountryCode: "US"
        )
        
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: paymentIntentClientSecret,
            configuration: configuration)
        
        paymentSheet.present(from: self) { [weak self] (paymentResult) in
            switch paymentResult {
            case .completed:
                self?.displayAlert(title: "Payment complete!")
            case .canceled:
                print("Payment canceled!")
            case .failed(let error):
                self?.displayAlert(title: "Payment failed", message: error.localizedDescription)
            }
        }
    }
    ///
    func displayAlert(title: String, message: String? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func optionBtnTapped(_ sender: UIButton) {
        let id = cartData[sender.tag]["_id"] as! String
        print("sd",id)
        print("sd")
        ARSLineProgress.show()
        ApiManager.shared.deleteCart(id: id) { isSuccess in
            ARSLineProgress.hide()
            if isSuccess{
                self.getCart()
                print("deletedSuccessfully")
            }
            else{
                print("error")
            }
        }
    }
    
    func didTapCheckoutButton() {
        // MARK: Start the checkout process
        paymentSheet?.present(from: self) { paymentResult in
            // MARK: Handle the payment result
            switch paymentResult {
            case .completed:
                print("Your order is confirmed")
            case .canceled:
                print("Canceled!")
            case .failed(let error):
                print("Payment failed: \(error)")
            }
        }
    }
    
    @IBAction func buyTapped(_ sender:UIButton){
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
        vc.key = "cart"
        let storedata = self.cartData[0]["store"] as! NSDictionary
        print(totalPrice,totalLabel.text,totalArray,"ss",self.cartIdArray)
        UserDefaults.standard.setValue(totalPrice, forKey: "price")
        UserDefaults.standard.setValue(storedata.object(forKey: "deliveryCharges") as? Double ?? 10.0, forKey: "DeliveryCharges")
        print(self.cartData[0]["store"],"gyghjbkj",cartData[0],"asdfas")
        UserDefaults.standard.setValue(self.cartIdArray, forKey: "cartIds")
        print(self.cartIdArray)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func deleteTapped(_ sender:UIButton){
        
    }
    
}
class CartTablecell: UITableViewCell{
    
    @IBOutlet weak var cartView: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var color: UILabel!
    @IBOutlet weak var quantity: UILabel!
    
}

extension CartVC{
    func getCart(){
        ARSLineProgress.show()
        
        ApiManager.shared.getCart(id: userId) {[self] isSuccess in
            print(userId)
            ARSLineProgress.hide()
            if isSuccess{
                ARSLineProgress.hide()
                self.cartData = ApiManager.shared.data
                if cartData.count == 0{
                    cartTable.isHidden = true
                    emptyCartView.isHidden = false
                    checkoutButton.isHidden = true
                    totalLabel.text = "Total: $\(0.0)"
                    
                }else{
                    self.totalArray.removeAll()
                    cartTable.isHidden = false
                    emptyCartView.isHidden = true
                    checkoutButton.isHidden = false
                    totalLabel.text = "Total: $\(0.0)"
                    cartIdArray.removeAll()
                    for i in 0...cartData.count-1{
                        let cartid = cartData[i]["_id"] as? String ?? ""
                        let material: [String: String] = [
                                           "cartId": cartid,
                            ]
                        let m = material as NSDictionary
                        self.cartIdArray.append(m)
                        guard let product = cartData[i]["product"] as? NSDictionary else {return}
                        let discount = Double(product.object(forKey: "discount") as? String ?? "0.0")
                        let pricee = product.object(forKey: "masterPrice") as? Double ?? 0.0
                        self.dicountTotal = pricee - (pricee*(discount ?? 0.0)/100)
                        print(self.dicountTotal)
                        self.totalArray.append(self.dicountTotal)
                        print(self.totalArray,"rfrf")
                        self.totalPrice = totalArray.reduce(0,+)
                        print(self.totalPrice,"sdn")
                        totalLabel.text = "Total: $\((totalPrice*100).rounded()/100)"
                        
                    }
                    
                }
                cartTable.reloadData()
                
            }else{
                ARSLineProgress.hide()
                self.alert(message: ApiManager.shared.msg)
            }
            
        }
    }
}
extension CartVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartTable.dequeueReusableCell(withIdentifier: "cell") as! CartTablecell
        cell.deleteBtn.tag = indexPath.row
        cell.cartView.layer.cornerRadius = 20
        cell.cartView.layer.shadowColor = UIColor.lightGray.cgColor
        cell.cartView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cell.cartView.layer.shadowRadius = 2
        cell.cartView.layer.shadowOpacity = 5
        if cartData.count != 0{
            guard let product = cartData[indexPath.row]["product"] as? NSDictionary else {return cell}
            cell.quantity.text = ""
            cell.productName.text = product.object(forKey: "name") as! String
            cell.color.text = product.object(forKey: "description") as! String
            let discount = Double(product.object(forKey: "discount") as? String ?? "0.0")
            let pricee = product.object(forKey: "masterPrice") as? Double ?? 0.0
            self.dicountTotal = pricee - (pricee*(discount ?? 0.0)/100)
            print(self.dicountTotal)
            //            self.totalArray.append(self.dicountTotal)
            //            print(self.totalArray,"rfrf")
            //            self.totalPrice = totalArray.reduce(0,+)
            //            print(self.totalPrice,"sdn")
            //            totalLabel.text = "Total: $\(totalPrice)"
            cell.price.text = "Price - $\(self.dicountTotal)"
            if let gallery = product.object(forKey: "gallery") as? [AnyObject]{
                if gallery.count != 0{
                    if let image = gallery[0]["name"] as? String{
                        let url = URL(string: "http://93.188.167.68/projects/mymall_nodejs/assets/images/\(image)")
                        if url != nil{
                            cell.cartImage.af.setImage(withURL: url!)
                        }else{
                            print("hello")
                        }
                    }
                }else{
                    print("hii")
                }
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.key = "cart"
        let product = cartData[indexPath.row]["product"] as! NSDictionary
        vc.productId = product.object(forKey: "_id") as! String
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
