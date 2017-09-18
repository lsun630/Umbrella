//
//  WebService.swift
//  Umbrella
//
//  Created by User on 9/14/17.
//  Copyright © 2017 louis.sun. All rights reserved.
//


import Foundation
import Alamofire

class WebService{
    //gets current conditions from API using Alamofire
    class func getTopRepositories(receivedLoc: String, completion: @escaping (RepoObject)-> Void){
        Alamofire.request("https://api.wunderground.com/api/67045a1191faf678/conditions/q/\(receivedLoc).json").responseJSON { response in
            //cast response as [String:Any] else exit function
            guard let json = response.result.value as? [String: Any] else {
                return
            }
            //finds current_observation key and casts its data into [String:Any]
            guard let results = json["current_observation"]
                as? [String: Any] else{
                    return
            }
            //casts repoObj into RepoObject else exit function
            guard let repoObj = RepoObject(json: results) else{
                print("error casting repoObj into Repository object")
                return
            }
            //return repoObj
            completion(repoObj)
        }
    }
    //gets hourly weather from API using Alamofire and creates an array with multiple arrays(3 unless API changes) of HourlyObjects.
    //If the API changes then this function would need to be refactored if there is a need to get more or less days
    class func getHourlyRepositories(receivedLoc: String, completion: @escaping ([[HourlyObject]])-> Void){
        Alamofire.request("https://api.wunderground.com/api/67045a1191faf678/hourly/q/\(receivedLoc).json").responseJSON { response in
            //cast response as [String:Any] else exit function
            guard let json = response.result.value as? [String: Any]
                else {
                    return
            }
            //finds hourly_forecast key and casts its data into [[String:Any]]
            guard let results = json["hourly_forecast"] as? [[String: Any]] else{
                return
            }
            
            var totalArray: [[HourlyObject]] = []
            
            //casts each object in results as HourlyObject else exit function
            var repoArray: [HourlyObject] = results.flatMap{HourlyObject(json: $0)}
            //set today as the yday for the first object in repoArray.
            let today = repoArray[0].yday
            // if the yday for the object is the same as today then add it to index 0 of totalArray
            var dayArray: [HourlyObject] = repoArray.flatMap{$0.yday}
            totalArray.append(dayArray)
            dayArray = []
            // if the yday for the object is one day greater than today then add it to index 1 of totalArray
            dayArray = repoArray.flatMap{
                guard $0.yday - today == 1 else {return nil}
                return $0
            }
            totalArray.append(dayArray)
            dayArray = []
            // if the yday for the object is one day greater than today then add it to index 2 of totalArray
            dayArray = repoArray.flatMap{
                guard $0.yday - today == 2 else {return nil}
                return $0
            }
            totalArray.append(dayArray)
            dayArray = []
            //return totalArray
            completion(totalArray)
        }
    }
}
