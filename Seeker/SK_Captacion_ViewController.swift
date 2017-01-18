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


var haPasado : Bool?

class SK_Captacion_ViewController: UIViewController {

    
    //MARK: - VARIABLES LOCALES GLOBALES
    var locationManager = CLLocationManager()
    var latitud : Double?
    var longitud : Double?
    var calle = ""
    var localidad = ""
    var provincia = ""
    var telefonoCliente = [String]()
    var latitudCliente = [Double]()
    var longitudCliente = [Double]()
    var calleCliente = [String]()
    var dicImagen = [String : UIImage]()
    var telefCliente = ""
    var oculto = true
    var existeCliente = false
    
    var localizacion = [CLLocation]()
    
    
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
        
        // Bloqueamos myBotonAddClienteBTN.
        myBotonAddClienteBTN.isEnabled = false
        
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
        
        // Cargamos los clientes
        cargarClientes()
        
    }

    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - CARGAMOS LOS CLIENTES CUANDO RECUPERAMOS EL VIEW
    override func viewDidAppear(_ animated: Bool) {
        if haPasado == true{
            cargarClientes()
            haPasado = false
        }
    }
    
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // UNWIND.
    @IBAction func unWindSegue(segue: UIStoryboardSegue){}
    
    // AÑADIR CLIENTE.
    @IBAction func addClienteACTION(_ sender: Any) {
        // Ocultamos las anotaciones y paramos la actualización de la posición.
        myMapaCaptacionMV.removeAnnotations(myMapaCaptacionMV.annotations)
        locationManager.stopUpdatingLocation()
        oculto = true
        
        // Creamos la instacia de SK_Captacion_AddClient_ViewController.
        let addCliente = self.storyboard?.instantiateViewController(withIdentifier: "addClient") as! SK_Captacion_AddClient_ViewController
        // Pasamos los datos a la SK_Captacion_AddClient_ViewController.
        addCliente.latitud = self.latitud
        addCliente.longitud = self.longitud
        addCliente.calle = "\(self.calle), \(self.localidad)"
    
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
        lanzarPararCaptacion(parar: false)
        oculto = true
        myMapaCaptacionMV.removeAnnotations(myMapaCaptacionMV.annotations)
        print(localizacion)
    }
    
    
    // PARAR CAPTACIÓN.
    @IBAction func pararCaptacionACTION(_ sender: Any) {
        lanzarPararCaptacion(parar: true)
    }
    
    // MOSTRAR CLIENTES
    @IBAction func verClientesACTION(_ sender: Any) {        
        // Si los clientes estan ocultos los mostramos
        if existeCliente{
            if oculto{
                for i in 1...self.longitudCliente.count{
                    let center = CLLocationCoordinate2DMake(self.latitudCliente[i - 1], self.longitudCliente[i - 1])
                
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center
                    annotation.title = self.telefonoCliente[i - 1]
                    annotation.subtitle = self.calleCliente[i - 1]
                    self.myMapaCaptacionMV.addAnnotation(annotation)
                }
                oculto = false
            }else{ // Si no los ocultamos.
                myMapaCaptacionMV.removeAnnotations(myMapaCaptacionMV.annotations)
                oculto = true
            }
        }else{
            present(showAlertVC("ATENCIÓN", messageData: "Actualmente no existe ningún cliente."), animated: true, completion: nil)
        }
    }
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // PARAR / LANZAR CAPTACIÓN
    func lanzarPararCaptacion(parar: Bool){
        if parar{
            myBotonPararCaptacionBTN.isEnabled = false
            myBotonEmpezarCaptacionBTN.isEnabled = true
            myBotonAddClienteBTN.isEnabled = false
            locationManager.stopUpdatingLocation()
        }else{
            myBotonPararCaptacionBTN.isEnabled = true
            myBotonEmpezarCaptacionBTN.isEnabled = false
            myBotonAddClienteBTN.isEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    // CARGAMOS CLIENTES
    func cargarClientes(){
        telefonoCliente.removeAll()
        latitudCliente.removeAll()
        longitudCliente.removeAll()
        calleCliente.removeAll()
        dicImagen.removeAll()
        
        // Realizamos la consulta de los datos del cliente.
        let userData = PFUser.current()!
        let usuario = userData.username! as String
        
        let queryClient = PFQuery(className: "Client")
        queryClient.whereKey("usuarioCliente", equalTo: usuario)
        
        // Mostramos la carga y paramos los eventos.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Buscamos todos los objetos.
        queryClient.findObjectsInBackground { (objectUno, errorUno) in
            if errorUno == nil && objectUno! != []{
                if let objectUnoDes = objectUno{
                    for objectDataUnoDes  in objectUnoDes{
                        // Realizamos la consulta de las imagenes de los clientes.
                        let queryImage = PFQuery(className: "imageClient")
                        queryImage.whereKey("telefonoCliente", equalTo: objectDataUnoDes["telefonoCliente"])
                        
                        // Buscamos los objetos del cliente comprobando si hay errores.
                        queryImage.findObjectsInBackground(block: { (objectDos, errorDos) in
                            
                            self.existeCliente = true
                            if errorDos == nil{
                                if let objectDosDes = objectDos{
                                    for objectDataDosDes in objectDosDes{
                                        let clientFile = objectDataDosDes["imagenCliente"] as! PFFile
                                        
                                        // Cargamos el valor a la imagen.
                                        clientFile.getDataInBackground(block: { (imageData, imageError) in
                                            
                                            //// Ocultamos la carga y lanzamos los eventos.
                                            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            
                                            if imageError == nil{
                                                if let imageDataDes = imageData{
                                                    let image = UIImage(data: imageDataDes)
                                                    self.dicImagen[objectDataUnoDes["telefonoCliente"] as! String] = image!
                                                }
                                            }
                                        })
                                    }
                                }
                            }else{
                                //// Ocultamos la carga y lanzamos los eventos.
                                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                        })
                        // Cargamos los datos del cliente.
                        if objectDataUnoDes["telefonoCliente"] != nil{
                            self.telefonoCliente.append(objectDataUnoDes["telefonoCliente"] as! String)
                        }
                        if objectDataUnoDes["latitudCliente"] != nil{
                            self.latitudCliente.append(objectDataUnoDes["latitudCliente"] as! Double)
                        }
                        if objectDataUnoDes["longitudCliente"] != nil{
                            self.longitudCliente.append(objectDataUnoDes["longitudCliente"] as! Double)
                        }
                        if objectDataUnoDes["calleCliente"] != nil{
                            self.calleCliente.append(objectDataUnoDes["calleCliente"] as! String)
                        }
                    }
                }
            }else{
                // Ocultamos la carga y lanzamos los eventos.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
                self.existeCliente = false
            }
        }
    }
    
    
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
    
    // MOSTRAR DATOS DEL CLIENTE
    func cargaDatosCliente(){
        
        // Ocultamos las anotaciones.
        lanzarPararCaptacion(parar: true)
        myMapaCaptacionMV.removeAnnotations(myMapaCaptacionMV.annotations)
        oculto = true
        
        // Creamos la instacia de SK_Captacion_InfoCliente_ViewController.
        let infoCliente = self.storyboard?.instantiateViewController(withIdentifier: "informationClient") as! SK_Captacion_InfoCliente_ViewController
        
        // Pasamos los datos a la SK_Captacion_InfoCliente_ViewController.
        infoCliente.telefonoCliente = self.telefCliente

        self.navigationController?.pushViewController(infoCliente, animated: true)
    }
}


//MARK: - EXTENSION CLLOCATIONMANAGER
extension SK_Captacion_ViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Creamos los valores del mapa
        var center = CLLocationCoordinate2DMake(0.0, 0.0)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        
        if let location = locations.first{
            center = location.coordinate
            self.latitud = location.coordinate.latitude
            self.longitud = location.coordinate.longitude
            self.cargarCalle(location: location)
            localizacion.append(location)
        }
        
        
        let region = MKCoordinateRegion(center: center, span: span)
        myMapaCaptacionMV.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    /*func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
    }*/
}

//MARK: - EXTENSION PARA CREAR ANOTACIONES PERSONALIZADAS.
extension SK_Captacion_ViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let reusarId = "\(dicImagen[annotation.title!!]!)"
        
        var anotacionView = mapView.dequeueReusableAnnotationView(withIdentifier: reusarId)
        if anotacionView == nil {
            let imagen = self.dicImagen[annotation.title!!]!
            anotacionView = MKAnnotationView(annotation: annotation, reuseIdentifier: reusarId)
            anotacionView!.image = UIImage(named:"pinCliente")
            anotacionView!.canShowCallout = true
            let smallSquare = CGSize(width: 30, height: 30)
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            button.setBackgroundImage(imagen, for: UIControlState())
            button.addTarget(self, action: #selector(SK_Captacion_ViewController.cargaDatosCliente), for: .touchUpInside)
            anotacionView!.leftCalloutAccessoryView = button
        }
        else{
            anotacionView!.annotation = annotation
        }
        
        return anotacionView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.telefCliente = ((view.annotation?.title)!)!
    }
}
