//
//  SK_Captacion_AddClient_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 7/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Captacion_AddClient_ViewController: UIViewController {

    //MARK: - VARIABLES LOCALES GLOBALES
    var fotoSeleccionada = false
    var latitud : Double?
    var longitud : Double?
    var calle : String?
    
    var textField : UITextField!
    
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myImagenClienteIV: UIImageView!
    @IBOutlet weak var myImagenCamaraIV: UIImageView!
    @IBOutlet weak var myNombreClienteTF: UITextField!
    @IBOutlet weak var myTelefonoClienteTF: UITextField!
    @IBOutlet weak var myCalleClienteTF: UITextField!
    @IBOutlet weak var myObservacionesClienteTF: UITextField!
    
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Configuramos el borde de myImagenUsuarioIV y myImagenCamaraIV.
        configuraBordesImagenes(myImagenClienteIV, redondo: true, borde: true)
        configuraBordesImagenes(myImagenCamaraIV, redondo: true, borde: false)
        
        // Hacemos interactiva a myImagenCamaraIV.
        myImagenCamaraIV.isUserInteractionEnabled = true
        
        // Añadimos el gesto a la myImagenInteractivaIV para que se habra la camara de fotos.
        let imageGestureReconize = UITapGestureRecognizer(target: self, action: #selector(SK_Captacion_AddClient_ViewController.showCamaraFotos))
        myImagenCamaraIV.addGestureRecognizer(imageGestureReconize)
        
        // Configuramos el textfield del teclado.
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
        
        // Añadimos el boton al teclado.
        addBotonOkAlTeclado()
        addtextfieldAlTeclado()
        
        // Cargamos los datos de la localización del cliente.
        myCalleClienteTF.text = calle
        
        // Indicamos que ha pasado de view.
        haPasado = true
    }


    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - CIERRA TECLADO
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // GUARDAR CLIENTE.
    @IBAction func guardarClienteACTION(_ sender: Any) {
        // Si los campos son correctos, coprobamos si el usuario existe.
        if compruebaCampos(){
            existeCliente()
        }
    }


    // CERRAR TECLADO AL CLICAR EN ACEPTAR.
    @IBAction func cerrarTcladoACTION(_ sender: Any) {
    }
    
    
    // ACTUALIZAR VALOR DEL TEXTFIELD
    @IBAction func actualizaValorACTION(_ sender: Any) {
        textField.text = myObservacionesClienteTF.text
    }
    
    
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // SELECCIONAR FOTO DEL CLIENTE
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
    }
    
    
    // ESTABLECEMOS COMO RESPONDEDOR A myTelefonoEmpresaTF.
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
        
        // Añadimos el accesorio a myNumeroEmpresaTF.
        myObservacionesClienteTF.inputAccessoryView = textFieldToolbar
    }
    
    // COMPROBAR CAMPOS PARA AÑADIR AL CLIENTE.
    func compruebaCampos() -> Bool{
        // Comprobamos que el campo telefono tiene que estar relleno y tener los caracteres correctos.
        if myTelefonoClienteTF.text == ""{
            present(showAlertVC("ATENCIÓN", messageData: "El cliente debe contener un número de teléfono."), animated: true, completion: nil)
            return false
        }else if myTelefonoClienteTF.text?.characters.count != 9 {
            present(showAlertVC("ATENCIÓN", messageData: "El número de Telefono no es correcto."), animated: true, completion: nil)
            return false
        }else {
            return true
        }
    }
    
    // COMPRUEBA SI EL CLIENTE EXISTE.
    func existeCliente(){
        // Realizamos la consulta de los datos del cliente.
        let usuario = String(describing: PFUser.current()!)
        let queryUser = PFQuery(className: "Client")
        queryUser.whereKey("telefonoCliente", equalTo: myTelefonoClienteTF.text!)
        
        // Buscamos todos los objetos de la consulta comprobando que no existe el cliente.
        queryUser.findObjectsInBackground { (objectUno, errorUno) in
            if errorUno == nil{
                if let objectUnoDes = objectUno{
                    if objectUnoDes.count != 0{
                        for objectDataUnoDes  in objectUnoDes{
                            // Si el cliente existe lanzamos un error sino lo guardamos.
                            if self.myTelefonoClienteTF.text! == objectDataUnoDes["telefonoCliente"] as? String && usuario == objectDataUnoDes["usuarioCliente"] as? String{
                                self.present(showAlertVC("ATENCIÓN", messageData: "El número ya esta dado de alta en la base de datos"), animated: true, completion: nil)
                            }
                        }
                    }else{
                        self.guardarDatos()
                    }
                }
            }
        }
    }
    
    
    // GUARDA AL NUEVO CLIENTE.
    func guardarDatos(){
        // Damos de alta al cliente si los los campos no están vacíos.
        let userData = PFObject(className: "Client")
        
        userData["usuarioCliente"] = PFUser.current()?.username
        userData["estadoCliente"] = "Pendiente"
        
        if myNombreClienteTF.text != ""{
            userData["nombreCliente"] = myNombreClienteTF.text
        }
        if myTelefonoClienteTF.text != ""{
            userData["telefonoCliente"] = myTelefonoClienteTF.text
        }
        if myCalleClienteTF.text != ""{
            userData["calleCliente"] = myCalleClienteTF.text
            userData["latitudCliente"] = latitud!
            userData["longitudCliente"] = longitud!
        }
        if myObservacionesClienteTF.text != ""{
            userData["observacionesCliente"] = myObservacionesClienteTF.text
        }
        
        // Mostramos la carga e ignoramos cualquier evento.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        // Salvamos los datos y si todo es correcto también salvamos la imagen.
        userData.saveInBackground { (actualizacionExitosa, errorActualizacion) in
            if actualizacionExitosa{
                self.salvarImagenEnBackgroundWhitBlock()
            }else{
                // Ocultamos la carga y lanzamos cualquier evento.
                muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }

    
    // SALVAR IMAGEN EN PARSE
    func salvarImagenEnBackgroundWhitBlock(){
        // Declaramos la clase, el formato de la imagen y el fichero donde se guarda.
        let postImagen = PFObject(className: "imageClient")
        let imageData = UIImageJPEGRepresentation(myImagenClienteIV.image!, 0.2)
        let imageFile = PFFile(name: "imagePerfilCliente" + myTelefonoClienteTF.text! + ".jpg", data: imageData!)
        
        // Asignamos el fichero y el usuario.
        postImagen["imagenCliente"] = imageFile
        postImagen["telefonoCliente"] = myTelefonoClienteTF.text!
        
        // Comprobamos si se puede guardar la imagen.
        postImagen.saveInBackground{ (salvadoExitoso, errorDeSubidaImagen) in
            
            // Ocultamos la carga y lanzamos cualquier evento.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()

            // Si todo es correcto, lanzamos un mensaje de registro correcto y limpiamos los campos.
            if salvadoExitoso{
                let alertVC = UIAlertController(title: "ATENCION", message: "Datos salvados exitosamente", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (cerrar) in
                    self.performSegue(withIdentifier: "unWind", sender: self.view)
                })
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
                limpiaCampos([self.myNombreClienteTF, self.myTelefonoClienteTF, self.myCalleClienteTF, self.myObservacionesClienteTF])
                self.myImagenClienteIV.image = UIImage(named: "clienteGrande")
            }else{ // Sino lanzamos un mensaje de error.
                self.present(showAlertVC("ATENCION", messageData: "Error en el registro"), animated: true, completion: nil)
            }
        }
    }
}


//MARK: - DELEGATE UIIMAGEPICKER / PHOTO
extension SK_Captacion_AddClient_ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    // SELECCIONAMOS LA CAMARA O LA LIBRERIA
    func pickerPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            takePhotowithCamera()
        }
    }
    
    // LANZAMOS LA CAMARA PARA TOMAR UNA FOTO
    func takePhotowithCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // CERRAMOS LA CAMARA CUANDO SELECCIONEMOS LA IMAGEN
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        fotoSeleccionada = true
        myImagenClienteIV.image = image
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - DELEGATE DEL TEXTFIELD
extension SK_Captacion_AddClient_ViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        myObservacionesClienteTF.text = textField.text
        textField.resignFirstResponder()
        return true
    }
    
}

