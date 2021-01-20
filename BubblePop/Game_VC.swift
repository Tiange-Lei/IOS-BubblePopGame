//
//  File.swift
//  BubblePop
//
//  Created by Tiange Lei on 21/12/20.
//

import UIKit
import AVFoundation

class Game_VC: UIViewController {


    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBOutlet weak var gamePointsLabel: UILabel!
    @IBOutlet weak var gameTimerLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    var score = Double(0)
    //Retrieve the playername and scoredata from UDM
    var playerName=UserDefaultManagement.shared.getPlayerName()
    var scoreData=UserDefaultManagement.shared.getRecord()
    //As a global vaiable, last clicked bubble is used to judge the sequence of each clicked bubble
    var lastClickedBubble=""
    var audioPlayer:AVAudioPlayer!
    var threeSecondsCountDownTimer: Timer!
    var gamingCountDownTimer: Timer!
    var gameStartCount=3
    //Default value of gametime and max bubble
    var gameTimeCount=UserDefaultManagement.shared.getSettedTime()
    var maxBubbles=UserDefaultManagement.shared.getSettedBubbles()

    //As a global vairable, it is used to manage the total amount of bubbles
    var bubbleArray=[UIButton]()
    //Get the width and height of the screen for the arrangement of bubbles
    let screenWidth=UIScreen.main.bounds.width
    let screenHeight=UIScreen.main.bounds.height

