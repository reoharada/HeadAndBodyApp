//
//  ViewController.swift
//  HeadAndBodyDataGenerator
//
//  Created by REO HARADA on 2021/09/23.
//

import UIKit
import NCMB

class ViewController: UIViewController {
    
    @IBOutlet weak var humanListTableView: UITableView!
    @IBOutlet weak var averageHeightLabel: UILabel!
    @IBOutlet weak var averageBodyRateByHeadLabel: UILabel!
    @IBOutlet weak var maxHeightLabel: UILabel!
    @IBOutlet weak var minHeightLabel: UILabel!
    var refreshControl = UIRefreshControl()
    
    let cellSize = CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat(400))
    let baseFaceSize = CGFloat(40)
    let averageFaceParam = CGFloat(1.0)
    let averageNeckParam = CGFloat(0.3)
    let averageShoulderParam = CGFloat(0.45)
    let averageShoulderWidthParam = CGFloat(1.69)
    let averageUpperBodyParam = CGFloat(2.35)
    let averageLowerBodyParam = CGFloat(2.825)
    var faceParams = [(CGFloat, CGFloat)]()
    var neckParams = [CGFloat]()
    var shoulderParams = [CGFloat]()
    var shoulderWidthParams = [CGFloat]()
    var upperBodyParams = [CGFloat]()
    var lowerBodyParams = [CGFloat]()
    var humanViews = [HumanView]()
    
    let limit = 10000
    let randomLimit = CGFloat(2000)
    let randomRate = 0.0001

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(ViewController.reloadData), for: .valueChanged)
        humanListTableView.addSubview(refreshControl)
        
        generateData()
        humanListTableView.reloadData()
    }
    
    @objc func reloadData() {
        neckParams = []
        shoulderParams = []
        shoulderWidthParams = []
        upperBodyParams = []
        lowerBodyParams = []
        humanViews = []
        generateData()
        humanListTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func generateData() {
        for _ in 0..<limit {
            let randomW = CGFloat(arc4random()%UInt32(randomLimit))
            let randomH = CGFloat(arc4random()%UInt32(randomLimit))
            var random = (CGFloat(0), CGFloat(0))
            if randomW < randomLimit/2 {
                random.0 = averageFaceParam + (randomW - randomLimit/2)*randomRate
            } else {
                random.0 = averageFaceParam + randomW*randomRate
            }
            if randomH < randomLimit/2 {
                random.1 = averageFaceParam + (randomH - randomLimit/2)*randomRate
            } else {
                random.1 = averageFaceParam + randomH*randomRate
            }
            faceParams.append(random)
        }
        for _ in 0..<limit {
            let random = CGFloat(arc4random()%UInt32(randomLimit))
            if random < randomLimit/2 {
                neckParams.append(averageNeckParam + (random - randomLimit/2)*randomRate)
            } else {
                neckParams.append(averageNeckParam + random*randomRate)
            }
        }
        for _ in 0..<limit {
            let random = CGFloat(arc4random()%UInt32(randomLimit))
            if random < randomLimit/2 {
                shoulderParams.append(averageShoulderParam + (random - randomLimit/2)*randomRate)
            } else {
                shoulderParams.append(averageShoulderParam + random*randomRate)
            }
        }
        for _ in 0..<limit {
            let random = CGFloat(arc4random()%UInt32(randomLimit))
            if random < randomLimit/2 {
                shoulderWidthParams.append(averageShoulderWidthParam + (random - randomLimit/2)*randomRate)
            } else {
                shoulderWidthParams.append(averageShoulderWidthParam + random*randomRate)
            }
        }
        for _ in 0..<limit {
            let random = CGFloat(arc4random()%UInt32(randomLimit))
            if random < randomLimit/2 {
                upperBodyParams.append(averageUpperBodyParam + (random - randomLimit/2)*randomRate)
            } else {
                upperBodyParams.append(averageUpperBodyParam + random*randomRate)
            }
        }
        for _ in 0..<limit {
            let random = CGFloat(arc4random()%UInt32(randomLimit))
            if random < randomLimit/2 {
                lowerBodyParams.append(averageLowerBodyParam + (random - randomLimit/2)*randomRate)
            } else {
                lowerBodyParams.append(averageLowerBodyParam + random*randomRate)
            }
        }
        for i in 0..<limit {
            let faceSize = (baseFaceSize * faceParams[i].0, baseFaceSize * faceParams[i].1)
            let neckParamH = neckParams[i]
            let neckParamW = CGFloat(0.5)
            let shoulderParamH = shoulderParams[i]
            let shoulderParamW = shoulderWidthParams[i]
            let upperBodyParamH = upperBodyParams[i]
            let lowerBodyParamH = lowerBodyParams[i]
            let rect = CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height)
            let humanView = HumanView(frame: rect, faceSize: faceSize, neckParamH: neckParamH, neckParamW: neckParamW, shoulderParamH: shoulderParamH, shoulderParamW: shoulderParamW, upperBodyParamH: upperBodyParamH, lowerBodyParamH:  lowerBodyParamH)
            humanViews.append(humanView)
        }
        caluculateAverageAndMaxAndMin()
    }

    func caluculateAverageAndMaxAndMin() {
        var sumHeight = CGFloat(0)
        var sumBodyRateByHead = CGFloat(0)
        var maxHeight = CGFloat(0)
        var minHeight = CGFloat(300)
        humanViews.forEach {
            if $0.height < minHeight { minHeight = $0.height }
            if $0.height > maxHeight { maxHeight = $0.height }
            sumHeight = sumHeight + $0.height
            sumBodyRateByHead = sumBodyRateByHead + $0.bodyRateByHead
        }
        averageHeightLabel.text = "平均身長：\(sumHeight/CGFloat(humanViews.count))"
        averageBodyRateByHeadLabel.text = "平均頭身：\(sumBodyRateByHead/CGFloat(humanViews.count))"
        maxHeightLabel.text = "身長の最大値：\(maxHeight)"
        minHeightLabel.text = "身長の最小値：\(minHeight)"
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        let array = humanViews.map {
            [
                "height": $0.height,
                "body_rate_by_head": $0.bodyRateByHead,
                "left_year_point": $0.leftYearPoint.toDictionary(),
                "right_year_point": $0.rightYearPoint.toDictionary(),
                "jaw_point": $0.jawPoint.toDictionary(),
                "head_top_point": $0.headTopPoint.toDictionary(),
                "left_shoulder_point": $0.leftShoulderPoint.toDictionary(),
                "right_shoulder_point": $0.rightShoulderPoint.toDictionary()
            ]
        }
        guard let json = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) else { return }
        let fileName = "\(Int(Date().timeIntervalSince1970)).json"
        let file = NCMBFile(fileName: fileName)
        _ = file.save(data: json)
        let alert = UIAlertController(title: "データ保存が完了しました", message: "https://mbaas.api.nifcloud.com/2013-09-01/applications/vBxsqkwzR2pAfWC5/publicFiles/\(fileName)", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAlertAction)
        present(alert, animated: true, completion: nil)
    }
}

