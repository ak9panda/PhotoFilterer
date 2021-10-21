//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit
import PhotosUI

class MainViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var imgOriginal: UIImageView!
    @IBOutlet var imgFiltered: UIImageView!
    @IBOutlet var valueSlider: UISlider!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var lblCompareStatus: UILabel!
    
    @IBOutlet weak var btnFilters: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnCompare: UIButton!
    
    var effectView: EffectsView = EffectsView()
    var filteredImage: UIImage = UIImage()
    var selectedFilterIndex: Int = 0
    var sliderChangeValue: Float = 100.0
    let loading = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        effectView.effectDelegate = self
        lblCompareStatus.isHidden = true
        btnFiltersActive(status: false)
        btnEditActive(status: false)
        btnCompareActive(status: false)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.numberOfTouchesRequired = 1
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.imgFiltered.addGestureRecognizer(lpgr)
        self.imgFiltered.isUserInteractionEnabled = true
        
        loading.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        loading.activityIndicatorViewStyle = .white
        loading.hidesWhenStopped = true
    }
    
    func btnFiltersActive(status: Bool) {
        btnFilters.isEnabled = status
        if status {
            btnFilters.tintColor = .black
        }else {
            btnFilters.tintColor = .lightGray
        }
    }
    
    func btnEditActive(status: Bool) {
        btnEdit.isEnabled = status
        if status {
            btnEdit.tintColor = .black
        }else {
            btnEdit.tintColor = .lightGray
        }
    }
    
    func btnCompareActive(status: Bool) {
        btnCompare.isEnabled = status
        if status {
            btnCompare.tintColor = .black
        }else {
            btnCompare.tintColor = .lightGray
        }
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .began {
            compareImagesToggle(status: false)
        }else if gestureReconizer.state == .ended {
            compareImagesToggle(status: true)
        }
    }
    
    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        if imgFiltered.image != nil {
            let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imgFiltered.image!], applicationActivities: nil)
            present(activityController, animated: true, completion: nil)
        }else {
            self.showAlert(title: "Error", message: "Please edit photo first")
        }
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Select new photo", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Open Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose from Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.isSelected) {
            hideEffectView()
            sender.backgroundColor = .white
            sender.isSelected = false
        } else {
            showEffectView()
            sender.backgroundColor = .lightGray
            sender.isSelected = true
        }
    }
    
    // MARK: Edit Menu
    @IBAction func onEdit(_ sender: UIButton) {
        if (sender.isSelected) {
            hideIntensitySlider()
            sender.backgroundColor = .white
            sender.isSelected = false
        }else {
            showIntensitySlider()
            sender.backgroundColor = .lightGray
            sender.isSelected = true
        }
    }
    
    // MARK: Compare Menu
    @IBAction func onCompare(_ sender: UIButton) {
        compareImagesToggle(status: sender.isSelected)
    }
    
    func compareImagesToggle(status: Bool) {
        if (status) {
            self.imgFiltered.isHidden = false
            self.lblCompareStatus.isHidden = true
            self.btnCompare.backgroundColor = .white
            self.btnCompare.isSelected = false
        }else {
            self.imgFiltered.isHidden = true
            self.lblCompareStatus.isHidden = false
            self.btnCompare.backgroundColor = .lightGray
            self.btnCompare.isSelected = true
        }
    }
    
    @IBAction func onSliderChanged(_ sender: UISlider) {
        self.sliderChangeValue = sender.value
        DispatchQueue.main.async {
            self.selectEffect(by: self.selectedFilterIndex)
        }
    }
    
    @IBAction func onTouchBtnCancel(_ sender: Any) {
        imgOriginal.image = nil
        imgFiltered.image = nil
        lblCompareStatus.isHidden = true
        btnFiltersActive(status: false)
        btnEditActive(status: false)
        btnCompareActive(status: false)
        hideEffectView()
        hideIntensitySlider()
    }
    
    // MARK: Effect View
    func showEffectView() {
        view.addSubview(effectView)
        
        effectView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = effectView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor)
        let leftConstraint = effectView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = effectView.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = effectView.heightAnchor.constraint(equalToConstant: 50)
        let widthConstraint = effectView.widthAnchor.constraint(equalToConstant: self.view.frame.width)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint, widthConstraint])
        view.layoutIfNeeded()
        
        self.effectView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.effectView.alpha = 1.0
        }
    }

    func hideEffectView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.effectView.alpha = 0
            }) { completed in
                if completed == true {
                    self.effectView.removeFromSuperview()
                }
        }
    }
    
    // MARK: Intensity Slider
    func showIntensitySlider() {
        
        valueSlider.setValue(sliderChangeValue, animated: true)
        view.addSubview(valueSlider)
        
        valueSlider.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = valueSlider.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -60)
        let leftConstraint = valueSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50)
        let rightConstraint = valueSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50)
        
        let heightConstraint = valueSlider.heightAnchor.constraint(equalToConstant: 30)
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        view.layoutIfNeeded()
        
        self.valueSlider.alpha = 0
        UIView.animate(withDuration: 0.03) {
            self.valueSlider.alpha = 1.0
        }
    }
    
    func hideIntensitySlider() {
        UIView.animate(withDuration: 0.3) {
            self.valueSlider.alpha = 0
        } completion: { completed in
            if completed == true {
                self.valueSlider.removeFromSuperview()
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoading() {
        view.addSubview(loading)
        loading.startAnimating()
        
        loading.translatesAutoresizingMaskIntoConstraints = false
        let centerX = loading.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let centerY = loading.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        NSLayoutConstraint.activate([centerX, centerY])
        view.layoutIfNeeded()
    }
    
    func hideLoading() {
        loading.stopAnimating()
    }
}

// MARK:- extenstion for delegates
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoEffectsDelegate, PHPickerViewControllerDelegate {
    
    func selectEffect(by index: Int) {
        self.showLoading()
        self.selectedFilterIndex = index
        var intensity: Float = 0.0
        if selectedFilterIndex == 0 {
            intensity = sliderChangeValue/20
        }else if selectedFilterIndex == 1 {
            intensity = ((sliderChangeValue/100) * (256)) - 128
        }
        
        ImageProcessor.shared.addEffect(index: index, image: self.imgOriginal.image!,intensity: intensity) { [weak self] returnImg in
            DispatchQueue.main.async {
                UIView.transition(with: (self?.imgFiltered)!, duration: 0.4, options: .transitionCrossDissolve) {
                    self?.imgFiltered.image = returnImg
                } completion: { completed in
                    self?.hideLoading()
                    if self?.selectedFilterIndex == 0 || self?.selectedFilterIndex == 1 {
                        self?.btnEditActive(status: true)
                    }else {
                        self?.btnEditActive(status: false)
                    }
                    self?.btnCompareActive(status: true)
                    print("adding effect and animated: ", completed)
                }
            }
        }
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        // Request permission to access photo library
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
                DispatchQueue.main.async { [unowned self] in
                    showUI(for: status)
                }
            }
        } else {
            photoPicker()
        }
    }
    
    @available(iOS 14, *)
    func showUI(for status: PHAuthorizationStatus) {
        switch status {
        case .authorized:
            newPhotoPicker()

        case .limited:
            newPhotoPicker()

        case .restricted:
            newPhotoPicker()

        case .denied:
            newPhotoPicker()

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }
    
    // MARK: Photo Picker
    func photoPicker () {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .photoLibrary
        present(cameraPicker, animated: true, completion: nil)
    }
    
    // UIImagePickerControllerDelegate
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgOriginal.image = image
            self.btnFiltersActive(status: true)
        }
    }
    
    private func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Photo Picker for iOS14
    @available(iOS 14, *)
    func newPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        // Create instance of PHPickerViewController
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Get the reference of itemProvider from results
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self)
            { [weak self]  image, error in
                DispatchQueue.main.async {
                    guard self != nil else { return }
                  if let image = image as? UIImage {
                        picker.dismiss(animated: true) {
                            self?.imgOriginal.image = image
                            self?.btnFiltersActive(status: true)
                        }
                    }
                }
            }
        }
    }
}
