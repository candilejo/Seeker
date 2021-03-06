//
//  SK_Utilidades.swift
//  Seeker
//
//  Created by Jose Candilejo on 1/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import Foundation
import UIKit


//MARK: - CONFIGURA LA SOMBRA Y EL ASPECTO DEL BOTON
func configuraSombraAspectoBotones(boton : UIButton, redondo : Bool){
    // Configuramos la sombra del botón.
    boton.layer.shadowColor = UIColor.darkGray.cgColor
    boton.layer.shadowOffset = CGSize(width: 3, height: 3)
    boton.layer.shadowRadius = 3
    boton.layer.shadowOpacity = 1.0
    
    if redondo{ // Si redondo es 'true' lo hacemos redondo.
        boton.layer.cornerRadius = boton.frame.width / 2
    }
}


//MARK: - CONFIGURACION DE LOS BORDES DE LAS IMAGENES
func configuraBordesImagenes(_ imagen: UIImageView, redondo: Bool, borde: Bool){
    imagen.clipsToBounds = true
    
    if redondo{ // Si redondo es 'true' la hacemos redonda.
        imagen.layer.cornerRadius = imagen.frame.width/2
    }else{ // Sino redondeamos las esquinas.
        imagen.layer.cornerRadius = 10
    }
    
    if borde{ // Si el borde es 'true', cargamos el borde a la imagen.
        imagen.layer.borderColor = UIColor.white.cgColor
        imagen.layer.borderWidth = 3
    }
}



//MARK: - CREA Y DEVUELVE UN ALERTCONTROLLER.
func showAlertVC (_ titleData : String, messageData : String) -> UIAlertController{
    let alertVC = UIAlertController(title: titleData, message: messageData, preferredStyle: .alert) // Creamos el Alert.
    
    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil)) // Añadimos el boton.
    
    return alertVC // Devolvemos el Alert.
}



//MARK: - LIMPIA LOS CAMPOS.
func limpiaCampos(_ campos : [UITextField]){
    for campo in campos{
        campo.text = ""
    }
}

//MARK: - CAMBIA ESTADO DE UN BOTON.
func cambiaEstadoBTN(boton : UIButton, estado : Bool){
    boton.isEnabled = estado // Establecemo el estado de boton.
    
    if estado{ // Si el estado es 'true' lo ponemos verde.
        boton.backgroundColor = UIColor(red:0.53, green:0.91, blue:0.45, alpha:1.0)
    }else{ //Sino gris.
        boton.backgroundColor = UIColor.lightGray
    }
}

// MARK: - CARGA VIEW DE CARGA
func muestraCarga(muestra : Bool, view : UIView, imageGroupTag : Int){
    if muestra{ // Si muestra es 'true'.
        // Creamos un fondo negro con transparencia.
        let background = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        background.backgroundColor = UIColor.darkGray
        background.alpha = 0.4
        background.tag = imageGroupTag
        
        // Creamos el AI
        let ai = UIActivityIndicatorView(frame: CGRect(x: view.frame.width / 3, y: view.frame.height / 2.5, width: view.frame.width / 3, height: view.frame.height / 6))
        ai.layer.cornerRadius = 10
        ai.activityIndicatorViewStyle = .whiteLarge
        ai.color = UIColor(red:0.53, green:0.91, blue:0.45, alpha:1.0)
        ai.isHidden = false
        ai.backgroundColor = UIColor.white
        ai.startAnimating()
        ai.tag = imageGroupTag
        ai.alpha = 0.8
        
        // Creamos el texto inferior.
        let label = UILabel(frame: CGRect(x: view.frame.width / 3, y: view.frame.height / 1.95, width: ai.frame.width, height: ai.frame.height / 3))
        label.text = "   Cargando..."
        label.textColor = UIColor.black
        label.tag = imageGroupTag
        
        // Añadimos los subViews
        view.addSubview(background)
        view.addSubview(ai)
        view.addSubview(label)
    }else{ // Sino eliminamos todos los subviews.
        for subvista in view.subviews{
            if subvista.tag == imageGroupTag{
                subvista.removeFromSuperview()
            }
        }
    }
}
    
//MARK: - ERRORES USUARIO
func erroresUser(code : Int) -> String{
    var error = ""
    // En función del error devolvemos el texto correcto.
    if code == 101{
        error = "Usuario o contraseña incorrectos."
    }else if code == 202{
        error = "El usuario ya existe."
    }else if code == 200{
        error = "El usuario no puede estar vacío."
    }else if code == 125{
        error = "El email escrito no es correcto."
    }
    return error
}

