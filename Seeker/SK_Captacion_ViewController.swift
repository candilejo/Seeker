//
//  SK_Captacion_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 7/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBREIRAS
import UIKit
import MapKit
import Parse

class SK_Captacion_ViewController: UIViewController {

    
    //MARK: - VARIABLES LOCALES GLOBALES
    var locationManager = CLLocationManager()
    var latitud : Double?
    var longitud : Double?
    var calle = ""
    var localidad = ""
    var provincia = ""
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myMapaCaptacionMV: MKMapView!
    @IBOutlet weak var myBotonAddClienteBTN: UIButton!
    @IBOutlet weak var myBotonEmpezarCaptacionBTN: UIButton!
    @IBOutlet weak var myBotonPararCaptacionBTN: UIButton!
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Bloqueamos myBotonPararCaptacionBTN y establecemos los colores del texto.
        myBotonPararCaptacionBTN.isEnabled = false
        myBotonPararCaptacionBTN.setTitleColor(UIColor.lightGray, for: .disabled)
        myBotonPararCaptacionBTN.setTitleColor(UIColor.white, for: .normal)
        
        // Establecemos los colores del texto de myBotonEmpezarCaptacionBTN.
        myBotonEmpezarCaptacionBTN.setTitleColor(UIColor.lightGray, for: .disabled)
        myBotonEmpezarCaptacionBTN.setTitleColor(UIColor.white, for: .normal)
        
        // Establecemos los bordes y sombras de los botones
        configuraSombraAspectoBotones(boton: myBotonAddClienteBTN, redondo: true)
        configuraSombraAspectoBotones(boton: myBotonEmpezarCaptacionBTN, redondo: false)
        configuraSombraAspectoBotones(boton: myBotonPararCaptacionBTN, redondo: false)
        
        // Configuración del locationManager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // Establecemos que myMapaCaptacionMV sea su propio delegado.
        myMapaCaptacionMV.delegate = self
    }

    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //MARK: - ACTUALIZAMOS LOS DATOS CUANDO RECUPERAMOS EL VIEW
    override func viewDidAppear(_ animated: Bool) {
        //cargarDatos()
    }
    
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // AÑADIR CLIENTE.
    @IBAction func addClienteACTION(_ sender: Any) {
        
        // Creamos la instacia de SK_Captacion_AddClient_ViewController.
        let addCliente = self.storyboard?.instantiateViewController(withIdentifier: "addClient") as! SK_Captacion_AddClient_ViewController
        
        // Pasamos los datos a la Segunda Ventana.
        addCliente.latitud = self.latitud
        addCliente.longitud = self.longitud
        addCliente.calle = "\(self.calle), \(self.localidad),(\(self.provincia))"
    
        self.navigationController?.pushViewController(addCliente, animated: true)
    }
    
    
    // CAMBIA EL MODELO DEL MAPA.
    @IBAction func cambiaModeloMapaACTION(_ sender: AnyObject) {
        
        // Cambiamos el tipo de mapa en función de la selección.
        if sender.selectedSegmentIndex == 0 {
            myMapaCaptacionMV.mapType = .standard
        }else{
            myMapaCaptacionMV.mapType = .satellite
        }
    }
    
    
    // EMPEZAR CAPTACIÓN.
    @IBAction func empezarCaptacionACTION(_ sender: Any) {
        myBotonPararCaptacionBTN.isEnabled = true
        myBotonEmpezarCaptacionBTN.isEnabled = false
        myMapaCaptacionMV.showsUserLocation = false
        //cargarCalle()
    }
    
    
    // PARAR CAPTACIÓN.
    @IBAction func pararCaptacionACTION(_ sender: Any) {
        myBotonPararCaptacionBTN.isEnabled = false
        myBotonEmpezarCaptacionBTN.isEnabled = true
        myMapaCaptacionMV.removeAnnotations(myMapaCaptacionMV.annotations)
    }
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // CARGAMOS LOS DATOS DEL CLIENTE
    func cargaDatosUsuario(){}
    
    
    // CARGA CALLE
    func cargarCalle(location : CLLocation){

        // Transformamos la localización en datos.
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            
            // Asignamos los valores.
            if let placeMarksData = placemarks?.first{
                self.calle = placeMarksData.name!
                self.localidad = placeMarksData.locality!
                self.provincia = placeMarksData.administrativeArea!
            }
        })
        
    }
}


//MARK: - EXTENSION CLLOCATIONMANAGER
extension SK_Captacion_ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Creamos los valores del mapa
        var center = CLLocationCoordinate2DMake(0.0, 0.0)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        
        if let location = locations.first {
            myMapaCaptacionMV.showsUserLocation = true
            center = location.coordinate
            self.latitud = location.coordinate.latitude
            self.longitud = location.coordinate.longitude
            
            self.cargarCalle(location: location)
        }
        
        
        let region = MKCoordinateRegion(center: center, span: span)
        myMapaCaptacionMV.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
}

//MARK: - EXTENSION PARA CREAR ANOTACIONES PERSONALIZADAS.
extension SK_Captacion_ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let reusarId = "anotacion"
        
        var anotacionView = mapView.dequeueReusableAnnotationView(withIdentifier: reusarId)
        if anotacionView == nil {
            anotacionView = MKAnnotationView(annotation: annotation, reuseIdentifier: reusarId)
            anotacionView!.image = UIImage(named:"negocio2")
            anotacionView!.canShowCallout = true
            let smallSquare = CGSize(width: 30, height: 30)
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            button.setBackgroundImage(UIImage(named: "negocioGrande"), for: UIControlState())
            button.addTarget(self, action: #selector(SK_Captacion_ViewController.cargaDatosUsuario), for: .touchUpInside)
            anotacionView!.leftCalloutAccessoryView = button
        }
        else{
            anotacionView!.annotation = annotation
        }
        return anotacionView
    }
    
}
