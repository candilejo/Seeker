//
//  SK_Yo_Editar_SearchLocationTableViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 5/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import MapKit

class SK_Yo_Editar_SearchLocationTableViewController: UITableViewController {

    //MARK: - VARIABLES LOCALES GLOBALES
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    weak var handleMapSearchDelegate: HandleMapSearch?
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
    }

    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK: - CONFIGURACION DE LA TABLA
    
    // NÚMERO DE CELDAS DE LA TABLA.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    // CARGA DE VALORES DE LA CELDA.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
    // CARGAMOS LOS VALORES SELECCIONADOS.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK -------------------------- UTILIDADES --------------------------
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        // Poner espacio en el primer hueco.
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // Poner coma entre la calle y la ciudad
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // Poner espacio entre la ciudad y la provincia
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // Numero de la calle
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // Nombre de la calle
            selectedItem.thoroughfare ?? "",
            comma,
            // Ciudad
            selectedItem.locality ?? "",
            secondSpace,
            // Provincia
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}


//MARK - EXTENSION PARA ACTUALIZAR LA TABLA DE RESULTADOS
extension SK_Yo_Editar_SearchLocationTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
