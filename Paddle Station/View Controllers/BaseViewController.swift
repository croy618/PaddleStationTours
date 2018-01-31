//
//  BaseViewController.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2017-12-02.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import Foundation





class BaseViewController: UIViewController, SeguePerformer
{
    lazy var segueManager: SegueManager = {
        return SegueManager(viewController: self)
    }()
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
	}
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        self.segueManager.prepare(for: segue)
    }
}




