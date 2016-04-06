import java.awt.Color;
import java.awt.Point;
import vialab.SMT.*;

TextArea textArea;
boolean showTouch = true; // set true to show colorful touch points for demo

void setup() {
  size(250, 430, SMT.RENDERER);
  SMT.init(this, TouchSource.WM_TOUCH);
  SMT.setWarnUnimplemented(false);
  if (!showTouch) {
    SMT.setTouchDraw(TouchDraw.NONE);
  }

  textArea = new TextArea(0, 0, width, height, createFont("Courier", 14));
  textArea.textColor = 20;
  textArea.marginLeft = 22;
  textArea.marginRight = 20;
  textArea.marginTop = 15;
  textArea.marginBottom = 35;
  Trials.generateTrials();
  textArea.text = Trials.trialText[0];


  final PinchSelectingZone z = new PinchSelectingZone(textArea);
  //final HandleSelectingZone z = new HandleSelectingZone(textArea);
  z.showTouches = showTouch;

  SMT.add(z);
}

void draw() {
  background(200);
}

