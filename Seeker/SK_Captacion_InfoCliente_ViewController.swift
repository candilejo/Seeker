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
    var telefonoCliente : String?
    var nombreCliente : String?
    var observacionesCliente : String?
    var latitudCliente : Double?
    var longitudCliente : Double?
    var image : UIImage?
    var arrayEstado = ["Pendiente","Contactado"]
    
    var fotoSeleccionada = false
    var imageGroupTag = 1
    var activo = false
    
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myImagenClienteIV: UIImageView!
    @IBOutlet weak var myImagenCamaraIV: UIImageView!
    @IBOutlet weak var myNombreClienteTF: UITextField!
    @IBOutlet weak var myTelefonoClienteTF: UITextField!
    @IBOutlet weak var myCalleClienteTF: UITextField!
    @IBOutlet weak var myEstadoClienteTF: UITextField!
    @IBOutlet weak var myObservacionesTF: UITextField!
    @IBOutlet weak var myBotonActualizarBTN: UIButton!
    
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Ocultamos la barra de navegación cuando nos desplazamos.
        navigationController?.hidesBarsOnSwipe = false
        
        // Creamos el PickerView
        let myPickerView = UIPickerView()
        myPickerView.delegate = self
        myPickerView.dataSource = self
        
        myEstadoClienteTF.inputView = myPickerView
        
        // Configuramos los bordes  y bloqueamos myBotonActualizarBTN.
        configuraSombraAspectoBotones(boton: myBotonActualizarBTN, redondo: false)
        cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
        
        // Configuración de los bordes de myImagenClienteIV y myImagenCamaraIV.
        configuraBordesImagenes(myImagenClienteIV, redondo: true, borde: false)
        configuraBordesImagenes(myImagenCamaraIV, redondo: true, borde: false)
        
        // Hacemos interactiva myImagenCamaraIV.
        myImagenCamaraIV.isUserInteractionEnabled = true
        
        // Añadimos el gesto a la myImagenInteractivaIV para que se habra la camara de fotos.
        let imageGestureReconize = UITapGestureRecognizer(target: self, action: #selector(SK_Captacion_InfoCliente_ViewController.showCamaraFotos))
        myImagenCamaraIV.addGestureRecognizer(imageGestureReconize)
        
        // Creamos el gesto y se lo añadimos al View.
        let viewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SK_Captacion_InfoCliente_ViewController.hideKeyBoard))
        view.addGestureRecognizer(viewGestureRecognizer)
        
        // Añadimos el boton al teclado.
        addBotonOkAlTeclado()
        
        // Cargamos los datos del Cliente.
        myTelefonoClienteTF.text = telefonoCliente!
        cargarDatosCliente()
        
    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Función para crear el teclado.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    
    //MARK -------------------------- ACCIONES --------------------------


    // ELIMINAR CLIENTE
    @IBAction func eliminarClienteACTION(_ sender: Any) {
        var error = false
        
        // Eliminamos el cliente.
        let queryRemover = PFQuery(className: "Client")
        queryRemover.whereKey("telefonoCliente", equalTo: self.myTelefonoClienteTF.text!)
        
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
            queryRemoverImage.whereKey("telefonoCliente", equalTo: self.myTelefonoClienteTF.text!)
            queryRemoverImage.findObjectsInBackground(block: { (objectRemove, errorRemove) in
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if errorRemove == nil{
                    for objectRemoverDes in objectRemove!{
                        objectRemoverDes.deleteInBackground(block: nil)
                    }
                    haPasado = true
                    // Lanzamos un mensaje de eliminación y limpiamos los campos.
                    let alertVC = UIAlertController(title: "INFORMACIÓN", message: "Cliente eliminado correctamente", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (cerrar) in
                        self.performSegue(withIdentifier: "unWind", sender: self.view)
                    })
                    alertVC.addAction(okAction)
                    limpiaCampos([self.myNombreClienteTF, self.myTelefonoClienteTF, self.myCalleClienteTF, self.myObservacionesTF])
                    self.myImagenClienteIV.image = UIImage(named: "clienteGrande")
                        self.present(alertVC, animated: true, completion: nil)
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
    
    // LLAMAR AL CLIENTE
    @IBAction func llamarClienteACTION(_ sender: Any) {
        if let url = NSURL(string: "tel://\(myTelefonoClienteTF.text!)") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    // ACTUALIZA LOS CAMPOS
    @IBAction func actualizarClienteACTION(_ sender: Any) {
        actualizarDatos()
        haPasado = true
    }
    
    // COMPRUEBA SI LOS CAMPOS SON IGUALES.
    @IBAction func compruebaCamposACTION(_ sender: Any) {
        if myNombreClienteTF.text != nombreCliente || myObservacionesTF.text != observacionesCliente || myImagenClienteIV.image != image || myTelefonoClienteTF.text != telefonoCliente{
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: true)
        }
    }
    
    // CERRAR TECLADO AL PULSAR EN ACEPTAR.
    @IBAction func cerrarTecladoACTION(_ sender: Any) {
    }

    
    //MARK -------------------------- UTILIDADES --------------------------

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
        
        // Añadimos el accesorio a myNumeroEmpresaTF.
        myTelefonoClienteTF.inputAccessoryView = aceptarToolbar
        myEstadoClienteTF.inputAccessoryView = aceptarToolbar
    }
    
    
    // ESTABLECEMOS COMO RESPONDEDOR A myTelefonoEmpresaTF.
    func doneButtonAction(){
        myTelefonoClienteTF.resignFirstResponder()
        myEstadoClienteTF.resignFirstResponder()
    }
    
    // CIERRA TECLADO
    func hideKeyBoard(){
        view.endEditing(true)
    }
    
    // SELECCIONAR FOTO DEL LOGO
    func showCamaraFotos(){
        pickerPhoto()
    }
    
    // CARGAR DATOS DEL CLIENTE
    func cargarDatosCliente(){
        // Realizamos la consulta de los datos del cliente.
        let queryClient = PFQuery(className: "Client")
        queryClient.whereKey("telefonoCliente", equalTo: self.myTelefonoClienteTF.text!)
        
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
                        queryImage.whereKey("telefonoCliente", equalTo: self.myTelefonoClienteTF.text!)
                        
                        // Buscamos los objetos del cliente comprobando si hay errores.
                        queryImage.findObjectsInBackground(block: { (objectDos, errorDos) in
                            
                            // Ocultamos la carga y lanzamos cualquier evento.
                            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            if errorDos == nil{
                                if let objectDosDes = objectDos{
                                    for objectDataDosDes in objectDosDes{
                                        let usernameFile = objectDataDosDes["imagenCliente"] as! PFFile
                                        
                                        // Cargamos el valor a la imagen.
                                        usernameFile.getDataInBackground(block: { (imageData, imageError) in
                                            if imageError == nil{
                                                if let imageDataDes = imageData{
                                                    self.image = UIImage(data: imageDataDes)
                                                    self.myImagenClienteIV.image = UIImage(data: imageDataDes)
                                                }
                                            }
                                        })
                                    }
                                }
                            }
                        })
                        // Cargamos los datos del usuario.
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
                            self.myEstadoClienteTF.text = objectDataUnoDes["estadoCliente"] as? String
                        }else{
                            self.myEstadoClienteTF.text = self.arrayEstado[0]
                        }
                        if objectDataUnoDes["observacionesCliente"] != nil{
                            self.myObservacionesTF.text = objectDataUnoDes["observacionesCliente"] as? String
                            self.observacionesCliente = self.myObservacionesTF.text
                        }
                        self.latitudCliente = objectDataUnoDes["latitudCliente"] as? Double
                        self.longitudCliente = objectDataUnoDes["longitudCliente"] as? Double
                    }
                }
            }else{
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    //GESTO DE RECONOCIMIENTO
    func hideImageGroup(gesto : UIGestureRecognizer){
        for subvista in self.view.subviews{
            if subvista.tag == self.imageGroupTag{
                subvista.removeFromSuperview()
            }
        }
    }
    
    
    //ACTUALIZAR DATOS DEL CLIENTE
    func actualizarDatos(){
        var correcto = true
        
        // Eliminamos el cliente si existe.
        let queryRemover = PFQuery(className: "Client")
        queryRemover.whereKey("telefonoCliente", equalTo: telefonoCliente!)
        
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
                
                correcto = false
            }
        })
        if correcto{
            // Actualizamos los datos del cliente si los campos no están vacíos.
            let clientData = PFObject(className: "Client")
            
            clientData["usuarioCliente"] = PFUser.current()?.username
            
            if myNombreClienteTF.text != "" {
                clientData["nombreCliente"] = myNombreClienteTF.text
            }
            clientData["telefonoCliente"] = myTelefonoClienteTF.text
            clientData["calleCliente"] = myCalleClienteTF.text
            if myObservacionesTF.text != ""{
                clientData["observacionesCliente"] = myObservacionesTF.text
            }
            clientData["latitudCliente"] = latitudCliente
            clientData["longitudCliente"] = longitudCliente
        
            // Salvamos los datos y si todo es correcto también salvamos la imagen.
            clientData.saveInBackground { (actualizacionExitosa, errorActualizacion) in
            
                if actualizacionExitosa{
                    self.upatePhoto()
                }else{
                    // Ocultamos la carga y lanzamos cualquier evento.
                    muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
    }
    
    
    
    //ACTUALIZAR FOTO DEL PERFIL
    func upatePhoto(){
        // Eliminamos la foto antigua si existe.
        let queryRemover = PFQuery(className: "imageClient")
        queryRemover.whereKey("telefonoCliente", equalTo: telefonoCliente!)
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
            }
        })
        
        // Cargamos de nuevo la imagen.
        telefonoCliente = myTelefonoClienteTF.text
        let postImagen = PFObject(className: "imageClient")
        let imagenData = UIImageJPEGRepresentation(myImagenClienteIV.image!, 0.2)
        let imageFile = PFFile(name: "imagePerfilCliente" + myTelefonoClienteTF.text! + ".jpg", data: imagenData!)
        
        postImagen["imagenCliente"] = imageFile
        postImagen["telefonoCliente"] = myTelefonoClienteTF.text
        postImagen.saveInBackground { (salvadoExitoso, errorDeSubida) in
            
            // Ocultamos la carga y lanzamos cualquier evento.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if salvadoExitoso{
                self.present(showAlertVC("ATENCION", messageData: "Datos actualizados exitosamente."), animated: true, completion: nil)
            }else{
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
        fotoSeleccionada = true
        myImagenClienteIV.image = image
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - EXTENSION DELEGADO PICKERVIEW
extension SK_Captacion_InfoCliente_ViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    
    // Función que crea un PickerView.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Función que crea el número de filas del PickerView.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayEstado.count
    }
    
    // Función que crea el título de cada fila del PickerView.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayEstado[row]
    }
    
    // Función que establece el título del TextField según la fila seleccionada.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        myEstadoClienteTF.text = arrayEstado[row]
    }
}


