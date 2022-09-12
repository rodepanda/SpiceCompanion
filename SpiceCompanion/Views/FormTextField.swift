//
//  FormTextField.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-04.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// A single text field within a form that implements common functionality.
class FormTextField: UITextField {

    /// The next text field below this text field in the form, if any.
    @IBOutlet private weak var nextTextField: UITextField?

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        delegate = self

        if nextTextField != nil {
            returnKeyType = .next
        }
        else {
            returnKeyType = .done
        }
    }
}

// MARK: - UITextFieldDelegate

extension FormTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = nextTextField {
            nextTextField.becomeFirstResponder()
        }
        else {
            resignFirstResponder()
        }

        return true
    }
}
