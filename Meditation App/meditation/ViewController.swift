
import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var myPickerView: UIPickerView!
    private let timeValues = [[Int](0..<24), [Int](0..<60)]
    
    @IBOutlet weak var myButton: UIButton!
    
    var count:Int = 0
    
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var mySlider: UISlider!
    @IBAction func changeSlider(_ sender: UISlider) {
         UIScreen.main.brightness = CGFloat(sender.value)
    }
    
    @IBOutlet weak var homeTabBarItem: UITabBarItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradateBackground()
        
                
        myButton.backgroundColor = self.UIColorFromRGB(rgbValue: 0x194F48)
        myButton.layer.masksToBounds = true
        myButton.layer.cornerRadius = 10.0
        myButton.setTitle(NSLocalizedString("start", comment: ""), for: .normal)
        
        myPickerView.delegate = self
        myPickerView.dataSource = self
        myPickerView.selectRow(1, inComponent: 1, animated: true)
        myPickerView.showsSelectionIndicator = true
        
    
        //時間のラベルを追加
        let hourLabel:UILabel! = UILabel()
        hourLabel.text = NSLocalizedString("hour", comment: "")
        hourLabel.sizeToFit()
        hourLabel.textColor = .white
        hourLabel.sizeToFit()
        
        //componentの要素までのwidth
        let pickerView = myPickerView.view(forRow: 0, forComponent: 0)
        let pickerWidth: CGFloat = (pickerView?.bounds.width)!
        
        hourLabel.frame = CGRect(x:pickerWidth + 20,
                                 y: myPickerView.bounds.height/2 - (hourLabel.bounds.height/2),
                                 width: hourLabel.bounds.width,
                                 height: hourLabel.bounds.height)
        myPickerView.addSubview(hourLabel)
        
        //分のラベルを追加
        let minutesLabel:UILabel! = UILabel()
        minutesLabel.text = NSLocalizedString("minutes", comment: "")
        minutesLabel.sizeToFit()
        minutesLabel.textColor = .white
        minutesLabel.sizeToFit()
        minutesLabel.frame = CGRect(x: pickerWidth*2 + 20,
                                 y: myPickerView.bounds.height/2 - (minutesLabel.bounds.height/2),
                                 width: minutesLabel.bounds.width,
                                 height: minutesLabel.bounds.height)
        myPickerView.addSubview(minutesLabel)
        
        
        
        
        
        homeTabBarItem.title = NSLocalizedString("home", comment: "")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return timeValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeValues[component].count
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.left
        pickerLabel.text = String(timeValues[component][row])
        pickerLabel.textColor = .white
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return myPickerView.bounds.width/4
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let hour = timeValues[0][myPickerView.selectedRow(inComponent: 0)]
        let minutes = timeValues[1][myPickerView.selectedRow(inComponent: 1)]
        
        if(hour == 0 && minutes == 0){
            myButton.isEnabled = false
            myButton.backgroundColor = UIColor.gray
        } else {
            myButton.isEnabled = true
            myButton.backgroundColor = UIColorFromRGB(rgbValue: 0x194F48)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tomeditateViewController") {
            let vc2: meditateViewController = (segue.destination as? meditateViewController)!
            
            count = timeValues[0][myPickerView.selectedRow(inComponent: 0)] * 60 * 60
                + timeValues[1][myPickerView.selectedRow(inComponent: 1)] * 60
            
            vc2.count = count
        }
    }
    
    //画面が消える時に遷移
    override func viewDidDisappear(_ animated: Bool) {
        myButton.addTarget(self, action: #selector(self.activateSegue), for: .touchUpInside)

    }
    
    func activateSegue(){
        performSegue(withIdentifier: "tomeditateViewController",sender: nil)
        
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
        super.didReceiveMemoryWarning()
        
    }

}

