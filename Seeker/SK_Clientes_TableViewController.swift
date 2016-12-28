//
//  SK_Clientes_TableViewController.swift
//  Seeker
//
//  Created by Jose Candilejo on 28/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse

class SK_Clientes_TableViewController: UITableViewController {

    
    //MARK: - VARIABLES LOCALES GLOBALES
    var refreshTableView = UIRefreshControl()
    
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshTableView.attributedTitle = NSAttributedString(string: "Arrastra para recargar.")
        refreshTableView.addTarget(self, action: #selector(SK_Clientes_TableViewController.refreshVC), for: .valueChanged)
    }

    
    //MARK: - SE EJECUTA AL RECIBIR UNA ALERTA DE MEMORIA
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK: -------------------------- UTILIDADES --------------------------
    //REFRESH CONTROLLER
    func refreshVC(){
        //llamadaUsuariosFromParse()
        refreshTableView.endRefreshing()
    }
    
    
    //MARK: -------------------------- CONFIGURACION DE LA TABLA --------------------------
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let clientes = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SK_Clientes_Celda_TableViewCell

        // Configure the cell...

        return clientes
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }

}
