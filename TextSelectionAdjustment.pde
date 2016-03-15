import java.awt.Point;
import vialab.SMT.*;

TextArea textArea;
boolean showTouch = true;

void setup() {
  size(400, 600, SMT.RENDERER);
  SMT.init(this, TouchSource.AUTOMATIC);
  SMT.setWarnUnimplemented(false);
  if (!showTouch) {
    SMT.setTouchDraw(TouchDraw.NONE);
  }

  textArea = new TextArea(10, 10, width - 20, height - 20, createFont("Arial", 20));
  textArea.textColor = 20;
  textArea.backgroundColor = 255;
  textArea.marginLeft = 10;
  textArea.marginRight = 10;
  textArea.marginTop = 5;
  textArea.marginBottom = 5;
  textArea.lineSpacing = 1.5;
  textArea.text = "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------===================";
  textArea.setSelection(200, 500);

  final PinchSelectingZone z = new PinchSelectingZone(0, 0, width, height, textArea);
  z.showInnerPoints = showTouch;
  SMT.add(z);
}

void draw() {
  background(200);
  textArea.draw();
}

