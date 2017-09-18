//
//  HourlyObject.swift
//  Umbrella
//
//  Created by User on 9/14/17.
//  Copyright © 2017 louis.sun. All rights reserved.
//

import Foundation
import UIKit

class HourlyObject{
    
    let time: String
    let temp: String
    let imageURL: String
    let yday: Int
    
    // casts json into readable data
    init?(json: [String: Any]){
        guard let fcttime = json["FCTTIME"] as? [String: Any],
            let time = fcttime["civil"] as? String,
            let temp1 = json["temp"] as? [String: Any],
            let temp = temp1["english"] as? String,
            var iconURL = json["icon_url"] as? String,
            let yday = fcttime["yday"] as? String
            else{
                print("Repoitory Object returning nil")
                return nil
            }
        //removes http from url
        for _ in 0...3{
            iconURL.remove(at: iconURL.startIndex)
        }
        self.time = time
        self.temp = temp
        //adds https to url
        self.imageURL = "https" + iconURL
        self.yday = Int(yday)!
        
    }
    //get image from imageURL if no image found return nil
    lazy var thumbnail: UIImage? = {
        
        guard let url = URL(string: self.imageURL) else{
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            let image = UIImage(data: data)
            return image
        }catch{
            print("image URL not valid")
            return nil
        }
        
    }()
}
