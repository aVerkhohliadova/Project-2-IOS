//
//  DetailsViewController.swift
//  Project2
//
//  Created by Алла Верхоглядова on 03.04.2023.
//

import UIKit

class DetailsViewController: UIViewController {

    var labelMessage: String?
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let message = labelMessage{
            messageLabel.text = message
        }
        // Do any additional setup after loading the view.
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
