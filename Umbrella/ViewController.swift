//
//  ViewController.swift
//  Umbrella
//
//  Created by User on 9/14/17.
//  Copyright © 2017 louis.sun. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    fileprivate let reuseIdentifier = "cell"
    var defaultZip = ZipSingleton.sharedZip.zip
    var currentConditions: [RepoObject] = []
    var hourlyConditions: [[HourlyObject]] = []
    let vc = SettingsViewController()
    let warmColor = UIColor(red:1.00, green:0.60, blue:0.00, alpha:1.0)
    let coldColor = UIColor(red:0.01, green:0.66, blue:0.96, alpha:1.0)
    var extremesArray: [[Int]] = [[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(getRepositories), name: NSNotification.Name(rawValue: "getRepositories"), object: nil)
        
        //gets userdefaults for zipString.
        if let userZipString = UserDefaults.standard.string(forKey: "zipString") {
            defaultZip = userZipString
            getRepositories()
        }else{
            //if userdefaults zipString does not exist then set default zip to 60602(Chicago) and segue to add zip menu
            defaultZip = "60602"
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "segueID", sender: nil)
            }
            print("default")
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // return the number of sections
        return hourlyConditions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return the number of items
        return hourlyConditions[section].count
    }
    func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollectionReusableView", for: indexPath) as? HeaderCollectionReusableView else {
            print("HeaderView not correct class")
            assert(false, "Incorrect Kind")
            
        }
        switch indexPath.section {
        case 0:
            headerView.headerTitle.text = "Today"
        case 1:
            headerView.headerTitle.text = "Tomorrow"
        default:
            headerView.headerTitle.text = "Day After Tomorrow"
        }
        
        return headerView

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCell", for: indexPath)
        
        // Configure the cell
        let hourlyCell = cell as? CollectionViewCell
        
        switch indexPath.row {
        case extremesArray[indexPath.section][0]:
            //if the cell's row is the same as the hottest index then set the text color to warm
            hourlyCell?.tempLabel.textColor = warmColor
            hourlyCell?.timeLabel.textColor = warmColor
        case extremesArray[indexPath.section][1]:
            //if the cell's row is the same as the coldest index then set the text color to cold
            hourlyCell?.tempLabel.textColor = coldColor
            hourlyCell?.timeLabel.textColor = coldColor
        default:
            hourlyCell?.tempLabel.textColor = .black
            hourlyCell?.timeLabel.textColor = .black
        }
        
        hourlyCell?.timeLabel.text = hourlyConditions[indexPath.section][indexPath.row].time
        hourlyCell?.tempLabel.text = hourlyConditions[indexPath.section][indexPath.row].temp
        hourlyCell?.imageView.image = hourlyConditions[indexPath.section][indexPath.row].thumbnail
        
        return cell
    }

    func getRepositories(){
        if let userZipString = UserDefaults.standard.string(forKey: "zipString") {
            defaultZip = userZipString
        }
            WebService.getTopRepositories(receivedLoc: defaultZip, completion: {
                repo in
                let degreeSymbol = "°"
                
                self.nameLabel.text = repo.locationName
                self.conditionLabel.text = repo.currentCondition
                self.tempLabel.text = String(repo.currentTemp) + degreeSymbol
                if repo.currentTemp > 60{
                    self.topView.backgroundColor = self.warmColor
                    
                }
                else{
                    self.topView.backgroundColor = self.coldColor
                }
            })

            WebService.getHourlyRepositories(receivedLoc: defaultZip, completion: {
                repo in
                self.hourlyConditions = []
                self.extremesArray = []
                for day in repo{
                    self.hourlyConditions.append(day)
                    //goes through the conditions for one day and looks for hottest and coldest hour
                    //and adds the index for that hour to an Array
                    let sortedTemp:[(temp:Int,index:Int)] = day.enumerated().flatMap{
                        guard let number = Int($0.element.temp) else {return nil}
                        return (temp:number,index:$0.offset)
                        }.sorted{$0.0 > $1.0}
                    guard let hotest = sortedTemp.first?.index else {continue}
                    guard let coldest = sortedTemp.last?.index else {continue}
                    var dayExtremes: [Int] = []
                    dayExtremes.append(hotest)
                    dayExtremes.append(coldest)
                    //adds the array of extreme hour indexs to an Array that holds the extreme 
                    //hour indexs for all hours
                    // index 0 for extremes array will show an array with two indexs,
                    // the hottest and the coldest respectively,
                    // and so on
                    self.extremesArray.append(dayExtremes)
                }
                print(self.extremesArray)
                self.collectionView.reloadData()
                
                
            })
        
    }


}

