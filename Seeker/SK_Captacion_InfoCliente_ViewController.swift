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
    
    var fotoSeleccionada = false
    var imageGroupTag = 1
    var activo = false
    
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myImagenClienteIV: UIImageView!
    @IBOutlet weak var myImagenCamaraIV: UIImageView!
    @IBOutlet weak var myNombreClienteTF: UITextField!
    @IBOutlet weak var myTelefonoClienteTF: UITextField!
    @IBOutlet weak var myCalleClienteTF: UITextField!
    @IBOutlet weak var myObservacionesTF: UITextField!
    @IBOutlet weak var myBotonActualizarBTN: UIButton!
    @IBOutlet weak var myActivityIndicatorAI: UIActivityIndicatorView!
    
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Ocultamos myActivityIndicatorAI.
        myActivityIndicatorAI.isHidden = true
        
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
        
        // Cargamos los datos del Cliente.
        cargarDatosCliente()
    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    //MARK -------------------------- ACCIONES --------------------------

    @IBAction func eliminarClienteACTION(_ sender: Any) {
    }
    @IBAction func llamarClienteACTION(_ sender: Any) {
    }
    
    // ACTUALIZA LOS CAMPOS
    @IBAction func actualizarClienteACTION(_ sender: Any) {
        actualizarDatos()
        haPasado = true
    }
    
    // COMPRUEBA SI LOS CAMPOS SON IGUALES.
    @IBAction func compruebaCamposACTION(_ sender: Any) {
        if myNombreClienteTF.text != nombreCliente || myObservacionesTF.text != observacionesCliente || myImagenClienteIV.image != image{
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: true)
        }
    }
    
    // CERRAR TECLADO AL PULSAR EN ACEPTAR.
    @IBAction func cerrarTecladoACTION(_ sender: Any) {
    }

    
    //MARK -------------------------- UTILIDADES --------------------------

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
        queryClient.whereKey("telefonoCliente", equalTo: telefonoCliente!)
        
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
                            if errorDos == nil{
                                if let objectDosDes = objectDos{
                                    for objectDataDosDes in objectDosDes{
                                        let usernameFile = objectDataDosDes["imagenCliente"] as! PFFile
                                        
                                        // Cargamos el valor a la imagen.
                                        usernameFile.getDataInBackground(block: { (imageData, imageError) in
                                            if imageError == nil{
                                                if let imageDataDes = imageData{
                                                    self.image = UIImage(data: imageDataDes)
                                                    self.myImagenClienteIV.image = self.image
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
                        }
                        if objectDataUnoDes["calleCliente"] != nil{
                            self.myCalleClienteTF.text = objectDataUnoDes["calleCliente"] as? String
                        }
                        if objectDataUnoDes["observacionesCliente"] != nil{
                            self.myObservacionesTF.text = objectDataUnoDes["observacionesCliente"] as? String
                            self.observacionesCliente = self.myObservacionesTF.text
                        }
                        self.latitudCliente = objectDataUnoDes["latitudCliente"] as? Double
                        self.longitudCliente = objectDataUnoDes["longitudCliente"] as? Double
                    }
                }
            }
        }
    }
    
    // GESTO DE RECONOCIMIENTO
    func hideImageGroup(gesto : UIGestureRecognizer){
        for subvista in self.view.subviews{
            if subvista.tag == self.imageGroupTag{
                subvista.removeFromSuperview()
            }
        }
    }
    
    
    // ACTUALIZAR DATOS DEL USUARIO
    func actualizarDatos(){
        // Eliminamos la foto antigua si existe.
        let queryRemover = PFQuery(className: "Client")
        queryRemover.whereKey("telefonoCliente", equalTo: telefonoCliente!)
        queryRemover.findObjectsInBackground(block: { (objectRemove, errorRemove) in
            if errorRemove == nil{
                for objectRemoverDes in objectRemove!{
                    objectRemoverDes.deleteInBackground(block: nil)
                }
            }else{
                print("Error \((errorRemove! as NSError).userInfo)")
            }
        })
        
        // Actualizamos los datos del cliente si los campos no están vacíos.
        let clientData = PFObject(className: "Client")
        if myNombreClienteTF.text != "" {
            clientData["nombreCliente"] = myNombreClienteTF.text
        }
        clientData["telefonoCliente"] = telefonoCliente
        clientData["calleCliente"] = myCalleClienteTF.text
        if myObservacionesTF.text != ""{
            clientData["observacionesCliente"] = myObservacionesTF.text
        }
        clientData["latitudCliente"] = latitudCliente
        clientData["longitudCliente"] = longitudCliente
    
        // Hacemos visible e iniciamos myActivityIndicator e ignoramos la interacción con eventos.
        self.myActivityIndicatorAI.isHidden = false
        self.myActivityIndicatorAI.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        // Salvamos los datos y si todo es correcto también salvamos la imagen.
        clientData.saveInBackground { (actualizacionExitosa, errorActualizacion) in
            
            // Hacemos visible e iniciamos myActivityIndicator y activamos los eventos.
            self.myActivityIndicatorAI.isHidden = true
            self.myActivityIndicatorAI.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if actualizacionExitosa{
                self.upatePhoto()
            }else{
                print("error")
            }
        }
    }
    
    
    
    // ACTUALIZAR FOTO DEL PERFIL
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
            }
        })
        
        // Cargamos de nuevo la imagen.
        let postImagen = PFObject(className: "imageClient")
        let imagenData = UIImageJPEGRepresentation(myImagenClienteIV.image!, 0.2)
        let imageFile = PFFile(name: "imagePerfilCliente" + myTelefonoClienteTF.text! + ".jpg", data: imagenData!)
        
        postImagen["imagenCliente"] = imageFile
        postImagen["telefonoCliente"] = myTelefonoClienteTF.text
        postImagen.saveInBackground { (salvadoExitoso, errorDeSubida) in
            if salvadoExitoso{
                self.present(showAlertVC("ATENCION", messageData: "Datos actualizados exitosamente."), animated: true, completion: nil)
            }else{
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