extension CGPoint {
    
    func toDictionary() -> [String:CGFloat] {
        return [
            "x": x,
            "y": y,
        ]
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return neckParams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HumanListTableViewCell
        let oldHumanView = cell.subviews.filter { $0 is HumanView }
        oldHumanView.first?.removeFromSuperview()
        let humanView = humanViews[indexPath.row]
        cell.addSubview(humanView)
        cell.heightLabel.text = "\(String(format: "%.3f", humanView.height))cm"
        cell.bodyRateByHeadLabel.text = "\(String(format: "%.3f", humanView.bodyRateByHead))頭身"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = tableView.dequeueReusableCell(withIdentifier: "cell")?.frame.height {
            return height
        }
        return CGFloat(0)
    }
    
}

class HumanView: UIView {
    
    var height = CGFloat(0)
    var bodyRateByHead = CGFloat(0)
    
    let averageHeight = CGFloat(159.9825)
    let averageFaceHeight = CGFloat(22.4475)
    
    var leftYearPoint = CGPoint(x: 0, y: 0)
    var rightYearPoint = CGPoint(x: 0, y: 0)
    var jawPoint = CGPoint(x: 0, y: 0)
    var headTopPoint = CGPoint(x: 0, y: 0)
    var leftShoulderPoint = CGPoint(x: 0, y: 0)
    var rightShoulderPoint = CGPoint(x: 0, y: 0)
    
