//
//  SK_Acceso_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 1/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Acceso_ViewController: UIViewController {

    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myUsuarioTF: UITextField!
    @IBOutlet weak var myPasswordTF: UITextField!
    @IBOutlet weak var myBotonAccederBTN: UIButton!
    @IBOutlet weak var myActivityIndicatorAI: UIActivityIndicatorView!
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la StatusBar por defecto.
        UIApplication.shared.statusBarStyle = .default
        
        // Ocultamos myActivityIndicatorAI.
        myActivityIndicatorAI.isHidden = true
        
        // Configuramos el estado y la sombra de myBotonAccederBTN.
        cambiaEstadoBTN(boton: myBotonAccederBTN, estado: false)
        configuraSombraAspectoBotones(boton: myBotonAccederBTN, redondo: false)
        
        // Creamos el gesto y se lo añadimos al View.
        let viewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SK_Acceso_ViewController.hideKeyBoard))
        view.addGestureRecognizer(viewGestureRecognizer)
    }

    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - ACCESO A LA APP SI LA SESION ESTA ABIERTA
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .default
        
        // Si la sesión del usuario está activa accedemos a la App.
        if PFUser.current()?.username != nil{
            performSegue(withIdentifier: "presentTabBarController", sender: self)
        }else{
            print ("El usuario no exite.")
        }
    }
    
    
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // MUESTRA INFORMACIÓN DE LA PASSWORD.
    @IBAction func informacionPasswordACTION(_ sender: Any) {
        present(showAlertVC("INFORMACIÓN", messageData: "La contraseña debe contener un mínimo de 6 caracteres."), animated: true, completion: nil)
    }
    
    // ACCESO A LA APLICACIÓN.
    @IBAction func loginACTION(_ sender: Any) {
        // Hacemos visible e iniciamos myActivityIndicator e ignoramos la interacción con eventos.
        self.myActivityIndicatorAI.isHidden = false
        self.myActivityIndicatorAI.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Comprobamos que el usuario y contraseña son correctos.
        PFUser.logInWithUsername(inBackground: myUsuarioTF.text!, password: myPasswordTF.text!) { (UserFromParse, errorLogIn) in
            
            // Ocultamos y paramos myActivityIndicator y reanudamos la interacción con eventos.
            self.myActivityIndicatorAI.isHidden = true
            self.myActivityIndicatorAI.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            // Si el usuasio no esta vacío accedemos a la App.
            if UserFromParse != nil{
                self.performSegue(withIdentifier: "presentTabBarController", sender: self)
                limpiaCampos([self.myUsuarioTF, self.myPasswordTF])
                
            }else{ // Sino.
                //Lanzamos el error de porque no hemos podido logarnos.
                if let errorString = (errorLogIn! as NSError).userInfo["error"] as? NSString{
                    self.present(showAlertVC("ATENCION", messageData: errorString as String), animated: true, completion: nil)
                    
                }else{
                    self.present(showAlertVC("Error", messageData: "Error en el registro."), animated: true, completion: nil)
                }
            }
        }
    }

    // COMPRUEBA LOS CARACTERES DE LOS CAMPOS.
    @IBAction func compruebaCamposACTION(_ sender: Any) {
        // Bloquemos / Desbloqueamos myBotonAccederBTN en función del estado de los campos.
        if estadoCampos(){
            cambiaEstadoBTN(boton: myBotonAccederBTN, estado: true)
        }else{
            cambiaEstadoBTN(boton: myBotonAccederBTN, estado: false)
        }
    }
    
    // CIERRA EL TECLADO AL PULSAR ACEPTAR.
    @IBAction func cierraTecladoACTION(_ sender: Any) {
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
        
        // Si myUsuarioTF esta vacio o myPasswordTF tiene menos de 6 caracteres devolvemos 'false'.
        if myUsuarioTF.text! == "" || (myPasswordTF.text?.characters.count)! < 6{
            estado = false
        }
        
        return estado
    }
}
