//
//  ViewController.swift
//  PostApp
//
//  Created by Admin on 21/01/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var postTable: UITableView!
    var posts = [(Post,Bool)](){
        didSet{
            self.postTable.reloadData()
        }
    }
    var count = 0
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postTable.rowHeight = UITableView.automaticDimension;
        self.postTable.estimatedRowHeight = 100;
        self.postTable.tableFooterView = UIView()
        self.title = "Selected Posts = (0)"
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.postTable.refreshControl = refreshControl
        
        PostManager.shared.getPosts(page: 1) { (err, posts) in
            self.posts = posts.map({ ($0,false)})
        }
        
    }
    @objc func refresh(refreshControl: UIRefreshControl) {
        self.posts=[]
        let myGroup = DispatchGroup()
        for i in 1..<self.page {
            myGroup.enter()
            PostManager.shared.getPosts(page: i) { (err, posts) in
                myGroup.leave()
                self.posts += posts.map({ ($0,false)})
            }
        }
        
        myGroup.notify(queue: .main) {
            print("Finished all requests.")
            refreshControl.endRefreshing()
        }
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PostTableViewCell
        let post = self.posts[indexPath.row]
        cell.title.text = post.0.title
        cell.date.text = post.0.created_at
        cell.isActive.isOn = post.1
        cell.isActive.addTarget(self, action: #selector(self.switchToggle(sender:)), for: .valueChanged)
        cell.isActive.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= self.posts.count-1{
            self.page+=1
            PostManager.shared.getPosts(page: self.page) { (err, posts) in
                self.posts += posts.map({ ($0,false)})
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PostTableViewCell
        cell.isActive.isOn = !cell.isActive.isOn

        if cell.isActive.isOn {
            self.count+=1
        }else{
            self.count-=1
        }
        self.title = "Selected Posts = (\(self.count))"
        var post = self.posts[indexPath.row]
        post.1 = cell.isActive.isOn
        self.posts[indexPath.row] = post
        self.postTable.reloadData()
    }
    
    @objc func switchToggle(sender:UISwitch){
        if sender.isOn {
            self.count+=1
        }else{
            self.count-=1
        }
        self.title = "Selected Posts = (\(self.count))"

        var post = self.posts[sender.tag]
        post.1 = sender.isOn
        self.posts[sender.tag] = post
        self.postTable.reloadData()

    }
}
