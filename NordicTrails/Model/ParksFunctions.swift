//
//  ParksFunctions.swift
//  NordicTrails
//
//  Created by Samuel Grosenick on 11/3/18.
//  Copyright © 2018 Samuel Grosenick. All rights reserved.
//

import Foundation
import ArcGIS

var featureTable:AGSServiceFeatureTable?

class ParksFunctions {
    
    static func readParks(completion: @escaping () -> ()) {
        
//        DispatchQueue.global(qos: .userInitiated).async {
//            let parksList = ["Kincaid", "Russian Jack", "Hillside"]
//
//            for p in parksList {
//                ParksData.parksModels.append(ParksModel(title: p))
//            }
//        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            featureTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/HRPe58bUyBqyyiCt/arcgis/rest/services/NordicSkiTrails_view/FeatureServer/0")!)

            var parkList = [String]()
            let queryParams = AGSQueryParameters()
            queryParams.whereClause = "SYSTEM_NAM LIKE '%'"

            print(queryParams as Any)

            featureTable!.queryFeatures(with: queryParams, completion: { (result:AGSFeatureQueryResult?, error:Error?) in
                if let error = error {
                    print(error as Any)
                }
                else if let features = result?.featureEnumerator().allObjects {
                    if features.count > 0 {
                        let enumerator = result?.featureEnumerator()
                        for feature in enumerator! {
                            let attr = feature as! AGSFeature
                            if attr.attributes["SYSTEM_NAM"] as? String == nil {
                                print("nil value")
                            } else {
                                if parkList.contains(attr.attributes["SYSTEM_NAM"] as! String) == false {
                                    parkList.append(attr.attributes["SYSTEM_NAM"] as! String)
                                    print("Added \(attr.attributes["SYSTEM_NAM"] as! String)")
                                    ParksData.parksModels.append(ParksModel(title: attr.attributes["SYSTEM_NAM"] as! String))
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion()
                }
            })
        }
        
    }
}
