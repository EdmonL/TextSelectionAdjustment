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

  textArea = new TextArea(10, 10, width - 20, height - 20, createFont("Courier", 14));
  textArea.textColor = 20;
  textArea.backgroundColor = 255;
  textArea.marginLeft = 10;
  textArea.marginRight = 10;
  textArea.marginTop = 5;
  textArea.marginBottom = 5;
  textArea.lineSpacing = 1.0;
  textArea.text = "********************************************************************************************************************************"
  + "********************************************************************************************************************************"
  + "*****************************@**************************************************************************************************"
  + "********************************************************************************************************************************"
  + "********************************************************************************************************************************";
  textArea.setSelection(240, 250);

  final PinchSelectingZone z = new PinchSelectingZone(0, 0, width, height, textArea);
  z.showTouches = showTouch;
  SMT.add(z);
}

void draw() {
  background(200);
  textArea.draw();
}

