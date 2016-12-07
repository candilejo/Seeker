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
    boton.layer.shadowColor = UIColor.darkGray.cgColor
    boton.layer.shadowOffset = CGSize(width: 3, height: 3)
    boton.layer.shadowRadius = 3
    boton.layer.shadowOpacity = 1.0
    if redondo == true{
        boton.layer.cornerRadius = boton.frame.width / 2
    }
}


//MARK: - CONFIGURACION DE LOS BORDES DE LAS IMAGENES
func configuraBordesImagenes(_ imagen: UIImageView, redondo: Bool, borde: Bool){
    imagen.clipsToBounds = true
    if redondo{
        imagen.layer.cornerRadius = imagen.frame.width/2
    }else{
        imagen.layer.cornerRadius = 10
    }
    if borde{
        imagen.layer.borderColor = UIColor.white.cgColor
        imagen.layer.borderWidth = 3
    }
}



//MARK: - CREA Y DEVUELVE UN ALERTCONTROLLER.
func showAlertVC (_ titleData : String, messageData : String) -> UIAlertController{
    let alertVC = UIAlertController(title: titleData, message: messageData, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    return alertVC
}



//MARK: - LIMPIA LOS CAMPOS.
func limpiaCampos(_ campos : [UITextField]){
    for campo in campos{
        campo.text = ""
    }
}

//MARK: - CAMBIA ESTADO DE UN BOTON.
func cambiaEstadoBTN(boton : UIButton, estado : Bool){
    // Establecemo el estado de boton.
    boton.isEnabled = estado
    
    // Si el estado es 'true' lo ponemos verde.
    if estado{
        boton.backgroundColor = UIColor(red:0.53, green:0.91, blue:0.45, alpha:1.0)
        
    }else{ //Sino gris.
        boton.backgroundColor = UIColor.lightGray
    }
}
