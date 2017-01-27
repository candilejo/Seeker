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

//MARK: - VARIABLES GLOBALES
var haPasado : Bool?
var guardado = false

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
    var localizacion : [CLLocation] = []
    var overlay : [MKOverlay] = []
    var pintar = false
    var latitudRuta : [Double] = []
    var longitudRuta : [Double] = []
    var direccionInicial : String?
    
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myMapaCaptacionMV: MKMapView!
    @IBOutlet weak var myBotonAddClienteBTN: UIButton!
    @IBOutlet weak var myBotonEmpezarCaptacionBTN: UIButton!
    @IBOutlet weak var myBotonPararCaptacionBTN: UIButton!
    @IBOutlet weak var myBotonClientesBTN: UIBarButtonItem!
    @IBOutlet weak var myBotonRutaBTN: UIBarButtonItem!
    
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
    
    //MARK: - CARGAMOS LOS CLIENTES Y PARAMOS LA CAPTACIÓN CUANDO RECUPERAMOS EL VIEW
    override func viewDidAppear(_ animated: Bool) {
        if haPasado == true{
            cargarClientes()
            haPasado = false
        }
        if guardado{
           lanzarPararCaptacion(parar: true)
            guardado = false
        }
    }
    
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // UNWIND.
    @IBAction func unWindSegue(segue: UIStoryboardSegue){}
    
    // AÑADIR CLIENTE.
    @IBAction func addClienteACTION(_ sender: Any) {
        // Ocultamos las anotaciones.
        myMapaCaptacionMV.removeAnnotations(myMapaCaptacionMV.annotations)
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
        if sender.selectedSegmentIndex == 0 {
            myMapaCaptacionMV.mapType = .standard
        }else{
            myMapaCaptacionMV.mapType = .satellite
        }
    }
    
    
    // EMPEZAR CAPTACIÓN.
    @IBAction func empezarCaptacionACTION(_ sender: Any) {
        if calle == ""{
            present(showAlertVC("ATENCIÓN", messageData: "Espere a que su localización sea correcta."), animated: true, completion: nil)
        }else{
            lanzarPararCaptacion(parar: false)
        }
    }
    
    
    // PARAR CAPTACIÓN.
    @IBAction func pararCaptacionACTION(_ sender: Any) {
        
        // Creamos un ActionSheet con varias opciones.
        let alertVC = UIAlertController(title: "INFORMACIÓN", message: "Seleccione una opción.", preferredStyle: .actionSheet)
        
        let guardarAction = UIAlertAction(title: "Guardar", style: .default) { (GuardarAction) in
            
            let infoRuta = self.storyboard?.instantiateViewController(withIdentifier: "infoRuta") as! SK_InformacionRuta_ViewController
            infoRuta.direccionInicial = self.direccionInicial
            infoRuta.latitudRuta = self.latitudRuta
            infoRuta.longitudRuta = self.longitudRuta
            
            self.navigationController?.pushViewController(infoRuta, animated: true)
        }
        let eliminarAction = UIAlertAction(title: "Eliminar", style: .default, handler: { (EliminarAction) in
            self.lanzarPararCaptacion(parar: true)
        })
        let cancelarAcrion = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertVC.addAction(guardarAction)
        alertVC.addAction(eliminarAction)
        alertVC.addAction(cancelarAcrion)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MOSTRAR CLIENTES
    @IBAction func verClientesACTION(_ sender: Any) {
        if existeCliente{// Si existen clientes comprobamos que no esten ocultos.
            if oculto{ // Si los clientes estan ocultos los mostramos
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
        }else{ // Sino lanzamos un mensaje de error.
            present(showAlertVC("ATENCIÓN", messageData: "Actualmente no existe ningún cliente."), animated: true, completion: nil)
        }
    }
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // PARAR / LANZAR CAPTACIÓN
    func lanzarPararCaptacion(parar: Bool){
        if parar{ // Si se para la captación.
            // Bloqueamos / Activamos los botones
            myBotonPararCaptacionBTN.isEnabled = false
            myBotonEmpezarCaptacionBTN.isEnabled = true
            myBotonAddClienteBTN.isEnabled = false
            myBotonRutaBTN.isEnabled = true
            // Dejamos de pintar.
            pintar = false
            // Eliminamos los lineas pintadas.
            myMapaCaptacionMV.removeOverlays(overlay)
            // Paramos la actualización de la localización
            locationManager.stopUpdatingLocation()
            // Vaciamos el array de localizaciones.
            localizacion.removeAll()
        }else{// Sino
            // Bloqueamos / Activamos los botones
            myBotonPararCaptacionBTN.isEnabled = true
            myBotonEmpezarCaptacionBTN.isEnabled = false
            myBotonAddClienteBTN.isEnabled = true
            myBotonRutaBTN.isEnabled = false
            // Lanzamos la actualización de la localización
            locationManager.startUpdatingLocation()
            // Ocultamos los clientes y empezamos a pintar
            oculto = true
            pintar = true
            // Eliminamos las anotaciones.
            myMapaCaptacionMV.removeAnnotations(myMapaCaptacionMV.annotations)
        }
    }
    
    // CARGAMOS CLIENTES
    func cargarClientes(){
        // Limpiamos todos los array de almacenamiento.
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
                                            
                                            // Ocultamos la carga y lanzamos los eventos.
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
    
    // CARGA DIRECCION
    func cargarDireccion(location : CLLocation){
        // Transformamos la localización en datos.
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if let placeMarksData = placemarks?.first{
                    self.direccionInicial = "\(placeMarksData.name!), \(placeMarksData.locality!)"
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
        if pintar == false{ // Si no hay que pintar.
            // Creamos los valores del mapa
            var center = CLLocationCoordinate2DMake(0.0, 0.0)
            let span = MKCoordinateSpanMake(0.01, 0.01)
            
            // Cogemos la última localización.
            if let location = locations.first{
                center = location.coordinate
                self.latitud = location.coordinate.latitude
                self.longitud = location.coordinate.longitude
                self.cargarCalle(location: location)
                localizacion.append(location)
            }
            
            let region = MKCoordinateRegion(center: center, span: span)
            myMapaCaptacionMV.setRegion(region, animated: true)
            
        }else if pintar{ // Si hay que pintar.
            // Cargamos los valores del mapa
            let spanX = 0.007
            let spanY = 0.007
            let newRegion = MKCoordinateRegion(center: myMapaCaptacionMV.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            myMapaCaptacionMV.setRegion(newRegion, animated: true)
            
            // Empezamos a rellenar los arrays
            localizacion.append(locations[0] as CLLocation)
            latitudRuta.append((locations.first?.coordinate.latitude)!)
            longitudRuta.append((locations.first?.coordinate.longitude)!)
            
            // Cargamos la dirección inicial.
            self.cargarDireccion(location: localizacion.first!)

            if (localizacion.count > 1){ // Si la longitud del array es mayor de 1.
                // Establecemos el inicio y el destino.
                let inicio = localizacion.count - 1
                let destino = localizacion.count - 2
                
                // Establecemos las coordenadas.
                let c1 = localizacion[inicio].coordinate
                let c2 = localizacion[destino].coordinate
                
                // Cargamos las coordenadas
                var coordenadas = [c1, c2]
                
                // Añadimos la linea.
                let polyline = MKPolyline(coordinates: &coordenadas, count: coordenadas.count)
                myMapaCaptacionMV.add(polyline)
            }
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 4
        self.overlay.append(overlay)
        return polylineRenderer
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.telefCliente = ((view.annotation?.title)!)!
    }
}
