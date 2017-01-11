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
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la StatusBar por defecto.
        UIApplication.shared.statusBarStyle = .default
        
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
    
    
    //MARK: - ACTUALIZAMOS EL STATUSBAR CUANDO RECUPERAMOS EL VIEW.
    override func viewDidAppear(_ animated: Bool) {
        // Mostramos la StatusBar por defecto.
        UIApplication.shared.statusBarStyle = .default
    }
    
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // MUESTRA INFORMACIÓN DE LA PASSWORD.
    @IBAction func informacionPasswordACTION(_ sender: Any) {
        present(showAlertVC("INFORMACIÓN", messageData: "La contraseña debe contener un mínimo de 6 caracteres."), animated: true, completion: nil)
    }
    
    // ACCESO A LA APLICACIÓN.
    @IBAction func loginACTION(_ sender: Any) {
        // Lanzamos la carga e ignoramos los eventos.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Comprobamos que el usuario y contraseña son correctos.
        PFUser.logInWithUsername(inBackground: myUsuarioTF.text!, password: myPasswordTF.text!) { (UserFromParse, errorLogIn) in
            
            // Ocultamos la carga y lanzamos los eventos.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            // Si el usuasio no esta vacío accedemos a la App.
            if UserFromParse != nil{
                self.performSegue(withIdentifier: "presentTabBarController", sender: self)
                limpiaCampos([self.myUsuarioTF, self.myPasswordTF])
                
            }else{ // Sino.
                //Lanzamos el error de porque no hemos podido logarnos.
                let error =  erroresUser(code: (errorLogIn! as NSError).code)
                if error != ""{
                    self.present(showAlertVC("ATENCION", messageData: error), animated: true, completion: nil)
                }else{
                    self.present(showAlertVC("Error", messageData: "Error en el Login."), animated: true, completion: nil)
                }
            }
            // Limpiamos los campos y bloqueamos myBotonAccederBTN.
            limpiaCampos([self.myUsuarioTF, self.myPasswordTF])
            cambiaEstadoBTN(boton: self.myBotonAccederBTN, estado: false)
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
    
    // LOGOUT
    @IBAction func logoutACTION(storyboard : UIStoryboardSegue){
        PFUser.logOut()
        present(showAlertVC("INFORMACIÓN", messageData: "La sesión se ha cerrado correctamente."), animated: true, completion: nil)
    }
}
