//
//  ViewController.swift
//  PaddleStationApp
//
//  Created by Carlin Liu on 2017-11-11.
//  Copyright © 2017 PaddleStation. All rights reserved.
//


//TODO:
/*
 UI: Add logos to side menu, change colour of navigation bar(find rgb values from ravi's doc)
     Add each page*, set a lauch screen, fix lines and spacing on side bar
 Missing Logo: Menu_timeline
 */
import UIKit

class ViewController: UIViewController {

    
    @IBAction func loginButton(_ sender: Any) {
    }
    //IMPORTANT, DELETE ME
    /*
     In order to connect page to sideMenu:
         Make sure the page has an embedded navigation controller and inherits from "viewController".
         Click and drag from the side menu and use "reveal PUSH view controller". In order to connect
         page menu buttons to "menuButton", you must click on the view controller and change it from
         "UIViewController" to "ViewController" (Under the identity tab). Then you can click and drag
         the button onto menuButton using the twoCircles method.
     */
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sideMenus()
        customizeNavBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //SideMenus
    /*Call to animate and change side menu*/
    func sideMenus() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 300
            
            //revealViewController().rightViewRevealWidth = 160
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    //Current color is purple, can be fixed later
    func customizeNavBar() {
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(red: 17/255, green: 38/255, blue: 58/255, alpha: 1)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

}
class UIOutlinedLabel: UILabel {
    var outlineWidth: CGFloat = 1
    var outlineColor: UIColor = UIColor.white
    
    override func drawText(in rect: CGRect) {
        let strokeTextAttributes = [
            NSAttributedStringKey.strokeColor : outlineColor,
            NSAttributedStringKey.strokeWidth : -1 * outlineWidth,
            ] as [NSAttributedStringKey : Any]
        
        
        self.attributedText = NSAttributedString(string: self.text ?? "",attributes: strokeTextAttributes)
        super.drawText(in: rect)
    }
    
    
    
}
