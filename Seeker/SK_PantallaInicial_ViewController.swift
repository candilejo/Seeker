//
//  SK_PantallaInicial_ViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 16/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_PantallaInicial_ViewController: UIViewController {

    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
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
            performSegue(withIdentifier: "presentViewController", sender: self)
        }
    }
    
    // UNWIND.
    @IBAction func unWind(segue: UIStoryboardSegue){
        PFUser.logOutInBackground()
    }

}
