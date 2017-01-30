//
//  SK_Clientes_TableViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 28/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Clientes_TableViewController: UITableViewController {

    
    //MARK: - VARIABLES LOCALES GLOBALES
    var informacionClientes : [SK_ModeloClientes] = []
    var esPrimero = 0
    var longitudCliente = [Double]()
    var latitudCliente = [Double]()
    var telefonoCliente = [String]()
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Recogemos los datos de los clientes del usuario.
        obtenerDatosClientes()
    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - CARGA LOS CLIENTES AL RECUPERAR EL VIEW
    override func viewDidAppear(_ animated: Bool) {
        haPasado = true
        if esPrimero > 0 {
            self.obtenerDatosClientes()
            tableView.reloadData()
        }
        esPrimero = esPrimero + 1
    }

    //MARK: -------------------------- ACCIONES --------------------------
    
    // UNWIND
    @IBAction func unWindTabla(storyboard : UIStoryboardSegue){}
    
    // FILTAR CLIENTES PENDIENTES
    @IBAction func filtrarClientesACTION(_ sender: Any) {
        print("ok")
    }
    
    //MARK: -------------------------- UTILIDADES --------------------------
    
    // REFRESCAR TABLA
    func refreshVC(){
        self.obtenerDatosClientes()
        tableView.reloadData()
    }
    
    // OBTENER LOS DATOS DE LOS CLIENTES
    func obtenerDatosClientes(){
        var telefono = ""
        var calle = ""
        
        // Limpiamos los array.
        informacionClientes.removeAll()
        latitudCliente.removeAll()
        longitudCliente.removeAll()
        telefonoCliente.removeAll()
        
        // Realizamos la consulta.
        let clientes = PFQuery(className: "Client")
        clientes.whereKey("usuarioCliente", equalTo: (PFUser.current()?.username)!)
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Realizamos la busqueda de los objetos.
        clientes.findObjectsInBackground { (objetoCliente, errorCliente) in
            
            // Si el objeto esta vacio lanzamos el error.
            if let objetoClienteData = objetoCliente{
                if objetoClienteData == []{
                    // Ocultamos la carga y lanzamos los eventos.
                    muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    self.present(showAlertVC("ATENCIÓN", messageData: "No existe ningún cliente."), animated: true, completion: nil)
                }else{// Sino lo buscamos y obtenemos la imagen.
                    for objetoClienteDes in objetoCliente!{
                        telefono = objetoClienteDes["telefonoCliente"] as! String
                        calle = objetoClienteDes["calleCliente"] as! String
                        self.latitudCliente.append(objetoClienteDes["latitudCliente"] as! Double)
                        self.longitudCliente.append(objetoClienteDes["longitudCliente"] as! Double)
                        self.telefonoCliente.append(telefono)
                        self.obtenerImagen(telefono: telefono, calle: calle)
                    }
                }
            }
        }
    
    }
    
    // OBTENEMOS LAS IMAGENES DE LOS CLIENTES
    func obtenerImagen(telefono : String, calle : String){
        // Realizamos la consulta.
        let imagenCliente = PFQuery(className: "imageClient")
        imagenCliente.whereKey("telefonoCliente", equalTo: telefono)
        
        // Buscamos los objetos.
        imagenCliente.findObjectsInBackground(block: { (objetoImagen, errorImagen) in
            // Ocultamos la carga y lanzamos los eventos.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if let objetoImagenDes = objetoImagen{
                for objetoImagenData in objetoImagenDes{ // Buscamos los objetos y cargamos el modelo.
                    if objetoImagenData["usuarioCliente"] as! String == (PFUser.current()?.username)!{
                        let imagenDataModel = SK_ModeloClientes(pTelefonoClienteData: telefono,pDireccionClienteData: calle, pImagenClienteData: objetoImagenData["imagenCliente"] as! PFFile)
                        self.informacionClientes.append(imagenDataModel)
                    }
                }
                    self.tableView.reloadData()
            }
        })
    }
    
    // ELIMINAR CLIENTE
    func eliminarCliente(telefono : String) {
        var error = false
        
        // Realizamos la consulta.
        let queryRemover = PFQuery(className: "Client")
        queryRemover.whereKey("telefonoCliente", equalTo: telefono)
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Buscamos los objetos.
        queryRemover.findObjectsInBackground(block: { (objectRemove, errorRemove) in
            if errorRemove == nil{ // Si no hay error eliminamos el cliente.
                for objectRemoverDes in objectRemove!{
                    objectRemoverDes.deleteInBackground(block: nil)
                }
            }else{
                print("Error \((errorRemove! as NSError).userInfo)")
                
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
                
                error = true
            }
        })
        if error == false{ // Si no hay error
            // Realizamos la consulta.
            let queryRemoverImage = PFQuery(className: "imageClient")
            queryRemoverImage.whereKey("telefonoCliente", equalTo: telefono)
            
            // Buscamos los objetos.
            queryRemoverImage.findObjectsInBackground(block: { (objectRemove, errorRemove) in
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if errorRemove == nil{ // Si no hay error eliminamos la imagen del cliente.
                    for objectRemoverDes in objectRemove!{
                        objectRemoverDes.deleteInBackground(block: nil)
                    }
                    self.refreshVC()
                }else{ // Sino lanzamos un error
                    print("Error \((errorRemove! as NSError).userInfo)")
                    // Ocultamos la carga y lanzamos cualquier evento.
                    muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            })
        }else{ // Sino lanzamos un error.
            present(showAlertVC("ATENCION", messageData: "Error al eliminar el cliente."), animated: true, completion: nil)
            // Ocultamos la carga y lanzamos cualquier evento.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    //MARK: -------------------------- CONFIGURACION DE LA TABLA --------------------------
    
    // NÚMERO DE SECCIONES.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // NÚMERO DE CELDAS.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informacionClientes.count
    }

    // CONFIGURACIÓN DE LAS CELDAS.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Creamos la instancia de SK_Clientes_Celda_TableViewCell.
        let clientes = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SK_Clientes_Celda_TableViewCell

        // Creamos la instancia de informacionClientes.
        let dataModel = informacionClientes[indexPath.row]

        // Asignamos el valor a los componentes.
        clientes.myNumeroTelefonoClienteLBL.text = dataModel.telefonoClienteData
        clientes.myDireccionClienteLBL.text = dataModel.direccionClienteData
        dataModel.imagenClienteData?.getDataInBackground(block: { (imagenDataCliente, errorData) in
            if errorData == nil{
                let imagenDescargada = UIImage(data: imagenDataCliente!)
                clientes.myImagenClienteIV.image = imagenDescargada
            }else{
                print("hubo un error en la descarga \(indexPath.row)")
            }
        })

        return clientes
    }
    
    // PASAR VALORES DE LA CELDA SELECCIONADA.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Creamos la instacia de SK_Captacion_InfoCliente_ViewController.
        let infoCliente = self.storyboard?.instantiateViewController(withIdentifier: "informationClient") as! SK_Captacion_InfoCliente_ViewController
        
        // Creamos la instancia de informacionClientes.
        let dataModel = informacionClientes[indexPath.row]
        
        // Pasamos los datos a la SK_Captacion_InfoCliente_ViewController.
        infoCliente.telefonoCliente = dataModel.telefonoClienteData
        infoCliente.origen = "Tabla"
        
        self.navigationController?.pushViewController(infoCliente, animated: true)
    }
    
    // CREAMOS LOS BOTONES DESLIZANTES DE LA CELDA
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Creamos el boton deleteAction.
        let deleteAction = UITableViewRowAction(style: .default, title: "Eliminar"){ Void in
            
            // Creamos un ActionSheet con varias opciones.
            let deleteMenu = UIAlertController(title: nil, message: "¿Desea eliminar el cliente?", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Eliminar", style: .default, handler: { (eliminar) in
                let dataModel = self.informacionClientes[indexPath.row]
                self.eliminarCliente(telefono: dataModel.telefonoClienteData!)
            })
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            deleteMenu.addAction(deleteAction)
            deleteMenu.addAction(cancelAction)
            self.present(deleteMenu, animated: true, completion: nil)
            
        }
        
        // Creamos el boton de gpsAction.
        let gpsAction = UITableViewRowAction(style: .default, title: "GPS") { Void in
            if let url = NSURL(string: "http://maps.apple.com/?daddr=\(self.latitudCliente[indexPath.row]),\(self.longitudCliente[indexPath.row])") {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        
        // Creamos el boton de callAction.
        let callAction = UITableViewRowAction(style: .default, title: "Llamar") { Void in
            if let url = NSURL(string: "tel://\(self.telefonoCliente[indexPath.row])") {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        
        // Asignamos el color de los fondos.
        deleteAction.backgroundColor = UIColor.red
        gpsAction.backgroundColor = UIColor(red:0.53, green:0.91, blue:0.45, alpha:1.0)
        callAction.backgroundColor = UIColor.darkGray
        
        return[deleteAction,gpsAction,callAction]
    }
    



}
