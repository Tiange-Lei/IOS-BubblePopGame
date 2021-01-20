//
//  File.swift
//  BubblePop
//
//  Created by Tiange Lei on 28/12/20.
//

import UIKit

class Setting_VC: UIViewController {
    @IBOutlet weak var bubbleLabel: UILabel!
    @IBOutlet weak var bubbleSlider: UISlider!
    @IBOutlet weak var gameTimeSlider: UISlider!
    @IBOutlet weak var gameTimeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Retrieve the setted time and setted bubbles from UDM and give them to corresponding sliders
        gameTimeSlider.value=Float(UserDefaultManagement.shared.getSettedTime())
        gameTimeLabel.text=String(UserDefaultManagement.shared.getSettedTime())
        bubbleSlider.value=Float(UserDefaultManagement.shared.getSettedBubbles())
        bubbleLabel.text=String(UserDefaultManagement.shared.getSettedBubbles())
    }
    //Using segue to pass the setted time and bubbles to game_VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="toGame"{
            let destinationController=segue.destination as! Game_VC
            destinationController.gameTimeCount=Int(gameTimeSlider.value)
            destinationController.maxBubbles=Int(bubbleSlider.value)
        }
    }
    //Using a label to display the value of time when it changed
    @IBAction func timeChanged(_ sender: UISlider) {
        let currentTime=Int(sender.value)
        gameTimeLabel.text="\(currentTime)"
        UserDefaultManagement.shared.defaults.setValue(currentTime, forKey: "setTime")
    }
    //Using a label to display the value of maximum bubble when it changed
    @IBAction func bubbleChanged(_ sender: UISlider) {
        let currentBubbles=Int(sender.value)
        bubbleLabel.text="\(currentBubbles)"
        UserDefaultManagement.shared.defaults.setValue(currentBubbles, forKey: "setBubble")
    }
    //Navigate to entry_VC when back button is clicked
    @IBAction func backClicked(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    //Navigate to Game_VC when start button is clicked
    @IBAction func startClicked(_ sender: UIButton){
        self.performSegue(withIdentifier: "toGame", sender: nil)
    }
}

