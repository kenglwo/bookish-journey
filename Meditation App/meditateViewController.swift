
import UIKit
import AVFoundation
import AudioToolbox

class meditateViewController: UIViewController {
    
    var timer  : Timer = Timer()
    var count  : Int? = 0
    
    var hour   : Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    var hourString: String!
    var minutesString: String!
    var secondsString: String!
    
    var pastTime = 0
    
    var pastCount:Int = 0
    var futureCount:Int = 0


    var audioPlayerClear : AVAudioPlayer! = nil
    
    @IBOutlet weak var myLabel: UILabel!
    
    
    
    @IBOutlet weak var pastButton: UIButton!
    @IBAction func countPast(_ sender: UIButton) {
        pastCount += 1
        self.audioPlayerClear.currentTime = 0
        self.audioPlayerClear.volume = 1.0
        self.audioPlayerClear.play()
        UIView.animate(withDuration: 1.0, delay:0.0, options: .curveEaseOut,
          
            animations: { () -> Void in
                self.pastButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.pastButton.layer.shadowOffset = CGSize(width: 20.0, height: 20.0)
                self.pastButton.backgroundColor =  self.UIColorFromRGB(rgbValue: 0x194F48)
            },
            completion: nil
        )
        
        //バイブ 
        if(UserDefaults.standard.bool(forKey: "vibSwitchOn")){
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    @IBAction func animatePast(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay:0.0, options: .curveEaseIn,
            animations: { () -> Void in
                self.pastButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.pastButton.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
                self.pastButton.backgroundColor = UIColor.blue
                        
            },
            completion: nil
        )
    }
    
    @IBOutlet weak var futureButton: UIButton!

    @IBAction func countFuture(_ sender: UIButton) {
        futureCount += 1
        self.audioPlayerClear.currentTime = 0
        self.audioPlayerClear.volume = 1.0
        self.audioPlayerClear.play()
        
        //バイブ
        if(UserDefaults.standard.bool(forKey: "vibSwitchOn")){
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        UIView.animate(withDuration: 1.0,
            animations: { () -> Void in
                
                self.futureButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.futureButton.layer.shadowOffset = CGSize(width: -20.0, height: 20.0)
                self.futureButton.backgroundColor = self.UIColorFromRGB(rgbValue: 0x194F48)
                
        })
    }
    @IBAction func animateFuture(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2,
            animations: { () -> Void in
                self.futureButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.futureButton.layer.shadowOffset = CGSize(width: -10.0, height: 10.0)
                self.futureButton.backgroundColor = UIColor.blue
        })

    }
    
    @IBOutlet weak var endButton: UIButton!
    @IBAction func endMeditate(_ sender: UIButton) {
        self.timer.invalidate()
        self.audioPlayerClear.stop()
        count = nil
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradateBackground()
        
        makeSound()
        
        //pastButtonの設定
        let widthButton = self.view.bounds.width*9/20
        let heightButton = self.view.bounds.height/2
        pastButton.frame = CGRect(x:-40,
                                  y:self.view.frame.height/2-widthButton/3,
                                  width: widthButton+40,
                                  height: heightButton)

        pastButton.layer.cornerRadius = 40
        pastButton.layer.shadowColor = UIColor.black.cgColor
        pastButton.layer.shadowOffset = CGSize(width: 20.0, height: 20.0)
        pastButton.layer.shadowOpacity = 0.5
        pastButton.setTitle(NSLocalizedString("past", comment: ""), for: .normal)
        
        //futureButtonの設定
        let futureX = self.view.frame.width/2 + (self.view.frame.width/2 - widthButton)
        futureButton.frame = CGRect(x:futureX,
                                    y:self.view.frame.height/2-widthButton/3,
                                    width:widthButton+40,
                                    height: heightButton)

        futureButton.layer.cornerRadius = 40
        futureButton.layer.shadowColor = UIColor.black.cgColor
        futureButton.layer.shadowOffset = CGSize(width: -20.0, height: 20.0)
        futureButton.layer.shadowOpacity = 0.5
        futureButton.setTitle(NSLocalizedString("future", comment: ""), for: .normal)

        
        //終了ボタンの設定
        endButton.layer.masksToBounds = true
        endButton.layer.cornerRadius = 10.0
        endButton.setTitle(NSLocalizedString("result", comment: ""), for: .normal)
        endButton.setTitle(NSLocalizedString("result", comment: ""), for: .normal)
        endButton.backgroundColor = self.UIColorFromRGB(rgbValue: 0x194F48)
        
        
        //ラベルに時間経過
        hour = count! / 3600
        hourString = String(hour)
        minutes = count! % 3600 / 60
        if( minutes < 10 ){
            minutesString = NSString(format: "%02d", minutes) as String!
        } else {
            minutesString = NSString(format: "%d", minutes) as String!
        }
        secondsString = NSString(format: "%02d", 0) as String!
        seconds = 0
        
        myLabel.text = hourString + " : " + minutesString + " : " + secondsString
        myLabel.sizeToFit()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        
    }
    
    func countDown() {
        
            //タイマー処理
        if(count == 0) {
            timer.invalidate()
            myLabel.text = NSLocalizedString("end", comment: "")
            pastButton.isEnabled = false
            pastButton.backgroundColor = UIColor.gray
            futureButton.isEnabled = false
            futureButton.backgroundColor = UIColor.gray
            //バイブ
            if(UserDefaults.standard.bool(forKey: "vibSwitchOn")){
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            //音
            let soundId:SystemSoundID = 1009
            AudioServicesPlaySystemSound(soundId)
            
        }
        
            if(count! > 0){
                
                if(minutes == 0 && seconds == 0){
                    hour -= 1
                    minutes = 59
                    seconds = 59
                    
                    hourString = NSString(format: "%02d", hour) as String!
                    minutesString = NSString(format: "%02d", minutes) as String!
                    secondsString = NSString(format: "%02d", seconds) as String!
                    
                    myLabel.text = hourString + " : " + minutesString + " : " + secondsString
                    myLabel.sizeToFit()
                }

                if(seconds > 0){
                    seconds -= 1
                    secondsString = NSString(format: "%02d", seconds) as String!
                    myLabel.text = hourString + " : " + minutesString + " : " + secondsString
                    myLabel.sizeToFit()
                } else if(seconds == 0) {
                    minutes -= 1
                    minutesString = NSString(format: "%02d", minutes) as String!
                    seconds = 59
                    secondsString = NSString(format: "%02d", seconds) as String!
                    myLabel.text = hourString + " : " + minutesString + " : " + secondsString
                    myLabel.sizeToFit()
                }
                count! -= 1
                pastTime += 1
            }
    }
    
    func makeSound() {
        let soundArray = ["bell2", "bell3", "bell1"]
        
        let sound = UserDefaults.standard.integer(forKey: "soundId")
        let soundType: String = soundArray[sound]
        
        
        let soundFilePathClear : NSString = Bundle.main.path(forResource: soundType, ofType: "mp3")! as NSString
        let soundClear : NSURL = NSURL(fileURLWithPath: soundFilePathClear as String)
        
        do{
            audioPlayerClear = try AVAudioPlayer(contentsOf: soundClear as URL, fileTypeHint:nil)
        }catch{
            print("Failed AVAudioPlayer Instance")
        }
        
        audioPlayerClear.prepareToPlay()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toResultViewController") {
            let rvc: ResultViewController = (segue.destination as? ResultViewController)!
            
            rvc.timeCount = pastTime
            rvc.pastCount = pastCount
            rvc.futureCount = futureCount

        }
    }
    
    private var _orientations = UIInterfaceOrientationMask.landscapeLeft
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
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
