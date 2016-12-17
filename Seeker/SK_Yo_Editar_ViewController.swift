//
//  SK_Yo_Editar_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 5/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Yo_Editar_ViewController: UIViewController {

    
    //MARK: - VARIABLES LOCALES GLOBALES
    var fotoSeleccionada = false
    
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myImagenUsuarioIV: UIImageView!
    @IBOutlet weak var myImagenCamaraIV: UIImageView!
    @IBOutlet weak var myNombreEmpresaTF: UITextField!
    @IBOutlet weak var myTelefonoEmpresaTF: UITextField!
    @IBOutlet weak var myCalleEmpresaTF: UITextField!
    @IBOutlet weak var myPostalEmpresaTF: UITextField!
    @IBOutlet weak var myLocalidadEmpresaTF: UITextField!
    @IBOutlet weak var myProvinciaEmpresaTF: UITextField!
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Establecemos lo bordes de myImagenLogoIV y myImagenCamaraIV
        configuraBordesImagenes(myImagenUsuarioIV, redondo: true, borde: true)
        configuraBordesImagenes(myImagenCamaraIV, redondo: true, borde: true)
        
        // Hacemos interactiva la imagen.
        myImagenCamaraIV.isUserInteractionEnabled = true
        
        // Añadimos el gesto a la myImagenInteractivaIV para que se habra la camara de fotos.
        let imageGestureReconize = UITapGestureRecognizer(target: self, action: #selector(SK_Yo_Editar_ViewController.showCamaraFotos))
        myImagenCamaraIV.addGestureRecognizer(imageGestureReconize)
        
        // Cargamos los datos del usuario.
        cargarDatos()
        
        // Añadimos el boton al teclado.
        addBotonOkAlTeclado()
    }
    
    
    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - ACTUALIZAMOS LOS DATOS CUANDO RECUPERAMOS EL VIEW
    override func viewDidAppear(_ animated: Bool) {
        cargarNuevaUbicacion()
    }
    
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // ACTUALIZAMOS LOS DATOS.
    @IBAction func actualizarDatosACTION(_ sender: Any) {
        // Comprobamos que los campos no esten vacíos.
        if myNombreEmpresaTF.text == ""{
            present(showAlertVC("ATENCION", messageData: "El nombre de la empresa no puede estar vacío."), animated: true, completion: nil)
        }else if myTelefonoEmpresaTF.text != ""{
            // Si tiene 9 caracteres actualizamos los campos.
            if myTelefonoEmpresaTF.text?.characters.count == 9 {
                actualizarDatos()
            }else{
                present(showAlertVC("ATENCION", messageData: "El número de Telefono no es correcto."), animated: true, completion: nil)
            }
        }
    }
    
    //MARK -------------------------- UTILIDADES --------------------------

    // SELECCIONAR FOTO DEL LOGO
    func showCamaraFotos(){
        pickerPhoto()
    }
    
    
    // AÑADIMOS LOS BOTONES AL TECLADO
    func addBotonOkAlTeclado(){
        // Creamos la barra de herramientas y le damos un formato.
        let aceptarToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        aceptarToolbar.barStyle = UIBarStyle.blackTranslucent
        
        // Creamos los botones que añadiremos a la barra de herramientas.
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.done, target: self, action: #selector(SK_Yo_Editar_ViewController.doneButtonAction))
        
        // Establecemos el color del texto.
        done.tintColor = UIColor(red:0.53, green:0.91, blue:0.45, alpha:1.0)
        
        // Añadimos los botones a la barra de herramientas.
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        aceptarToolbar.items = items
        aceptarToolbar.sizeToFit()
        
        // Añadimos el accesorio a myNumeroEmpresaTF.
        myTelefonoEmpresaTF.inputAccessoryView = aceptarToolbar
    }
    
    
    // ESTABLECEMOS COMO RESPONDEDOR A myTelefonoEmpresaTF.
    func doneButtonAction(){
        myTelefonoEmpresaTF.resignFirstResponder()
    }
    
    // CARGAR DATOS DEL USUARIO
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
                        self.myNombreEmpresaTF.text = objectDataUnoDes["nombreEmpresa"] as? String
                        if objectDataUnoDes["telefonoEmpresa"] != nil{
                            self.myTelefonoEmpresaTF.text = objectDataUnoDes["telefonoEmpresa"] as? String
                        }
                        if objectDataUnoDes["calleEmpresa"] != nil{
                            self.myCalleEmpresaTF.text = objectDataUnoDes["calleEmpresa"] as? String
                        }
                        if objectDataUnoDes["postalEmpresa"] != nil{
                            self.myPostalEmpresaTF.text = objectDataUnoDes["postalEmpresa"] as? String
                        }
                        if objectDataUnoDes["localidadEmpresa"] != nil{
                            self.myLocalidadEmpresaTF.text = objectDataUnoDes["localidadEmpresa"] as? String
                        }
                        if objectDataUnoDes["provinciaEmpresa"] != nil{
                            self.myProvinciaEmpresaTF.text = objectDataUnoDes["provinciaEmpresa"] as? String
                        }
                    }
                }
            }
        }
    }
    
    // CARGAR LA NUEVA UBICACION
    func cargarNuevaUbicacion(){
        // Realizamos la consulta de los datos del usuario.
        let queryUser = PFUser.query()!
        queryUser.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        // Lanzamos la carga e ignoramos los eventos.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Buscamos todos los objetos de la consulta comprobando que no hay errores.
        queryUser.findObjectsInBackground { (objectUno, errorUno) in

            // Ocultamos la carga y lanzamos los eventos.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if errorUno == nil{
                if let objectUnoDes = objectUno{
                    for objectDataUnoDes  in objectUnoDes{
                        
                        // Cargamos la ubicación del usuario.
                        if objectDataUnoDes["calleEmpresa"] != nil{
                            self.myCalleEmpresaTF.text = objectDataUnoDes["calleEmpresa"] as? String
                        }
                        if objectDataUnoDes["postalEmpresa"] != nil{
                            self.myPostalEmpresaTF.text = objectDataUnoDes["postalEmpresa"] as? String
                        }
                        if objectDataUnoDes["localidadEmpresa"] != nil{
                            self.myLocalidadEmpresaTF.text = objectDataUnoDes["localidadEmpresa"] as? String
                        }
                        if objectDataUnoDes["provinciaEmpresa"] != nil{
                            self.myProvinciaEmpresaTF.text = objectDataUnoDes["provinciaEmpresa"] as? String
                        }
                    }
                }
            }
        }
    }
    
    // ACTUALIZAR DATOS DEL USUARIO
    func actualizarDatos(){
        
        // Actualizamos los datos del usuario si los campos no están vacíos.
        let userData = PFUser.current()!
        if myNombreEmpresaTF.text != ""{
            userData["nombreEmpresa"] = myNombreEmpresaTF.text
        }
        if myTelefonoEmpresaTF.text != ""{
            userData["telefonoEmpresa"] = myTelefonoEmpresaTF.text
        }
        if myCalleEmpresaTF.text != ""{
            userData["calleEmpresa"] = myCalleEmpresaTF.text
            userData["postalEmpresa"] = myPostalEmpresaTF.text
            userData["localidadEmpresa"] = myLocalidadEmpresaTF.text
            userData["provinciaEmpresa"] = myProvinciaEmpresaTF.text
        }
        
        // Lanzamos la carga e ignoramos los eventos.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Salvamos los datos y si todo es correcto también salvamos la imagen.
        userData.saveInBackground { (actualizacionExitosa, errorActualizacion) in
            
            // Si la actualización es exitosa, actualizamos la foto.
            if actualizacionExitosa{
                self.upatePhoto()
            }else{
                print((errorActualizacion! as NSError).userInfo)
            }
        }
    }
    
    
    
    // ACTUALIZAR FOTO DEL PERFIL
    func upatePhoto(){
        // Eliminamos la foto antigua si existe.
        let queryRemover = PFQuery(className: "ImageProfile")
        queryRemover.whereKey("username", equalTo: (PFUser.current()?.username)!)
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
        let postImagen = PFObject(className: "ImageProfile")
        let imagenData = UIImageJPEGRepresentation(myImagenUsuarioIV.image!, 0.2)
        let imageFile = PFFile(name: "imagePerfilusuario" + (PFUser.current()?.username)! + ".jpg", data: imagenData!)
        
        postImagen["imageFile"] = imageFile
        postImagen["username"] = PFUser.current()?.username
        postImagen.saveInBackground { (salvadoExitoso, errorDeSubida) in
            
            // Lanzamos la carga e ignoramos los eventos.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if salvadoExitoso{
                UIApplication.shared.endIgnoringInteractionEvents()
                self.present(showAlertVC("ATENCION", messageData: "Datos actualizados exitosamente."), animated: true, completion: nil)
            }else{
                if let errorString = (errorDeSubida! as NSError).userInfo["error"] as? NSString{
                    self.present(showAlertVC("ATENCION", messageData: errorString as String), animated: true, completion: nil)
                }
            }
        }
    }
    
}


//MARK: - DELEGATE UIIMAGEPICKER / PHOTO
extension SK_Yo_Editar_ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    // SELECCIONAMOS LA CAMARA O LA LIBRERIA
    func pickerPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            showPhotoMenu()
        }else{
            choosePhotoFromLibrary()
        }
    }
    
    
    
    // MENU DE SELECCION DE LA CAMARA O DE LA LIBRERIA
    func showPhotoMenu(){
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Tomar Foto", style: .default) { Void  in
            self.takePhotowithCamera()
        }
        let chooseFromLibraryAction = UIAlertAction(title: "Escoge de la Librería", style: .default) { Void  in
            self.choosePhotoFromLibrary()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(takePhotoAction)
        alertVC.addAction(chooseFromLibraryAction)
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
    
    
    // CERRAMOS LA CAMARA CUANDO SELECCIONEMOS LA IMAGEN
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        fotoSeleccionada = true
        myImagenUsuarioIV.image = image
        self.dismiss(animated: true, completion: nil)
    }
}

