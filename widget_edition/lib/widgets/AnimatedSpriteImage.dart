import 'dart:async';

import 'package:flutter/widgets.dart';

class AnimatedSpriteImage extends StatefulWidget {

  final Image image;
  final Size spriteSize;
  final int startIndex;
  final int endIndex;
  final int playTimes;
  final Duration duration;
  final Axis axis;

  AnimatedSpriteImage({
    Key? key,
    required this.image,
    required this.spriteSize,
    required this.duration,
    this.axis = Axis.horizontal,
    this.startIndex = 0,
    this.endIndex = 0,
    this.playTimes = 0,//0 = loop
  }) : super(key: key);

  @override
  _AnimatedSpriteImageState createState() => _AnimatedSpriteImageState();
}

class _AnimatedSpriteImageState extends State<AnimatedSpriteImage> {

  int currentIndex = 0;
  int currentTimes = 0;

  @override
  void initState() {

    currentIndex = widget.startIndex;

    Timer.periodic(widget.duration, (timer) { 
      if(currentTimes<=widget.playTimes){
        setState(() {
          if(currentIndex>=widget.endIndex){
            if(widget.playTimes!=0)currentTimes++;
            if(currentTimes<widget.playTimes||widget.playTimes==0)currentIndex=widget.startIndex;
            else currentIndex = widget.endIndex;
          }
          else currentIndex++;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.spriteSize.width,
        height: widget.spriteSize.height,
        
        child: Stack(
          children: [
            Positioned(
              left: widget.axis==Axis.horizontal?-widget.spriteSize.width*currentIndex:0,
              top: widget.axis==Axis.vertical?-widget.spriteSize.height*currentIndex:0,
              child: widget.image
            )
          ],
        ),
    );
  }
}