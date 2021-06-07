//
//  RecordsCell.swift
//  GrabadoraVoz
//
//  Created by Angel Olvera on 05/06/21.
//

import UIKit
import AVFoundation
import FirebaseStorage

class RecordsCell: UITableViewCell {
    
    static let Identifier = "RecordsCell"
    
    static func nib() -> UINib {
        return UINib(nibName: Identifier, bundle: nil)
    }
  
    @IBOutlet weak var playStopButton: UIButton!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var durationL: UILabel!
    
    var soundPlayer: AVAudioPlayer!
    var urlRecibed: String = ""
    
    var timer: Timer = Timer()
    var count: Int = 0
    var timerCounting: Bool = false
    var lastDuration: String = "00 : 00 : 00"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData (m: urlDownloaded){
        urlRecibed = m.url!
        nameL.text = m.date
        durationL.text = m.time
    }
    
    private func prepareForPlay(url: String) {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(nameL.text ?? "").m4a")
        let storage = Storage.storage()
        let httpsReference = storage.reference(forURL: url)
        httpsReference.getData(maxSize: 10 * 1024 * 1024) { [self] (data, error) in
            if let error = error {
                print(error)
            } else {
                if let d = data {
                    do {
                        try d.write(to: fileURL)
                        self.soundPlayer = try AVAudioPlayer(contentsOf: fileURL)
                        self.soundPlayer.prepareToPlay()
                        self.soundPlayer.delegate = self
                        self.soundPlayer.volume = 1.0
                        self.soundPlayer.play()
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    @objc func timerCounter() {
        count += 1
        let time = secondsToHours(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        durationL.text = timeString
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String{
        var timeString = " "
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    func secondsToHours(seconds: Int) -> (Int, Int, Int){
        return ((seconds / 3600), ((seconds / 3600) / 60), ((seconds % 3600) % 60))
    }
    
    @IBAction func playStopButtonTapped(_ sender: Any) {
        playStopButton.setImage(UIImage(named: "stopButton"), for: .normal)
        prepareForPlay(url: urlRecibed)
    }
    
}

extension RecordsCell: AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playStopButton.setImage(UIImage(named: "playButton"), for: .normal)
        timer.invalidate()
        count = 0
        soundPlayer.stop()
    }
}
