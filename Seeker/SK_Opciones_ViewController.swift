//
//  SK_Opciones_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 9/1/17.
//  Copyright © 2017 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Opciones_ViewController: UIViewController {

    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK -------------------------- ACCIONES --------------------------
    
    // CERRAR SESION
    @IBAction func cerrarSesionACTION(_ sender: Any) {
        self.performSegue(withIdentifier: "logout", sender: view)
    }
}
