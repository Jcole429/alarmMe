//
//  ViewController.swift
//  alarmMe
//
//  Created by Justin Cole on 8/16/19.
//  Copyright © 2019 Jcole. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate, UITableViewDataSource,UISearchBarDelegate{

    @IBOutlet weak var searchResultsTableView: searchResultsUITableView!
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 1000
    let searchRequest = MKLocalSearch.Request()
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    var searchString:String = ""
    var searchResults:[MKMapItem] = []
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchBar.text ?? ""
        print("\(searchString)")
        searchRequest.naturalLanguageQuery = searchString
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            self.searchResults = response.mapItems
            self.searchResultsTableView.reloadData()
//            print("\(self.searchResults)")
        }
    }
    
 
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnLocation(location: MKPlacemark) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100 //100 meter frequency filter
        
        //locationManager.stopUpdatingLocation()()
        
        centerMapOnLocation(location: initialLocation)
        // Do any additional setup after loading the view.
        searchResultsTableView.dataSource = self
        searchBar.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations{
//            print("\(index): \(currentLocation)")
            centerMapOnLocation(location: currentLocation)
        }
    }
    
    func numberOfSections(in searchResultsTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ searchResultsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ searchResultsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "searchResultCell") as! searchResultCell
        let placemark = searchResults[indexPath.row].placemark
        cell.nameLabel?.text = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "") \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""), \(placemark.countryCode ?? "")"
        return cell
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

class searchResultCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}
