//
//  SK_ModeloRutas.swift
//  Seeker
//
//  Created by Jose Candilejo on 19/1/17.
//  Copyright © 2017 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import Foundation
import UIKit
import Parse

class SK_ModeloRutas: NSObject {
    
    //MARK: - VARIABLES LOCALES GLOBALES
    var usuarioRutaData : String?
    var fechaRutaData : String?
    var direccionInicialData : String?
    var latitudRutaData : Array<Double>?
    var longitudRutaData : Array<Double>?
    var nombreRutaData : String?
    
    
    //MARK: - INICIALIZADOR
    init(pUsuarioRutaData : String, pFechaRutaData : String, pDireccionInicialData : String, pLatitudRutaData : Array<Double>, pLongitudRutaData : Array<Double>, pNombreRutaData : String){
        self.usuarioRutaData = pUsuarioRutaData
        self.fechaRutaData = pFechaRutaData
        self.direccionInicialData = pDireccionInicialData
        self.latitudRutaData = pLatitudRutaData
        self.longitudRutaData = pLongitudRutaData
        self.nombreRutaData = pNombreRutaData
        
        super.init()
    }
    
}
