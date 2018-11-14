
//セルの右端に何回唱えたか数字を表示したい。


import UIKit
import RealmSwift
import UserNotifications

class TableViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    //Notification
    let center = UNUserNotificationCenter.current()

    
    @IBOutlet weak var navigationBar: UINavigationItem!
        
    @IBOutlet var myTableView: UITableView!
    
    var fruits: [String] = [String]()
    var detailRow: Int?
    
    var selectedItem: String!
    
    let config = Realm.Configuration(schemaVersion: 5)
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //テストで全部削除
//        self.center.removeAllDeliveredNotifications()
//        self.center.removeAllPendingNotificationRequests()
        

        
        //RealmからtableView配列へ読み込む
        let realm = try! Realm(configuration: config)
        let objs = realm.objects(modelAffirmation.self)
        for i in objs {
            fruits.append(i.content)
        }

        
        
        myTableView.estimatedRowHeight = 30
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        //ナビバーにaddボタンを追加
        let addButton:UIBarButtonItem = UIBarButtonItem(title: "追加", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.addTapped))
        self.navigationBar.setRightBarButtonItems([addButton], animated: true)
        
        
        
        
    }
    
    func addTapped(){
        //addボタンが押されたら編集画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let editView = storyboard.instantiateViewController(withIdentifier: "editView")
        
        present(editView, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fruits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = myTableView.dequeueReusableCell(withIdentifier: "MyCell")!
        cell.textLabel?.numberOfLines = 0
        
        
        cell.textLabel?.text = fruits[indexPath.row]
        
        let tempTextLabel: UILabel = UILabel()
        
        //RealmからchantTimesを読み出し
        let realm = try! Realm(configuration: config)
        let objs = realm.objects(modelAffirmation.self)
        
        for index in objs {
            if(index.content == fruits[indexPath.row]){
                tempTextLabel.text = String(index.chantTimes)
            }
        }
       
        
        tempTextLabel.sizeToFit()
        tempTextLabel.textColor = UIColor.blue
        cell.accessoryView = tempTextLabel
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        self.selectedItem = fruits[indexPath.row]
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChantViewController" {
           
            let chantViewController = segue.destination as! chantViewController
            chantViewController.received = self.selectedItem
            
        }
    }
    
    //ボタンの拡張
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton:UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除"){(action, index) -> Void in
            //tableView配列から削除
            self.fruits.remove(at: indexPath.row)
            //tableViewから削除
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            //Realmから削除
            let config = Realm.Configuration(schemaVersion: 5)
            let realm = try! Realm(configuration: config)
            let dataSet = realm.objects(modelAffirmation.self)
            let data = dataSet[indexPath.row]
            
            
            //通知が設定されていたら削除
            if( data.ifNoticePlace == true || data.ifNoticeTime == true){
                self.center.removePendingNotificationRequests(withIdentifiers: [data.dateIdTime])
            }

            
            try! realm.write() {
                realm.delete(data)
            }
            
        }
        deleteButton.backgroundColor = UIColor.red
        
        let detailButton:UITableViewRowAction = UITableViewRowAction(style: .normal, title: "詳細"){(action, index) -> Void in
            //DetailViewControllerに遷移。Realmから情報を表示する
            
            self.detailRow = indexPath.row
            
            
            let storyboard: UIStoryboard = self.storyboard!
            let detailView = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            detailView.content = self.fruits[self.detailRow!]
            
            self.present(detailView, animated: true, completion: nil)
            
        }
        
        return [deleteButton, detailButton]
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
}
