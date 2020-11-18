import 'package:flutter/material.dart';
import 'package:flutter_flappy_bird/bird.dart';
import 'dart:async';
import 'barriers.dart';
import 'dart:math';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//TODO: Add gradient to the background
// TODO: commit to memory the high score
// ToDO: Show number of clicks
// TODO: allow different sprites ++
// TODO: enhance the barriers
// Todo: Enable clouds??
// TODO: The next todo is going to be

class _MyHomePageState extends State<MyHomePage> {
  static double birdYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdYaxis;
  bool gameStarted = false;
  static double barrierXone = 1;
  double barrierXtwo = barrierXone + 1.7;
  int score=0;
  int highScore=0;
  double bOneBottom =200.0;
  double bOneTop = 150.0;
  double bTwoBottom = 120.0;
  double bTwoTop = 230.0;
  double screenHeight;
  double alignmentFactor;

List<double> generateRandomHeight() {
  double heightBottom;
  double heightTop;
  var screenFactor = ((screenHeight / 3) *
      2); //this is the sky size of container
  var rand = Random().nextDouble();
  while (rand == 0) {
    rand = Random().nextDouble();
    print(rand);
  }
  heightBottom = rand * screenFactor;
  (heightBottom > screenFactor / 2) ? heightBottom -= 150 : heightBottom =
      heightBottom; //If the height of the bottom barrier is too big
  (heightBottom <= 0) ? heightBottom = 50 : heightBottom = heightBottom; // if its too small

  heightTop = screenFactor - heightBottom - 150;
  if (heightTop <= 0){
    heightTop = 50;
  }
  if (heightTop > screenFactor/2){
    heightTop -= 150;
  }
  return [heightBottom, heightTop];

}

void makeNewBarrier(int barrierNo){
  var list = generateRandomHeight();

  switch(barrierNo){
    case 1:
      bOneBottom = list[0];
      bOneTop = list[1];
      break;
    case 2:
      bTwoBottom = list[0];
      bTwoTop = list[1];
      break;
  }
}

  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdYaxis;
    });
  }
  void restartGame(){
    barrierXone = 1;
    barrierXtwo = barrierXone + 1.7;
    birdYaxis = 0;
    initialHeight = birdYaxis;
    time = 0;
    height = 0;
    bOneBottom =200.0;
    bOneTop = 150.0;
    bTwoBottom = 120.0;
    bTwoTop = 230.0;
    gameStarted = false;


  }

  bool checkCollision() {
    //this will happen if the birds yAxis falls between
    bool retVal = false;
    if (barrierXone > -0.30 && barrierXone < 0.40) {

      if (birdYaxis > (1 - bOneBottom * alignmentFactor) && birdYaxis < 1.2) {
        retVal = true;
      }
      if (birdYaxis < -(1.2 - bOneTop * alignmentFactor) && birdYaxis > -1.3) {
        retVal = true;
      }
    }

    if (barrierXtwo > -0.30 && barrierXtwo < 0.40) {

      if (birdYaxis > (1 - bTwoBottom * alignmentFactor) && birdYaxis < 1.2) {
        retVal = true;
      }
      if (birdYaxis < -(1.2 - bTwoTop * alignmentFactor) && birdYaxis > -1.3) {
        retVal = true;
      }
    }

    return retVal;
  }
  void calculateBarrierAlignment(){
    //I used flex 2 on 1 expanded widget and no flex in the other so total parts of the screen =3, and a small green patch of 15pixels
    double segmentHeight = (screenHeight / 3); //Expanded widget
    double skyPartHeight = 2*segmentHeight + 15.0; //2 parts for sky+15 for ground
    alignmentFactor = (1 / (skyPartHeight/2))-0.000; //So Alignment is 1bottom, 0 center, -1 top. we Split the sky height into 2, so 1 for top 1 for bottom. Then I divide 1 by that segment to find the exact alignment number for each pixel (so Y axis number is height of barrier* alignmentFactor), so if the bird is at that y axis then its a hit! the last -0.001 is there to adjust for default padding
  }

  void startGame() {
    gameStarted = true;
    score = 0;
    Timer.periodic(Duration(milliseconds: 60), (timer) {

      time += 0.05;
      height = -4.9 * time * time + 2.8 * time;
      setState(() {
        birdYaxis = initialHeight - height;
      });

      setState(() { //moving barrier one from off screen to forward
        if(barrierXone < -2){
          barrierXone +=3.5;
          makeNewBarrier(1);
        } else {
          barrierXone -= 0.05;
        }
        if(barrierXone <0.06 && barrierXone > 0){
          score++;
        }


      });

      setState(() { //moving barrier one from off screen to forward
        if(barrierXtwo < -2){
          barrierXtwo +=3.5;
          makeNewBarrier(2);
        } else {
          barrierXtwo -= 0.05;
        }
        if(barrierXtwo <0.05 && barrierXtwo > 0){
          score++;
        }
      });

      if(checkCollision()){
        timer.cancel();
        gameStarted = false;
        _sowDialog();
      }
      if (birdYaxis > 1.2) { //if bird hits the ground
        timer.cancel();
        gameStarted = false;
        _sowDialog();
      }
    });
  }
  void _sowDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: Text(
          'GAME OVER',
          style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Score: " + score.toString(),
            style: TextStyle(color: Colors.white,)
          ),
          actions: [
            FlatButton(
                onPressed: (){
                  if (score > highScore){ highScore = score;}
                  //print('about to run init state');
                  //initState();
                  setState(() {
                    restartGame();
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Play Again'))
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    calculateBarrierAlignment();
    return GestureDetector(
      onTap: () {
        if (gameStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack( //lowest one is the one stacked on top,
                children: [
                  AnimatedContainer( //Sky and bird
                    alignment: Alignment(0, birdYaxis),
                    duration: Duration(milliseconds: 0),
                    color: Colors.lightBlueAccent,
                    child: MyBird(),
                  ),
                  AnimatedContainer( //First barrier bottom
                    alignment: Alignment(barrierXone, 1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(
                      size: bOneBottom,
                    ),
                  ),
                  AnimatedContainer( //First barrier top
                    alignment: Alignment(barrierXone, -1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(
                      size: bOneTop,
                    ),
                  ),
                  AnimatedContainer( //Second Barrier bottom
                    alignment: Alignment(barrierXtwo, 1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(
                      size: bTwoBottom,
                    ),
                  ),
                  AnimatedContainer( //Second Barrier top
                    alignment: Alignment(barrierXtwo, -1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(
                      size: bTwoTop,
                    ),
                  ),
                  Container(
                    child: gameStarted
                        ? Text('')
                        : Text(
                      'T A P   T O   P L A Y',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    alignment: Alignment(0, -0.3),
                  ),
                ],
              ),
            ),
            Container(
              height: 15,
              color: Colors.green,
            ),
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Score',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          score.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 35),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hi-Score',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          highScore.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 35),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
