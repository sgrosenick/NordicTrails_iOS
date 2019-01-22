//
//  FirstViewController.swift
//  NordicTrails
//
//  Created by Samuel Grosenick on 11/3/18.
//  Copyright © 2018 Samuel Grosenick. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // set title and color of navigation and tab bar
        self.navigationItem.title = "Choose a Park"
        navigationController?.navigationBar.backgroundColor = Theme.background
        navigationController?.navigationBar.barTintColor = Theme.background
        
        
        ParksFunctions.readParks(completion: { [weak self] in
            // reload the data
            self?.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParksData.parksModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ParksTableViewCell
        
        cell.contentSetup(ParksModel: ParksData.parksModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "parkSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "parkSegue") {
            let destVC: TrailsViewController = segue.destination as! TrailsViewController
            
            let selectedIndexPath = tableView.indexPathForSelectedRow
            let selectData = ParksData.parksModels[selectedIndexPath!.row]
            
            destVC.parkName = selectData.title
        }
    }

}
