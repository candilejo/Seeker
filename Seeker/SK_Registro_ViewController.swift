//
//  SK_Registro_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 2/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse


class SK_Registro_ViewController: UIViewController {

    
    //MARK: - VARIABLES LOCALES GLOBALES
    var fotoSeleccionada = false
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myImagenUsuarioIV: UIImageView!
    @IBOutlet weak var myImagenCamaraIV: UIImageView!
    @IBOutlet weak var myUsuarioTF: UITextField!
    @IBOutlet weak var myPasswordTF: UITextField!
    @IBOutlet weak var myEmailTF: UITextField!
    @IBOutlet weak var myNombreEmpresaTF: UITextField!
    @IBOutlet weak var myBotonRegistrarseBTN: UIButton!
    @IBOutlet weak var myActivityIndicatorAI: UIActivityIndicatorView!
    
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Ocultamos myActivityIndicatorAI.
        myActivityIndicatorAI.isHidden = true
        
        // Configuramos la sombra de myBotonRegistrarseBTN y le bloqueamos.
        configuraSombraAspectoBotones(boton: myBotonRegistrarseBTN, redondo: false)
        cambiaEstadoBTN(boton: myBotonRegistrarseBTN, estado: false)
        
        // Configuramos el borde de myImagenUsuarioIV y myImagenCamaraIV.
        configuraBordesImagenes(myImagenUsuarioIV, redondo: true, borde: true)
        configuraBordesImagenes(myImagenCamaraIV, redondo: true, borde: false)
        
        // Hacemos interactiva la imagen.
        myImagenCamaraIV.isUserInteractionEnabled = true
        
        // Añadimos el gesto a la myImagenInteractivaIV para que se habra la camara de fotos.
        let imageGestureReconize = UITapGestureRecognizer(target: self, action: #selector(SK_Registro_ViewController.showCamaraFotos))
        myImagenCamaraIV.addGestureRecognizer(imageGestureReconize)
        
        // Creamos el gesto y se lo añadimos al View.
        let viewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SK_Registro_ViewController.hideKeyBoard))
        view.addGestureRecognizer(viewGestureRecognizer)
        
        
    }

    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK -------------------------- ACCIONES --------------------------
    
    // CANCELA EL REGISTRO.
    @IBAction func cancelarRegistroACTION(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MUESTRA INFORMACIÓN SOBRE LA CONTRASEÑA.
    @IBAction func informacionPasswordACTION(_ sender: Any) {
        present(showAlertVC("INFORMACIÓN", messageData: "La contraseña debe contener un mínimo de 6 caracteres"), animated: true, completion: nil)
    }
    
    // CAMBIA EL ESTADO DEL BOTON EN FUNCION DE LOS CARACTERES.
    @IBAction func cambiaEstadoBotonACTION(_ sender: Any) {
        // Bloquemos / Desbloqueamos myBotonRegistrarseBTN en función del estado de los campos.
        if estadoCampos(){
            cambiaEstadoBTN(boton: myBotonRegistrarseBTN, estado: true)
        }else{
            cambiaEstadoBTN(boton: myBotonRegistrarseBTN, estado: false)
        }
    }
    
    // CERRAR TECLADO AL CLICAR EN ACEPTAR.
    @IBAction func cerrarTecladoACTION(_ sender: Any) {
    }
    
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // CIERRA TECLADO
    func hideKeyBoard(){
        view.endEditing(true)
    }
    
    
    // COMPRUEBA EL ESTADO DE LOS CAMPOS
    func estadoCampos() -> Bool{
        // Declaramos el estado de los campos.
        var estado = true
        
        // Si myEmailTF o myNombreEmpresaTF estan vacios o myPasswordTF tiene menos de 6 caracteres devolvemos 'false'.
        if myEmailTF.text! == "" || (myPasswordTF.text?.characters.count)! < 6 || myNombreEmpresaTF.text! == ""{
            estado = false
        }
        
        return estado
    }
    
    
    // SALVAR IMAGEN EN PARSE
    func salvarImagenEnBackgroundWhitBlock(){
        // Declaramos la clase, el formato de la imagen y el fichero donde se guarda.
        let postImagen = PFObject(className: "ImageProfile")
        let imageData = UIImageJPEGRepresentation(myImagenUsuarioIV.image!, 0.2)
        let imageFile = PFFile(name: "imagePerfilusuario" + myEmailTF.text! + ".jpg", data: imageData!)
        
        // Asignamos el fichero y el usuario.
        postImagen["imageFile"] = imageFile
        postImagen["username"] = PFUser.current()?.username
        
        // Comprobamos si se puede guardar la imagen.
        postImagen.saveInBackground{ (salvadoExitoso, errorDeSubidaImagen) in
            
            // Si todo es correcto, lanzamos un mensaje de registro correcto y limpiamos los campos.
            if salvadoExitoso{
                
                self.present(showAlertVC("ATENCION", messageData: "Datos salvados exitosamente"), animated: true, completion: nil)
                
                print("usuario registrado correctamente")
                limpiaCampos([self.myPasswordTF, self.myNombreEmpresaTF, self.myEmailTF])
                self.myImagenUsuarioIV.image = UIImage(named: "placeholder")
                
                
            }else{ // Sino lanzamos un mensaje de error.
                
                self.present(showAlertVC("ATENCION", messageData: "Error en el registro"), animated: true, completion: nil)
                
            }
        }
    }
    
    
    
    
    // SELECCIONAR FOTO DEL LOGO
    func showCamaraFotos(){
        pickerPhoto()
    }
    
}



//MARK: - DELEGATE UIIMAGEPICKER / PHOTO
extension SK_Registro_ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
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

