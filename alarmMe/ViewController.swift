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

class ViewController: UIViewController,CLLocationManagerDelegate, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate{

    @IBOutlet weak var searchResultsTableView: searchResultsUITableView!
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 1000
    let searchRequest = MKLocalSearch.Request()
    let locationManager:CLLocationManager = CLLocationManager()
    
    var searchString:String = ""
    var searchResults:[MKMapItem] = []
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
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
        searchResultsTableView.delegate = self
        searchResultsTableView.isHidden = true
        searchBar.delegate = self
    }
    
    @IBAction func searchButton(_ sender: Any) {
        centerMapOnLocation(location: searchResults.first!.placemark)
    }
    
    func doSearch () {
        searchString = searchBar.text ?? ""
        print("\(searchString)")
        searchRequest.naturalLanguageQuery = searchString
        searchRequest.region = mapView.region
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchResultsTableView.isHidden = false
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchResultsTableView.isHidden = true
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        centerMapOnLocation(location: searchResults.first!.placemark)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("I'm selected")
        let placemark = searchResults[indexPath.row].placemark
        searchBar.text = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "") \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""), \(placemark.countryCode ?? "")"
        doSearch()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

class searchResultCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}
