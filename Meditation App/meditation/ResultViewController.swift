
import UIKit
import RealmSwift
import GoogleMobileAds

class resultSet: Object {


    dynamic var day: String = ""
    dynamic var time: Int = 0
    dynamic var past: Int = 0
    dynamic var future: Int = 0
}


class ResultViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pastLabel: UILabel!
    @IBOutlet weak var futureLabel: UILabel!
    
    var timeCount: Int = 0
    var pastCount: Int = 0
    var futureCount: Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Admob
                var bannerView: GADBannerView = GADBannerView()
                bannerView = GADBannerView(adSize:kGADAdSizeBanner)
                bannerView.frame.origin = CGPoint(x:0, y:10)
                bannerView.frame.size = CGSize(width:self.view.frame.width, height:bannerView.frame.height)
        
                bannerView.adUnitID = "ca-app-pub-8406329207608644/6752340415"
                bannerView.delegate = self as? GADBannerViewDelegate
                bannerView.rootViewController = self
                let gadRequest:GADRequest = GADRequest()
        
                bannerView.load(gadRequest)
                self.view.addSubview(bannerView)

        
        
        backButton.setTitle(NSLocalizedString("end", comment: ""), for: .normal)
        
        //背景をグラデーション化
        gradateBackground()
        
        backButton.backgroundColor = self.UIColorFromRGB(rgbValue: 0x194F48)
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 10.0
        
        //テキスト
        let meditationStr: String = NSLocalizedString("meditation", comment: "")
        let pastStr: String = NSLocalizedString("past", comment: "")
        let futureStr: String = NSLocalizedString("future", comment: "")
        let hourStr: String = NSLocalizedString("hour", comment: "")
        let minutesStr: String = NSLocalizedString("minutes", comment: "")
        let secondsStr: String = NSLocalizedString("seconds", comment: "")
        let timesStr: String = NSLocalizedString("times", comment: "")
        
        
        
        
        
        //秒から換算
        if( timeCount < 60 ){
            timeLabel.text = meditationStr + "  :  " + String(timeCount) + " " + secondsStr
        } else if( timeCount < 3600 ){
            let minutes = timeCount / 60
            timeLabel.text = meditationStr + "  :  " + String(minutes) + " " + minutesStr
        } else {
            let hour = timeCount / 3600
            let minutes = timeCount % 3600 / 60
            timeLabel.text = meditationStr + "  :  " + String(hour) + " " + hourStr + "  " + String(minutes) + "分"
        }

        timeLabel.sizeToFit()
        pastLabel.text = pastStr + "  :  " + String(pastCount) + "  " + timesStr
        pastLabel.sizeToFit()
        futureLabel.text = futureStr + "  :  " + String(futureCount) + "  " + timesStr
        futureLabel.sizeToFit()
        
        
        
        //RealmSwiftの処理
        let config = Realm.Configuration(schemaVersion: 2)
        let realm = try! Realm(configuration: config)
        let resultData = resultSet()
        
        // 現在日時の取得
        let now = NSDate()
        let dateFormatter = DateFormatter()
        
        /////
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        
//        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        
        //データを入れる
        resultData.day = dateFormatter.string(from: now as Date)
        resultData.time = timeCount
        resultData.past = pastCount
        resultData.future = futureCount
        
        //データを保存
        try! realm.write() {
            realm.add(resultData)
        }
    }
    
    //UIntに16進で数値をいれるとUIColorが戻る関数
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func gradateBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        let color_1 = UIColor(red: 0.0, green:0.0, blue:0.5, alpha:1.0).cgColor
        let color_2 = UIColor(red: 0.0, green:0.0, blue:1.0, alpha:1.0).cgColor
        let color_3 = UIColor(red: 0.0, green:0.0, blue:0.5, alpha:1.0).cgColor
        gradient.colors = [color_1, color_2, color_3]
        
        let position_1 = NSNumber(value: 0.0 as Float)
        let position_2 = NSNumber(value: 0.5 as Float)
        let position_3 = NSNumber(value: 1.0 as Float)
        
        gradient.startPoint = CGPoint(x:0.0, y:0.0)
        gradient.endPoint = CGPoint(x:0.0, y:1.0)
        gradient.locations = [position_1, position_2, position_3]
        
        self.view.layer.insertSublayer(gradient, at:0)
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}
