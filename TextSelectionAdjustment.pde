import vialab.SMT.*;

TextArea textArea;

void setup() {
  size(300, 600, SMT.RENDERER);
  SMT.init(this, TouchSource.AUTOMATIC);
  SMT.setWarnUnimplemented(false);

  textArea = new TextArea(0, 0, width, height, createFont("Arial", 20));
  textArea.textSize = 20;
  textArea.marginLeft = 0;
  textArea.marginTop = 0;
  textArea.marginBottom = 0;
  textArea.text = "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------==================="
    + "The quick brown fox jumps over the lazy dog. THE QUICK BROWN FOX JUPMS OVER THE LAZY DOG. ---------------********************&&&&&&&&&&&&&&&&&&&-----------===================";
  textArea.selectionStart = 500;
  textArea.selectionEnd = 510;

  SMT.add(new PinchSelectingZone(0, 0, width, height, textArea));
}

void draw() {
  background(255);
  textArea.draw();
}

