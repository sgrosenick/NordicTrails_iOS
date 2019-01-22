//
//  TrailsViewController.swift
//  NordicTrails
//
//  Created by Samuel Grosenick on 11/8/18.
//  Copyright © 2018 Samuel Grosenick. All rights reserved.
//

import UIKit
import ArcGIS

class TrailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var tableView: UITableView!
    
    private var featureLayer: AGSFeatureLayer!
    
    // empty variables for creating envelope
    var xMin: Double = 9999999.0
    var xMax: Double = 0.0
    var yMin: Double = 9999999.0
    var yMax: Double = 0.0
    
    
    var parkName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navigation controller title
        self.title = parkName

        tableView.dataSource = self
        tableView.delegate = self

        // set up map
        mapView.map = AGSMap(basemap: .imagery())

        let featureTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/HRPe58bUyBqyyiCt/arcgis/rest/services/NordicSkiTrails_view/FeatureServer/0")!)
        
        print("These fields are editable: \(featureTable.editableAttributeFields)")

        let featureLayer = AGSFeatureLayer(featureTable: featureTable)

        mapView.map!.operationalLayers.add(featureLayer)

        let featureSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 1)
        featureLayer.renderer = AGSSimpleRenderer(symbol: featureSymbol)

        // set definition query to only show selecte trail system
        featureLayer.definitionExpression = "SYSTEM_NAM = '\(parkName)'"

        // zoom to trail system
        zoom(mapView: mapView, to: featureLayer)

        // setup table
        trailCellSetup {
            self.tableView.reloadData()
        }
    }
    
    // This will clear trails when leaving view controller
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            TrailsData.trailsModels.removeAll()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrailsData.trailsModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trailCell = tableView.dequeueReusableCell(withIdentifier: "trailCell") as! TrailsTableViewCell
        
        trailCell.contentSetup(TrailsModel: TrailsData.trailsModels[indexPath.row])
        return trailCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "trailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "trailSegue") {
            let destVC: TrailDataViewController = segue.destination as! TrailDataViewController
            
            let selectedIndexPath = tableView.indexPathForSelectedRow
            let selectData = TrailsData.trailsModels[selectedIndexPath!.row]
            
            destVC.trail = selectData.title
            destVC.skiType = selectData.skiType
            destVC.difficulty = selectData.difficulty
            destVC.groomingStatus = selectData.groomStatus
            destVC.conditions = selectData.conditions
        }
    }
    
    func trailCellSetup(completion: @escaping () -> ()) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            featureTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/HRPe58bUyBqyyiCt/arcgis/rest/services/NordicSkiTrails_view/FeatureServer/0")!)
            
            
            var trailList = [String]()
            let queryParams = AGSQueryParameters()
            queryParams.whereClause = "SYSTEM_NAM LIKE '\(self.parkName)'"
            
            print(queryParams as Any)
            
            featureTable!.queryFeatures(with: queryParams,  queryFeatureFields: .loadAll) { (result:AGSFeatureQueryResult?, error:Error?) in
                if let error = error {
                    print(error as Any)
                }
                else if let features = result?.featureEnumerator().allObjects {
                    if features.count > 0 {
                        let enumerator = result?.featureEnumerator()
                        for feature in enumerator! {
                            let attr = feature as! AGSFeature
                            
                            // zoom to trail system
//                            let attrGeom = attr.geometry
//                            let attrExtent = attrGeom?.extent
//
//                            if((attrExtent?.xMin)! < self.xMin) {
//                                self.xMin = (attrExtent?.xMin)!
//                                print("New xMin: \(self.xMin)")
//                            }
//
//                            if((attrExtent?.xMax)! > self.xMax) {
//                                self.xMax = (attrExtent?.xMax)!
//                            }
//
//                            if((attrExtent?.yMin)! < self.yMin) {
//                                self.yMin = (attrExtent?.yMin)!
//                            }
//
//                            if((attrExtent?.yMax)! > self.yMax) {
//                                self.yMax = (attrExtent?.yMax)!
//                            }
                            
                            
                            // filter trails for table
                            if attr.attributes["TRAIL_NAME"] as? String == nil {
                                print("nil value")
                            } else {
                                if trailList.contains(attr.attributes["TRAIL_NAME"] as! String) == false {
                                    trailList.append(attr.attributes["TRAIL_NAME"] as! String)
                                    print("Added \(attr.attributes["TRAIL_NAME"] as! String)")
                                    TrailsData.trailsModels.append(TrailsModel(title: attr.attributes["TRAIL_NAME"] as? String ?? "No Data", skiType: attr.attributes["WINTERUSET"] as? String ?? "No Data", groomStatus: attr.attributes["GROOMINGGO"] as? String ?? "No Data", difficulty: attr.attributes["GRADE"] as? String ?? "No Data", conditions: attr.attributes["CONDITIONS"] as? String ?? "No Data"))
                                }
                            }
                        }
                    }
//                    let envelope = AGSEnvelope(xMin: self.xMin, yMin: self.yMin, xMax: self.xMax, yMax: self.yMax, spatialReference: self.mapView.spatialReference)
//
//                    let targetExtent = AGSViewpoint.init(targetExtent: envelope)
//
//                    self.mapView.setViewpoint(targetExtent)
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func zoom(mapView:AGSMapView, to featureLayer:AGSFeatureLayer) {
        // ensure the feature layer's metadata is loaded
        featureLayer.load { error in
            guard error == nil else {
                print("Couldn't load data \(error!.localizedDescription)")
                return
            }

            // once the layer's metadata as loaded, we can read it's extent
            if let initialExtent = featureLayer.fullExtent {
                mapView.setViewpointGeometry(initialExtent)
            }
        }
    }
}
