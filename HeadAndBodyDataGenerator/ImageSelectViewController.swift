//
//  ImageSelectViewController.swift
//  HeadAndBodyDataGenerator
//
//  Created by REO HARADA on 2021/09/25.
//

import UIKit
import Photos
import ImageDetect

class ImageSelectViewController: UIViewController {

    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    
    var operationDataText = [
        "頭頂部の位置をタップしてください",
        "左耳の位置をタップしてください",
        "右耳の位置をタップしてください",
        "顎（あご）の位置をタップしてください",
        "肩の左端をタップしてください",
        "肩の右端をタップしてください",
    ]
    var operationStatus = 0
    
    var bodyData = BodyData()
    var faceImage: UIImage!
    
    func initData() {
        undoButton.isEnabled = false
        selectedImageView.isHidden = true
        operationLabel.isHidden = true
        selectImageButton.isHidden = false
        titleLabel.isHidden = false
        bodyData = BodyData()
        operationStatus = 0
        operationLabel.text = self.operationDataText[self.operationStatus]
        selectedImageView.subviews.forEach {
            if $0 is CircleView { $0.removeFromSuperview() }
        }
        faceImage = nil
        selectedImageView.image = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initData()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "頭身を予測しますか？", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "はい", style: .default) { Action in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
            vc.bodyData = self.bodyData
            vc.faceImage = self.faceImage
            self.show(vc, sender: nil)
        }
        let noAction = UIAlertAction(title: "いいえ", style: .cancel) { action in
            self.operationStatus = 0
            self.operationLabel.text = self.operationDataText[self.operationStatus]
            self.selectedImageView.subviews.forEach {
                if $0 is CircleView { $0.removeFromSuperview() }
            }
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showNotFoundFaceAlert() {
        let alert = UIAlertController(title: "エラー", message: "顔が検出されませんでした、または顔が複数検出されました、一人で写ってるの写真を活用ください", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "OK", style: .default) { Action in self.initData() }
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapSelectImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func tapUndoButton(_ sender: Any) {
        if operationStatus == 0 {
            initData()
            return
        }
        operationStatus = operationStatus - 1
        operationLabel.text = self.operationDataText[self.operationStatus]
        selectedImageView.subviews.last?.removeFromSuperview()
    }
    
}

extension ImageSelectViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let pos = touches.first?.location(in: selectedImageView) {
            if pos.x * pos.y < 0 { return }
            undoButton.isEnabled = true
            let size = CGFloat(25)
            let rect = CGRect(x: pos.x-size/2, y: pos.y-size/2, width: size, height: size)
            let circleView = CircleView(frame: rect)
            switch operationStatus {
            case 0: bodyData.headTopPos = circleView.center
            case 1: bodyData.leftEarPos = circleView.center
            case 2: bodyData.rightEarPos = circleView.center
            case 3: bodyData.jawPos = circleView.center
            case 4: bodyData.leftShoulderPos = circleView.center
            default: bodyData.rightShoulderPos = circleView.center
            }
            selectedImageView.addSubview(circleView)
            if operationDataText.count - 1 == operationStatus {
                showAlert()
                return
            }
            operationStatus = operationStatus + 1
            operationLabel.text = operationDataText[operationStatus]
        }
    }
    
}

extension ImageSelectViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            img.detector.crop(type: .face) { [weak self] result in
                switch result {
                case .success(let imgs):
                    self!.undoButton.isEnabled = true
                    self!.selectImageButton.isHidden = true
                    self!.titleLabel.isHidden = true
                    self!.operationLabel.isHidden = false
                    self!.selectedImageView.isHidden = false
                    self!.faceImage = imgs.first
                    self!.selectedImageView.image = img
                    self!.operationLabel.text = self!.operationDataText[self!.operationStatus]
                case .failure(let error):
                    print(error)
                    self!.showNotFoundFaceAlert()
                case .notFound:
                    print("Not Found")
                    self!.showNotFoundFaceAlert()
                }
            }
        }
    }
    
}

class CircleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = frame.size.width/2
        backgroundColor = UIColor(displayP3Red: 255/255, green: 62/255, blue: 106/255, alpha: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class BodyData {
    var headTopPos: CGPoint!
    var leftEarPos: CGPoint!
    var rightEarPos: CGPoint!
    var jawPos: CGPoint!
    var leftShoulderPos: CGPoint!
    var rightShoulderPos: CGPoint!
}
