//
//  InformationViewController.swift
//  uc-access
//
//  Created by Patricio Lopez on 14-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import UIKit
import Static

let FORM = "https://almapp.github.io/uc-access/form"
let POLICY = "https://almapp.github.io/uc-access/policy"
let REPO = "https://github.com/almapp/uc-access-ios"

class InformationViewController: UITableViewController {
    var data: DataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.data = DataSource(tableView: self.tableView, sections: [

            Section(header: "¿Quieres que tú página aparezca acá?", rows: [
                Row(text: "Ir al formulario", selection: { [unowned self] in
                    self.goToURL(FORM)
                    }, accessory: Row.Accessory.DisclosureIndicator),
                ], footer: "También puedes avisar de algún error o problema"),

            Section(header: "Legal", rows: [
                Row(text: "Aplicación no oficial de la PUC", detailText: "Por y para la comunidad", cellClass: SubtitleCell.self),

                Row(text: "Política de privacidad", selection: { [unowned self] in
                    self.goToURL(POLICY)
                    }, accessory: Row.Accessory.DisclosureIndicator)
                ], footer: "Resumen: Tus datos son guardados de manera segura en tu dispositivo y no son enviados a ninguna fuente externa, solo a las páginas que explícitamente seleccionas y requieren inicio de sesión. Es de tu responsabilidad tener tu dispositivo con clave"),
            
            Section(header: "Aplicación", rows: [
                Row(text: "Versión", detailText: "1.0.0"),
                Row(text: "Licencia", detailText: "GPL-3.0"),
                Row(text: "Repositorio", detailText: "Github", selection: { [unowned self] in
                    self.goToURL(REPO)
                    }, accessory: Row.Accessory.DisclosureIndicator)
                ]),
            
            Section(header: "Autor", rows: [
                Row(text: "Patricio López Juri", detailText: "Ingeniería", cellClass: SubtitleCell.self),
                Row(text: "Email", detailText: "patricio@lopezjuri.com", selection: { [unowned self] in
                    self.sendEmail("patricio@lopezjuri.com")
                    }, accessory: Row.Accessory.DisclosureIndicator),
                Row(text: "URL", detailText: "lopezjuri.com", selection: { [unowned self] in
                    self.goToURL("https://lopezjuri.com")
                    }, accessory: Row.Accessory.DisclosureIndicator),
                ])
            ])
    }
    
    func goToURL(URL: String) {
        UIApplication.sharedApplication().openURL(NSURL(string: URL)!)
    }

    func sendEmail(email: String) {
        self.goToURL("mailto:\(email)")
    }
}
