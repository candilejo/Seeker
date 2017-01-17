//
//  SK_Yo_Editar_Ubicacion_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 5/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import MapKit
import Parse

//MARK: - PROTOCOLO PARA AÑADIR MARCAS
protocol HandleMapSearch : class {
    func dropPinZoomIn(_ placemark : MKPlacemark)
}


class SK_Yo_Editar_Ubicacion_ViewController: UIViewController {

    
    //MARK: - VARIABLES LOCALES GLOBALES
    var locationManager = CLLocationManager()
    var resultSearchController : UISearchController? = nil
    var selectedPin : MKPlacemark? = nil
    var latitud : CLLocationDegrees? = nil
    var longitud : CLLocationDegrees? = nil
    var calle = ""
    var postal = ""
    var localidad = ""
    var provincia = ""
    
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myMapaUbicacionMV: MKMapView!
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Configuración del locationManager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // Configuración de la locationSearchTable,
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "SearchLocation") as! SK_Yo_Editar_SearchLocationTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        // Configuración de la searchBar.
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Ubicación de su empresa"
        navigationItem.titleView = resultSearchController?.searchBar
        
        
        // Controladores del locationSearchTable.
        locationSearchTable.mapView = myMapaUbicacionMV
        locationSearchTable.handleMapSearchDelegate = self
        
        // Establecemos que myMapaUbicacionMV sea su propio delegado.
        myMapaUbicacionMV.delegate = self
    }
    
    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // CANCELAR CAMBIO DE UBICACIÓN.
    @IBAction func cancelarUbicacionACTION(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // CAMBIO TIPO DE MAPA.
    @IBAction func cambioTipoMapaACTION(_ sender: AnyObject) {
        if sender.selectedSegmentIndex == 0{
            myMapaUbicacionMV.mapType = .standard
        }else if sender.selectedSegmentIndex == 1{
            myMapaUbicacionMV.mapType = .satellite
        }
    }
    

    //MARK -------------------------- UTILIDADES --------------------------
    
    // MUESTRA UN ALERT CON LA UBICACION
    func mostrarUbicacion(){
        let userData = PFUser.current()!
        
        // Si alguno de los campos coincide con los ya cargados lanzamos un error.
        if userData["calleEmpresa"] as? String == calle && userData["postalEmpresa"] as? String == postal && userData["localidadEmpresa"] as? String == localidad && userData["provinciaEmpresa"] as? String == provincia && userData["latitudEmpresa"] as? Double == latitud! && userData["longitudEmpresa"] as! Double == longitud!{
            present(showAlertVC("ATENCION", messageData: "La ubicación ya esta seleccionada."), animated: true, completion: nil)
        }else{// Sino mostramos una alerta con varias acciones.
            let alert = UIAlertController(title: "UBICACIÓN SELECCIONADA",message: "Calle: \(calle) \n Código Postal: \(postal) \n Localidad: \(localidad) \n Provincia: \(provincia)",preferredStyle: UIAlertControllerStyle.alert)
            let saveAction = UIAlertAction(title: "Guardar", style: UIAlertActionStyle.default, handler: { (guardarAccion) in
                self.actualizarUbicacionActual()
                self.dismiss(animated: true, completion: nil)
            })
            let cancelAccion = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: { (cancelarAccion) in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(saveAction)
            alert.addAction(cancelAccion)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // ACTUALIZAR DATOS DEL USUARIO
    func actualizarUbicacionActual(){
        
        // Actualizamos los datos del usuario si los campos no están vacíos.
        let userData = PFUser.current()!
        userData["calleEmpresa"] = calle
        userData["postalEmpresa"] = postal
        userData["localidadEmpresa"] = localidad
        userData["provinciaEmpresa"] = provincia
        userData["latitudEmpresa"] = latitud
        userData["longitudEmpresa"] = longitud
        
        // Mostramos la carga e ignoramos los eventos
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Salvamos los datos.
        userData.saveInBackground { (seActualiza, errorActualizacion) in
            // Ocultamos la carga y lanzamos los eventos.
            UIApplication.shared.endIgnoringInteractionEvents()
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            // Si existe algún error.
            if errorActualizacion != nil{
                //Lanzamos el error de porque no hemos podido actualizarlo.
                let error =  erroresUser(code: (errorActualizacion! as NSError).code)
                if error != ""{
                    self.present(showAlertVC("ATENCION", messageData: error), animated: true, completion: nil)
                }else{
                    self.present(showAlertVC("Error", messageData: "Error al actualizar."), animated: true, completion: nil)
                }
            }
        }
    }
    
}



//MARK: - EXTENSION CLLOCATIONMANAGER
extension SK_Yo_Editar_Ubicacion_ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Creamos los valores del mapa
        var center = CLLocationCoordinate2DMake(0.0, 0.0)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        
        // Asignamos los valores del usuario si no están vacios.
        let userData = PFUser.current()!
        if userData["calleEmpresa"] as? String != nil{
            self.calle = userData["calleEmpresa"] as! String
        }
        if userData["postalEmpresa"] as? String != nil{
            self.postal = userData["postalEmpresa"] as! String
        }
        if userData["localidadEmpresa"] as? String != nil{
            self.localidad = userData["localidadEmpresa"] as! String
        }
        if userData["provinciaEmpresa"] as? String != nil{
            self.provincia = userData["provinciaEmpresa"] as! String
        }
        if userData["latitudEmpresa"] as? Double != nil{
            self.latitud = userData["latitudEmpresa"] as? Double
        }
        if userData["longitudEmpresa"] as? Double != nil{
            self.longitud = userData["longitudEmpresa"] as? Double
        }
        
        // Comprobamos que la longitud y latitud sean correctas, en caso contrario establecemos la posición actúal del usuario.
        if latitud != nil && longitud != nil{
            myMapaUbicacionMV.showsUserLocation = false
            center = CLLocationCoordinate2DMake(latitud!, longitud!)
            
            myMapaUbicacionMV.removeAnnotations(myMapaUbicacionMV.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = userData["calleEmpresa"]as? String
            annotation.subtitle = userData["localidadEmpresa"] as? String
            myMapaUbicacionMV.addAnnotation(annotation)
            
        } else if let location = locations.first {
            myMapaUbicacionMV.showsUserLocation = true
            center = location.coordinate
        }
        
        let region = MKCoordinateRegion(center: center, span: span)
        myMapaUbicacionMV.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
}



//MARK: - EXTENSION PARA AÑADIR MARCAS
extension SK_Yo_Editar_Ubicacion_ViewController: HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        myMapaUbicacionMV.removeAnnotations(myMapaUbicacionMV.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let street = placemark.name, let postalCode = placemark.postalCode, let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
            calle = street
            postal = postalCode
            localidad = city
            provincia = state
            latitud = placemark.coordinate.latitude
            longitud = placemark.coordinate.longitude
        }
        myMapaUbicacionMV.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        myMapaUbicacionMV.setRegion(region, animated: true)
    }
}



//MARK: - EXTENSION PARA CREAR ANOTACIONES PERSONALIZADAS.
extension SK_Yo_Editar_Ubicacion_ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let reusarId = "anotacion"
        
        var anotacionView = mapView.dequeueReusableAnnotationView(withIdentifier: reusarId)
        if anotacionView == nil {
            anotacionView = MKAnnotationView(annotation: annotation, reuseIdentifier: reusarId)
            anotacionView!.image = UIImage(named:"pinNegocio")
            anotacionView!.canShowCallout = true
            let smallSquare = CGSize(width: 30, height: 30)
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            button.setBackgroundImage(UIImage(named: "negocioGrande2"), for: UIControlState())
            button.addTarget(self, action: #selector(SK_Yo_Editar_Ubicacion_ViewController.mostrarUbicacion), for: .touchUpInside)
            anotacionView!.leftCalloutAccessoryView = button
        }
        else{
            anotacionView!.annotation = annotation
        }
        return anotacionView
    }
    
}
