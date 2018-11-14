
import UIKit
import RealmSwift
import UserNotifications
import MapKit

class DetailViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UNUserNotificationCenterDelegate {
    
    //Notification
    let center = UNUserNotificationCenter.current()
    
    //Realmから取得するデータ
    var content: String = ""
    var EditedContent: String?
    
    var ifNoticeTime: Bool = false
    
    var noticeTimeHour: Int = 0
    var noticeTimeMinutes: Int = 0
    
    var timeRepeats: Bool = false
    
    var ifNoticePlace: Bool = false
    var lati: Double = 0.0
    var long: Double = 0.0
    

    
    @IBOutlet weak var editTableView: UITableView!
    
    let noticeTimeSwitch: UISwitch = UISwitch()
    let noticePlaceSwitch: UISwitch = UISwitch()
    let ifRepeatSwitch: UISwitch = UISwitch()
    
    let noticeTimePicker: UIPickerView = UIPickerView(frame: CGRect(x:0, y:0, width:375, height:100))
    private var timeValues = [[Int](0..<24), [Int]()]
    var pickerIsShowed : Bool = false
    
    var noticeTimeLabel = UILabel()
    var hour = 0
    var minutes = 0
    
    
    var editData: [String] = [ "指定時間で通知"]
    var editData2: [String] = ["指定場所で通知"]
    let sectionTitle: [String] = ["", ""]

    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    @IBOutlet weak var myTextView: UITextView!
    
    let config = Realm.Configuration(schemaVersion: 5)
    
    
    //登録日と唱えた回数のラベル
    @IBOutlet weak var addDateLabel: UILabel!
    
    @IBOutlet weak var chantTimesLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        var minutesValue: Int = 0
        while(minutesValue<60){
            timeValues[1].append(minutesValue)
            minutesValue += 1
        }
        
