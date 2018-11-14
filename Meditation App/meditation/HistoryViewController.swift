
import UIKit
import RealmSwift


class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var histDay: [String] = [String]()
    var histTime: [Int] = [Int]()
    var histPast: [Int] = [Int]()
    var histFuture: [Int] = [Int]()
    
    //多言語ラベル
    let hourStr: String = NSLocalizedString("hour", comment: "")
    let minutesStr: String = NSLocalizedString("minutes", comment: "")
    let secondsStr: String = NSLocalizedString("seconds", comment: "")
    let timeStr: String = NSLocalizedString("time", comment: "")
    let timesStr: String = NSLocalizedString("times", comment: "")
    
    
    @IBOutlet weak var histTableView: UITableView!
    
    @IBOutlet weak var histTabBarItem: UITabBarItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableViewのヘッダー
        let headerCell: UITableViewCell = histTableView.dequeueReusableCell(withIdentifier: "histCell")!
        let headerView: UIView = headerCell.contentView
        histTableView.tableHeaderView = headerView
        
        histTabBarItem.title = NSLocalizedString("history", comment: "")
        
        //RealmSwiftでデータを読み出す
        let config = Realm.Configuration(schemaVersion: 2)
        let realm = try! Realm(configuration: config)
        
        let dataSet = realm.objects(resultSet.self)
        
        for data in dataSet {
            histDay.append(data.day)
            histTime.append(data.time)
            histPast.append(data.past)
            histFuture.append(data.future)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histDay.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 40
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "histCell", for: indexPath)
        
        
        
        
        var cellText: String = String(indexPath.row+1) + ".   "
        cellText += histDay[indexPath.row] + "     "
        //秒から換算
        
        if( histTime[indexPath.row] < 60 ){
            cellText += String(histTime[indexPath.row]) + " " + NSLocalizedString("seconds", comment: "") + "    "
        } else if( histTime[indexPath.row] < 3600 ){
            let minutes = histTime[indexPath.row] / 60
            cellText += String(minutes) + " " + NSLocalizedString("minutes", comment: "") + "    "
        } else {
            let hour = histTime[indexPath.row] / 3600
            let minutes = histTime[indexPath.row] % 3600 / 60
            cellText += String(hour) + " " + NSLocalizedString("hour", comment: "") + "  " + String(minutes) + " " + NSLocalizedString("minutes", comment: "") + "    "
        }
        
        cellText += String(histPast[indexPath.row]) + " " + NSLocalizedString("times", comment: "") + "    "
        cellText += String(histFuture[indexPath.row]) + " " + NSLocalizedString("times", comment: "")
        
        cell.textLabel?.text = cellText
        
        return cell
        
    }
    
    //TableViewのヘッダーの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x:0, y:0, width: tableView.bounds.width, height: 40))
        label.backgroundColor = UIColor.blue
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.text = "---" + NSLocalizedString("history", comment: "") + "--" + NSLocalizedString("date", comment: "") + "-----------" + NSLocalizedString("time", comment: "") + "---" + NSLocalizedString("past", comment: "past") + "---" +
        NSLocalizedString("future", comment: "")
        
        let button = UIButton(frame: CGRect(x:histTableView.bounds.width-100, y:4, width:40, height: 32))
        button.layer.cornerRadius = 15.0
        button.setTitleColor(UIColor.white, for: .normal)
        button.setImage(#imageLiteral(resourceName: "hako"), for: .normal)
        button.addTarget(self , action: #selector(buttonEvent(sender:)), for: .touchUpInside)
        button.sizeToFit()
        
        self.view.addSubview(button)
        
        return label
    }
    
    //ボタンが押されてUIAlert
    func buttonEvent(sender: UIButton) {
        // アラートを作成
        let alert = UIAlertController(
            title: NSLocalizedString("alertDelete", comment: ""),
            message: NSLocalizedString("message", comment: ""),
            preferredStyle: .actionSheet)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
//            RealmSwiftから全部削除
                        let config = Realm.Configuration(schemaVersion: 2)
                        let realm = try! Realm(configuration: config)
                        let dataSet = realm.objects(resultSet.self)
                        try! realm.write() {
                            realm.delete(dataSet)
                        }
            
//          TableViewCellを全て削除し、tableを更新
            if self.histDay.count > 0 {
                for _ in 0..<self.histDay.count {
                    self.histDay.remove(at: 0)
                    self.histTime.remove(at: 0)
                    self.histPast.remove(at: 0)
                    self.histFuture.remove(at: 0)
                }
            }
            self.histTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
        }))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //削除処理かどうか
        if editingStyle == UITableViewCellEditingStyle.delete {
            //配列から削除
            histDay.remove(at: indexPath.row)
            histTime.remove(at: indexPath.row)
            histPast.remove(at: indexPath.row)
            histFuture.remove(at: indexPath.row)
            histTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
        //Realmから消す
        let config = Realm.Configuration(schemaVersion: 2)
        let realm = try! Realm(configuration: config)
        let dataSet = realm.objects(resultSet.self)
            
        let data = dataSet[indexPath.row]
            try! realm.write() {
                realm.delete(data)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}
