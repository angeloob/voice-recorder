//
//  LoginVC.swift
//  GrabadoraVoz
//
//  Created by Angel Olvera on 04/06/21.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTf.delegate = self
        passwordTf.delegate = self
        validateTextField()
        emailTf.addTarget(self, action: #selector(emailTextFieldDidChange), for: .editingChanged)
        passwordTf.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
        self.hideKeyboardWhenTappedAround()
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String, let provider = defaults.value(forKey: "provider") as? String{
            navigationController?.pushViewController(RecordVC(email: email, provider: ProviderType.init(rawValue: provider)!), animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
    
    private func validateTextField() {
        loginButton.ButtonisEnabled {
            if let email = email, !email.isEmpty, email.isEmail(), let password = password, !password.isEmpty { return true } else { return false }
        }
    }
    
    @objc private func emailTextFieldDidChange()  {
        email = emailTf.text
    }
    
    @objc private func passwordTextFieldDidChange()  {
        password = passwordTf.text
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if let email = emailTf.text, let password = passwordTf.text{
            Auth.auth().signIn(withEmail: email, password: password) {
                (result, error) in
                if let result = result, error == nil {
                    self.navigationController?.pushViewController(RecordVC(email: result.user.email!, provider: .basic), animated: true)
                }else {
                    let alertConroller = UIAlertController(title: "Error", message: "Se ha producido un error al iniciar sesión.", preferredStyle: .alert)
                    alertConroller.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(alertConroller, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let vc = RegisterVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    

}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            if loginButton.isEnabled{
                loginButtonTapped(loginButton!)
            }else{
                debugPrint("el botón está deshabilitado")
            }
        }
        
        return false
    }
}
