import UIKit


class UploadViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    
    private let currentUser = Account.shared
    private let networkManager = NetworkManager.shared
    private var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager.toAuthInImgur()
    }
    

    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            presentImagePicker()
        } else {
            guard imageView.image != nil else { return infoLabel.text = "Choose your image!"}
            uploadImageToImgur(image: selectedImage)
        }
    }
    
    
    
    private func uploadImageToImgur(image: UIImage) {
        let alertController = UIAlertController(title: "Wait", message: "Uploading...", preferredStyle: .alert)
        alertController.addActivityIndicator()
        present(alertController, animated: true)
        
        networkManager.uploadToImgur(image: image) {image in
            alertController.dismissActivityIndicator()
            DispatchQueue.main.async {
                self.setInfoGUI(imageData: image)
            }
        }
    }
    
    private func setInfoGUI(imageData: Image) {
        urlTextField.moveIn()
        urlTextField.text = imageData.link
        infoLabel.moveIn()
        infoLabel.text = """
            id: \(String(describing: imageData.id))
            width: \(String(describing: imageData.width))
            height: \(String(describing: imageData.height))
            """
    }
    
    
}

    
extension UploadViewController: UIImagePickerControllerDelegate {
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        self.selectedImage = image
        self.imageView.image = image
    }
}

extension UIAlertController {
    
    private struct ActivityIndicatorData {
        static var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    }
    
    func addActivityIndicator() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 40,height: 40)
        ActivityIndicatorData.activityIndicator.color = UIColor.blue
        ActivityIndicatorData.activityIndicator.startAnimating()
        vc.view.addSubview(ActivityIndicatorData.activityIndicator)
        self.setValue(vc, forKey: "contentViewController")
    }
    
    func dismissActivityIndicator() {
        DispatchQueue.main.async {
            ActivityIndicatorData.activityIndicator.stopAnimating()
            self.dismiss(animated: true)
        }
    }
}

extension UIView {
    
    func moveIn() {
        transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        alpha = 0.0
        
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.alpha = 1.0
        }
    }
}


