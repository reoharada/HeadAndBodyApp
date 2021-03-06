//
//  ResultViewController.swift
//  HeadAndBodyDataGenerator
//
//  Created by REO HARADA on 2021/09/25.
//

import UIKit

extension CGPoint {
    func distance(point: CGPoint) -> Double {
        let dx = Double(x - point.x)
        let dy = Double(y - point.y)
        return sqrt(dx*dx + dy*dy)
    }
}

class ResultViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultTableView: UITableView!
    
    var bodyData = BodyData()
    var faceImage: UIImage!
    var bodyRateByHead = CGFloat(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultLabel.isHidden = true;
        
        fetchRequest { value in
            DispatchQueue.main.async {
                print(value)
                print("\(String(format: "%.2f", value))頭身！")
                self.resultLabel.text = "\(String(format: "%.2f", value))頭身！"
                self.resultLabel.isHidden = false
                self.bodyRateByHead = value
                self.resultTableView.reloadData()
                self.addBodyView(value: value)
            }
        }
        
    }

    func fetchRequest(handler: ((_ value: CGFloat) -> Void)? ) {
        
        print(bodyData)
        print("頭から顎")
        let distanceFromHeadToJaw = bodyData.headTopPos.distance(point: bodyData.jawPos)
        print("肩幅")
        let distanceShoulders = bodyData.leftShoulderPos.distance(point: bodyData.rightShoulderPos)
        print("耳の間")
        let distanceEars = bodyData.leftEarPos.distance(point: bodyData.rightEarPos)
        print("耳から顎")
        let distanceFromLeftEraToJaw = bodyData.leftEarPos.distance(point: bodyData.jawPos)
        let distanceFromRightEraToJaw = bodyData.rightEarPos.distance(point: bodyData.jawPos)
        guard let url = URL(string: "http://35.75.4.190") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params: [String:Any] = [
            "distance_from_head_to_jaw": distanceFromHeadToJaw,
            "distance_shoulders": distanceShoulders,
            "distance_ears": distanceEars,
            "distance_from_left_era_to_jaw": distanceFromLeftEraToJaw,
            "distance_from_right_era_to_jaw": distanceFromRightEraToJaw
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed)
        } catch {
            print("パラメータ生成エラー")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { LoadingWindowManager.share.hide() }
            if error != nil { return print(error) }
            guard let d = data else { return }
            guard let result = try? JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed) as? [String:Any] else { return }
            guard let headAndBodyResult = result["head_and_boody_result"] as? Double else { return }
            guard let nextAction = handler else { return }
            nextAction(headAndBodyResult)
        }
        LoadingWindowManager.share.show()
        task.resume()
        
    }
    
    func drawFaceView(value: CGFloat) {
        
        let height = view.frame.size.height - resultLabel.frame.size.height
        let rate = Int(value)
        let size = height/CGFloat(rate)
        for i in 0..<rate+1 {
            let rect = CGRect(x: UIScreen.main.bounds.size.width/2, y: resultLabel.frame.size.height + CGFloat(i)*size, width: size, height: size)
            print(rect)
            let imageView = UIImageView(frame: rect)
            imageView.image = faceImage
            imageView.contentMode = .scaleAspectFill
            view.addSubview(imageView)
        }
        
    }
    
    func addBodyView(value: CGFloat) {
        
        let imageView = UIImageView(image: UIImage(named: "body"))
        imageView.contentMode = .scaleToFill
        let height = resultTableView.frame.size.height / CGFloat(Int(value)+1) * CGFloat(Int(value)) + resultTableView.frame.size.height / CGFloat(Int(value)+1) * (value - CGFloat(Int(value)))
        let rect = CGRect(x: 32.0, y: 0, width: resultTableView.frame.size.width/2, height: height)
        imageView.frame = rect
        resultTableView.addSubview(imageView)
        
    }
}

extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Int(bodyRateByHead) == 0 { return 0 }
        return Int(bodyRateByHead) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultImageTableViewCell
        
        cell.subviews.forEach { if $0 is UIImageView { $0.removeFromSuperview() } }
        
        let imgView = UIImageView(image: faceImage)
        imgView.contentMode = .scaleAspectFill
        let size = tableView.frame.size.height / CGFloat(Int(bodyRateByHead))
        imgView.frame = CGRect(x: tableView.frame.size.width - size*3/2, y: 0, width: size, height: size)
        cell.addSubview(imgView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < Int(bodyRateByHead) {
            return tableView.frame.size.height / CGFloat(Int(bodyRateByHead)+1)
        }
        let rate = bodyRateByHead - CGFloat(Int(bodyRateByHead))
        return tableView.frame.size.height / CGFloat(Int(bodyRateByHead)+1) * rate
    }
    
}

class LoadingWindowManager {
    
    static let share = LoadingWindowManager()

    var window: UIWindow!
    var activityIndicatorView: UIActivityIndicatorView!
    let blackColorWithHalfAlpha = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
    
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive || $0.activationState == .unattached }) as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window.backgroundColor = blackColorWithHalfAlpha

        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
        activityIndicatorView.style = .large
        activityIndicatorView.color = UIColor.blue
        window.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        window.makeKeyAndVisible()
    }
    
    func hide() {
        guard let mainWindow = UIApplication.shared.windows.first(where: { $0 != window }) else { return }
        mainWindow.makeKeyAndVisible()
    }
    
}

class ResultImageTableViewCell: UITableViewCell {
}
