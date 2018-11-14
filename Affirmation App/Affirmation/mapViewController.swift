
import UIKit
import MapKit
import RealmSwift


class mapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapNavigationItem: UINavigationItem!
    
    @IBOutlet weak var myMapView: MKMapView!
    
    var myLocationManager: CLLocationManager!
    
    var annotation = MKPointAnnotation()
    
    //EditViewに遷移させる値の座標
    var Latis: [Double : Int] = [:]
    var indexLatis: Int = 0
    var Longs: [Double : Int] = [:]
    
    //Realmに登録してるピンを表示するピンの配列
    var pinArray: [Any] = []
    
    
    //ロングタップしたときに立てるピンを定義
    var pinByLongPress:MKPointAnnotation!

    //ロングプレスでピンを追加
    @IBAction func longPressMap(_ sender: UILongPressGestureRecognizer) {
        
        //ロングタップの最初の感知のみ受け取る
        if(sender.state != UIGestureRecognizerState.began){
            return
        }
        
        pinByLongPress = MKPointAnnotation()
        
        //ロングタップから位置情報を取得
        let location:CGPoint = sender.location(in: myMapView)
        
        //取得した位置情報をCLLocationCoordinate2D（座標）に変換
        let longPressedCoordinate:CLLocationCoordinate2D = myMapView.convert(location, toCoordinateFrom: myMapView)
        
        
        //ロングタップした位置の座標をピンに入力
        pinByLongPress.coordinate = longPressedCoordinate
        
        
        //遷移する配列に保存　ピンを削除したら配列からremove...
        Latis = [pinByLongPress.coordinate.latitude : indexLatis]
        Longs = [pinByLongPress.coordinate.longitude : indexLatis]
        indexLatis += 1
        
        //Realmから本文をピンのタイトルに設定
        pinByLongPress.title = "新しいピン"
        
        //ピンを追加する（立てる）
        myMapView.addAnnotation(pinByLongPress)
        
        
        
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "戻る", style:UIBarButtonItemStyle.plain, target: self, action: #selector(self.clickBackButton))
        self.mapNavigationItem.leftBarButtonItem = backButton
        
        let setMapButton: UIBarButtonItem = UIBarButtonItem(title: "完了", style:UIBarButtonItemStyle.plain, target: self, action: #selector(self.setMapButton))
        self.mapNavigationItem.rightBarButtonItem = setMapButton
        
        // LocationManagerの生成.
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = 100
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        myLocationManager.allowsBackgroundLocationUpdates = true
        
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status != CLAuthorizationStatus.authorizedAlways) {
            print("not determined")
            myLocationManager.requestAlwaysAuthorization()
        }
        
        // 位置情報の更新を開始.
        myLocationManager.startUpdatingLocation()
        myMapView.delegate = self
        
        
        //Realmに保存してあるものを全てピンで表示
        let config = Realm.Configuration(schemaVersion: 5)
        let realm = try! Realm(configuration: config)
        let datas = realm.objects(modelAffirmation.self).filter("ifNoticePlace == true")

        
        // ためしに名前を表示
        for pin in datas {
            
            let designatedAnnotation = MKPointAnnotation()
            if( pin.lati != 0.0){
                designatedAnnotation.coordinate = CLLocationCoordinate2DMake(pin.lati, pin.long)
                designatedAnnotation.title = pin.content
                pinArray.append(designatedAnnotation)
            }

        }
        
        for index in pinArray {
            myMapView.addAnnotation(index as! MKAnnotation)
        }
        

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }

    
    
        // GPSから値を取得した際に呼び出されるメソッド.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
            
        // 配列から現在座標を取得.
        let myLocations: NSArray = locations as NSArray
        let myLastLocation: CLLocation = myLocations.lastObject as! CLLocation
        let myLocation:CLLocationCoordinate2D = myLastLocation.coordinate
        
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 100
        let myLonDist : CLLocationDistance = 100
            
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation, myLatDist, myLonDist)
        
        // MapViewに反映.
        myMapView.setRegion(myRegion, animated: true)
        myMapView.addAnnotation(annotation)
        
    }
    
    
    // Regionが変更した時に呼び出されるメソッド.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        
    }
    
    //addAnnotationが呼ばれた時
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation === mapView.userLocation {
            return nil
        }
        
        let myPinIdentifier = "PinAnnotationIdentifier"
        
        //ピンをインスタンス化
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
        
        
        //"新しいピン"は色を変える
        if((pinAnnotationView.annotation?.title)! == "新しいピン"){
            pinAnnotationView.pinTintColor = UIColor.green

        }
        
        pinAnnotationView.animatesDrop = true
        pinAnnotationView.canShowCallout = true
        return pinAnnotationView
        
    }
    
    //annotationが追加された時
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            
            let annotationButton = UIButton(type: .infoLight)
            view.rightCalloutAccessoryView = annotationButton
            
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
            let alert: UIAlertController = UIAlertController(title: "ピンの操作", message: nil, preferredStyle:  UIAlertControllerStyle.actionSheet)
            
