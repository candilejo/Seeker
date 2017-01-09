//
//  SK_ModeloClientes.swift
//  Seeker
//
//  Created by Jose Candilejo on 5/1/17.
//  Copyright © 2017 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import Foundation
import UIKit
import Parse

class SK_ModeloClientes: NSObject {
    
    //MARK: - VARIABLES LOCALES GLOBALES
    var telefonoClienteData : String?
    var direccionClienteData : String?
    var imagenClienteData : PFFile?
    
    
    //MARK: - INICIALIZADOR
    init(pTelefonoClienteData : String, pDireccionClienteData : String, pImagenClienteData : PFFile){
        self.telefonoClienteData = pTelefonoClienteData
        self.direccionClienteData = pDireccionClienteData
        self.imagenClienteData = pImagenClienteData
        
        super.init()
    }
    
}
