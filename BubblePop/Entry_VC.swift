//
//  ViewController.swift
//  BubblePop
//
//  Created by Tiange Lei on 19/12/20.
//

import UIKit
import AVFoundation


class Entry_VC: UIViewController {
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var videoLayer: UIView!
    var timeChanged=60
    var bubbles=15
    var playerName=UserDefaultManagement.shared.getPlayerName()
    var backgroundVideoPlayer:AVPlayer?
    var backgroundMusicPlayer:AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()


//                UserDefaultManagement.shared.clearRecord()
//                UserDefaultManagement.shared.clearName()
        // Play the background Video
        playVideo()
        playMusic()
        // Observe that when the app is going to be terminated
        NotificationCenter.default.addObserver(self,
             selector: #selector(applicationWillTerminate(notification:)),
             name: UIApplication.willTerminateNotification,
             object: nil)
        //Observe when the app is going to back to menu after the game, then stop the music
        NotificationCenter.default.addObserver(self,
             selector: #selector(stopBackgroundMusic(notification:)),
             name: Notification.Name("stopMusic"),
             object: nil)
        //Name TextFiled configuration:
        NameTextField.autocapitalizationType = .words
        NameTextField.returnKeyType = .done
        NameTextField.delegate=self
        //Retrieve the playername from UDM for convenience
        NameTextField.text=playerName
        //If there is no playername in the UDM, the name textfield becomes the first responder and force user to put in a name
    }
    // Play the stored video as the entry_VC background
    func playVideo(){
        guard let path=Bundle.main.path(forResource: "intro4", ofType: "mp4")else{
            return
        }
        backgroundVideoPlayer=AVPlayer(url:URL(fileURLWithPath: path))
        let playerLayer=AVPlayerLayer(player:backgroundVideoPlayer)
        backgroundVideoPlayer!.actionAtItemEnd=AVPlayer.ActionAtItemEnd.none
        playerLayer.frame=self.view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        self.videoLayer.layer.insertSublayer(playerLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundVideoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: backgroundVideoPlayer!.currentItem)
        backgroundVideoPlayer!.seek(to: CMTime.zero)
        backgroundVideoPlayer!.play()
            
    }
    //Play the background music
    func playMusic(){
        if let player=backgroundMusicPlayer{
            player.stop()
        }else{
            let url=Bundle.main.path(forResource: "little-frog", ofType: "mp3")
            do {
                try AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                guard let url=url else{
                    return
                }
                backgroundMusicPlayer=try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
                guard let player=backgroundMusicPlayer else{
                    return
                }
                player.prepareToPlay()
                player.play()
                player.numberOfLoops = -1
                player.volume=0.08
            }
            catch  {
                print("Music error")
            }
        }
    }
    //The objc selector function when received the notification of terminating application and clear the setting records
    @objc func applicationWillTerminate(notification: Notification) {
        UserDefaultManagement.shared.clearSetting()
    }
    @objc func stopBackgroundMusic(notification: Notification){
        backgroundMusicPlayer!.stop()
    }
    //When the video end, restart it for looping
    @objc func backgroundVideoDidEnd(){
        backgroundVideoPlayer!.seek(to: CMTime.zero)
    }
    //Objc function for start button
    @IBAction func didTapStart(){
        //Create an alert
        let alertController=UIAlertController(title: "", message: "Please input a name", preferredStyle:  .alert)
        let alertAction=UIAlertAction(title: "OK", style:  .cancel) { (action) in
            self.NameTextField.becomeFirstResponder()
        }
        //If there is no name in name textfield, ask the player to put in a name before start the game
        if NameTextField.text==""{
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            return
        //Store the value of name textfield in UDM as player name and navigate to setting_VC
        }else{
            UserDefaultManagement.shared.defaults.setValue(NameTextField.text, forKey: "playerName")
            self.performSegue(withIdentifier: "toSetting", sender: nil)
        }
    }
    //Objc function to navigate to leader_VC when leaderboard is pressed
    @IBAction func didTapLeader(){
    let vc=self.storyboard?.instantiateViewController(identifier: "Leader") as! Leader_VC
        vc.modalPresentationStyle = .fullScreen
        //Since the user go to the leaderboard directly from entry_VC, set the score to nil for leader_VC to distinguish
        vc.score=nil
        self.present(vc, animated: true)
    }
}

// An extension for the UItextfield of entry_VC to configure when the keyboard will return
extension Entry_VC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name=textField.text{
            if name==""{
                return false
            }else{
                playerName=name
                UserDefaultManagement.shared.defaults.setValue(playerName, forKey: "playerName")
                textField.resignFirstResponder()
                return true
            }
        }else{
            return false
        }
    }
}


