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

class ViewController: UIViewController,CLLocationManagerDelegate, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

    var currentCLLocation = CLLocation(latitude: 21.282778, longitude: -157.829444) //random initial location
    var currentCLPlacemark:CLPlacemark = CLPlacemark()
    let regionRadius: CLLocationDistance = 1000
    let locationManager:CLLocationManager = CLLocationManager()
    
    //variables for search function
    var searchString:String = ""
    let searchRequest = MKLocalSearch.Request()
    var searchResults:[MKMapItem] = []
    var proposedDestinationLocation:MKMapItem = MKMapItem()
    var confirmedDestinationLocation:MKMapItem = MKMapItem()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: searchResultsUITableView!
    @IBOutlet weak var proposedDestinationLabel: UILabel!
    @IBOutlet weak var confirmedDestinationLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func setAlertButton(_ sender: Any) {
        self.confirmedDestinationLocation = proposedDestinationLocation
        confirmedDestinationLabel.text =
        mkMapItemToAddress(mkMapItem: self.confirmedDestinationLocation)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupSearchFunctionality()

        centerMapOnLocation(location: currentCLLocation)
        
        mapView.showsUserLocation = true
    }
    
    func numberOfSections(in searchResultsTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ searchResultsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ searchResultsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "searchResultCell") as! searchResultCell
        cell.nameLabel?.text = mkMapItemToAddress(mkMapItem: searchResults[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("I'm selected")
        searchBar.text = mkMapItemToAddress(mkMapItem: searchResults[indexPath.row])
        doSearch()
        
        self.proposedDestinationLocation = searchResults[indexPath.row]
        proposedDestinationLabel.text = mkMapItemToAddress(mkMapItem: proposedDestinationLocation)
        searchBar.endEditing(true)
        centerMapOnLocation(location: self.proposedDestinationLocation.placemark)
    }
    //convert a MKMapItem to a readable address
    func mkMapItemToAddress (mkMapItem : MKMapItem) -> String {
        let placemark = mkMapItem.placemark
        let result = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "") \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""), \(placemark.countryCode ?? "")"
        return result
    }
}
//searchFunctionality
extension ViewController {
    func setupSearchFunctionality () {
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.isHidden = true
        searchBar.delegate = self
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
    
    @IBAction func searchButton(_ sender: Any) {
        centerMapOnLocation(location: searchResults.first!.placemark)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func centerMapOnLocation(location: MKPlacemark) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
//locationManager
extension ViewController {
    func setupLocationManager () {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100 //100 meter frequency filter
        //locationManager.stopUpdatingLocation()()
    }
    //center location on map using CCLocation
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    //center location on map using CLPlacemark
    func centerMapOnLocation(location: CLPlacemark) {
        if location.location?.coordinate != nil{
            let coordinateRegion = MKCoordinateRegion(center: location.location!.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    //when location gets updated, center the map on the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations{
            //            print("\(index): \(currentLocation)")
            self.currentCLLocation = currentLocation
            centerMapOnLocation(location: self.currentCLLocation)
        }
    }
}

class searchResultCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}
