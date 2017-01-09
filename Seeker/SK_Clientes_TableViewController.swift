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
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Recogemos los datos de los clientes del usuario.
        obtenerDatosClientes()
        
        refreshTableView.attributedTitle = NSAttributedString(string: "Arrastra para recargar.")
        refreshTableView.addTarget(self, action: #selector(SK_Clientes_TableViewController.refreshVC), for: .valueChanged)
        tableView.addSubview(refreshTableView)
    }

    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK: -------------------------- UTILIDADES --------------------------
    //REFRESH CONTROLLER
    func refreshVC(){
        //llamadaUsuariosFromParse()
        tableView.reloadData()
        refreshTableView.endRefreshing()
    }
    
    //OBTENER LOS DATOS DE LOS CLIENTES
    func obtenerDatosClientes(){
        let clientes = PFQuery(className: "Client")
        clientes.whereKey("usuarioCliente", equalTo: (PFUser.current()?.username)!)
        
        // Lanzamos la carga e ignoramos los eventos.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        clientes.findObjectsInBackground { (objetoUno, errorUno) in
            if errorUno == nil{
                if let objetoUnoDes = objetoUno{
                    var telefonoCliente = ""
                    var direccionCliente = ""
                    for objetoDataUno in objetoUnoDes{
                        telefonoCliente = objetoDataUno["telefonoCliente"] as! String
                        direccionCliente = objetoDataUno["calleCliente"] as! String
                        
                        let imagenCliente = PFQuery(className: "imageClient")
                        imagenCliente.whereKey("telefonoCliente", equalTo: telefonoCliente)
                        imagenCliente.findObjectsInBackground(block: { (objetoDos, errorDos) in
                            
                            // Ocultmos la carga y lanzamos los eventos.
                            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            if errorDos == nil{
                                if let objetoDosDes = objetoDos{
                                    for objetDosData in objetoDosDes{
                                        let imagenDataModel = SK_ModeloClientes(pTelefonoClienteData: telefonoCliente,pDireccionClienteData: direccionCliente, pImagenClienteData: objetDosData["imagenCliente"] as! PFFile)
                                        self.informacionClientes.append(imagenDataModel)
                                    }
                                    self.tableView.reloadData()
                                }
                            }
                        })
                    }
                }
            }else{
                // Ocultmos la carga y lanzamos los eventos.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    
    //MARK: -------------------------- CONFIGURACION DE LA TABLA --------------------------
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informacionClientes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let clientes = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SK_Clientes_Celda_TableViewCell

        let dataModel = informacionClientes[indexPath.row]

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Creamos la instacia de SK_Captacion_InfoCliente_ViewController.
        let infoCliente = self.storyboard?.instantiateViewController(withIdentifier: "informationClient") as! SK_Captacion_InfoCliente_ViewController
        
        let dataModel = informacionClientes[indexPath.row]
        
        // Pasamos los datos a la SK_Captacion_InfoCliente_ViewController.
        infoCliente.telefonoCliente = dataModel.telefonoClienteData
        
        self.navigationController?.pushViewController(infoCliente, animated: true)
    }

}
