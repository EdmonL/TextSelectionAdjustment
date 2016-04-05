import java.awt.Point;
import vialab.SMT.*;

TextArea textArea;
boolean showTouch = true; // set true to show colorful touch points for demo

void setup() {
  size(250, 430, SMT.RENDERER);
  SMT.init(this, TouchSource.AUTOMATIC);
  SMT.setWarnUnimplemented(false);
  if (!showTouch) {
    SMT.setTouchDraw(TouchDraw.NONE);
  }

  textArea = new TextArea(0, 0, width, height, createFont("Courier", 14));
  textArea.textColor = 20;
  textArea.backgroundColor = 255;
  textArea.marginLeft = 20;
  textArea.marginRight = 20;
  textArea.marginTop = 15;
  textArea.marginBottom = 15;
  textArea.lineSpacing = 1.0;
  textArea.text = Trials.trialText[0];
  //textArea.setSelection(90, 95);

  final PinchSelectingZone z = new PinchSelectingZone(textArea);
  //final HandleSelectingZone z = new HandleSelectingZone(0, 0, width, height, textArea);
  z.showTouches = showTouch;
  SMT.add(z);
}

void draw() {
  background(200);
  textArea.draw();
}

