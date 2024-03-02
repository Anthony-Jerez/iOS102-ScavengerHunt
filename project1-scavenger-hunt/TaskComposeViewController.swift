//
//  TaskComposeViewController.swift
//  project1-scavenger-hunt
//
//  Created by Anthony Jerez on 3/2/24.
//

import UIKit

class TaskComposeViewController: UIViewController {
    
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    var onComposeTask: ((Task) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        guard let title = titleField.text,
              let description = descriptionField.text,
              !title.isEmpty,
              !description.isEmpty else {
            presentEmptyFieldsAlert()
            return
        }

        let task = Task(title: title, description: description)
        onComposeTask?(task)
        dismiss(animated: true)
    }
    
    private func presentEmptyFieldsAlert() {
        let alertController = UIAlertController(
            title: "Error performing action!",
            message: "Both title and description fields must be filled out",
            preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}
