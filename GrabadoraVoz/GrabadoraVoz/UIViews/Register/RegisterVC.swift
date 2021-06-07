//
//  RegisterVC.swift
//  GrabadoraVoz
//
//  Created by Angel Olvera on 05/06/21.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var confirmPasswordTf: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTf.delegate = self
        passwordTf.delegate = self
        confirmPasswordTf.delegate = self
        validateTextField()
        emailTf.addTarget(self, action: #selector(emailTextFieldDidChange), for: .editingChanged)
        passwordTf.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
        confirmPasswordTf.addTarget(self, action: #selector(confirmPasswordTextFieldDidChange), for: .editingChanged)
        self.hideKeyboardWhenTappedAround()
    }

    private var email: String? {
        didSet {
            validateTextField()
        }
    }

    private var password: String? {
        didSet {
            validateTextField()
        }
    }

    private var confirmPassword: String? {
        didSet {
            validateTextField()
        }
    }

    private func validateTextField() {
        registerButton.ButtonisEnabled {
            if let email = email, !email.isEmpty, email.isEmail(), let password = password, !password.isEmpty, let confirmPassword = confirmPassword, !confirmPassword.isEmpty { return true } else { return false }
        }
    }

    @objc private func emailTextFieldDidChange()  {
        email = emailTf.text
    }

    @objc private func passwordTextFieldDidChange()  {
        password = passwordTf.text
    }

    @objc private func confirmPasswordTextFieldDidChange()  {
        confirmPassword = confirmPasswordTf.text
    }

    @IBAction func registerButtonTapped(_ sender: Any) {
        if confirmPassword == password{
            if let email = emailTf.text, let password = passwordTf.text{
                Auth.auth().createUser(withEmail: email, password: password) {
                    (result, error) in
                    if let result = result, error == nil {
                        self.navigationController?.pushViewController(RecordVC(email: result.user.email!, provider: .basic), animated: true)
                    }else {
                        let alertConroller = UIAlertController(title: "Error", message: "Se ha producido un error registrando el usuario.", preferredStyle: .alert)
                        alertConroller.addAction(UIAlertAction(title: "Aceptar", style: .default))
                        self.present(alertConroller, animated: true, completion: nil)
                    }
                }
            }
        }else{
            let alertConroller = UIAlertController(title: "Error", message: "Las contraseñas no coinciden", preferredStyle: .alert)
            alertConroller.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alertConroller, animated: true, completion: nil)
        }
        
    }

    @IBAction func backButtonTapped(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
        let vcs = [self.navigationController!.viewControllers[0]]
        self.navigationController?.setViewControllers(vcs, animated: true)
    }
}

extension RegisterVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            if registerButton.isEnabled{
                registerButtonTapped(registerButton!)
            }else{
                debugPrint("el botón está deshabilitado")
            }
        }
        
        return false
    }
}