        //ナビバーにボタンを追加
        let compButton: UIBarButtonItem = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.clickCompButton))
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "戻る", style:UIBarButtonItemStyle.plain, target: self, action: #selector(self.clickBackButton))
        self.myNavigationItem.leftBarButtonItem = backButton
        self.myNavigationItem.rightBarButtonItem = compButton
        
        
        myTextView.delegate = self
        editTableView.delegate = self
        editTableView.dataSource = self
        
        
        myTextView.text = content
        //行間を設定
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSParagraphStyleAttributeName : style]
        myTextView.attributedText = NSAttributedString(string: myTextView.text,
                                                             attributes: attributes)

        
        noticeTimeSwitch.tag = 0
        self.noticeTimeSwitch.addTarget(self, action: #selector(self.changeTimeSwitch(sender:)), for: UIControlEvents.valueChanged)
        
        
        noticePlaceSwitch.tag = 1
        self.noticePlaceSwitch.addTarget(self, action: #selector(self.changePlaceSwitch(sender:)), for: UIControlEvents.valueChanged)
        
        
        //Realmから呼び出し
        let realm = try! Realm(configuration: config)
        
        //全部読んでcontentが同じやつ   重複するcontentでエラー?
        let affirmations = realm.objects(modelAffirmation.self)
        for affirmation in affirmations {
            
            if(self.content == affirmation.content){
                
                //登録日と唱えた回数を表示
                self.addDateLabel.text = "登録日時 : \(affirmation.registeredDate)"
                self.addDateLabel.sizeToFit()
                self.chantTimesLabel.text = "唱えた回数 : \(String(affirmation.chantTimes)) 回"
                self.chantTimesLabel.sizeToFit()
                
                self.ifNoticeTime = affirmation.ifNoticeTime
                
                self.noticeTimeHour = affirmation.noticeTimeHour
                hour = noticeTimeHour
                self.noticeTimeMinutes = affirmation.noticeTimeMinutes
                minutes = noticeTimeMinutes
                
                self.timeRepeats = affirmation.timeRepeats
                
                
                //RealmでtrueならOnにする
                if( self.ifNoticeTime ){
                    
                    self.noticeTimeSwitch.isOn = true
                    self.ifRepeatSwitch.isOn = self.timeRepeats
                    
                    //ここからセルの追加の処理
                    //消えたnoticeTimeLabelを復活
//                    noticeTimeLabel = UILabel()
                    
                    editTableView.beginUpdates()
                    editData.insert("アラート", at: 1)
                    editData.insert("繰り返し", at: 2)
                    let indexPath1 = IndexPath(row:1, section:0)
                    let indexPath2 = IndexPath(row:2, section:0)
                    editTableView.insertRows(at: [indexPath1], with: .automatic)
                    editTableView.insertRows(at: [indexPath2], with: .automatic)
                    editTableView.endUpdates()
                    
                    //アラートのラベル
                    let timeLabel = "\(self.noticeTimeHour) 時 \(self.noticeTimeMinutes) 分"
                    self.noticeTimeLabel.text = timeLabel
                    self.noticeTimeLabel.sizeToFit()
                    
                    
                }

                self.ifNoticePlace = affirmation.ifNoticePlace
                
                if( self.ifNoticePlace ){
                    self.lati = affirmation.lati
                    self.long = affirmation.long
                    
                    //せるに追加
                    //せるのラベルに表示

                    self.noticePlaceSwitch.isOn = true

                    editTableView.beginUpdates()
                    editData2.append("場所")
                    
                    let indexPath7 = IndexPath(row:editData2.count-1, section:1)
                    editTableView.insertRows(at: [indexPath7], with: .automatic)
                    editTableView.endUpdates()
                    
                    editTableView.cellForRow(at: indexPath7)?.accessoryType = .detailButton

                }
                
            }
        }
        
        
        //通知時間のPickerView---------------------------------
        noticeTimePicker.delegate = self
        noticeTimePicker.dataSource = self
        noticeTimePicker.selectRow(1, inComponent: 1, animated: true)
        noticeTimePicker.showsSelectionIndicator = true
        
        //時間のラベルを追加
        let hourLabel:UILabel! = UILabel()
        hourLabel.text = "時"
        hourLabel.sizeToFit()
        hourLabel.textColor = .black
        hourLabel.sizeToFit()

        //componentの要素までのwidth
        let pickerView = noticeTimePicker.view(forRow: 0, forComponent: 0)
        let pickerWidth: CGFloat = (pickerView?.bounds.width)!
        
        hourLabel.frame = CGRect(x:pickerWidth + 40,
                                 y: noticeTimePicker.bounds.height/2 - (hourLabel.bounds.height/2),
                                 width: hourLabel.bounds.width,
                                 height: hourLabel.bounds.height)
        noticeTimePicker.addSubview(hourLabel)

        
        //分のラベルを追加
        let minutesLabel:UILabel! = UILabel()
        minutesLabel.text = "分"
        minutesLabel.sizeToFit()
        minutesLabel.textColor = .black
        minutesLabel.sizeToFit()
        minutesLabel.frame = CGRect(x: pickerWidth*2 + 40,
                                    y: noticeTimePicker.bounds.height/2 - (minutesLabel.bounds.height/2),
                                    width: minutesLabel.bounds.width,
                                    height: minutesLabel.bounds.height)
        noticeTimePicker.addSubview(minutesLabel)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //詳細でcontentが編集されたら
    func textViewDidChange(_ textView: UITextView) {
        if( textView.text != nil){
            self.EditedContent = textView.text
        }
    }

    
    func onClickToolButton(sender: UIButton){
        self.view.endEditing(true)
    }
    
    func changeTimeSwitch(sender: UISwitch){
        if(!sender.isOn){
            
            //ifNoticeTime = false
            
            pickerIsShowed = false
            
            if(editData.count == 3){
                
                editTableView.beginUpdates()
                let indexPath1 = IndexPath(row:1, section:0)
                let indexPath2 = IndexPath(row:2, section:0)
                editData.removeSubrange(1...2)
                
                editTableView.deleteRows(at: [indexPath1], with: .automatic)
                editTableView.deleteRows(at: [indexPath2], with: .automatic)
                editTableView.endUpdates()
                
            } else if(editData.count == 4){
                
                //ifNoticeTime = false
                
                editTableView.beginUpdates()
                let indexPath1 = IndexPath(row:1, section:0)
                let indexPath2 = IndexPath(row:2, section:0)
                let indexPath3 = IndexPath(row:3, section:0)
                editData.removeSubrange(1...3)
                
                
                noticeTimePicker.removeFromSuperview()
                
                editTableView.deleteRows(at: [indexPath1], with: .automatic)
                editTableView.deleteRows(at: [indexPath2], with: .automatic)
                editTableView.deleteRows(at: [indexPath3], with: .automatic)
                editTableView.endUpdates()
                
            }
            
        }
        
        if(sender.isOn){
            
            //消えたnoticeTimeLabelを復活
            noticeTimeLabel = UILabel()
            
            
            editTableView.beginUpdates()
            editData.insert("アラート", at: 1)
            editData.insert("繰り返し", at: 2)
            let indexPath1 = IndexPath(row:1, section:0)
            let indexPath2 = IndexPath(row:2, section:0)
            editTableView.insertRows(at: [indexPath1], with: .automatic)
            editTableView.insertRows(at: [indexPath2], with: .automatic)
            editTableView.endUpdates()
            
            //アラートのラベル
            
            let timeLabel = "\(noticeTimeHour) 時 \(noticeTimeMinutes) 分"
            noticeTimeLabel.text = timeLabel
            noticeTimeLabel.sizeToFit()
            
            editTableView.cellForRow(at: indexPath2)?.accessoryView = nil
            editTableView.cellForRow(at: indexPath1)?.accessoryView = noticeTimeLabel
            
            editTableView.cellForRow(at: indexPath1)?.accessoryType = .none
            editTableView.cellForRow(at: indexPath2)?.accessoryType = .disclosureIndicator
            
        }
    }
    
    func changePlaceSwitch(sender:UISwitch){
        if(!sender.isOn){
            
            //ifNoticePlace = false 通知消去
            
            editTableView.beginUpdates()
            editData2.removeLast()
            let indexPath6 = IndexPath(row: editData2.count, section:1)
            
            editTableView.deleteRows(at: [indexPath6], with: .automatic)
            editTableView.endUpdates()
            
        }
        
        if(sender.isOn){
            editTableView.beginUpdates()
            editData2.append("場所")
            
            let indexPath7 = IndexPath(row:editData2.count-1, section:1)
            editTableView.insertRows(at: [indexPath7], with: .automatic)
            editTableView.endUpdates()
            
            editTableView.cellForRow(at: indexPath7)?.accessoryType = .detailButton
            

            
        }
    }
    
    
    func clickCompButton(){
        
        //Realmのデータをアップデート
        let realm = try! Realm(configuration: config)
        
        //全部読んでcontentが同じやつ
        let affirmations = realm.objects(modelAffirmation.self)
        for affirmation in affirmations {
            
            if(self.content == affirmation.content){
                
                // データを更新
                try! realm.write() {
                    
                    //contentが変わってたらRealmのデータを変更
                    if let newContent = self.EditedContent {
                        affirmation.content = newContent
                    }
                    
                    affirmation.ifNoticeTime = noticeTimeSwitch.isOn
                    
                    if( noticeTimeSwitch.isOn){
                        
                        affirmation.noticeTimeHour = hour
                        affirmation.noticeTimeMinutes = minutes
                        affirmation.timeRepeats = ifRepeatSwitch.isOn
                        
                        //通知を一度消してから再設定
                        center.removePendingNotificationRequests(withIdentifiers: [affirmation.dateIdTime])
                        
                        let date2 = Date()
                        let format = DateFormatter()
                        format.dateFormat = "yyyy-MM-dd-HH:mm:ss"
                        var strDate = format.string(from: date2)
                        strDate += "time"
                        affirmation.dateIdTime = strDate
                        
                        //時間の通知の設定をする
                        let content = UNMutableNotificationContent()
                        content.body = NSString.localizedUserNotificationString(forKey: self.myTextView.text!, arguments: nil)
                        content.sound = UNNotificationSound.default()
                        
                        let date = Date()
                        let calendar = Calendar.current
                        let month = calendar.component(.month, from: date)
                        let day = calendar.component(.day, from: date)
                        
                        let noticeDate = DateComponents(month: month, day: day, hour: hour, minute: minutes)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: noticeDate, repeats: ifRepeatSwitch.isOn)
                        
                        //identifierを日時 + "time"で設定
                        let requestTime = UNNotificationRequest(identifier: strDate, content: content, trigger: trigger)
                        
                        center.add(requestTime) { (error : Error?) in
                            if error != nil {
                                // エラー処理
                                print("通知centerに追加でエラー")
                            }
                        }

                        
                        
                    } else if ( !noticeTimeSwitch.isOn ){
                        //該当の通知を取り消す
                        
                        if(!affirmation.dateIdTime.isEmpty){
                            center.removePendingNotificationRequests(withIdentifiers: [affirmation.dateIdTime])
                        }
                        
                    }
                    
                    
                    
                    
                    //場所の通知
                    affirmation.ifNoticePlace = noticePlaceSwitch.isOn
                    
                    if (noticePlaceSwitch.isOn && self.lati != 0.0){
                        
                        affirmation.lati = self.lati
                        affirmation.long = self.long
                        
                        //通知を一度消してから再設定
                        center.removePendingNotificationRequests(withIdentifiers: [affirmation.dateIdPlace])
                        
                        let date2 = Date()
                        let format = DateFormatter()
                        format.dateFormat = "yyyy-MM-dd-HH:mm:ss"
                        var strDate = format.string(from: date2)
                        strDate += "place"
                        affirmation.dateIdPlace = strDate
                        
                        //場所の通知の設定をする
                        let content = UNMutableNotificationContent()
                        content.body = NSString.localizedUserNotificationString(forKey: self.myTextView.text!, arguments: nil)
                        content.sound = UNNotificationSound.default()
                        
                        
                        
                        let coordinate = CLLocationCoordinate2DMake(self.lati, self.long)
                        
                        let region = CLCircularRegion(center: coordinate, radius: 100.0, identifier: "noticePlace")
                        let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: true)
                        
                        let requestPlace = UNNotificationRequest(identifier: strDate, content: content, trigger: locationTrigger)
                        
                    
                        
                        center.add(requestPlace) { (error : Error?) in
                            if error != nil {
                                // エラー処理
                                print("通知centerに追加でエラー")
                            }
                        }
                        
                    } else if( !noticePlaceSwitch.isOn) {
                        //設定されてた通知を消す
                        if(!affirmation.dateIdPlace.isEmpty){
                            center.removePendingNotificationRequests(withIdentifiers: [affirmation.dateIdPlace])
                        }

                    }
                }
                
            }
        }
        
        //もとのViewへ戻る
        let storyboard: UIStoryboard = self.storyboard!
        let homeView = storyboard.instantiateViewController(withIdentifier: "homeView")
        present(homeView, animated: true, completion: nil)
   
    }


    
    //textViewに文字が入っているか
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                return false
        }
        return true
    }
    
    func clickBackButton(){
        self.dismiss(animated: true, completion: nil)
    }

    
    //tableViewの設定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1){
            return 44
        } else {
            return 0
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let label : UILabel = UILabel()
//        label.backgroundColor = UIColor.lightGray
//        label.textColor = UIColor.blue
//        label.textAlignment = .center
//        
//        if (section == 1){
//            label.text = "ここで場所の変更はできません。"
//        }
//        return label
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return editData.count
        } else if section == 1{
            return editData2.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        if(indexPath.section == 0){
            
            cell.textLabel?.text = editData[indexPath.row]
            
            if(cell.textLabel?.text == "指定時間で通知"){
                
                cell.accessoryView = noticeTimeSwitch
                cell.imageView?.image = UIImage(named: "clock")
                
            } else if(cell.textLabel?.text == "繰り返し"){
                
                cell.accessoryView = ifRepeatSwitch
                
            } else if(cell.textLabel?.text == "アラート"){
                
                cell.accessoryView = noticeTimeLabel
            }
            
        } else if(indexPath.section == 1){
            cell.textLabel?.text = editData2[indexPath.row]
            
            if (cell.textLabel?.text == "指定場所で通知"){
                cell.accessoryView = noticePlaceSwitch
                cell.imageView?.image = UIImage(named: "pin.png")
                
            } else if (indexPath.row == 1){
                if(self.lati == 0.0){
                    cell.textLabel?.text = "場所"

                } else {
                    cell.textLabel?.text = "場所：指定済み"

                }
                            }
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0){
            if(editData[indexPath.row] == ""){
                if(pickerIsShowed){
                    return 100
                } else {
                    return 44
                }
            }
        }
        
        return 44
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 0){
            
            if(editData[indexPath.row] == "アラート" && pickerIsShowed == false){
                pickerIsShowed = true
                
                //PickerViewを追加
                editTableView.beginUpdates()
                editData.insert("", at: 2)
                let indexPath2 = IndexPath(row:2, section:0)
                editTableView.insertRows(at: [indexPath2], with: .automatic)
                editTableView.endUpdates()
                
                editTableView.cellForRow(at: indexPath2)?.accessoryView = nil
                editTableView.cellForRow(at: indexPath2)?.contentView.addSubview(noticeTimePicker)
                
            } else if(editData[indexPath.row] == "アラート" && pickerIsShowed == true){
                pickerIsShowed = false
                
                //PickerViewを削除
                editTableView.beginUpdates()
                let indexPath2 = IndexPath(row:2, section:0)
                editData.remove(at: 2)
                editTableView.deleteRows(at: [indexPath2], with: .top)
                editTableView.endUpdates()
            }
            
        }
        
        if(indexPath.section == 1){
            
            if(indexPath.row == 1){
                
                //あとで考える
                let next = storyboard!.instantiateViewController(withIdentifier: "mapViewController")
                self.present(next,animated: true, completion: nil)
                
            }
        }
    }
    
    
    
    //PickerViewの設定-----------------------------------------------
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeValues[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.left
        pickerLabel.text = String(timeValues[component][row])
        pickerLabel.textColor = .black
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return noticeTimePicker.bounds.width/4
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //ラベルに時間を表示
        if(component == 0){
            hour = timeValues[component][row]
        } else if(component == 1){
            minutes = timeValues[component][row]
        }
        
        noticeTimeLabel.text = "\(hour) 時 \(minutes) 分"
        noticeTimeLabel.sizeToFit()
    }


    
    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
    }
    
}
