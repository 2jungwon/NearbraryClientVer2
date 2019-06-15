//
//  DetailViewController.swift
//  Nearbrary
//
//  Created by 이정원 on 04/06/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit
import Foundation
import SafariServices

class DetailViewController: UITableViewController {
    
    var selectedBook : book? = nil
    
    @IBOutlet var booktitle: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var publisher: UILabel!
    @IBOutlet var pubdate: UILabel!
    @IBOutlet var isbn: UILabel!
    @IBOutlet var bookImageView: UIImageView!
    @IBAction func NaverLink(_ sender: UIButton) {
        let url = URL(string: selectedBook?.link ?? "")!
        let webVC = SFSafariViewController(url: url)
        present(webVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        booktitle.text = selectedBook?.title
        author.text = selectedBook?.author
        publisher.text = selectedBook?.publisher
        pubdate.text = selectedBook?.pubdate
        let cut_isbn = selectedBook?.isbn?.components(separatedBy: " ")
        isbn.text = cut_isbn?[1]
        //link.text = selectedBook?.link
        bookImageView.image = selectedBook?.image
    }
}
