//
//  ViewController.swift
//  iBeaconManager

import UIKit
import CoreLocation


class ViewController: UIViewController{
    
    /// label to show the seleced beacon's id
    @IBOutlet var beaconIDLabel: UILabel!

    
    /// RadarView
    @IBOutlet var radarView: TESTRadarView!


    
    
    var beaconsDate: [String:NSDate] = [:]
    var beacons : [String:iBeacon] = [:]
    
    //New instance
    let beaconManager = TestiBeaconManager()
    override func viewDidLoad() {
        
        beaconIDLabel.textColor = UIColor.white
        
        //self.view.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(beaconsRanged(notification:)), name: NSNotification.Name(rawValue: iBeaconNotifications.BeaconProximity.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(beaconTaped(notification:)), name: NSNotification.Name(rawValue: TESTRadarNotifications.BeaconTapped.rawValue), object: nil)

        startMonitoring()
        
        
//        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.addBeacon), userInfo: nil, repeats: false)
//        
//        NSTimer.scheduledTimerWithTimeInterval(5.5, target: self, selector: #selector(ViewController.addBeacon2), userInfo: nil, repeats: false)
    }
    
//    func addBeacon(){
//        
//        let testBeacon = iBeacon(minor: 255, major: 255, proximityId: "Test1")
//        testBeacon.proximity = CLProximity.far
//        testBeacon.id = "test1"
//        radarView.addBeacon(testBeacon)
//    }
//    
//    func addBeacon2(){
//        
//        let testBeacon2 = iBeacon(minor: 255, major: 255, proximityId: "Test2")
//        testBeacon2.proximity = .near
//        testBeacon2.id = "test2"
//        radarView.addBeacon(testBeacon2)
//    }

    
    //MARK: notifications
    func beaconsEnabled(notification:NSNotification){
        ///Wait for notificatio
        
        // Removes old beacons
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(ViewController.removeOldBeacons), userInfo: nil, repeats: true)

    }
    
    func beaconTaped(notification: NSNotification) {
        print("Notification Received \(String(describing: notification.object))")
        if let bs = notification.object as? BeaconShape{ //}, let beacon = bs.b iBeacon{
            beaconIDLabel.numberOfLines = 0
            beaconIDLabel.text = bs.beacon.id
        }
    }

    func beaconsDisabled(notification:NSNotification){
        
    }

    
    /**Called when the beacons are ranged*/
    func beaconsRanged(notification:NSNotification){
        if let visibleIbeacons = notification.object as? [iBeacon]
        {
            for beacon in visibleIbeacons{
                self.radarView.addBeacon(beacon: beacon)
                beaconsDate[beacon.id] = NSDate()
                beacons[beacon.id] = beacon
                print(NSDate().description)
            }
        }
    }
    
   
    
    func startMonitoring(){
        //check if enabled
        // beaconManager.registerBeacon("f7826da6-4fa2-4e98-8024-bc5b71e0893e")
       
        let kontaktIOBeacon = iBeacon(minor: nil, major: nil, proximityId: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")//"f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        //let estimoteBeacon = iBeacon(minor: nil, major: nil, proximityId: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        
      
        //major 2505 minor 36274
        beaconManager.registerBeacons(beacons: [kontaktIOBeacon])
        
        beaconManager.startMonitoring(successCallback: {
            
            }) { (messages) in
                    print("Error Messages \(messages)")
        }
        
        
        /**updates user's visited places information*/
        func stateCallback(beacon:iBeacon)->Void{
            //FIXME - unused
        }
        
        /**updates user's visited places information*/
        func rangeCallback (beacon:iBeacon)->Void{
            //FIXME - unused
        }
        
        beaconManager.stateCallback = stateCallback
        beaconManager.rangeCallback = rangeCallback
        
        beaconManager.logging = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeOldBeacons(){
        
        for id in beaconsDate.keys{
            
            let now = NSDate()
            let beaconDate = beaconsDate[id]
            let date = beaconDate?.addSeconds(secondsToAdd: 4)
            
            if date!.isLessThanDate(dateToCompare: now) {
                radarView.removeBeacon(beacon: beacons[id]!)
                beacons.removeValue(forKey: id)//ValueForKey(id)
                beaconsDate.removeValue(forKey: id)
            }
        }
    }
}

extension NSDate {
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        var isGreater = false
        
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        var isLess = false
        
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        var isEqualTo = false
        
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.addingTimeInterval(secondsInDays)
        
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.addingTimeInterval(secondsInHours)
        
        return dateWithHoursAdded
    }
    
    func addSeconds(secondsToAdd: Int) -> NSDate {
        let seconds: TimeInterval = Double(secondsToAdd)
        let dateWithSecondsAdded: NSDate = self.addingTimeInterval(seconds)
        
        return dateWithSecondsAdded
    }
}

