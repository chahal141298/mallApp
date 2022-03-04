//
//  ImageUploadVC.swift
//  TheMallApp
//
//  Created by Macbook on 01/03/22.
//

import UIKit

class ImageUploadVC: UIViewController {

    @IBOutlet weak var backTapped: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backTaped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}