//            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
//                        // ボタンが押された時の処理を書く（クロージャ実装）
//            (action: UIAlertAction!) -> Void in
//                
//                
//            })
        
            //ピンを削除する
            let deletePinAction: UIAlertAction = UIAlertAction(title: "ピンを削除", style: UIAlertActionStyle.destructive, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                
                
                //Latis, Longsから削除-------------------------------------------------
                
                
                //もともと登録してたピンならRealmのifNoticePlaceをfalseに？
                let config = Realm.Configuration(schemaVersion: 5)
                let realm = try! Realm(configuration: config)
                let affirmation = realm.objects(modelAffirmation.self).filter("lati == %@", view.annotation!.coordinate.latitude)
                let data = affirmation.first

                try! realm.write(){
                    data?.ifNoticePlace = false
                }

                
                //辞書でキーと値をつけ、値で削除する！！！！！！！
                self.Latis.removeValue(forKey: (view.annotation!.coordinate.latitude))
                self.Longs.removeValue(forKey: (view.annotation!.coordinate.longitude))
                
                
        
                self.myMapView.removeAnnotation(view.annotation!)
        
            })
            
                    // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
            
            })
                    
            // ③ UIAlertControllerにActionを追加
            alert.addAction(cancelAction)
//            alert.addAction(defaultAction)
            alert.addAction(deletePinAction)
                    
            // ④ Alertを表示
            present(alert, animated: true, completion: nil)
        
    }
    
    
    
    func clickBackButton(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //完了ボタンを押したら
    func setMapButton(){
        
        
        //遷移元がEditかDetailかで分ける
        
        if( self.presentingViewController!.title! == "EditViewController"){
            
            let prevView = self.presentingViewController as! EditViewController
            
            //Latis,Longsに値が入っていれば → editView.latiに何入れる？
            if( !Latis.isEmpty ){
                
                for(lati, _) in Latis {
                    prevView.lati.append(lati)
                }
                Latis.removeAll()
                
                for(long, _) in Longs {
                    prevView.long.append(long)
                }
                Longs.removeAll()
                
            }
            
            self.dismiss(animated: true, completion: nil)
            
            
        } else if ( self.presentingViewController!.title! == "DetailViewController" ){
            
            let prevView = self.presentingViewController as! DetailViewController
            
            //該当のピンが削除された0個の場合 noticePlaceSwitchをオフに。セルも削除
            //Realmからも削除する
            if( Latis.isEmpty ){
                prevView.noticePlaceSwitch.isOn = false
                
                //セルの削除
                prevView.editTableView.beginUpdates()
                prevView.editData2.removeLast()
                let indexPath6 = IndexPath(row: prevView.editData2.count, section:1)
                
                prevView.editTableView.deleteRows(at: [indexPath6], with: .automatic)
                prevView.editTableView.endUpdates()
                
            } else if( !Latis.isEmpty ){
                
                //値を渡す DetailではAffirmation.latiからlatiに渡している。Latisの最後を更新
                //prevView.latiにそのままわたせば？
                for key in Latis.keys {
                    prevView.lati = key
                    //最後のDoubleが入るはず...
                }
                //tableCellのラベル表示を変える 
                let indexPath7 = IndexPath(row:prevView.editData2.count-1, section:1)

                prevView.editTableView.cellForRow(at: indexPath7)?.textLabel?.text = "場所：指定済"
                
            }
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        

        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