    init(frame: CGRect, faceSize: (CGFloat, CGFloat), neckParamH: CGFloat, neckParamW: CGFloat, shoulderParamH: CGFloat, shoulderParamW:CGFloat, upperBodyParamH:
        CGFloat, lowerBodyParamH: CGFloat) {
        
        super.init(frame: frame)
        
        let facePosX = CGFloat(frame.size.width/2-faceSize.0/2)
        let facePosY = CGFloat(0)
        let faceRect = CGRect(x: facePosX, y: facePosY, width: faceSize.0, height: faceSize.1)
        let faceView = FaceView(frame: faceRect, color: UIColor.red)
        addSubview(faceView)
        
        let neckHeight = faceSize.1 * neckParamH
        let neckWidth = faceSize.0 * neckParamW
        let neckRect = CGRect(x: facePosX - neckWidth/2 + faceSize.0/2, y: facePosY + faceSize.1, width: neckWidth, height: neckHeight)
        let neckView = BodyView(frame: neckRect, color: UIColor.green)
        addSubview(neckView)
        
        let shoulderHeight = faceSize.1 * shoulderParamH
        let shoulderWidth = faceSize.0 * shoulderParamW
        let shoulderRect = CGRect(x: facePosX - shoulderWidth/2 + faceSize.0/2, y: facePosY + faceSize.1 + neckHeight, width: shoulderWidth, height: shoulderHeight)
        let shoulderView = BodyView(frame: shoulderRect, color: UIColor.blue)
        addSubview(shoulderView)
        
        let upperBodyHeight = faceSize.1 * upperBodyParamH
        let upperBodyRect = CGRect(x: facePosX - shoulderWidth/2 + faceSize.0/2, y: facePosY + faceSize.1 + neckHeight + shoulderHeight, width: shoulderWidth, height: upperBodyHeight)
        let upperBodyView = BodyView(frame: upperBodyRect, color: UIColor.brown)
        addSubview(upperBodyView)
        
        let lowerBodyHeight = faceSize.1 * lowerBodyParamH
        let lowerBodyRect = CGRect(x: facePosX - shoulderWidth/2 + faceSize.0/2, y: facePosY + faceSize.1 + neckHeight + shoulderHeight + upperBodyHeight, width: shoulderWidth, height: lowerBodyHeight)
        let lowerBodyView = BodyView(frame: lowerBodyRect, color: UIColor.orange)
        addSubview(lowerBodyView)
        
        leftYearPoint = CGPoint(x: faceView.frame.minX, y: faceView.frame.midY)
        rightYearPoint = CGPoint(x: faceView.frame.maxX, y: faceView.frame.midY)
        jawPoint = CGPoint(x: faceView.frame.midX, y: faceView.frame.maxY)
        headTopPoint = CGPoint(x: faceView.frame.midX, y: faceView.frame.minY)
        leftShoulderPoint = CGPoint(x: shoulderView.frame.minX, y: shoulderView.frame.midY)
        rightShoulderPoint = CGPoint(x: shoulderView.frame.maxX, y: shoulderView.frame.midY)
                
        let sumHeight = faceSize.1+neckHeight+shoulderHeight+upperBodyHeight+lowerBodyHeight
        let rate = averageFaceHeight/faceSize.1
        self.frame.origin.y = frame.size.height - sumHeight
        height = sumHeight * rate
        bodyRateByHead = sumHeight/faceSize.1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class FaceView: UIView {
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        layer.cornerRadius = frame.size.width/2
        backgroundColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class BodyView: UIView {

    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        backgroundColor = color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class HumanListTableViewCell: UITableViewCell {
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bodyRateByHeadLabel: UILabel!
}

