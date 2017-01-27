//
//  SK_InformacionRuta_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 24/1/17.
//  Copyright © 2017 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import UIKit
import MapKit
import Parse

class SK_InformacionRuta_ViewController: UIViewController{

    //MARK: - VARIABLES LOCALES GLOBALES
    var direccionInicial: String?
    var latitudRuta : Array <Double>?
    var longitudRuta : Array <Double>?
    var locations : [CLLocation] = []
    var formatter:DateFormatter = DateFormatter()
    var fecha : String?
    
    //MARK: - IBOUTLET
    @IBOutlet weak var myNombreRutaTF: UITextField!
    @IBOutlet weak var myMapaRutaTF: MKMapView!
    @IBOutlet weak var myFechaRutaLBL: UILabel!
    @IBOutlet weak var myDireccionInicialLBL: UILabel!
    
    //MARK: - LIVE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Establecemos el formato de la fecha.
        formatter.dateStyle = DateFormatter.Style.long
        fecha = formatter.string(from: NSDate() as Date)
        
        // Establecemos los valores de los parametros.
        myFechaRutaLBL.text = fecha
        myDireccionInicialLBL.text = direccionInicial
        
        // Establecemos myMapaRutaTF como su propio delegado.
        myMapaRutaTF.delegate = self
        
        // Creamos la PolyLine
        createPolyLine()
    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK -------------------------- ACCIONES --------------------------
    @IBAction func guardarRutaACTION(_ sender: Any) {
        if myNombreRutaTF.text != ""{ // Si el nombre de la ruta no esta vacío.
            compruebaNombreRuta() // Comprobamos la ruta.
        }else{ // Sino lanzamos un error
            present(showAlertVC("ATENCIÓN", messageData: "Debe rellenar el nombre de la ruta"), animated: true, completion: nil)
        }
    }
    
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // CERAR POLYLINE.
    func createPolyLine(){
        let anotationInicial = MKPointAnnotation()
        
        // Cargamos las localizaciones en locations
        for i in 1...longitudRuta!.count{
            let longitud = Double(longitudRuta![i - 1])
            let latitud = Double(latitudRuta![i - 1])
            locations.append(CLLocation(latitude: latitud, longitude: longitud))
            
            if i == 1{ // Si i es 1 añadimos el el comienzo de la ruta.
                anotationInicial.coordinate = (locations.first?.coordinate)!
                anotationInicial.title = "Comienzo de la ruta"
                anotationInicial.subtitle = direccionInicial!
                myMapaRutaTF.addAnnotation(anotationInicial)
            }
        }
        
        addPolyLine(locations: locations) // Añadimos la PolyLine al mapa
        
        // Establecemos el Zoom y la localización del mapa.
        let location = CLLocationCoordinate2D(latitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!)
        let region = MKCoordinateRegionMake(location,MKCoordinateSpanMake(0.01, 0.01))
        myMapaRutaTF.setRegion(region, animated: true)
        
    }
    
    // AÑADIR POLYLINE
    func addPolyLine(locations: [CLLocation?]){
        var localizacion : [CLLocation] = []
        
        // Cargamos las localizaciones.
        for i in 1...locations.count{
            localizacion.append(locations[i - 1]!)
        }
        
        // Pintamos la Polyline
        for i in 1...localizacion.count{
            let inicio = localizacion.count - i
            let destino = localizacion.count - (i + 1)
            if destino >= 0{ // Si el destino es igual o mayor que cero.
                // Añadimos las coordenadas
                let c1 = localizacion[inicio].coordinate
                let c2 = localizacion[destino].coordinate
                var coordenadas = [c1, c2]
                
                // Añadimos la Polyline al mapa.
                let polyline = MKPolyline(coordinates: &coordenadas, count: coordenadas.count)
                self.myMapaRutaTF.add(polyline)
            }
        }
    }
    
    // COMPRUEBA EL NOMBRE DE LA RUTA
    func compruebaNombreRuta(){
        let usuarioRuta = PFUser.current()?.username
        // Realizamos la consulta
        let nombreRuta = PFQuery(className: "Tracker")
        nombreRuta.whereKey("nombreRuta", equalTo: myNombreRutaTF.text!)
        
        // Buscamos los objetos.
        nombreRuta.findObjectsInBackground { (objetoRuta, errorRuta) in
            if errorRuta == nil{
                if let objetoRutaDes = objetoRuta{
                    if objetoRutaDes.count != 0{
                        for objetoRutaDataDes  in objetoRutaDes{
                            // Si la ruta ya existe lanzamos un error.
                            if self.myNombreRutaTF.text! == objetoRutaDataDes["nombreRuta"] as? String && usuarioRuta == objetoRutaDataDes["usuarioRuta"] as? String{
                                self.present(showAlertVC("ATENCIÓN", messageData: "Ya existe una ruta con ese nombre."), animated: true, completion: nil)
                            }else{ // Sino la guardamos.
                                self.guardarRuta()
                            }
                        }
                    }else{ // Sino la guadamos.
                        self.guardarRuta()
                    }
                }
            }
        }
    }
    
    // GUARDAR RUTA
    func guardarRuta(){
        // Damos de alta la nueva ruta.
        let userData = PFObject(className: "Tracker")
        
        userData["usuarioRuta"] = PFUser.current()?.username
        userData["nombreRuta"] = myNombreRutaTF.text
        userData["direccionInicial"] = direccionInicial
        userData["latitudRuta"] = latitudRuta
        userData["longitudRuta"] = longitudRuta
        userData["fechaRuta"] = fecha
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        // Salvamos los datos y si todo es correcto.
        userData.saveInBackground { (actualizacionExitosa, errorActualizacion) in
            // Ocultamos la carga y lanzamos cualquier evento.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            if actualizacionExitosa{ // Si todo es correcto lanzamos un mensaje.
                guardado = true
                let alertVC = UIAlertController(title: "INFORMACIÓN", message: "Datos salvados exitosamente", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (cerrar) in
                    self.performSegue(withIdentifier: "volverRuta", sender: self.view)
                })
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
            }else{// Sino pintamos el error.
                print("Error")
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    
}


//MARK: - EXTENSION PARA PINTAR LA RUTA
extension SK_InformacionRuta_ViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    }
}