    override func viewDidLoad() {
        super.viewDidLoad()
        // Prepare for the sound of popping bubbles from audioPlayer
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "popSound", ofType: "mp3")!))
            audioPlayer!.prepareToPlay()
        }catch{
            print("error")
        }
        //Start the 3 seconds countdown timer
        threeSecondsCountDownTimer=Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDownStart), userInfo: nil, repeats: true)
    }
    //Show a label of 3 seconds countdown when the timer start to work
    @objc func countDownStart(){
        gameStartCount -= 1
        countDownLabel.text=String(gameStartCount)
        //When the three seconds countdown ends, start the gaming countdown timer
        if gameStartCount==0{
            countDownLabel.text="Go!"
            gamingCountDownTimer=Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [self]
                timer2 in
                self.gameCountDown()
                self.randomBubble(maxBubbles,screenWidth,screenHeight)
            }
        }
        //When the three seconds countdown ends after zero, clear the text of this label and invalidate the three second countdown timer
        if gameStartCount<0{
            countDownLabel.text=""
            threeSecondsCountDownTimer.invalidate()
        }
    }
    //When the game countdown start, the according label of time and score will be updated per second
    @objc func gameCountDown(){
        gameTimerLabel.text=String(gameTimeCount)
        gameTimeCount -= 1
        gamePointsLabel.text=String(Int(round(score)))
        if scoreData.count != 0{
            highScoreLabel.text=String(scoreData[0].score)
            if Int(round(score)) >= scoreData[0].score{
                highScoreLabel.text=String(Int(round(score)))
            }
        }else{
            highScoreLabel.text=String(Int(round(score)))
        }
        if gameTimeCount == -1{
            self.gamingCountDownTimer.invalidate()
            //record and update the record from UDM
            let scoreRecords=recordScore(scoreData, playerName, Int(round(score)))
            //Since the score records are stored as struc format of tuple array in UDM, encode the data before storing it
            let recordData = try! PropertyListEncoder().encode(scoreRecords)
            UserDefaultManagement.shared.defaults.set(recordData, forKey: "record")
            //Navigate to leader_VC and pass the score to leaderVC as well
            let vc=self.storyboard?.instantiateViewController(identifier: "Leader") as! Leader_VC
            vc.modalPresentationStyle = .fullScreen
            vc.score=Int(round(score))
            //Since the user is going to leader_VC after finshing the game, the text of the button of leader_VC changed into "play again"
            vc.textForStartButton="Play Again"
                self.present(vc, animated: true)
        }
    }
    // Random bubble generator function, which will be called per second during the game time
    @objc func randomBubble(_ maxBubbles:Int,_ screenWidth:CGFloat,_ screenHeight:CGFloat){
        //Settle down the radius and position of each bubble
        let bubbleRadius=screenWidth/5
        let maxX=Int(screenWidth-bubbleRadius)
        let minY=Int(screenHeight/8)
        let maxY=Int(screenHeight-bubbleRadius)
        //Each second, the amount of bubbles should be in the range of 0 to maxBubbles
        let bubbleAmount=Int.random(in: 0...maxBubbles)
        //Fill the bubble array with the bubble amount generated randomly
        while bubbleArray.count<bubbleAmount {
            //The color of the bubble is decided by the decide color function
            let color=decideColor()
            //Random location for each bubble
            let randomX=Int.random(in: 0...maxX)
            let randomY=Int.random(in: minY...maxY)
            let bubble:UIButton=UIButton.init(frame: CGRect(x:CGFloat(randomX),y:CGFloat(randomY), width:bubbleRadius,height:bubbleRadius))
                bubble.setImage(UIImage(named:color), for: .normal)
                bubble.imageView?.contentMode = .scaleAspectFit
                bubble.alpha=0.8
            //Check if the new bubble and the bubbles inside bubbleArray are overlapping, if not, put the new one into the bubble array
            let result=checkIfOverlapping(bubbleArray, newButton: bubble)
            if !result{
                bubbleArray.append(bubble)
            }
        }
        // Randomly remove some of the bubbles from bubble array if the next bubble amount is greater than the previous bubble amount
        while bubbleArray.count>bubbleAmount{
            let randomIndex=Int.random(in: 0...bubbleArray.count-1)
            let deleteBubble=bubbleArray[randomIndex]
            deleteBubble.removeFromSuperview()
            bubbleArray=bubbleArray.filter{$0 != deleteBubble}
        }
        //For each bubble in the bubble array, add it to subview and give it the click function
        for bubble in bubbleArray{
            self.view.addSubview(bubble)
            bubble.addTarget(self, action: #selector(bubbleClicked(_:)), for: .touchDown)
            bubble.addTarget(self, action: #selector(animate(_:)), for: .touchUpInside)
        }
    }
    //Objc function for each bubble being clicked
    @objc public func bubbleClicked(_ bubble:UIButton) {
        //play the bubble poping sound effect
        audioPlayer!.stop()
        audioPlayer!.play()
        //judge the score according to the color of the clicked bubble and set the crack bubble image
        //CB stands for Crack Bonus(clicking on the same color bubble will show a score x 1.5 message)
        switch bubble.currentImage {
        case UIImage(named:"red"):
            if(lastClickedBubble=="red"){
                score+=1*1.5
                bubble.setImage(UIImage(named: "CBred"), for: .normal)
            }else{
                score+=1
                bubble.setImage(UIImage(named: "Cred"), for: .normal)
            }
            lastClickedBubble="red"
        case UIImage(named:"black"):
            if(lastClickedBubble=="black"){
                score+=10*1.5
                bubble.setImage(UIImage(named: "CBblack"), for: .normal)
            }else{
                score+=10
                bubble.setImage(UIImage(named: "Cblack"), for: .normal)
            }
            lastClickedBubble="black"
        case UIImage(named:"green"):
            if(lastClickedBubble=="green"){
                score+=5*1.5
                bubble.setImage(UIImage(named: "CBgreen"), for: .normal)
            }else{
                score+=5
                bubble.setImage(UIImage(named: "Cgreen"), for: .normal)
            }
            lastClickedBubble="green"
        case UIImage(named:"pink"):
            if(lastClickedBubble=="pink"){
                score+=2*1.5
                bubble.setImage(UIImage(named: "CBpink"), for: .normal)
            }else{
                score+=2
                bubble.setImage(UIImage(named: "Cpink"), for: .normal)
            }
            lastClickedBubble="pink"
        case UIImage(named:"blue"):
            if(lastClickedBubble=="blue"){
                score+=8*1.5
                bubble.setImage(UIImage(named: "CBblue"), for: .normal)
            }else{
                score+=8
                bubble.setImage(UIImage(named: "Cblue"), for: .normal)
            }
            lastClickedBubble="blue"
        default:
            return
        }
        //remove the clicked bubble from both the superview and bubble array

        bubbleArray=bubbleArray.filter{$0 != bubble}
    }

    @objc func animate(_ bubble:UIButton){
        UIView.animate(withDuration: 0.4, animations: {
            bubble.transform=CGAffineTransform(scaleX: 2, y: 2)
            bubble.alpha=0.0
        },completion: {done in
        if done{
        bubble.removeFromSuperview()
        }
        })
    }
    //Put the new score and playername into the score record array
    func recordScore(_ record:Array<ScoreRecord>,_ playerName:String,_ playerScore:Int)->Array<ScoreRecord>{
        var newRecord=record
        newRecord.append(ScoreRecord(name:playerName,score:playerScore))
        return newRecord.sorted(by: {$0.score>$1.score})
    }
    //Overlapping check for bubbles in bubble array
    func checkIfOverlapping(_ array:[UIButton],newButton:UIButton)->Bool{
        var array2=[Int]()
        for button in array{
            if button.frame.intersects(newButton.frame){
                array2.append(1)
            }else{
                array2.append(0)
            }
        }
        if array2.contains(1){
            return true
        }else{
            return false
        }
    }
    //Decide the color for bubbles base on the instruction
    func decideColor()->String{
        let colors=["black","green","red","blue","pink"]
        let num=Int.random(in: 1...20)
        switch num {
        case 1...8:
            return colors[2]
        case 9...14:
            return colors[4]
        case 15...17:
            return colors[1]
        case 18...19:
            return colors[3]
        case 20:
            return colors[0]
        default:
            return "Error"
        }
    }
}
