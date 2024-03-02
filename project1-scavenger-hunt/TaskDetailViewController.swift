//
//  TaskDetailViewController.swift
//  project1-scavenger-hunt
//
//  Created by Anthony Jerez on 3/1/24.
//

import UIKit
import MapKit
import PhotosUI

class TaskDetailViewController: UIViewController {
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var attachPhotoButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(TaskAnnotationView.self, forAnnotationViewWithReuseIdentifier: TaskAnnotationView.identifier)
        // set up map delegate
        mapView.delegate = self
        mapView.layer.cornerRadius = 12
        updateUI()
        updateMapView()
    }

    private func updateUI() {
        titleLabel.text = task.title
        descriptionLabel.text = task.description

        let completedImage = UIImage(systemName: task.isComplete ? "circle.inset.filled" : "circle")
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedLabel.text = task.isComplete ? "Complete" : "Incomplete"

        let color: UIColor = task.isComplete ? .systemBlue : .tertiaryLabel
        completedImageView.tintColor = color
        completedLabel.textColor = color

        mapView.isHidden = !task.isComplete
        attachPhotoButton.isHidden = task.isComplete
    }
    
    @IBAction func didTapPhotoAttachButton(_ sender: UIButton) {
        
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            // prompt user for access to photo library
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    DispatchQueue.main.async {
                        self?.presentGoToSettingsAlert()
                    }
                }
            }
        } else {
            presentImagePicker() // display photo picker
        }
    }
    
    
    private func presentImagePicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images // only allow picker to consider images
        config.preferredAssetRepresentationMode = .current
        // only allow 1 image to be selected
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        // present picker
        present(picker, animated: true)

    }

    func updateMapView() {
        guard let imageLocation = task.imageLocation else { return }
        let coordinate = imageLocation.coordinate
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

extension TaskDetailViewController {
    
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a scavenger task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Error Performing Action",
            message: "\(error?.localizedDescription ?? "Please try again!")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}

extension TaskDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let result = results.first
        
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }
        guard let provider = result?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error = error {
              DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
            
            }
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async { [weak self] in
                self?.task.set(image, with: location)
                self?.updateUI()
                self?.updateMapView()
            }
        }
    }
}

extension TaskDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TaskAnnotationView.identifier, for: annotation) as? TaskAnnotationView else {
            fatalError("Unable to dequeue TaskAnnotationView")
        }
        annotationView.configure(with: task.image)
        return annotationView
    }
}

