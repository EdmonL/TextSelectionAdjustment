import java.awt.Color;
import java.awt.Point;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;
import java.util.Observable;
import java.util.Observer;
import vialab.SMT.*;

TextArea textArea;
boolean showTouch = true; // set true to show colorful touch points for demo

final Trials trials = new Trials(2);
boolean startScreen = true, endScreen = false;
String userId = "";
String tech;

final PFont screenFont = createFont("Arial Black", 20, true);
final int buttonWidth = 200;
final int buttionHeight = 50;

void setup() {
  size(320, 550, SMT.RENDERER);
  SMT.init(this, TouchSource.AUTOMATIC);
  //  SMT.init(this, TouchSource.WM_TOUCH);
  SMT.setWarnUnimplemented(false);
  if (!showTouch) {
    SMT.setTouchDraw(TouchDraw.NONE);
  }

  final int buttonX = (width - buttonWidth) / 2;
  SMT.add(new ButtonZone("handlesButton", buttonX, height - 5 * buttionHeight, buttonWidth, buttionHeight, "HANDLES", screenFont));
  SMT.add(new ButtonZone("pinchButton", buttonX, height + 20 - 4 * buttionHeight, buttonWidth, buttionHeight, "PINCH", screenFont));
}

void draw() {
  background(255);
  if (startScreen) {
    pushStyle();
    textFont(screenFont);
    fill(0);
    textAlign(CENTER, TOP);
    text("Enter User ID: ", width / 2, 100);
    text(userId + "_", width / 2, 150);
    popStyle();
  } else if (endScreen) {
    pushStyle();
    textFont(screenFont);
    fill(0);
    textAlign(CENTER, CENTER);
    text("It's completed! Thank you!", width / 2, height / 2);
    popStyle();
  }
}

void keyPressed() {
  if (startScreen) {
    if (key == BACKSPACE && userId.length() > 0) {
      userId = userId.substring(0, userId.length() - 1);
    } else if (key != CODED && userId.length() < 15 && (Character.isLetterOrDigit(key) || key == '_' || key == '-')) {
      userId += key;
    }
  }
}

private TextArea startTrials() {
  startScreen = false;
  SMT.remove("handlesButton");
  SMT.remove("pinchButton");
  final TextArea textArea = createTextArea();
  startTrial(textArea);
  return textArea;
}

void pressHandlesButton(final Zone button) {
  if (userId.length() <= 0) {
    return;
  }
  tech = "handles";
  SMT.add(new HandleSelectingZone(tech, startTrials()));
}

void pressPinchButton(final Zone button) {
  if (userId.length() <= 0) {
    return;
  }
  tech = "pinch";
  SMT.add(new PinchSelectingZone(tech, startTrials()));
}

private boolean startTrial(final TextArea textArea) {
  if (!trials.next()) {
    return false;
  }
  textArea.text = trials.getText();
  textArea.redraw();
  return true;
}

private void finishTrial(final TextArea textArea) {
}

private TextArea createTextArea() {
  final TextArea textArea = new TextArea(0, 0, width, height, createFont("Courier", 14));
  textArea.textColor = 20;
  textArea.marginLeft = 22;
  textArea.marginRight = 20;
  textArea.marginTop = 15;
  textArea.marginBottom = 35;
  textArea.lineSpacing = 1.1;
  textArea.addObserver(new Observer() {
    @Override public void update(final Observable o, final Object arg) {
      if (arg instanceof TextSelectionEvent) {
        final TextSelectionEvent event = (TextSelectionEvent) arg;
        if (event.isInitial) { // start timeing
        } else if (!event.hasTouches && event.hasSelection() && trials.checkTarget(event.start, event.end)) { // check goal
          finishTrial(textArea);
          if (!startTrial(textArea)) {
            SMT.remove(tech);
            endScreen = true;
          }
        }
      }
    }
  }
  );
  return textArea;
}

