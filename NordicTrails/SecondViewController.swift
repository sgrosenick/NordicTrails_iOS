//
//  SecondViewController.swift
//  NordicTrails
//
//  Created by Samuel Grosenick on 11/3/18.
//  Copyright © 2018 Samuel Grosenick. All rights reserved.
//

import UIKit
import ArcGIS

class SecondViewController: UIViewController, AGSGeoViewTouchDelegate, AGSCalloutDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    
    private var lastQuery:AGSCancelable!
    private var featureLayer:AGSFeatureLayer!
    private var coffeeShopLayer:AGSFeatureLayer!
    private var coffeeShopTable:AGSServiceFeatureTable!
    private var hospitalLayer:AGSFeatureLayer!
    private var hospitalTable:AGSServiceFeatureTable!
    private var skiShopLayer:AGSFeatureLayer!
    private var skiShopTable:AGSServiceFeatureTable!
    private var parkingLayer:AGSFeatureLayer!
    private var selectedFeature:AGSArcGISFeature!
    private var graphicsOverlay = AGSGraphicsOverlay()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup map
        mapView.map = AGSMap(basemapType: .imagery, latitude: 61.161758, longitude: -149.831933, levelOfDetail: 10)
        //add the graphics overlay to the map view
        self.mapView.graphicsOverlays.add(self.graphicsOverlay)
        
        // add trails
        let featureTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/HRPe58bUyBqyyiCt/arcgis/rest/services/NordicSkiTrails_view/FeatureServer/0")!)
        featureLayer = AGSFeatureLayer(featureTable: featureTable)
        mapView.map!.operationalLayers.add(featureLayer)
        // add ski shops
        skiShopTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/HRPe58bUyBqyyiCt/arcgis/rest/services/Ski_AmenitiesIcon_view/FeatureServer/1")!)
        skiShopLayer = AGSFeatureLayer(featureTable: skiShopTable)
        mapView.map!.operationalLayers.add(skiShopLayer)
        // add coffee shops
        coffeeShopTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/HRPe58bUyBqyyiCt/arcgis/rest/services/Ski_AmenitiesIcon_view/FeatureServer/0")!)
        coffeeShopLayer = AGSFeatureLayer(featureTable: coffeeShopTable)
        mapView.map!.operationalLayers.add(coffeeShopLayer)
        // add hospitals
        hospitalTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/HRPe58bUyBqyyiCt/arcgis/rest/services/Ski_AmenitiesIcon_view/FeatureServer/2")!)
        hospitalLayer = AGSFeatureLayer(featureTable: hospitalTable)
        mapView.map!.operationalLayers.add(hospitalLayer)
        // add parking lots
        let parkingTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/HRPe58bUyBqyyiCt/arcgis/rest/services/ParkingLots_view/FeatureServer/0")!)
        parkingLayer = AGSFeatureLayer(featureTable: parkingTable)
        mapView.map!.operationalLayers.add(parkingLayer)
        
        
        let featureSymbol = AGSSimpleLineSymbol(style: .solid, color: UIColor(named: "Accent") ?? .blue, width: 2)
        featureLayer.renderer = AGSSimpleRenderer(symbol: featureSymbol)
        
        self.mapView.touchDelegate = self
        self.mapView.callout.delegate = self
        
        setupLocationDisplay()
        //add graphics to points
