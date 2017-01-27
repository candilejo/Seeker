//
//  SK_Rutas_Mapa_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 20/1/17.
//  Copyright © 2017 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import UIKit
import Parse
import MapKit

class SK_Rutas_Mapa_ViewController: UIViewController {

    //MARK: - VARIABLES LOCALES GLOBALES
    var titulo: String?
    var fechaRuta : String?
    var direccionInicial: String?
    var latitudRuta : Array <Double>?
    var longitudRuta : Array <Double>?
    var locations : [CLLocation] = []
    
    //MARK: - IBOUTLET
    @IBOutlet weak var myMapaRutaMV: MKMapView!
    @IBOutlet weak var myFechaRutaLBL: UILabel!
    @IBOutlet weak var myDireccionInicialLBL: UILabel!
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = titulo! // Establecemos el titulo del View.
        myFechaRutaLBL.text = fechaRuta! // Establecemos el valor de myFechaRutaLBL.
        myDireccionInicialLBL.text = direccionInicial! // Establecemos el valor de myDireccionInicialLBL.
        
        myMapaRutaMV.delegate = self // Hacemos que myMapaRutaMV sea su propio delegado.
        
        createPolyLine() // Creamos la PolyLine.

        
    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // ELIMINAR RUTA
    @IBAction func eliminarRutaACTION(_ sender: Any) {
        // Creamos un ActionSheet con diferentes Acciones
        let deleteMenu = UIAlertController(title: nil, message: "¿Desea eliminar la ruta?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Eliminar", style: .default, handler: { (eliminar) in
            self.eliminarRuta(usuario: (PFUser.current()?.username)!, nombreRuta: self.titulo!)
            self.performSegue(withIdentifier: "volverRutas", sender: self.view)
        })
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        deleteMenu.addAction(deleteAction)
        deleteMenu.addAction(cancelAction)
        
        self.present(deleteMenu, animated: true, completion: nil)
    }
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // CREAMOS LA RUTA
    func createPolyLine(){
        let anotationInicial = MKPointAnnotation()
        
        // Cargamos las localizaciones en locations
        for i in 1...longitudRuta!.count{
            let longitud = Double(longitudRuta![i - 1])
            let latitud = Double(latitudRuta![i - 1])
            locations.append(CLLocation(latitude: latitud, longitude: longitud))
            
            if i == 1{ // Si la i es 1 añadimos la ubicacion inicial
                anotationInicial.coordinate = (locations.first?.coordinate)!
                anotationInicial.title = titulo!
                anotationInicial.subtitle = direccionInicial!
                myMapaRutaMV.addAnnotation(anotationInicial)
            }
        }
        
        addPolyLine(locations: locations) // Añadimos la ruta al mapa
        
        // Establecemos el zoom y localización inicial del mapa.
        let location = CLLocationCoordinate2D(latitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!)
        let region = MKCoordinateRegionMake(location,MKCoordinateSpanMake(0.01, 0.01))
        myMapaRutaMV.setRegion(region, animated: true)

    }
    
    // AÑADIMOS LA RUTA
    func addPolyLine(locations: [CLLocation?]){
        var localizacion : [CLLocation] = []
        
        // Rellenamos el array con todas las localizaciones
        for i in 1...locations.count{
            localizacion.append(locations[i - 1]!)
        }
        
        // Pintamos la ruta.
        for i in 1...localizacion.count{
            let inicio = localizacion.count - i
            let destino = localizacion.count - (i + 1)
            if destino >= 0{ // Si el destino es mayor o igual que cero.
                let c1 = localizacion[inicio].coordinate
                let c2 = localizacion[destino].coordinate
                var coordenadas = [c1, c2]
            
                let polyline = MKPolyline(coordinates: &coordenadas, count: coordenadas.count)
                self.myMapaRutaMV.add(polyline)
            }
        }
    }
    
    // ELIMINAMOS LA RUTA
    func eliminarRuta(usuario: String, nombreRuta: String){
        // Realizamos la consulta
        let queryRemover = PFQuery(className: "Tracker")
        queryRemover.whereKey("usuarioRuta", equalTo: usuario)
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        queryRemover.findObjectsInBackground(block: { (objectRemove, errorRemove) in
            // Ocultamos la carga y lanzamos cualquier evento.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if errorRemove == nil{
                for objectRemoverDes in objectRemove!{
                    if (objectRemoverDes["nombreRuta"] as! String == nombreRuta){ // Si el nombre de la ruta coincide la eliminamos.
                        objectRemoverDes.deleteInBackground(block: nil)
                        otroView = true
                    }
                }
            }else{
                print("Error \((errorRemove! as NSError).userInfo)")
                
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        })
    }

}


//MARK: - EXTENSION PARA PINTAR LA RUTA
extension SK_Rutas_Mapa_ViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    }
}
