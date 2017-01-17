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
    var refreshTableView = UIRefreshControl()
    var esPrimero = 0
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Recogemos los datos de los clientes del usuario.
        obtenerDatosClientes()
        
        // Ocultamos la barra de navegación cuando nos desplazamos.
        navigationController?.hidesBarsOnSwipe = true
        
        // Configuramos el refreshTableView.
        refreshTableView.backgroundColor = UIColor(red:0.53, green:0.91, blue:0.45, alpha:1.0)
        refreshTableView.attributedTitle = NSAttributedString(string: "Arrastra para recargar.")
        refreshTableView.tintColor = UIColor.darkGray
        refreshTableView.addTarget(self, action: #selector(SK_Clientes_TableViewController.refreshVC), for: .valueChanged)
        tableView.addSubview(refreshTableView)
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
            refreshTableView.endRefreshing()
        }
        esPrimero = esPrimero + 1
    }

    //MARK: -------------------------- ACCIONES --------------------------
    
    // UNWIND
    @IBAction func unWindTabla(storyboard : UIStoryboardSegue){}
    
    //MARK: -------------------------- UTILIDADES --------------------------
    
    //REFRESH CONTROLLER
    func refreshVC(){
        obtenerDatosClientes()
        tableView.reloadData()
        refreshTableView.endRefreshing()
    }
    
    //OBTENER LOS DATOS DE LOS CLIENTES
    func obtenerDatosClientes(){
        var telefono = ""
        var calle = ""
        
        let clientes = PFQuery(className: "Client")
        clientes.whereKey("usuarioCliente", equalTo: (PFUser.current()?.username)!)
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        clientes.findObjectsInBackground { (objetoCliente, errorCliente) in
            self.informacionClientes.removeAll()
            if let objetoClienteData = objetoCliente{
                if objetoClienteData == []{
                    // Ocultamos la carga y lanzamos los eventos.
                    muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    self.present(showAlertVC("ATENCIÓN", messageData: "No existe ningún cliente."), animated: true, completion: nil)
                }else{
                    for objetoClienteDes in objetoCliente!{
                        telefono = objetoClienteDes["telefonoCliente"] as! String
                        calle = objetoClienteDes["calleCliente"] as! String
                        self.obtenerImagen(telefono: telefono, calle: calle)
                    }
                }
            }
        }
    
    }
    
    // OBTENEMOS LAS IMAGENES DE LOS CLIENTES
    func obtenerImagen(telefono : String, calle : String){
        let imagenCliente = PFQuery(className: "imageClient")
        imagenCliente.whereKey("telefonoCliente", equalTo: telefono)
        
        imagenCliente.findObjectsInBackground(block: { (objetoImagen, errorImagen) in
            // Ocultamos la carga y lanzamos los eventos.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if errorImagen == nil{
                if let objetoImagenDes = objetoImagen{
                    for objetoImagenData in objetoImagenDes{
                        let imagenDataModel = SK_ModeloClientes(pTelefonoClienteData: telefono,pDireccionClienteData: calle, pImagenClienteData: objetoImagenData["imagenCliente"] as! PFFile)
                        self.informacionClientes.append(imagenDataModel)
                    }
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    // ELIMINAR CLIENTE
    func eliminarClienteACTION(telefono : String) {
        var error = false
        
        // Eliminamos el cliente.
        let queryRemover = PFQuery(className: "Client")
        queryRemover.whereKey("telefonoCliente", equalTo: telefono)
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        queryRemover.findObjectsInBackground(block: { (objectRemove, errorRemove) in
            if errorRemove == nil{
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
        if error == false{
            // Eliminamos la foto antigua si existe.
            let queryRemoverImage = PFQuery(className: "imageClient")
            queryRemoverImage.whereKey("telefonoCliente", equalTo: telefono)
            queryRemoverImage.findObjectsInBackground(block: { (objectRemove, errorRemove) in
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if errorRemove == nil{
                    for objectRemoverDes in objectRemove!{
                        objectRemoverDes.deleteInBackground(block: nil)
                    }
                    self.refreshVC()
                }else{
                    print("Error \((errorRemove! as NSError).userInfo)")
                    // Ocultamos la carga y lanzamos cualquier evento.
                    muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            })
        }else{
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
        
        print(indexPath.row)
        // Creamos la instancia de informacionClientes.
        let dataModel = informacionClientes[indexPath.row]
        
        // Pasamos los datos a la SK_Captacion_InfoCliente_ViewController.
        infoCliente.telefonoCliente = dataModel.telefonoClienteData
        infoCliente.origen = "Tabla"
        
        self.navigationController?.pushViewController(infoCliente, animated: true)
    }
    
    // CREAMOS LOS BOTONES DESLIZANTES DE LA CELDA
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Eliminar"){ Void in
            
            let deleteMenu = UIAlertController(title: nil, message: "¿Desea eliminar el cliente?", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Eliminar", style: .default, handler: { (eliminar) in
                let dataModel = self.informacionClientes[indexPath.row]
                self.eliminarClienteACTION(telefono: dataModel.telefonoClienteData!)
            })
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            deleteMenu.addAction(deleteAction)
            deleteMenu.addAction(cancelAction)
            self.present(deleteMenu, animated: true, completion: nil)
            
        }
        deleteAction.backgroundColor = UIColor.red
        
        return[deleteAction]
    }
    



}
