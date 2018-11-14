
import Foundation
import RealmSwift


class modelAffirmation: Object {
    
    //登録した日時
    dynamic var registeredDate: String = ""
    
    //通知を区別するためのid 日時で！　stringにする
    dynamic var dateIdTime: String = ""
    dynamic var dateIdPlace: String = ""
    
    dynamic var content : String = ""
    dynamic var chantTimes: Int = 0
    
    //時間で通知するか
    dynamic var ifNoticeTime: Bool = false
    dynamic var noticeTimeHour: Int = 0
    dynamic var noticeTimeMinutes: Int = 0
    dynamic var timeRepeats: Bool = false
    
    //場所で通知するか
    dynamic var ifNoticePlace: Bool = false
    dynamic var lati: Double = 0.0
    dynamic var long: Double = 0.0
}
