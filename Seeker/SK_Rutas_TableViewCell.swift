//
//  SK_Rutas_TableViewCell.swift
//  Seeker
//
//  Created by Jose Candilejo on 19/1/17.
//  Copyright © 2017 Jose Candilejo. All rights reserved.
//

//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Rutas_TableViewCell: UITableViewCell {

    //MARK: - IBOUTLET
    @IBOutlet weak var myNombreRutaLBL: UILabel!
    @IBOutlet weak var myDireccionInicialLBL: UILabel!

    
    
    //MARK: - LIFE VC
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
