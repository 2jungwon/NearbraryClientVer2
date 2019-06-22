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
    
    struct AllInfo: Decodable {
        let sogang: [BookInfo]
        let yonsei: [BookInfo]
        let ewha: [BookInfo]
        let hongik: [BookInfo]
    }
    
    struct BookInfo: Decodable {
        let no: String?
        let location: String?
        let callno: String?
        let id: String?
        let status: String?
        let returndate: String?
    }
    
    struct cellData{
        var opened = Bool()
        var title = String()
        var sectionData = [BookInfo]()
        
        init(opened:Bool, title:String, sectionData:[BookInfo]){
            self.opened = opened
            self.title = title
            self.sectionData = sectionData
        }
    }
    var tableViewData = [cellData]()
    var flag:Bool = true
    var allinfo:AllInfo?
    
    func getBookInfoFromLibrary() {
        let lambda_url = "https://kw7eq88ls8.execute-api.ap-northeast-2.amazonaws.com/Prod/libinfo?isbn="
        
        if self.selectedBook!.isbn == nil {
            NSLog("There is no ISBN for this book")
            return;
        }
        
        let isbns = selectedBook?.isbn?.components(separatedBy: " ")
        //let len10 = String(isbns?[0] ?? "")
        let len13 = String(isbns?[1] ?? "")
        
        NSLog("len10:\(String(describing: isbns?[0])) + || + len13:\(String(describing: isbns?[1]))")
        //guard let url_len10 = URL(string: lambda_url + len10) else{return}
        guard let url_len13 = URL(string: lambda_url + len13) else{return}
        
        if len13 != "" {
            URLSession.shared.dataTask(with: url_len13) { (data, response, err) in
                NSLog("len13url : \(url_len13)")
                guard let data = data else {return}
                if data.isEmpty{
                    NSLog("There's No data responsed from Libraries ISBN Number:\(len13)")
                }
                else {
                    do {
                        let allinfo = try JSONDecoder().decode(AllInfo.self, from: data)
                        
                        DispatchQueue.main.async {
                            self.allinfo = allinfo
                            print("\(self.allinfo?.sogang.count as Optional)")
                            print("\(self.allinfo?.yonsei.count as Optional)")
                            print("\(self.allinfo?.ewha.count as Optional)")
                            print("\(self.allinfo?.hongik.count as Optional)")
                            
                            if self.allinfo?.sogang.count ?? 0 > 0 {
                                self.allinfo?.sogang.forEach{ book in
                                    self.tableViewData[0].sectionData.append(book)
                                }
                            }
                            if self.allinfo?.yonsei.count ?? 0 > 0 {
                                self.allinfo?.yonsei.forEach{ book in
                                    self.tableViewData[1].sectionData.append(book)
                                }
                            }
                            if self.allinfo?.ewha.count ?? 0 > 0 {
                                self.allinfo?.ewha.forEach{ book in
                                    self.tableViewData[2].sectionData.append(book)
                                }
                            }
                            if self.allinfo?.hongik.count ?? 0 > 0 {
                                self.allinfo?.hongik.forEach{ book in
                                    self.tableViewData[3].sectionData.append(book)
                                }
                            }
                            
                            self.tableView.reloadData()
                        }
                    } catch let jsonErr {
                        print("Error", jsonErr)
                    }
                }
            }.resume()
        }
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
        
        tableViewData = [
            cellData(opened: false, title: "서강대학교", sectionData: []),
            cellData(opened: false, title: "연세대학교", sectionData: []),
            cellData(opened: false, title: "이화여자대학교", sectionData: []),
            cellData(opened: false, title: "홍익대학교", sectionData: [])
        ]
        getBookInfoFromLibrary()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count + 1
        }
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_header")as! LibInfoHeaderCell? else {
                return UITableViewCell()
            }
            cell.univ.text = tableViewData[indexPath.section].title
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_content")as! LibInfoContentCell? else {
                return UITableViewCell()
            }
            let bookinfo : BookInfo = tableViewData[indexPath.section].sectionData[dataIndex]
            guard let location = bookinfo.location, let callno = bookinfo.callno, let id = bookinfo.id, let returndate = bookinfo.returndate, let status = bookinfo.status else {
                return cell
            }
            
            cell.location.text = "\(location)"
            cell.callno.text = "\(callno)"
            cell.id.text = "\(id)"
            cell.returndate.text = "\(returndate)"
            cell.status.text = "\(status)"
            if "\(status)"=="대출중" {
                cell.status.textColor=UIColor.orange
            }
            else if "\(status)"=="대출가능" {
                cell.status.textColor=UIColor.colorWithRGBHex(hex: 0x00994c, alpha: 1.0)
            }
            else {
                cell.status.textColor=UIColor.red
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if self.tableViewData[indexPath.section].opened == true {
                self.tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                self.tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
    }
}

extension UIColor {
    class func colorWithRGBHex(hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue:CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
}
