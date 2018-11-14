
import UIKit
import Speech
import RealmSwift

class chantViewController: UIViewController, SFSpeechRecognizerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var receivedTextView: UITextView!
    @IBOutlet weak var chantTextView: UITextView!

    @IBOutlet weak var naviItem: UINavigationItem!
    
    @IBOutlet weak var recordButton: UIButton!
    
    var received: String!
    
    let endChantButton: UIBarButtonItem = UIBarButtonItem(title: "完了", style:UIBarButtonItemStyle.plain, target: self, action: #selector(clickEndChantButton))
    
    
    //音声認識
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()

    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
        if audioEngine.isRunning {
            // 音声エンジン動作中なら停止
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("停止中", for: .disabled)
            recordButton.backgroundColor = UIColor.lightGray
            return
        }
        // 録音を開始する
        try! startRecording()
        chantTextView.text = "認識中です..."
        recordButton.setTitle("認識を終わる", for: [])
        recordButton.backgroundColor = UIColor.red
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.layer.masksToBounds = true
        recordButton.layer.cornerRadius = 15
        
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "戻る", style:UIBarButtonItemStyle.plain, target: self, action: #selector(self.clickBackButton))
        self.naviItem.leftBarButtonItem = backButton
        
        
        self.naviItem.rightBarButtonItem = endChantButton
        endChantButton.isEnabled = false
        
        
        
        receivedTextView.delegate = self
        receivedTextView.text = received
        //行間を設定
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSParagraphStyleAttributeName : style]
        receivedTextView.attributedText = NSAttributedString(string: receivedTextView.text,
                                                             attributes: attributes)
        
        
        chantTextView.delegate = self
        chantTextView.isEditable = true
        
    }
 
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //タップしたら全選択
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.perform(#selector(selectAll(_:)), with: self, afterDelay: 0.1)
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //行間を設定
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSParagraphStyleAttributeName : style]
        chantTextView.attributedText = NSAttributedString(string: chantTextView.text,
                                                          attributes: attributes)

        
        //正しく唱えられてたらendChantButtonをtrueに
        if( self.receivedTextView.text == self.chantTextView.text){
            self.endChantButton.isEnabled = true
        } else {
            self.endChantButton.isEnabled = false
        }
    }
    
    
    func clickBackButton() {
        //通知から直で来た時のためにdismissでなくてちゃんとtableView(homeView)に遷移
        returnToHomeView()
        
    }
    
    func clickEndChantButton() {
        //回数を記録して一覧に遷移
        //Realmから呼び出し
        let config = Realm.Configuration(schemaVersion: 5)
        let realm = try! Realm(configuration: config)
        
        //全部読んでcontentが同じやつ
        let affirmations = realm.objects(modelAffirmation.self)
        for affirmation in affirmations {
            
            if(self.receivedTextView.text == affirmation.content){
                
                try! realm.write() {
                    affirmation.chantTimes += 1
                }
            }
        }
        
        returnToHomeView()
        
    }
    
    func returnToHomeView() {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "homeView")
        present(nextView, animated: true, completion: nil)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:   // 許可OK
                    self.recordButton.isEnabled = true
                    self.recordButton.backgroundColor = UIColor.blue
                case .denied:       // 拒否
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("録音許可なし", for: .disabled)
                case .restricted:   // 限定
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("このデバイスでは無効", for: .disabled)
                case .notDetermined:// 不明
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("録音機能が無効", for: .disabled)
                }
            }
        }
        
        speechRecognizer.delegate = self
    }
    
    private func startRecording() throws {
        if let recognitionTask = recognitionTask {
            // 既存タスクがあればキャンセルしてリセット
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            
            fatalError("リクエスト生成エラー")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        guard let inputNode = audioEngine.inputNode else {
            
            fatalError("InputNodeエラー")
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            var isFinal = false
            
            if let result = result {
                self.chantTextView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("唱える", for: [])
                self.recordButton.backgroundColor = UIColor.blue
                
                //行間を設定
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                let attributes = [NSParagraphStyleAttributeName : style]
                self.chantTextView.attributedText = NSAttributedString(string: self.chantTextView.text, attributes: attributes)
                
                //正しく唱えられてたらendChantButtonをtrueに
                if( self.receivedTextView.text == self.chantTextView.text){
                    self.endChantButton.isEnabled = true
                } else {
                    self.endChantButton.isEnabled = false
                }
                
                
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()   // オーディオエンジン準備
        try audioEngine.start() // オーディオエンジン開始
        
    }
    
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            // 利用可能になったら、録音ボタンを有効にする
            recordButton.isEnabled = true
            recordButton.setTitle("始めます", for: [])
            recordButton.backgroundColor = UIColor.blue
            
            chantTextView.isEditable = true
            
        } else {
            // 利用できないなら、録音ボタンは無効にする
            recordButton.isEnabled = false
            recordButton.setTitle("現在、使用不可", for: .disabled)
        }
    }
    
    
    //キーボードがかぶらないように
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

