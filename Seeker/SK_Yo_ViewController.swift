//
//  SK_Yo_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 5/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Yo_ViewController: UIViewController {

    //MARK: - VARIABLES LOCALES GLOBALES
    var esInicial = true
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myImagenUsuarioIV: UIImageView!
    @IBOutlet weak var myNombreEmpresaLBL: UILabel!
    @IBOutlet weak var myEmailEmpresaLBL: UILabel!
    @IBOutlet weak var myTelefonoEmpresaLBL: UILabel!
    @IBOutlet weak var myCalleEmpresaLBL: UILabel!
    @IBOutlet weak var myPostalEmpresaLBL: UILabel!
    @IBOutlet weak var myLocalidadEmpresaLBL: UILabel!
    @IBOutlet weak var myProvinciaEmpresaLBL: UILabel!
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Establecemos el formato de myImagenUsurioIV.
        configuraBordesImagenes(myImagenUsuarioIV, redondo: true, borde: false)
        
        // Cargamos los datos de la empresa.
        cargarDatos()
    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - ACTUALIZAMOS LOS DATOS CUANDO RECUPERAMOS EL VIEW
    override func viewDidAppear(_ animated: Bool) {
        if esInicial == false{
            cargarDatos()
        }
    }
    

    //MARK -------------------------- UTILIDADES --------------------------
    
    //CARGAR DATOS DEL USUARIO
    func cargarDatos(){
        // Realizamos la consulta de los datos del usuario.
        let queryUser = PFUser.query()!
        queryUser.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        // Lanzamos la carga e ignoramos los eventos.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Buscamos todos los objetos de la consulta comprobando que no hay errores.
        queryUser.findObjectsInBackground { (objectUno, errorUno) in
            if errorUno == nil{
                if let objectUnoDes = objectUno{
                    for objectDataUnoDes  in objectUnoDes{
                        // Realizamos la consulta de las imagenes del usuario.
                        let queryImage = PFQuery(className: "ImageProfile")
                        queryImage.whereKey("username", equalTo: (PFUser.current()?.username)!)
                        
                        // Buscamos los objetos del usuario comprobando si hay errores.
                        queryImage.findObjectsInBackground(block: { (objectDos, errorDos) in
                            
                            // Ocultamos la carga y lanzamos los eventos.
                            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.esInicial = false
                            
                            if errorDos == nil{
                                if let objectDosDes = objectDos{
                                    for objectDataDosDes in objectDosDes{
                                        let usernameFile = objectDataDosDes["imageFile"] as! PFFile
                                        
                                        // Cargamos el valor a la imagen.
                                        usernameFile.getDataInBackground(block: { (imageData, imageError) in
                                            if imageError == nil{
                                                if let imageDataDes = imageData{
                                                    let image = UIImage(data: imageDataDes)
                                                    self.myImagenUsuarioIV.image = image
                                                }
                                            }
                                        })
                                    }
                                }
                            }
                        })
                        // Cargamos los datos del usuario.
                        self.myNombreEmpresaLBL.text = objectDataUnoDes["nombreEmpresa"] as? String
                        self.myEmailEmpresaLBL.text = PFUser.current()?.email
                        if objectDataUnoDes["telefonoEmpresa"] != nil{
                            self.myTelefonoEmpresaLBL.text = objectDataUnoDes["telefonoEmpresa"] as? String
                        }
                        if objectDataUnoDes["calleEmpresa"] != nil{
                            self.myCalleEmpresaLBL.text = objectDataUnoDes["calleEmpresa"] as? String
                        }
                        if objectDataUnoDes["postalEmpresa"] != nil{
                            self.myPostalEmpresaLBL.text = objectDataUnoDes["postalEmpresa"] as? String
                        }
                        if objectDataUnoDes["localidadEmpresa"] != nil{
                            self.myLocalidadEmpresaLBL.text = objectDataUnoDes["localidadEmpresa"] as? String
                        }
                        if objectDataUnoDes["provinciaEmpresa"] != nil{
                            self.myProvinciaEmpresaLBL.text = objectDataUnoDes["provinciaEmpresa"] as? String
                        }
                    }
                }
            }
        }
    }
}
