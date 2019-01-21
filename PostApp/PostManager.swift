//
//  PostManager.swift
//  PostApp
//
//  Created by Admin on 21/01/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire

class PostManager {
     static let shared = PostManager()

    func getPosts(page:Int,completion:@escaping (_ error:String?,_ posts:[Post])->Void){
        Alamofire.request("https://hn.algolia.com/api/v1/search_by_date?tags=story&page=\(page)")
            .responseJSON { (data) in
                do{
                    if data.error == nil{
                        let objects = try! JSONSerialization.jsonObject(with: data.data!, options: .allowFragments) as! [String:Any]
                        let hits = objects["hits"] as! [Any]
                        let hitsJson = try! JSONSerialization.data(withJSONObject: hits, options: JSONSerialization.WritingOptions.prettyPrinted)
                        let jsonDecoder = JSONDecoder()
                        let posts = try! jsonDecoder.decode([Post].self, from: hitsJson)
                        completion(nil,posts)
                    }else{
                        completion(data.error!.localizedDescription,[])
                    }

                }catch{
                    completion(error.localizedDescription,[])
                }
        }
        
    }
}
