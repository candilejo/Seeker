//
//  SK_Captacion_InfoCliente_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 12/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Captacion_InfoCliente_ViewController: UIViewController {

    //MARK: - VARIABLES LOCALES GLOBALES
    var nombreCliente : String?
    var telefonoCliente : String?
    var estadoCliente : String?
    var observacionesCliente : String?
    var latitudCliente : Double?
    var longitudCliente : Double?
    var origen : String?
    var imagen : String?
    var imagenCambiada = false
    var fotoSeleccionada = false
    var imageGroupTag = 1
    var activo = false
    var textField : UITextField!
    
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myImagenClienteIV: UIImageView!
    @IBOutlet weak var myImagenCamaraIV: UIImageView!
    @IBOutlet weak var myNombreClienteTF: UITextField!
    @IBOutlet weak var myTelefonoClienteTF: UITextField!
    @IBOutlet weak var myCalleClienteTF: UITextField!
    @IBOutlet weak var myEstadoClienteLBL: UILabel!
    @IBOutlet weak var myEstadoClienteSW: UISwitch!
    @IBOutlet weak var myBotonActualizarBTN: UIButton!
    @IBOutlet weak var myBotonGPSBTN: UIButton!
    @IBOutlet weak var myComentarioTF: UITextField!
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Configuramos los bordes y bloqueamos myBotonActualizarBTN.
        configuraSombraAspectoBotones(boton: myBotonActualizarBTN, redondo: false)
        cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
        
        // Configuramos los bordes de myBotonGPSBTN.
        configuraSombraAspectoBotones(boton: myBotonGPSBTN, redondo: false)
        
        // Configuración de los bordes de myImagenClienteIV y myImagenCamaraIV.
        configuraBordesImagenes(myImagenClienteIV, redondo: true, borde: false)
        configuraBordesImagenes(myImagenCamaraIV, redondo: true, borde: false)
        
        // Hacemos interactiva myImagenCamaraIV.
        myImagenCamaraIV.isUserInteractionEnabled = true
        
        // Añadimos el gesto a la myImagenInteractivaIV para que se habra la camara de fotos.
        let imageGestureReconize = UITapGestureRecognizer(target: self, action: #selector(SK_Captacion_InfoCliente_ViewController.showCamaraFotos))
        myImagenCamaraIV.addGestureRecognizer(imageGestureReconize)
        
        // Configuramos el textfield del teclado.
        configurarTextField()
        
        // Añadimos el boton al teclado.
        addBotonOkAlTeclado()
        addtextfieldAlTeclado()
        
        // Cargamos los datos del Cliente.
        myTelefonoClienteTF.text = telefonoCliente!
        cargarDatosCliente()
        
    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - CERRAR TECLADO
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    
    //MARK -------------------------- ACCIONES --------------------------

    // ELIMINAR CLIENTE
    @IBAction func eliminarClienteACTION(_ sender: Any) {
        // Creamos un ActionSheet con varias opciones.
        let alertVC = UIAlertController(title: "ELIMINAR", message: "¿Desea Eliminar el cliente?", preferredStyle: .actionSheet)
        let eliminarAction = UIAlertAction(title: "Eliminar", style: .default) { (Eliminar) in
            self.eliminarCliente()
        }
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertVC.addAction(eliminarAction)
        alertVC.addAction(cancelarAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    // LLAMAR AL CLIENTE
    @IBAction func llamarClienteACTION(_ sender: Any) {
        if let url = NSURL(string: "tel://\(myTelefonoClienteTF.text!)") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    // CARGAR GPS
    @IBAction func cargaGPSACTION(_ sender: Any) {
        if let url = NSURL(string: "http://maps.apple.com/?daddr=\(latitudCliente!),\(longitudCliente!)") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    // ACTUALIZA ESTADO
    @IBAction func cambiaEstadoSwitchACTION(_ sender: Any) {
        if myEstadoClienteSW.isOn{
            myEstadoClienteLBL.text = "Pendiente"
            compruebaSwitch(estado: myEstadoClienteLBL.text!)
        }else if myEstadoClienteSW.isOn == false{
            myEstadoClienteLBL.text = "Contactado"
            compruebaSwitch(estado: myEstadoClienteLBL.text!)
        }
    }
    
    // ACTUALIZA LOS CAMPOS
    @IBAction func actualizarClienteACTION(_ sender: Any) {
        existeCliente()
        haPasado = true
    }
    
    // COMPRUEBA SI LOS CAMPOS SON IGUALES.
    @IBAction func compruebaCamposACTION(_ sender: Any) {
        if compruebaCampos(){
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: true)
        }else{
            print ("llega")
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
        }
        textField.text = myComentarioTF.text

    }
    
    // CERRAR TECLADO AL PULSAR EN ACEPTAR.
    @IBAction func cerrarTecladoACTION(_ sender: Any) {}

    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // COMPRUEBA ESTADO DE LOS CAMPOS
    func compruebaCampos() -> Bool{
        if myNombreClienteTF.text != nombreCliente || myTelefonoClienteTF.text != telefonoCliente || myEstadoClienteLBL.text != estadoCliente || imagenCambiada == true || myComentarioTF.text != observacionesCliente{
            return true
        }else{
            return false
        }
    }
    // CONFIGURAR TEXTFIELD DEL TECLADO.
    func configurarTextField(){
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.delegate = self
        textField.textColor = UIColor.white
        textField.layer.masksToBounds = true
        textField.autocapitalizationType = .none
        textField.keyboardAppearance = .dark
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        let border = CALayer()
        let width : CGFloat = 2.0
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height-width, width: textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = width
        
        textField.layer.addSublayer(border)
    }
    
    // CARGAR DATOS DEL CLIENTE
    func cargarDatosCliente(){
        // Realizamos la consulta de los datos del cliente.
        let queryClient = PFQuery(className: "Client")
        queryClient.whereKey("telefonoCliente", equalTo: self.telefonoCliente!)
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Buscamos todos los objetos de la consulta comprobando que no hay errores.
        queryClient.findObjectsInBackground { (objectUno, errorUno) in
            if errorUno == nil{
                if let objectUnoDes = objectUno{
                    for objectDataUnoDes  in objectUnoDes{
                        
                        // Realizamos la consulta de las imagenes del cliente.
                        let queryImage = PFQuery(className: "imageClient")
                        queryImage.whereKey("telefonoCliente", equalTo: self.telefonoCliente!)
                        
                        // Buscamos los objetos del cliente comprobando si hay errores.
                        queryImage.findObjectsInBackground(block: { (objectDos, errorDos) in
                            
                            // Ocultamos la carga y lanzamos cualquier evento.
                            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            if errorDos == nil{
                                if let objectDosDes = objectDos{
                                    for objectDataDosDes in objectDosDes{
                                        if objectDataDosDes["usuarioCliente"] as! String == (PFUser.current()?.username)!{
                                            let usernameFile = objectDataDosDes["imagenCliente"] as! PFFile
                                            // Cargamos el valor a la imagen.
                                            usernameFile.getDataInBackground(block: { (imageData, imageError) in
                                                if imageError == nil{
                                                    if let imageDataDes = imageData{
                                                        self.myImagenClienteIV.image = UIImage(data: imageDataDes)
                                                        self.imagen = String(describing: self.myImagenClienteIV.image)
                                                    }
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                        })
                        // Cargamos los datos del cliente.
                        if objectDataUnoDes["usuarioCliente"] as! String == (PFUser.current()?.username)!{
                            if objectDataUnoDes["nombreCliente"] != nil{
                                self.myNombreClienteTF.text = objectDataUnoDes["nombreCliente"] as? String
                                self.nombreCliente = self.myNombreClienteTF.text
                            }
                            if objectDataUnoDes["telefonoCliente"] != nil{
                                self.myTelefonoClienteTF.text = objectDataUnoDes["telefonoCliente"] as? String
                                self.telefonoCliente = self.myTelefonoClienteTF.text
                            }
                            if objectDataUnoDes["calleCliente"] != nil{
                                self.myCalleClienteTF.text = objectDataUnoDes["calleCliente"] as? String
                            }
                            if objectDataUnoDes["estadoCliente"] != nil{
                                self.myEstadoClienteLBL.text = objectDataUnoDes["estadoCliente"] as? String
                                self.estadoCliente = self.myEstadoClienteLBL.text
                                self.compruebaSwitch(estado: self.estadoCliente!)
                            }else{
                                self.myEstadoClienteLBL.text = "Pendiente"
                                self.estadoCliente = self.myEstadoClienteLBL.text
                                self.compruebaSwitch(estado: self.estadoCliente!)
                            }
                            if objectDataUnoDes["observacionesCliente"] != nil{
                                self.myComentarioTF.text = objectDataUnoDes["observacionesCliente"] as? String
                                self.observacionesCliente = self.myComentarioTF.text
                                self.textField.text = self.observacionesCliente
                            }
                            self.latitudCliente = objectDataUnoDes["latitudCliente"] as? Double
                            self.longitudCliente = objectDataUnoDes["longitudCliente"] as? Double
                        }
                    }
                }
            }else{
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    // COMPRUEBA SI EL CLIENTE EXISTE.
    func existeCliente(){
        // Realizamos la consulta de los datos del cliente.
        let usuario = String(describing: (PFUser.current()?.username)!)
        let queryUser = PFQuery(className: "Client")
        queryUser.whereKey("telefonoCliente", equalTo: myTelefonoClienteTF.text!)
        
        // Buscamos todos los objetos de la consulta comprobando que no existe el cliente.
        queryUser.findObjectsInBackground { (objectUno, errorUno) in
            if errorUno == nil{
                if let objectUnoDes = objectUno{
                    if objectUnoDes.count != 0{
                        for objectDataUnoDes  in objectUnoDes{
                            if self.telefonoCliente != self.myTelefonoClienteTF.text{
                                // Si el cliente existe lanzamos un error sino lo guardamos.
                                if self.myTelefonoClienteTF.text! == objectDataUnoDes["telefonoCliente"] as? String && usuario == objectDataUnoDes["usuarioCliente"] as? String{
                                    self.present(showAlertVC("ATENCIÓN", messageData: "El número ya esta dado de alta en la base de datos"), animated: true, completion: nil)
                                }else{
                                    self.actualizarDatos()
                                }
                            }else{
                                if usuario == objectDataUnoDes["usuarioCliente"] as? String{
                                    self.actualizarDatos()
                                }
                            }
                        }
                    }else{
                        self.actualizarDatos()
                    }
                }
            }
        }
    }
    
    //ACTUALIZAR DATOS DEL CLIENTE
    func actualizarDatos(){
        let usuario = String(describing: (PFUser.current()?.username)!)
        var correcto = true
        
        // Si myTelefonoClienteTF es correcto actualizamos si no lanzamos un error.
        if myTelefonoClienteTF.text == ""{
            present(showAlertVC("ATENCIÓN", messageData: "El Teléfono del cliente no puede estar vacío."), animated: true, completion: nil)
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
        }else if (myTelefonoClienteTF.text?.characters.count)! < 9{
            present(showAlertVC("ATENCIÓN", messageData: "El número de Teléfono no es correcto."), animated: true, completion: nil)
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
        }else{
            // Realizamos la consulta.
            let queryRemover = PFQuery(className: "Client")
            queryRemover.whereKey("telefonoCliente", equalTo: telefonoCliente!)
        
            // Mostramos la carga e ignoramos cualquier evento.
            muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
            UIApplication.shared.beginIgnoringInteractionEvents()
        
            // Buscamos los objetos.
            queryRemover.findObjectsInBackground(block: { (objectRemove, errorRemove) in
                if errorRemove == nil{ // Si no hay errores eliminamos el cliente.
                    for objectRemoverDes in objectRemove!{
                        if objectRemoverDes["usuarioCliente"] as! String == usuario{
                            objectRemoverDes.deleteInBackground(block: nil)
                        }
                    }
                }else{ // Si no lanzamos un error.
                    print("Error \((errorRemove! as NSError).userInfo)")
                
                    // Ocultamos la carga y lanzamos cualquier evento.
                    muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                    UIApplication.shared.endIgnoringInteractionEvents()
                
                    correcto = false
                }
            })
            if correcto{ // Si erta correcto
                // Cargamos los datos del cliente.
                let clientData = PFObject(className: "Client")
            
                clientData["usuarioCliente"] = PFUser.current()?.username
                clientData["nombreCliente"] = myNombreClienteTF.text
                clientData["telefonoCliente"] = myTelefonoClienteTF.text
                clientData["calleCliente"] = myCalleClienteTF.text
                clientData["estadoCliente"] = myEstadoClienteLBL.text
                clientData["observacionesCliente"] = myComentarioTF.text
                clientData["latitudCliente"] = latitudCliente
                clientData["longitudCliente"] = longitudCliente
            
                // Salvamos los datos y si todo es correcto también salvamos la imagen.
                clientData.saveInBackground { (actualizacionExitosa, errorActualizacion) in
                    if actualizacionExitosa{ // Si la actualización es correcta actualizamos la foto.
                        self.upatePhoto()
                    }else{
                        // Ocultamos la carga y lanzamos cualquier evento.
                        muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                }
            }
        }
    }
    
    // ELIMINAR CLIENTE
    func eliminarCliente(){
        let usuario = String(describing: (PFUser.current()?.username)!)
        var error = false
        
        // Realizamos la consulta.
        let queryRemover = PFQuery(className: "Client")
        queryRemover.whereKey("telefonoCliente", equalTo: self.telefonoCliente!)
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Buscamos los objetos.
        queryRemover.findObjectsInBackground(block: { (objectRemove, errorRemove) in
            if errorRemove == nil{ // Si no hay error eliminamos el cliente.
                for objectRemoverDes in objectRemove!{
                    if objectRemoverDes["usuarioCliente"] as! String == usuario{
                        objectRemoverDes.deleteInBackground(block: nil)
                    }
                }
            }else{ // Si no lanzamos un error.
                print("Error \((errorRemove! as NSError).userInfo)")
                
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
                
                error = true
            }
        })
        if error == false{ // Si no hay error.
            // Realizamos la consulta
            let queryRemoverImage = PFQuery(className: "imageClient")
            queryRemoverImage.whereKey("telefonoCliente", equalTo: self.telefonoCliente!)
            
            // Buscamos los objetos.
            queryRemoverImage.findObjectsInBackground(block: { (objectRemove, errorRemove) in
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if errorRemove == nil{ // Si no hay error eliminamos la foto
                    for objectRemoverDes in objectRemove!{
                        if objectRemoverDes["usuarioCliente"] as! String == usuario{
                            objectRemoverDes.deleteInBackground(block: nil)
                        }
                    }
                    haPasado = true
                    // Lanzamos un mensaje de eliminación y limpiamos los campos.
                    let alertVC = UIAlertController(title: "INFORMACIÓN", message: "Cliente eliminado correctamente", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (cerrar) in
                        if self.origen == "Tabla"{
                            self.performSegue(withIdentifier: "tabla", sender: self.view)
                        }else{
                            self.performSegue(withIdentifier: "unWind", sender: self.view)
                        }
                    })
                    alertVC.addAction(okAction)
                    limpiaCampos([self.myNombreClienteTF, self.myTelefonoClienteTF, self.myCalleClienteTF])
                    self.myImagenClienteIV.image = UIImage(named: "clienteGrande")
                    self.present(alertVC, animated: true, completion: nil)
                }else{ // Si no pintamos el error.
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
    
    //ACTUALIZAR FOTO DEL PERFIL
    func upatePhoto(){
        let usuario = String(describing: (PFUser.current()?.username)!)
        
        // Realizamos la consulta.
        let queryRemover = PFQuery(className: "imageClient")
        queryRemover.whereKey("telefonoCliente", equalTo: telefonoCliente!)
        
        // Buscamos los objetos.
        queryRemover.findObjectsInBackground(block: { (objectRemove, errorRemove) in
            if errorRemove == nil{ // Si no existe ningún error eliminamos la foto.
                for objectRemoverDes in objectRemove!{
                    if objectRemoverDes["usuarioCliente"] as! String == usuario{
                        objectRemoverDes.deleteInBackground(block: nil)
                    }
                }
            }else{ // Sino lanzamos un error.
                print("Error \((errorRemove! as NSError).userInfo)")
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        })
        
        // Cargamos de nuevo la imagen.
        telefonoCliente = myTelefonoClienteTF.text
        // REalizamos la consulta y cargamos el formato de la foto.
        let postImagen = PFObject(className: "imageClient")
        let imagenData = UIImageJPEGRepresentation(myImagenClienteIV.image!, 0.2)
        let imageFile = PFFile(name: "imagePerfilCliente" + myTelefonoClienteTF.text! + ".jpg", data: imagenData!)
        
        postImagen["usuarioCliente"] = usuario
        postImagen["imagenCliente"] = imageFile
        postImagen["telefonoCliente"] = myTelefonoClienteTF.text
        
        // Guardamos los datos.
        postImagen.saveInBackground { (salvadoExitoso, errorDeSubida) in
            
            // Ocultamos la carga y lanzamos cualquier evento.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if salvadoExitoso{ // Si el salvado es correcto lanzamos un mensaje.
                self.present(showAlertVC("INFORMACIÓN", messageData: "Datos actualizados exitosamente."), animated: true, completion: nil)
            }else{ // Sino lanzamos un error.
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if let errorString = (errorDeSubida! as NSError).userInfo["error"] as? NSString{
                    self.present(showAlertVC("ATENCION", messageData: errorString as String), animated: true, completion: nil)
                }
            }
        }
        
        // Bloqueamos myBotonActualizarBTN.
        cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
    }

    // AÑADIMOS LOS BOTONES AL TECLADO
    func addBotonOkAlTeclado(){
        // Creamos la barra de herramientas y le damos un formato.
        let aceptarToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        aceptarToolbar.barStyle = UIBarStyle.blackTranslucent
        
        // Creamos los botones que añadiremos a la barra de herramientas.
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.done, target: self, action: #selector(SK_Captacion_AddClient_ViewController.doneButtonAction))
        
        // Establecemos el color del texto.
        done.tintColor = UIColor(red:0.53, green:0.91, blue:0.45, alpha:1.0)
        
        // Añadimos los botones a la barra de herramientas.
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        aceptarToolbar.items = items
        aceptarToolbar.sizeToFit()
        
        // Añadimos el accesorio a myTelefonoClienteTF.
        myTelefonoClienteTF.inputAccessoryView = aceptarToolbar
    }
    
    
    // ESTABLECEMOS COMO RESPONDEDOR A myTelefonoClienteTF.
    func doneButtonAction(){
        myTelefonoClienteTF.resignFirstResponder()
    }
    
    // AÑADIMOS TEXTFIELD AL TECLADO
    func addtextfieldAlTeclado(){
        // Creamos la barra de herramientas y le damos un formato.
        let textFieldToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        textFieldToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        // Creamos los botones que añadiremos a la barra de herramientas.
        let textFieldButton = UIBarButtonItem(customView: textField)
        
        // Añadimos los botones a la barra de herramientas.
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(textFieldButton)
        
        textFieldToolbar.items = items
        textFieldToolbar.sizeToFit()
        
        // Añadimos el accesorio a myComentarioTF.
        myComentarioTF.inputAccessoryView = textFieldToolbar
    }
    
    // SELECCIONAR FOTO DEL LOGO
    func showCamaraFotos(){
        pickerPhoto()
    }
    
    //CERRAR IMAGEN AMPLIADA
    func hideImageGroup(gesto : UIGestureRecognizer){
        for subvista in self.view.subviews{
            if subvista.tag == self.imageGroupTag{
                subvista.removeFromSuperview()
            }
        }
    }
    
    // COMPRUEBA SWITCH
    func compruebaSwitch(estado : String){
        if estado == "Pendiente"{
            self.myEstadoClienteSW.isOn = false
        }else if estado == "Contactado"{
            self.myEstadoClienteSW.isOn = true
        }
    }

}

//MARK: - DELEGATE UIIMAGEPICKER / PHOTO
extension SK_Captacion_InfoCliente_ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // SELECCIONAMOS LA CAMARA O LA LIBRERIA
    func pickerPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            //showPhotoMenu()
            self.activo = true
        }else{
            //choosePhotoFromLibrary()
            self.activo = false
        }
        showPhotoMenu()
    }
    
    
    // MENU DE SELECCION DE LA CAMARA O DE LA LIBRERIA
    func showPhotoMenu(){
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let chooseFromLibraryAction = UIAlertAction(title: "Escoge de la Librería", style: .default) { Void  in
            self.choosePhotoFromLibrary()
        }
        let ampliarImagenAction = UIAlertAction(title: "Ampliar Imagen", style: .default){ Void in
            self.ampliarImagen()
        }
        
        alertVC.addAction(cancelAction)
        if self.activo == true{
            let takePhotoAction = UIAlertAction(title: "Tomar Foto", style: .default) { Void  in
                self.takePhotowithCamera()
            }
            alertVC.addAction(takePhotoAction)
        }
        alertVC.addAction(chooseFromLibraryAction)
        alertVC.addAction(ampliarImagenAction)
        present(alertVC, animated: true, completion: nil)
        
    }
    
    
    // LANZAMOS LA CAMARA PARA TOMAR UNA FOTO
    func takePhotowithCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    // LANZAMOS LA LIBRERIA PARA MOSTRAR UNA FOTO
    func choosePhotoFromLibrary(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // AMPLIAR IMAGEN
    func ampliarImagen(){
        //Creamos un fondo negro con transparencia.
        let background = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        background.backgroundColor = UIColor.black
        background.alpha = 0.8
        background.tag = self.imageGroupTag
        self.view.addSubview(background)
        let imageViewClient = UIImageView(frame: CGRect(x: 10, y: 70, width: self.view.frame.width / 1.07, height: self.view.frame.height / 1.4))
        imageViewClient.contentMode = .scaleAspectFit
        imageViewClient.tag = imageGroupTag
        imageViewClient.image = self.myImagenClienteIV.image
        
        self.view.addSubview(imageViewClient)
        
        let tapGestureReconize = UITapGestureRecognizer(target: self, action: #selector(SK_Captacion_InfoCliente_ViewController.hideImageGroup(gesto:)))
            
        view.addGestureRecognizer(tapGestureReconize)
    }
    
    
    // CERRAMOS LA CAMARA CUANDO SELECCIONEMOS LA IMAGEN
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        myImagenClienteIV.image = image
        if imagen == String(describing: myImagenClienteIV.image){
            imagenCambiada = false
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
        }else{
            imagenCambiada = true
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: true)
        }
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - DELEGATE DEL TEXTFIELD
extension SK_Captacion_InfoCliente_ViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        myComentarioTF.text = textField.text
        textField.resignFirstResponder()
        return true
    }

}



