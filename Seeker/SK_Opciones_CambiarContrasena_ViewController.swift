//
//  SK_Opciones_CambiarContrasena_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 12/1/17.
//  Copyright © 2017 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Opciones_CambiarContrasena_ViewController: UIViewController {

    //MARK: - IBOUTLET
    @IBOutlet weak var myPasswordActualTF: UITextField!
    @IBOutlet weak var myPasswordNuevoTF: UITextField!
    @IBOutlet weak var myPasswordNuevoBisTF: UITextField!
    @IBOutlet weak var myBotonActualizarBTN: UIButton!
    
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Configuramos los bordes  y bloqueamos myBotonActualizarBTN.
        configuraSombraAspectoBotones(boton: myBotonActualizarBTN, redondo: false)
        cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
    }

    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - SE EJECUTA CUANDO COMIENZAN LOS TOQUES
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    //MARK -------------------------- ACCIONES --------------------------
    
    // ACTUALIZAR EMAIL.
    @IBAction func actualizarPasswordACTION(_ sender: Any) {
        passwordActualCorrecto()
    }
    
    // COMPRUEBA CAMPOS
    @IBAction func compruebaCamposPasswordACTION(_ sender: Any) {
        // Si los campos están vacíos bloqueamos myBotonActualizarBTN, sino lo desbloqueamos.
        if myPasswordActualTF.text == "" || myPasswordNuevoTF.text == "" || myPasswordNuevoBisTF.text == ""{
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: false)
        }else{
            cambiaEstadoBTN(boton: myBotonActualizarBTN, estado: true)
        }
    }
    
    // CERRAR TECLADO
    @IBAction func cierraTecladoPasswordACTION(_ sender: Any) {
    }
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // COMPROBAMOS QUE EL PASSWORD COINCIDE.
    func passwordActualCorrecto(){
        let passwordUser = PFUser.current()!
        // Si el Password es igual al de la base de datos comprobamos los Passwords Nuevos, sino lanzamos un error.
        if passwordUser["passwordEmpresa"] as! String == myPasswordActualTF.text!{
            // Si los campos de los Passwords Nuevos son iguales, comprobamos el número de caracteres si no lanzamos un error.
            if myPasswordNuevoTF.text! == myPasswordNuevoBisTF.text!{
                // Si la contraseña tiene menos de 6 caracteres lanzamos un error.
                if (myPasswordNuevoTF.text?.characters.count)! < 6{
                    present(showAlertVC("ATENCIÓN", messageData: "Los Passwords Nuevos deben tener un mínimo de 6 caracteres."), animated: true, completion: nil) 
                }else{
                    // Si la pasword Actual y la nueva son iguales lanzamos un error si no actualizamos.
                    if myPasswordActualTF.text! == myPasswordNuevoTF.text!{
                        present(showAlertVC("ATENCIÓN", messageData: "La Password elegida ya está en uso."), animated: true, completion: nil)
                    }else{
                        actualizaPassword()
                    }
                }
            }else{
                present(showAlertVC("ATENCIÓN", messageData: "Los Passwords Nuevos no coinciden."), animated: true, completion: nil)
            }
        }else{
            present(showAlertVC("ATENCIÓN", messageData: "El Password Actúal no coincide con el de la Base de Datos."), animated: true, completion: nil)
        }
    }
    
    // ACTUALIZAR EMAIL.
    func actualizaPassword(){
        
        // REALIZAMOS LA CONSULTA.
        let userData = PFUser.current()!
        userData.password = myPasswordNuevoTF.text!
        userData["passwordEmpresa"] = myPasswordNuevoTF.text!
        
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
                let alertVC = UIAlertController(title: "INFORMACIÓN", message: "Su Password se ha actualizado correctamente", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (cerrar) in
                    self.performSegue(withIdentifier: "volverAtras", sender: self.view)
                })
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
                limpiaCampos([self.myPasswordActualTF,self.myPasswordNuevoTF,self.myPasswordNuevoBisTF])
            }else{ // Sino lanzamos un mensaje de error.
                self.present(showAlertVC("ATENCION", messageData: "Error en el registro"), animated: true, completion: nil)
            }
        }
    }

}
