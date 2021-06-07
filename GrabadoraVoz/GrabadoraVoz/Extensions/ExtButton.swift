//
//  ExtButton.swift
//  GrabadoraVoz
//
//  Created by Angel Olvera on 04/06/21.
//

import UIKit

extension UIButton{
    func ButtonisEnabled(validation: () -> Bool) {
        if validation(){
            self.backgroundColor = UIColor.init(named: "buttonEnabled")
            self.isEnabled = true
        }else{
            self.backgroundColor = UIColor.init(named: "buttonDisabled")
            self.isEnabled = false
        }
    }
}

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
