
import UIKit
import AVFoundation
import AudioToolbox

let userDefaults = UserDefaults.standard

let soundStr: String = NSLocalizedString("sound", comment: "")
let highbellStr: String = NSLocalizedString("highbell", comment: "")
let lowbellStr: String = NSLocalizedString("lowbell", comment: "")
let rinStr: String = NSLocalizedString("rin", comment: "")
let settingStr: String = NSLocalizedString("setting", comment: "")
let vibStr: String = NSLocalizedString("vib", comment: "")


class ConfViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var confTableView: UITableView!
    
    @IBOutlet weak var confTabBarItem: UITabBarItem!
    
    let sectionItem1 = [highbellStr, lowbellStr, rinStr]
    let sectionItem2 = [vibStr]
    
    let mySections = [soundStr, settingStr]    //セクションのタイトル
    
    let mySwitch: UISwitch = UISwitch()
    
    var sectionArray: Array<Array<String>> = [[]]
    
    var audioPlayer1 : AVAudioPlayer! = nil
    var audioPlayer2 : AVAudioPlayer! = nil
    var audioPlayer3 : AVAudioPlayer! = nil
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeSound()
        
        //TableView
        sectionArray = [sectionItem1, sectionItem2]
        
        //UserDefault
        
        userDefaults.register(defaults: ["soundId": 2])
        userDefaults.register(defaults: ["vibSwitchOn": false])
        
        //Switchの設定 Realからswitchのon/offを
        self.mySwitch.isOn = userDefaults.bool(forKey: "vibSwitchOn")
        self.mySwitch.addTarget(self, action: #selector(self.onClickMySwitch(sender:)), for: UIControlEvents.valueChanged)
        
        confTabBarItem.title = NSLocalizedString("setting", comment: "")
        
        
    }
    
    //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    //セクションのタイトル
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mySections[section]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionArray[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyCell")!
        cell.textLabel!.text = sectionArray[indexPath.section][indexPath.row]

        
//        UserDefaultに保存してるsoundIdのセルにチェック
        let soundIndex = UserDefaults.standard.integer(forKey: "soundId")
        let soundName = sectionItem1[soundIndex]
        
        if(self.sectionArray[indexPath.section][indexPath.row] == soundName){
            cell.accessoryType = .checkmark
        }
        
        
        
        if (self.sectionArray[indexPath.section][indexPath.row] == vibStr) {
            cell.accessoryView = self.mySwitch
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        
        
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 0){
            //全てのセルに対してチェックマークを消す
            for i in 0..<sectionItem1.count {
                let indexPath: IndexPath = IndexPath(row: i, section: indexPath.section)
                if let cell: UITableViewCell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .none
                }
            }
        
            //選択されたCellにチェックマークをつける
            let cell = confTableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
        
            //そのindexPath.rowをUserDefaultに保存
            UserDefaults.standard.set(indexPath.row, forKey: "soundId")
            UserDefaults.standard.synchronize()
        }
        
        if (self.sectionArray[indexPath.section][indexPath.row] == rinStr) {
            self.audioPlayer2.stop()
            self.audioPlayer3.stop()
            
            self.audioPlayer1.currentTime = 0
            self.audioPlayer1.volume = 1.0
            self.audioPlayer1.play()
        } else if (self.sectionArray[indexPath.section][indexPath.row] == highbellStr) {
            self.audioPlayer1.stop()
            self.audioPlayer3.stop()
            
            self.audioPlayer2.currentTime = 0
            self.audioPlayer2.volume = 1.0
            self.audioPlayer2.play()
        } else if (self.sectionArray[indexPath.section][indexPath.row] == lowbellStr) {
            self.audioPlayer1.stop()
            self.audioPlayer2.stop()
            
            self.audioPlayer3.currentTime = 0
            self.audioPlayer3.volume = 1.0
            self.audioPlayer3.play()
        }
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if( indexPath.section == 0) {
            let cell = confTableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
        }
    }
    
    func makeSound() {
        //音声ファイルのパスを作る。
         let soundFilePath1 : NSString = Bundle.main.path(forResource: "bell1", ofType: "mp3")! as NSString
        let soundFilePath2 : NSString = Bundle.main.path(forResource: "bell2", ofType: "mp3")! as NSString
         let soundFilePath3 : NSString = Bundle.main.path(forResource: "bell3", ofType: "mp3")! as NSString
        
        let sound1 : NSURL = NSURL(fileURLWithPath: soundFilePath1 as String)
        let sound2 : NSURL = NSURL(fileURLWithPath: soundFilePath2 as String)
        let sound3 : NSURL = NSURL(fileURLWithPath: soundFilePath3 as String)
        
        //AVAudioPlayerのインスタンス化
        do{
            audioPlayer1 = try AVAudioPlayer(contentsOf: sound1 as URL, fileTypeHint:nil)
            audioPlayer2 = try AVAudioPlayer(contentsOf: sound2 as URL, fileTypeHint:nil)
            audioPlayer3 = try AVAudioPlayer(contentsOf: sound3 as URL, fileTypeHint:nil)

        }catch{
            print("Failed AVAudioPlayer Instance")
        }
        //出来たインスタンスをバッファに保持する。
        audioPlayer1.prepareToPlay()
        audioPlayer2.prepareToPlay()
        audioPlayer3.prepareToPlay()
    }
    
    //Switchを切り替えるごとにOn or Offを保存
    func onClickMySwitch(sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "vibSwitchOn")
        if( sender.isOn ) {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        UserDefaults.standard.synchronize()
    
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}
