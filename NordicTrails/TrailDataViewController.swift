//
//  TrailDataViewController.swift
//  NordicTrails
//
//  Created by Samuel Grosenick on 11/11/18.
//  Copyright © 2018 Samuel Grosenick. All rights reserved.
//

import UIKit
import ArcGIS

class TrailDataViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var trailTitle: UILabel!
    @IBOutlet weak var trailLabel: UILabel!
    @IBOutlet weak var difficultyTitle: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var skiTypeTitle: UILabel!
    @IBOutlet weak var skiTypeLabel: UILabel!
    @IBOutlet weak var groomingStatusTitle: UILabel!
    @IBOutlet weak var groomingStatusLabel: UILabel!
    @IBOutlet weak var conditionsTitle: UILabel!
    @IBOutlet weak var conditionsText: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    
    private var featureTable: AGSServiceFeatureTable!
    private var featureLayer: AGSFeatureLayer!
    
    // trail data
    var trail: String = ""
    var difficulty: String = ""
    var skiType: String = ""
    var groomingStatus: String = ""
    var conditions: String = ""
    var alert: UIAlertController?
    
    // create feedback generator
    let selection = UISelectionFeedbackGenerator()
    
    @IBAction func updateConditions(_ sender: Any) {
        
        // implement haptic feedback
        selection.selectionChanged()
        
        //  query data to only select current trail
        let queryParams = AGSQueryParameters()
        queryParams.whereClause = "TRAIL_NAME = '\(trail)'"
        
        featureTable.queryFeatures(with: queryParams, queryFeatureFields: .loadAll) { (result:AGSFeatureQueryResult?, error:Error?) in
            
            if let error = error {
                print(error)
            }
            else if let feature = result?.featureEnumerator().allObjects {
                let trail = feature[0]
                //let trailCond = trail.attributes["CONDITIONS"]
                let newCond: String = self.conditionsText.text
                trail.attributes["CONDITIONS"] = newCond
                print("Here are the updated conditions: \(trail.attributes["CONDITIONS"] as! String)")
                //print("Here are the conditions at \(trail.attributes["TRAIL_NAME"] as! String): \(newCond)")
                self.featureTable.update(trail) { (error:Error?) -> Void in
                    if let error = error {
                        print(error)
                    }
                    else {
                        self.featureTable.applyEdits(completion: { (result:[AGSFeatureEditResult]?, error:Error?) in
                            if let error = error {
                                print(error)
                            }
                            else {
                                print("Edits updated")
                                self.present(self.alert!, animated: true, completion: nil)
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        //set up notification center to adjust view for keyboard
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // set navigation title
        //self.title = trail
        
        // set color of back button
        navigationController?.navigationBar.tintColor = Theme.tint
        
        // setup map
        mapView.map = AGSMap(basemapType: .imagery, latitude: 61.161758, longitude: -149.831933, levelOfDetail: 10)
        
        featureTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/HRPe58bUyBqyyiCt/arcgis/rest/services/NordicSkiTrails_view/FeatureServer/0")!)
        
        let editable = featureTable.editableAttributeFields
        print("These are the editable fields")
        for ef in editable {
            print(ef)
        }
        
        mapView.selectionProperties.color = Theme.background!
        
        featureLayer = AGSFeatureLayer(featureTable: featureTable)
        
        mapView.map!.operationalLayers.add(featureLayer)
        
        let featureSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 1)
        featureLayer.renderer = AGSSimpleRenderer(symbol: featureSymbol)
        
        let queryParams = AGSQueryParameters()
        queryParams.whereClause = "TRAIL_NAME = '\(trail)'"
        
        //queries the selected trail and zooms to it
        featureTable.queryFeatures(with: queryParams, queryFeatureFields: .loadAll) { (result:AGSFeatureQueryResult?, error:Error?) in
            
            if let error = error {
                print(error)
            }
            else if let feature = result?.featureEnumerator().allObjects {
                // select trail
                self.featureLayer.select(feature)
                
                // zoom to selected feature
                self.mapView.setViewpointGeometry(feature[0].geometry!, padding:25)
            }
        }
        
        // build alert
        alert = UIAlertController(title: "Conditions Updated", message: nil, preferredStyle: .alert)
        alert!.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        // assign labels
        trailLabel.text = trail
        difficultyLabel.text = difficulty
        skiTypeLabel.text = skiType
        groomingStatusLabel.text = groomingStatus
        conditionsText.text = conditions
        
    }
//    @objc func keyboardWillShow(notification: NSNotification) {
//        guard  let userInfo = notification.userInfo else {return}
//        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
//        let keyboardFrame = keyboardSize.cgRectValue
//        if self.view.frame.origin.y == 0 {
//            self.view.frame.origin.y -= keyboardFrame.height
//        }
//
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
//    }
    
}
