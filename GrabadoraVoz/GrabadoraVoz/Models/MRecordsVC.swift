//
//  MRecordsVC.swift
//  GrabadoraVoz
//
//  Created by Angel Olvera on 06/06/21.
//

import Foundation

enum ProviderType: String {
    case basic
}

struct urlDownloaded {
    var url : String?
    var date: String?
    var time: String?
    
    init(url: String, date: String, time: String) {
        self.url = url
        self.date = date
        self.time = time
    }
}
