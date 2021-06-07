//
//  RecordVC.swift
//  GrabadoraVoz
//
//  Created by Angel Olvera on 04/06/21.
//

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class RecordVC: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var timerL: UILabel!
    @IBOutlet weak var hRecordV: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var viewRecord: UIView!
    
    private let email: String
    private let provider: ProviderType
        
//    let fileName = "\(self.getDate()).m4a"
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var isRecording = false
    let metadata = StorageMetadata()
    let database = Firestore.firestore()
    
    var arrUrls : [urlDownloaded] = []
    private var collectionRef: CollectionReference!
    
    var timer1: Timer = Timer()
    var count: Int = 0
    var timerCounting: Bool = false
    var lastDuration: String = "00 : 00 : 00"
        
    init(email: String, provider: ProviderType) {
        self.email = email
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAudio()
        downloadData(id: self.getId())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupView(){
        tableview.delegate = self
        tableview.dataSource = self
        tableview.rowHeight = UITableView.automaticDimension
        tableview.register(RecordsCell.nib(), forCellReuseIdentifier: RecordsCell.Identifier)
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        defaults.synchronize()
        viewRecord.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    }
    
    private func setupAudio(){
        recordingSession = AVAudioSession.sharedInstance()
        do{
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        setupRecorder()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    private func setupRecorder() {
        let recordSettings = [AVFormatIDKey : kAudioFormatAppleLossless,
                                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                                AVEncoderBitRateKey: 320000,
                                AVNumberOfChannelsKey: 2,
                                AVSampleRateKey: 44100.0] as [String : Any]
        do {
            audioRecorder = try AVAudioRecorder(url: getDocumentsDirectory().appendingPathComponent("\(self.getDate()).m4a"), settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func downloadData(id: String){
        collectionRef = database.collection(id)
        collectionRef.addSnapshotListener { snapshot, error in
            self.arrUrls.removeAll()
            if let err = error {
                debugPrint("Error al extraer los datos: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    debugPrint(document.data())
                    let data = document.data()
                    let urldownloaded = data["urlAudio"] as? String
                    let dateDownloaded = data["date"] as? String
                    let timeDownloaded = data["duration"] as? String
                    let downloads = urlDownloaded(url: urldownloaded!, date: dateDownloaded!, time: timeDownloaded!)
                    self.arrUrls.append(downloads)
                }
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    private func getId() -> String{
        let user = Auth.auth().currentUser
        let uid = user!.uid
        return "\(uid)"
    }
    
    private func uploadFirestore(url: String, id: String, date: String){
        let docRef = database.document("\(id)/\(date)")
        docRef.setData([
            "urlAudio": url, "date" : date, "duration" : lastDuration
        ])
    }
    
    @objc func timerCounter1() {
        count += 1
        let time = self.secondsToHours(seconds: count)
        let timeString = self.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerL.text = timeString
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        //MARK: Revisar si está activo el grabador
        if !isRecording {
            hRecordV.constant = 292
            timerL.isHidden = false
            blurView.isHidden = false
            recordButton.setImage(UIImage(named: "recordStop"), for: .normal)
            audioRecorder.record()
            isRecording = !isRecording
            timerCounting = true
            count = 0
            timer1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter1), userInfo: nil, repeats: true)
        } else {
            hRecordV.constant = 190
            timerL.isHidden = true
            blurView.isHidden = true
            recordButton.setImage(UIImage(named: "recordStart"), for: .normal)
            audioRecorder.stop()
            isRecording = !isRecording
            timerCounting = false
            timer1.invalidate()
            lastDuration = timerL.text!
            timerL.text = "00 : 00 : 00"
            
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "provider")
        defaults.synchronize()
        switch provider {
        case .basic:
            do{
                try Auth.auth().signOut()
                navigationController?.popViewController(animated: true)
            }catch{
                //Error al cerrar sesión
            }
        }
    }

}

extension RecordVC: AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        debugPrint("el audio grabado: \(recorder.url)")
        metadata.contentType = "audio/m4a"
        let date = self.getDate()
        let riversRef = Storage.storage().reference().child("message_voice").child("\(date).m4a")
        do {
            let audioData = try Data(contentsOf: recorder.url)
            riversRef.putData(audioData, metadata: metadata){ (data, error) in
                if error == nil{
                    debugPrint("se guardo el audio")
                    riversRef.downloadURL {url, error in
                        guard let downloadURL = url else { return }
                        debugPrint("el url descargado", downloadURL)
                        self.uploadFirestore(url: downloadURL.absoluteString, id: self.getId(), date: date)
                    }
                }
                else {
                    if let error = error?.localizedDescription{
                        debugPrint("error al cargar imagen", error)
                    }
                    else {
                        debugPrint("error de codigo")
                    }
                }
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

extension RecordVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recordCell = tableView.dequeueReusableCell(withIdentifier: RecordsCell.Identifier, for: indexPath) as! RecordsCell
        recordCell.setData(m: arrUrls[indexPath.row])
        return recordCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Borrar"
    }
    

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let indexToDelete = arrUrls[indexPath.row]
            let audioToDelete = Storage.storage().reference().child("message_voice").child("\(indexToDelete.date ?? "").m4a")
            audioToDelete.delete { error in
                if error != nil {
                    debugPrint("error al borrar")
                }
                else{
                    debugPrint("se borro correctamente")
                    self.database.collection(self.getId()).document(indexToDelete.date!).delete()
                }
            }
            

        }
    }
}
