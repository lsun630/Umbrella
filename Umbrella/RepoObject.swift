//
//  RepoObject.swift
//  Umbrella
//
//  Created by User on 9/14/17.
//  Copyright © 2017 louis.sun. All rights reserved.
//

import Foundation

class RepoObject{
    
    let locationName: String
    let currentTemp: Int
    let currentCondition: String
    
    // casts json into readable data
    init?(json: [String: Any]){
        guard let displayLocation = json["display_location"] as? [String: Any],
        let locationName = displayLocation["full"] as? String,
        let currentTemp = json["temp_f"] as? Float,
        let currentCondition = json["weather"] as? String
            else{
                print("Repoitory Object returning nil")
                return nil
        }
        
        self.locationName = locationName
        self.currentTemp = Int(currentTemp)
        self.currentCondition = currentCondition
    }
}
