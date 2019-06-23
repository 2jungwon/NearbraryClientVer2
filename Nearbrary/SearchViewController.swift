//
//  SearchViewController.swift
//  Nearbrary
//
//  Created by Release on 19/05/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    

    @IBOutlet var searchTextField: UITextField!
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if let _ = searchTextField.text {
            performSegue(withIdentifier: "searchSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let booksVC = segue.destination as? BooksTableViewController {
            if let text = searchTextField.text {
                booksVC.queryText = text
            }
        }
    }
    
}
