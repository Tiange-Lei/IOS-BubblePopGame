//
//  Leader_VC.swift
//  BubblePop
//
//  Created by Tiange Lei on 28/12/20.
//

import Foundation
import UIKit


class Leader_VC: UIViewController {
    //Declare score as an optional vaiable since both entry_VC and game_VC can navigate to Leader_VC
    var score:Int?
    //Retrieve information from UDM
    var playerName=UserDefaultManagement.shared.getPlayerName()
    var rank=UserDefaultManagement.shared.getRecord()
    var textForStartButton="Start Game"

    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var Rank1ScoreLabel: UILabel!
    @IBOutlet weak var Rank1NameLabel: UILabel!
    @IBOutlet weak var Rank2NameLabel: UILabel!
    @IBOutlet weak var Rank2ScoreLabel: UILabel!
    @IBOutlet weak var Rank3NameLabel: UILabel!
    @IBOutlet weak var Rank3ScoreLabel: UILabel!
    
    @IBOutlet weak var NoRecordsMessageLabel: UILabel!
    
    @IBOutlet weak var PlayerScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //The text for start button may change according to different situation
        startGameButton.setTitle(textForStartButton, for: .normal)
        //Sort the score record to generate a rank
        //According to the length of rank array, decide how to display the rank information
        switch rank.count {
        case 3...:
            Rank1ScoreLabel.text=String(rank[0].score)
            Rank2ScoreLabel.text=String(rank[1].score)
            Rank3ScoreLabel.text=String(rank[2].score)
            Rank1NameLabel.text=rank[0].name
            Rank2NameLabel.text=rank[1].name
            Rank3NameLabel.text=rank[2].name
            displayScore(score, playerName,rank)
        case 2:
            Rank1ScoreLabel.text=String(rank[0].score)
            Rank2ScoreLabel.text=String(rank[1].score)
            Rank1NameLabel.text=rank[0].name
            Rank2NameLabel.text=rank[1].name
            if score != nil{
                if score==rank[0].score && playerName==rank[0].name{
                    PlayerScoreLabel.text="Congratulations, You got a 🥇 medal!"
                }else{
                    PlayerScoreLabel.text="Congratulations, You got a 🥈 medal!"
                }
            }else{
                PlayerScoreLabel.text=""
            }
        case 1:
            Rank1ScoreLabel.text=String(rank[0].score)
            Rank1NameLabel.text=rank[0].name
            if score != nil{
                PlayerScoreLabel.text="Congratulations, You got a 🥇 medal!"
            }else{
                PlayerScoreLabel.text=""
            }
        default:
            NoRecordsMessageLabel.text="There is no records for now!"
            PlayerScoreLabel.text=""
        }
    }
    //If the player won a medal, display the message for congratulation
    func displayScore(_ score:Int?,_ playerName:String,_ recordValues:Array<ScoreRecord>){
        if let currentScore=score{
            switch (currentScore,playerName) {
            case (recordValues[2].score,recordValues[2].name):
                    PlayerScoreLabel.text="Congratulations, You got a 🥉 medal!"
            case (recordValues[1].score,recordValues[1].name):
                PlayerScoreLabel.text="Congratulations, You got a 🥈 medal!"
            case (recordValues[0].score,recordValues[0].name):
                PlayerScoreLabel.text="Congratulations, You got a 🥇 medal!"
            default:
                PlayerScoreLabel.text="Your Score: \(currentScore)"
            }
        }else{
            PlayerScoreLabel.text=""
        }
    }
    //Navigate to the Game_VC when play again button is clicked
    @IBAction func didTapPlayAgain(){
    let vc=self.storyboard?.instantiateViewController(identifier: "Setting") as! Setting_VC
        vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
    }
    //Navigate to the Entry_VC when back button is clicked
    @IBAction func didTapBackToMenu(){
        if let _=score{
            NotificationCenter.default.post(name: Notification.Name("stopMusic"), object: nil)
                let vc=self.storyboard?.instantiateViewController(identifier: "Entry") as! Entry_VC
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }

    }

}
