//
//  SK_Clientes_Celda_TableViewCell.swift
//  Seeker
//
//  Created by Jose Candilejo on 28/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Clientes_Celda_TableViewCell: UITableViewCell {

    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myImagenClienteIV: UIImageView!
    @IBOutlet weak var myNumeroTelefonoClienteLBL: UILabel!
    @IBOutlet weak var myDireccionClienteLBL: UILabel!
    
    
    //MARK: - LIFE VC
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configuramos los bordes de myImagenClienteIV.
        configuraBordesImagenes(myImagenClienteIV, redondo: true, borde: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
