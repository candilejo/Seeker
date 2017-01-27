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
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
    }

    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - ACCESO A LA APP SI LA SESION ESTA ABIERTA
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Mostramos la barra de estado.
        UIApplication.shared.statusBarStyle = .lightContent
        
        if PFUser.current()?.username != nil{ // Si la sesión del usuario está activa accedemos a la App.
            performSegue(withIdentifier: "presentTabBarController", sender: self)
        }else{ // Sino a la pantalla de logeo.
            performSegue(withIdentifier: "presentViewController", sender: self)
        }
    }
    
    // UNWIND LOGOUT.
    @IBAction func logoutACTION(storyboard : UIStoryboardSegue){
        PFUser.logOut() // Realizamos el logout del usuario.
        // Lanzamos un mensaje de información.
        present(showAlertVC("INFORMACIÓN", messageData: "La sesión se ha cerrado correctamente."), animated: true, completion: nil)
    }

}
