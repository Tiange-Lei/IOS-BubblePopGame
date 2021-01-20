//
//  UserDeaultManagment.swift
//  BubblePop
//
//  Created by Tiange Lei on 14/1/21.
//

import Foundation

//Declare a UDM class to store the data
class UserDefaultManagement{
    static let shared=UserDefaultManagement()
    let defaults=UserDefaults(suiteName: "BubblePop")!
    //Return the playerName if stored, otherwise return ""
    func getPlayerName()->String{
        if let name=defaults.value(forKey: "playerName") as? String{
            return name
        }else{
            return ""
        }
    }
    //Return the scoreRecord if stored, otherwise return an empty ScoreRecord struct
    func getRecord()->Array<ScoreRecord>{
        let defaultRecord=[ScoreRecord]()
        //Since the data is stored as struct format and encoded, decode it first to retrieve the record from UDM
        if let fetchedData = UserDefaultManagement.shared.defaults.data(forKey: "record"){
            let fetchedRecord = try! PropertyListDecoder().decode([ScoreRecord].self, from: fetchedData)
            return fetchedRecord
        }else{
            return defaultRecord
        }
    }
    //Return the setted time if stored, otherwise return default 60s
    func getSettedTime()->Int{
        if let settedTime=defaults.value(forKey: "setTime") as? Int{
            return settedTime
        }else{
            return 60
        }
    }
    //Return the setted maximum amount of bubble if stored, otherwise return default 15
    func getSettedBubbles()->Int{
        if let settedBubbles=defaults.value(forKey: "setBubble") as? Int{
            return settedBubbles
        }else{
            return 15
        }
    }
    //clear the correspongding record for test and development usage.
    func clearRecord(){
        defaults.removeObject(forKey: "record")
    }
    func clearName(){
        defaults.removeObject(forKey: "playerName")
    }
    func clearSetting(){
        defaults.removeObject(forKey: "setTime")
        defaults.removeObject(forKey: "setBubble")
    }
}
