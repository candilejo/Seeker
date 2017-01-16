//
//  SK_Opciones_CambiarEmail_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 12/1/17.
//  Copyright © 2017 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Opciones_CambiarEmail_ViewController: UIViewController {
    
    //MARK: - IBOUTLET
    @IBOutlet weak var myEmailActualTF: UITextField!
    @IBOutlet weak var myEmailNuevoTF: UITextField!
    @IBOutlet weak var myEmailNuevoBisTF: UITextField!
    @IBOutlet weak var myBotonActualizarBTN: UIButton!
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Configuramos los bordes  y bloqueamos myBotonActualizarBTN.
        configuraSombraAspectoBotones(boton: myBotonActualizarBTN, redondo: false)
        cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
        
        // Creamos el gesto y se lo añadimos al View.
        let viewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SK_Opciones_CambiarEmail_ViewController.hideKeyBoard))
        view.addGestureRecognizer(viewGestureRecognizer)
    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // ACTUALIZAR EMAIL.
    @IBAction func actualizarEmailACTION(_ sender: Any) {
        emailActualCorrecto()
    }
    
    // COMPRUEBA CAMPOS
    @IBAction func compruebaCamposACTION(_ sender: Any) {
        // Si los campos están vacíos bloqueamos myBotonActualizarBTN, sino lo desbloqueamos.
        if myEmailActualTF.text == "" || myEmailNuevoTF.text == "" || myEmailNuevoBisTF.text == ""{
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
        }else{
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: true)
        }
    }
    
    // CERRAR TECLADO
    @IBAction func cierraTecladoEmailACTION(_ sender: Any) {
    }
    
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // CIERRA TECLADO
    func hideKeyBoard(){
        view.endEditing(true)
    }
    
    // COMPROBAMOS QUE EL EMAIL COINCIDE.
    func emailActualCorrecto(){
        let emailUser = PFUser.current()!
        // Si el Email es igual al de la base de datos comprobamos los Emails Nuevos, sino lanzamos un error.
        if emailUser.email! as String == myEmailActualTF.text!{
            // Si los campos de los Emails Nuevos son iguales, actualizamos si no lanzamos un error.
            if myEmailNuevoTF.text! == myEmailNuevoBisTF.text!{
                actualizaEmail()
            }else{
                present(showAlertVC("ATENCIÓN", messageData: "Los Emails Nuevos no coinciden."), animated: true, completion: nil)
            }
        }else{
            present(showAlertVC("ATENCIÓN", messageData: "El Email Actúal no coincide con el de la Base de Datos."), animated: true, completion: nil)
        }
    }
    
    // ACTUALIZAR EMAIL.
    func actualizaEmail(){
        
        let userData = PFUser.current()!
        userData.email = myEmailNuevoTF.text!
        
        // Lanzamos la carga e ignoramos los eventos.
        muestraCarga(muestra: true, view: self.view, imageGroupTag: 1)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Comprobamos si se pueden actualizar los campos.
        userData.saveInBackground { (actualizacionExitosa, errorActualizacion) in
            
            // Ocultamos la carga y lanzamos los eventos.
            muestraCarga(muestra: false, view: self.view, imageGroupTag: 1)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            // Si todo es correcto, lanzamos un mensaje de actualización correcta y limpiamos los campos.
            if actualizacionExitosa{
                let alertVC = UIAlertController(title: "INFORMACIÓN", message: "Su Email se ha actualizado correctamente", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (cerrar) in
                    self.performSegue(withIdentifier: "volver", sender: self.view)
                })
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
                limpiaCampos([self.myEmailActualTF,self.myEmailNuevoTF,self.myEmailNuevoBisTF])
            }else{ // Sino lanzamos un mensaje de error.
                self.present(showAlertVC("ATENCION", messageData: "Error en el registro"), animated: true, completion: nil)
            }
        }
    }

}
