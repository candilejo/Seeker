//
//  SK_Rutas_TableViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 19/1/17.
//  Copyright © 2017 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import UIKit
import Parse

//MARK: - VARIABLES GLOBALES
var otroView : Bool?

class SK_Rutas_TableViewController: UITableViewController {

    //MARK: - VARIABLES LOCALES GLOBALES
    var informacionRutas : [SK_ModeloRutas] = []
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Recogemos los datos de las rutas del usuario.
        obtenerRutasUsuario()

    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - SE EJECUTA AL RECUPERAR EL CONTROL
    override func viewDidAppear(_ animated: Bool) {
        if otroView == true{
            refreshVC()
            otroView = false
        }
    }

    
    //MARK: -------------------------- ACCIONES --------------------------
    
    //UNWIND
    @IBAction func unWindRutas(storyBoard : UIStoryboardSegue){}
    
    //MARK: -------------------------- UTILIDADES --------------------------
    
    // REFRESCAR TABLA
    func refreshVC(){
        self.obtenerRutasUsuario()
        tableView.reloadData()
    }
    
    // OBTENER LAS RUTAS DEL USUARIO.
    func obtenerRutasUsuario(){
        informacionRutas.removeAll() // Limpiamos el Array
        
        // Realizamos la consulta.
        let clientes = PFQuery(className: "Tracker")
        clientes.whereKey("usuarioRuta", equalTo: (PFUser.current()?.username)!)
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Realizamos la busqueda de los objetos.
        clientes.findObjectsInBackground { (objetoCliente, errorCliente) in
            
            if let objetoClienteData = objetoCliente{ // Si el objeto esta vacio lanzamos el error.
                // Ocultamos la carga y lanzamos los eventos.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if objetoClienteData == []{ // Si el array esta vacio lanzamos un error.
                    self.present(showAlertVC("ATENCIÓN", messageData: "No existe ninguna ruta."), animated: true, completion: nil)
                }else{// Sino cargamos el modelo con los datos.
                    for objetoClienteDes in objetoCliente!{
                        let modeloRutas = SK_ModeloRutas(pUsuarioRutaData: (PFUser.current()?.username)!,pFechaRutaData: objetoClienteDes["fechaRuta"] as! String, pDireccionInicialData: objetoClienteDes["direccionInicial"] as! String, pLatitudRutaData: objetoClienteDes["latitudRuta"] as! Array, pLongitudRutaData: objetoClienteDes["longitudRuta"] as! Array, pNombreRutaData: objetoClienteDes["nombreRuta"] as! String)
                        self.informacionRutas.append(modeloRutas)
                    }
                    self.tableView.reloadData() // Recargamos la tabla.
                }
            }
        }
        
    }

    // ELIMINAR RUTA.
    func eliminarRuta(usuario: String, nombreRuta: String){
        // Realizamos la consulta
        let queryRemover = PFQuery(className: "Tracker")
        queryRemover.whereKey("usuarioRuta", equalTo: usuario)
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Buscamos las rutas del usuario.
        queryRemover.findObjectsInBackground(block: { (objectRemove, errorRemove) in
            // Ocultamos la carga y lanzamos cualquier evento.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if errorRemove == nil{ // Si no hay ningún error buscamos las rutas.
                for objectRemoverDes in objectRemove!{
                    if (objectRemoverDes["nombreRuta"] as! String == nombreRuta){ // Si el nombre de la ruta coincide la eliminamos.
                        objectRemoverDes.deleteInBackground(block: nil)
                    }
                }
                self.refreshVC() // Refrescamos la tabla.
            }else{ // Sino pintamos el error.
                print("Error \((errorRemove! as NSError).userInfo)")
                
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        })
    }
    
    // MARK: - CONFIGURACION DE LA TABLA
    
    // NUMERO DE SECCIONES  DE LA TABLA.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // NUMERO DE CELDAS DE LA TABLA.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informacionRutas.count
    }

    // CARGA DE LOS VALORES DE LA CELDA.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Creamos la instancia de SK_Rutas_TableViewCell
        let rutas = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SK_Rutas_TableViewCell
        
        // Creamos la instancia de informacionRutas.
        let dataModel = informacionRutas[indexPath.row]

        // Asignmos los valores a la celda.
        rutas.myNombreRutaLBL.text  = dataModel.nombreRutaData!
        rutas.myDireccionInicialLBL.text = dataModel.direccionInicialData!

        return rutas
    }
    
    // PASAR VALORES DE LA CELDA SELECCIONADA.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Creamos la instacia de SK_Rutas_Mapa_ViewController.
        let infoRuta = self.storyboard?.instantiateViewController(withIdentifier: "informationRutas") as! SK_Rutas_Mapa_ViewController
        
        // Creamos la instancia de informacionRutas.
        let dataModel = informacionRutas[indexPath.row]
        
        // Pasamos los valores.
        infoRuta.titulo = dataModel.nombreRutaData!
        infoRuta.fechaRuta = dataModel.fechaRutaData!
        infoRuta.direccionInicial = dataModel.direccionInicialData!
        infoRuta.latitudRuta = dataModel.latitudRutaData!
        infoRuta.longitudRuta = dataModel.longitudRutaData!
        
        self.navigationController?.pushViewController(infoRuta, animated: true)
    }
    
    // CREAMOS LOS BOTONES DESLIZANTES DE LA CELDA.
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Creamos el boton deleteAction.
        let deleteAction = UITableViewRowAction(style: .default, title: "Eliminar"){ Void in
            
            let deleteMenu = UIAlertController(title: nil, message: "¿Desea eliminar la ruta?", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Eliminar", style: .default, handler: { (eliminar) in
                let dataModel = self.informacionRutas[indexPath.row]
                self.eliminarRuta(usuario: dataModel.usuarioRutaData!, nombreRuta: dataModel.nombreRutaData!)
            })
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            deleteMenu.addAction(deleteAction)
            deleteMenu.addAction(cancelAction)
            self.present(deleteMenu, animated: true, completion: nil)
            
        }
        
        
        // Asignamos el color de los fondos.
        deleteAction.backgroundColor = UIColor.red
        
        return[deleteAction]
    }

}
