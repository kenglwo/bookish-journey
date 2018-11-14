
import UIKit
import RealmSwift
import UserNotifications
import MapKit


class EditViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var editTableView: UITableView!
    
    let noticeTimeSwitch: UISwitch = UISwitch()
    let noticePlaceSwitch: UISwitch = UISwitch()
    let ifRepeatSwitch: UISwitch = UISwitch()
    
    let noticeTimePicker: UIPickerView = UIPickerView(frame: CGRect(x:0, y:0, width:375, height:100))
    private var timeValues = [[Int](0..<24), [Int]()]
    var pickerIsShowed : Bool = false

    
    //noticeTimeLabelはアラートcellが生まれると同時に生成？
    var noticeTimeLabel = UILabel()
    var hour = 0
    var minutes = 0
    
    var editData: [String] = [ "指定時間で通知"]
    var editData2: [String] = ["指定場所で通知"]
    let sectionTitle: [String] = ["", ""]
    
    //Realmに保存する値-----------------------------------------------------
    var lati: [Double] = [] {
        
        didSet {
            
            let placePath = IndexPath(row: 1, section:1)
            
                if let data = lati.last {
                    editTableView.cellForRow(at: placePath)?.textLabel?.text! = "場所：指定済み"
                    print("ラベルにはったのは\(data)")
                }
        }
    }
    var long: [Double] = []

    
    @IBOutlet var singleTapRecognizer: UITapGestureRecognizer!
    
    
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    @IBOutlet var doubleTapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var myTextView: UITextView!
    
    //Notification
    let center = UNUserNotificationCenter.current()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Notificationの許可
        
    
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
        
        //ダブルタップに失敗した時のみシングルタップを呼び出す。
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        
        editTableView.delegate = self
        editTableView.dataSource = self
        
        
        noticeTimeSwitch.tag = 0
        self.noticeTimeSwitch.addTarget(self, action: #selector(self.changeTimeSwitch(sender:)), for: UIControlEvents.valueChanged)
        
        noticePlaceSwitch.tag = 1
        self.noticePlaceSwitch.addTarget(self, action: #selector(self.changePlaceSwitch(sender:)), for: UIControlEvents.valueChanged)
        
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //行間を設定
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSParagraphStyleAttributeName : style]
        self.myTextView.attributedText = NSAttributedString(string: self.myTextView.text,
                                                          attributes: attributes)
        
        
    }


    
    func onClickMyButton(sender: UIButton){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            let now = Date()
            let dateFormatter: DateFormatter = DateFormatter()
            //        let jaLocale = Locale(identifier: "ja_JP")
            //        dateFormatter.locale = jaLocale
            dateFormatter.timeStyle = .short
            dateFormatter.dateFormat = "HH 時 mm 分"
            
            let timeLabel = dateFormatter.string(from: now)
            
            //デフォルトのhourとminutsを設定する
            let calendar = Calendar.current
            let nowHour = calendar.component(.hour, from: now)
            let nowMinute = calendar.component(.minute, from: now)
            hour = nowHour
            minutes = nowMinute
            
            
            noticeTimeLabel.text = timeLabel
            noticeTimeLabel.sizeToFit()
            
            editTableView.cellForRow(at: indexPath1)?.accessoryType = .none
            editTableView.cellForRow(at: indexPath1)?.accessoryView = noticeTimeLabel
                        
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
    
    //完了が押されたら
    func clickCompButton(){
        
        //Realmに保存
        let affirmation = modelAffirmation()
        
        

        //（文章が書いてたら）
        if (validate(textView: myTextView)){
            
            //本文
            affirmation.content = self.myTextView.text!
            
            
            //登録日時を設定する
            let now = Date()
            let dateFormatter: DateFormatter = DateFormatter()
            //        let jaLocale = Locale(identifier: "ja_JP")
            //        dateFormatter.locale = jaLocale
            dateFormatter.timeStyle = .short
            dateFormatter.dateFormat = "yyyy/MM/dd  HH 時 mm 分"
            
            let timeLabel = dateFormatter.string(from: now)
            
            affirmation.registeredDate = timeLabel
            
            
            //通知時間
            if( noticeTimeSwitch.isOn){
                
                affirmation.ifNoticeTime = true
                affirmation.noticeTimeHour = hour
                affirmation.noticeTimeMinutes = minutes
                affirmation.timeRepeats = ifRepeatSwitch.isOn
                
                //identifierを日時 + "time"で設定
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
                
                
                let requestTime = UNNotificationRequest(identifier: strDate, content: content, trigger: trigger)
                
                center.add(requestTime) { (error : Error?) in
                    if error != nil {
                        // エラー処理
                        print("通知centerに追加でエラー")
                    }
                }
            }
            
            //ピンの座標 最後に追加したやつだけ... しかし複数も可能にしたい
            if( noticePlaceSwitch.isOn && !lati.isEmpty ){
                
                affirmation.ifNoticePlace = true
                
                if let lati = lati.last {
                    affirmation.lati = lati
                }
                
                if let long = long.last {
                    affirmation.long = long
                }
                
                
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
                
                let coordinate = CLLocationCoordinate2DMake(lati.last!, long.last!)
                let region = CLCircularRegion(center: coordinate, radius: 100.0, identifier: "noticePlace")
                let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: true)
                
                let requestPlace = UNNotificationRequest(identifier: strDate, content: content, trigger: locationTrigger)
                
                center.add(requestPlace) { (error : Error?) in
                    if error != nil {
                        // エラー処理
                        print("通知centerに追加でエラー")
                    }
                }
                
                lati.removeAll()
                long.removeAll()


                
            }
       
            let config = Realm.Configuration(schemaVersion: 5)
            let realm = try! Realm(configuration: config)
            try! realm.write(){
                //ここで保存するのは後でスライドタップ詳細からEditViewに来た時
                //情報を表示し、編集するため！！！！
                realm.add(affirmation)

            }

        }
        
        //もとのViewへ戻る
        let storyboard: UIStoryboard = self.storyboard!
        let homeView = storyboard.instantiateViewController(withIdentifier: "homeView")
        present(homeView, animated: true, completion: nil)
        
    }
    
    func clickBackButton(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //textViewに文字が入っているか
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                return false
        }
        return true
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath)
        if(indexPath.section == 0){
            
            cell.textLabel?.text = editData[indexPath.row]
            
            if(cell.textLabel?.text == "指定時間で通知"){
                
                cell.accessoryView = noticeTimeSwitch
                cell.imageView?.image = UIImage(named: "clock")
                
            } else if(cell.textLabel?.text == "繰り返し"){
                
                cell.accessoryView = ifRepeatSwitch
            
            }
            
        } else if(indexPath.section == 1){
            cell.textLabel?.text = editData2[indexPath.row]
            
            if (cell.textLabel?.text == "指定場所で通知"){
                cell.accessoryView = noticePlaceSwitch
                cell.imageView?.image = UIImage(named: "pin.png")
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

}
