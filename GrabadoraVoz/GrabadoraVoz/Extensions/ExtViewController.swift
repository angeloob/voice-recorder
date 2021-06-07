//
//  ExtViewController.swift
//  GrabadoraVoz
//
//  Created by Angel Olvera on 05/06/21.
//

import UIKit

extension UIViewController {
    
    // MARK: Función que despliega una alerta
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func getDate() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let dateTimeString = formatter.string(from: currentDateTime)
        return dateTimeString
    }
    
    
    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String{
        var timeString = " "
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    func secondsToHours(seconds: Int) -> (Int, Int, Int){
        return ((seconds / 3600), ((seconds / 3600) / 60), ((seconds % 3600) % 60))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
