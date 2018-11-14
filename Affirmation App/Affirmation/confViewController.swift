
import UIKit

class confViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var confTableView: UITableView!
    
    
    let confDic: [String] = ["通知","バイブ", "頻度", "a", "b"]
    let noticeSwitch = UISwitch()
    let vibSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confTableView.delegate = self
        confTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "confCell")
        
        cell.textLabel?.text = confDic[indexPath.row]
        
        if(cell.textLabel?.text == "通知"){
            cell.accessoryView = self.noticeSwitch
        } else if(cell.textLabel?.text == "バイブ"){
            cell.accessoryView = self.vibSwitch
        }
        cell.accessoryType = .disclosureIndicator
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    override func didReceiveMemoryWarning() {
        
    }
}