//        self.addPictureSymbol(picture: "CoffeeIcon-Small", featureTable: coffeeShopTable)
//        self.addPictureSymbol(picture: "HospitalIcon-Small", featureTable: hospitalTable)
//        self.addPictureSymbol(picture: "SkiShopIcon-Small", featureTable: skiShopTable)
    }
    
    // create zoom-to legend buttons
    @IBAction func zoomToCoffe(_ sender: Any) {
        let coffeeExtent:AGSEnvelope = coffeeShopTable.extent!
        
        let coffeeViewpoint = AGSViewpoint.init(targetExtent: coffeeExtent)
        self.mapView.setViewpoint(coffeeViewpoint)
    }
    
    @IBAction func zoomToSkiShops(_ sender: Any) {
        let skiShopExtent:AGSEnvelope = skiShopTable.extent!
        
        let skiShopViewpoint = AGSViewpoint.init(targetExtent: skiShopExtent)
        self.mapView.setViewpoint(skiShopViewpoint)
    }
    
    @IBAction func zoomToHospitals(_ sender: Any) {
        let hospitalExtent:AGSEnvelope = hospitalTable.extent!
        
        let hospitalViewpoint = AGSViewpoint.init(targetExtent: hospitalExtent)
        self.mapView.setViewpoint(hospitalViewpoint)
    }
    
    // displays users location
    func setupLocationDisplay() {
        mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanMode.compassNavigation
        
        mapView.locationDisplay.start { [weak self] (error: Error?) -> Void in
            if let error = error {
                self?.showAlert(withStatus: error.localizedDescription)
            }
            
        }
    }
    
    // asks for permission to use location services
    func showAlert(withStatus: String) {
        let alertController = UIAlertController(title: "Alert", message: withStatus, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
//    // builds trails callout
//    func showCallout(feature: AGSFeature, tapLocation: AGSPoint?) {
//        let trail = feature.attributes["TRAIL_NAME"] as! String
//        let trailSystem = feature.attributes["SYSTEM_NAM"] as! String
//        self.mapView.callout.title = trailSystem
//        self.mapView.callout.detail = trail
//        self.mapView.callout.color = Theme.background!
//        self.mapView.callout.delegate = self
//        self.mapView.callout.show(for: feature, tapLocation: tapLocation, animated: true)
//    }
    

    func didTapAccessoryButton(for callout: AGSCallout) {
        print("Accessory Button tapped")
    }
    
    func showNewTrailCallout(willShowForFeature feature: AGSFeature, layer: AGSFeatureLayer, mapPoint: AGSPoint?) {
        let trail = feature.attributes["TRAIL_NAME"] as! String
        let trailSystem = feature.attributes["SYSTEM_NAM"] as! String
        self.mapView.callout.title = trailSystem
        self.mapView.callout.detail = trail
        self.mapView.callout.delegate = self
        self.mapView.callout.isAccessoryButtonHidden = true
        self.mapView.callout.show(for: feature, tapLocation: mapPoint, animated: true)

    }

    
    
//    // coffee shop callout
//    func showCoffeeCallout(feature: AGSFeature, tapLocation: AGSPoint?) {
//        let trail = feature.attributes["CoffeeShop"] as! String
//        self.mapView.callout.title = "Coffee Shop"
//        self.mapView.callout.detail = trail
//        self.mapView.callout.delegate = self
//        self.mapView.callout.show(for: feature, tapLocation: tapLocation, animated: true)
//        self.mapView.callout.isAccessoryButtonHidden = true
//    }
//
//    // hospital callout
//    func showHospitalCallout(feature: AGSFeature, tapLocation: AGSPoint?) {
//        let trail = feature.attributes["MedicalClinc"] as! String
//        self.mapView.callout.title = "Hospital"
//        self.mapView.callout.detail = trail
//        self.mapView.callout.delegate = self
//        self.mapView.callout.show(for: feature, tapLocation: tapLocation, animated: true)
//        self.mapView.callout.isAccessoryButtonHidden = true
//    }
//
//    // ski shop callout
//    func showSkiShopCallout(feature: AGSFeature, tapLocation: AGSPoint?) {
//        let trail = feature.attributes["SkiShop"] as! String
//        self.mapView.callout.title = "Ski Shop"
//        self.mapView.callout.detail = trail
//        self.mapView.callout.delegate = self
//        self.mapView.callout.show(for: feature, tapLocation: tapLocation, animated: true)
//        self.mapView.callout.isAccessoryButtonHidden = true
//    }
    
    func showParkingCallout(feature: AGSFeature, tapLocation: AGSPoint?) {
        let trail = feature.attributes["LotName"] as! String
        //let parkSystem = feature.attributes["Park"] as! String
        self.mapView.callout.title = "Parking Lot"
        self.mapView.callout.detail = trail
        self.mapView.callout.delegate = self
        self.mapView.callout.show(for: feature, tapLocation: tapLocation, animated: true)
        self.mapView.callout.isAccessoryButtonHidden = true
    }
    
//    func addPictureSymbol(picture: String, featureTable: AGSFeatureTable) {
//
//        let symbol = AGSPictureMarkerSymbol(image: UIImage(imageLiteralResourceName: picture))
//
//        //setup query
//        let queryParams = AGSQueryParameters()
//        queryParams.whereClause = "OBJECTID > 0"
//
//        featureTable.queryFeatures(with: queryParams) { (result:AGSFeatureQueryResult?, error:Error?) in
//            if let error = error {
//                print(error as Any)
//            }
//            else if let features = result?.featureEnumerator().allObjects {
//                if features.count > 0 {
//                    for feature in features {
//                        let featGeometry:AGSGeometry = feature.geometry!
//                        let featLon = featGeometry.extent.center.x
//                        let featLat = featGeometry.extent.center.y
//                        let featSpatialRef = feature.geometry?.spatialReference
//
//                        let featPoint = AGSPoint(x: featLon, y: featLat, spatialReference: featSpatialRef)
//
//                        let featGraphic = AGSGraphic(geometry: featPoint, symbol: symbol, attributes: nil)
//                        //add graphic to graphics overlay
//                        self.graphicsOverlay.graphics.add(featGraphic)
//                    }
//                }
//            }
//        }
//
//    }
    
    
    // sets up touch delegate
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        if let lastQuery = self.lastQuery {
            lastQuery.cancel()
        }

        // hide any open callout
        self.mapView.callout.dismiss()

        // query trails
        self.lastQuery = self.mapView.identifyLayer(self.featureLayer, screenPoint: screenPoint, tolerance: 12, returnPopupsOnly: false, maximumResults: 1) { [weak self] (identifyLayerResult: AGSIdentifyLayerResult) -> Void in
            if let error = identifyLayerResult.error {
                print(error)
            }
            else if let features = identifyLayerResult.geoElements as? [AGSFeature], features.count > 0 {
                // show callout for first feature
                //self?.showCallout(feature: features[0], tapLocation: mapPoint)
                self?.showNewTrailCallout(willShowForFeature: features[0], layer: (self?.featureLayer!)!, mapPoint: self?.mapView.screen(toLocation: screenPoint))
                // update selected feature
                //self?.selectedFeature = features[0]
            }

        }

//        // query coffee shops
//        self.lastQuery = self.mapView.identifyLayer(self.coffeeShopLayer, screenPoint: screenPoint, tolerance: 12, returnPopupsOnly: false, maximumResults: 1) { [weak self] (identifyLayerResult: AGSIdentifyLayerResult) -> Void in
//            if let error = identifyLayerResult.error {
//                print(error)
//            }
//            else if let features = identifyLayerResult.geoElements as? [AGSArcGISFeature], features.count > 0 {
//                // show callout for first feature
//                self?.showCoffeeCallout(feature: features[0], tapLocation: mapPoint)
//                // update selected feature
//                self?.selectedFeature = features[0]
//            }
//
//        }
//
//        // query hospitals
//        self.lastQuery = self.mapView.identifyLayer(self.hospitalLayer, screenPoint: screenPoint, tolerance: 12, returnPopupsOnly: false, maximumResults: 1) { [weak self] (identifyLayerResult: AGSIdentifyLayerResult) -> Void in
//            if let error = identifyLayerResult.error {
//                print(error)
//            }
//            else if let features = identifyLayerResult.geoElements as? [AGSArcGISFeature], features.count > 0 {
//                // show callout for first feature
//                self?.showHospitalCallout(feature: features[0], tapLocation: mapPoint)
//                // update selected feature
//                self?.selectedFeature = features[0]
//            }
//
//        }
//
//        // query ski shops
//        self.lastQuery = self.mapView.identifyLayer(self.skiShopLayer, screenPoint: screenPoint, tolerance: 12, returnPopupsOnly: false, maximumResults: 1) { [weak self] (identifyLayerResult: AGSIdentifyLayerResult) -> Void in
//            if let error = identifyLayerResult.error {
//                print(error)
//            }
//            else if let features = identifyLayerResult.geoElements as? [AGSArcGISFeature], features.count > 0 {
//                // show callout for first feature
//                self?.showSkiShopCallout(feature: features[0], tapLocation: mapPoint)
//                // update selected feature
//                self?.selectedFeature = features[0]
//            }
//
//        }
//
//        // query parking lots
//        self.lastQuery = self.mapView.identifyLayer(self.parkingLayer, screenPoint: screenPoint, tolerance: 12, returnPopupsOnly: false, maximumResults: 1) { [weak self] (identifyLayerResult: AGSIdentifyLayerResult) -> Void in
//            if let error = identifyLayerResult.error {
//                print(error)
//            }
//            else if let features = identifyLayerResult.geoElements as? [AGSArcGISFeature], features.count > 0 {
//                // show callout for first feature
//                self?.showParkingCallout(feature: features[0], tapLocation: mapPoint)
//                // update selected feature
//                self?.selectedFeature = features[0]
//            }
//
//        }

    }
    
}
