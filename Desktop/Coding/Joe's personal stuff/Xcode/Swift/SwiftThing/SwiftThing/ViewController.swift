//
//  ViewController.swift
//  SwiftThing
//
//  Created by Joseph Jin on 6/16/16.
//  Copyright (c) 2016 Animator Joe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var displayText: UILabel!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func displayStuff(sender: AnyObject) {
        
        displayText.text = textField.text
        
    }
    

}

