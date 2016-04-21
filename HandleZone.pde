static final class HandleZone extends Zone {

  public static final int WIDTH = 20;
  public static final int HEIGHT = 30;
  public static final int GAP_FROM_LINE = 2;
  public static final int SHADE_WIDTH = 1;

  private final TextArea textArea;
  private int textOffset, row;
  private boolean toLeft;
  private boolean isMoving;
  private float scaling = 0.7;
  private final Point touchOffset = new Point();
  private Color myColor = new Color(0x40, 0x96, 0xb2, 240);

  public HandleZone(final TextArea textArea) {
    super(0, GAP_FROM_LINE, WIDTH, HEIGHT);
    this.textArea = textArea;
  }

  public void setScaling(final float scaling) {
    this.scaling = scaling;
  }

  public void setPosition(final int textOffset, final int row) {
    this.textOffset = textOffset;
    this.row = row;
    this.toLeft = textOffset == textArea.getSelectionStart();
    updatePosition();
  }

  public void updateOrientation() {
    final boolean left = textOffset == textArea.getSelectionStart();
    if (left != toLeft) {
      toLeft = left;
      scale(-1.0, 1.0);
    }
  }

  @Override public void draw() {
    pushStyle();
    noStroke();
    fill(0, 90);
    if (toLeft) {
      quad(-SHADE_WIDTH, SHADE_WIDTH, -SHADE_WIDTH, HEIGHT + SHADE_WIDTH, WIDTH - SHADE_WIDTH, HEIGHT + SHADE_WIDTH, WIDTH - SHADE_WIDTH, HEIGHT/2 + SHADE_WIDTH);
    } else {
      quad(SHADE_WIDTH, SHADE_WIDTH, SHADE_WIDTH, HEIGHT + SHADE_WIDTH, WIDTH + SHADE_WIDTH, HEIGHT + SHADE_WIDTH, WIDTH + SHADE_WIDTH, HEIGHT/2 + SHADE_WIDTH);
    }
    popStyle();
    pickDraw();
    pushStyle();
    stroke(255, 90);
    strokeWeight(SHADE_WIDTH);
    line(0, 0, WIDTH, HEIGHT / 2);
    line(WIDTH, HEIGHT, WIDTH, HEIGHT / 2);
    popStyle();
  }

  @Override public void pickDraw() {
    pushStyle();
    noStroke();
    fill(myColor.getRed(), myColor.getGreen(), myColor.getBlue(), myColor.getAlpha());
    quad(0, 0, 0, HEIGHT, WIDTH, HEIGHT, WIDTH, HEIGHT / 2);
    popStyle();
  }

  @Override public void touchMoved(final Touch touch) {
    if (isMoving) {
      final TextPosition tp = textArea.getTextPositionByInnerPoint(new Point(touch.x + touchOffset.x, touch.y + touchOffset.y));
      if (textOffset != tp.offset || row != tp.row) {
        final int anotherOffset = textArea.getSelectionStart() == textOffset ? textArea.getSelectionEnd() : textArea.getSelectionStart();
        if (anotherOffset != tp.offset) {
          textOffset = tp.offset;
          row = tp.row;
          textArea.setSelection(textOffset, anotherOffset);
          updatePosition();
          textArea.notifyObservers(this);
        }
      }
    }
  }

  @Override public void touchDown(final Touch touch) {
    isMoving = getNumTouches() == 1;
    if (isMoving) {
      final Point p = textArea.getInnerPointByTextPosition(textOffset, row);
      touchOffset.setLocation(p.x - touch.x, p.y - touch.y);
    }
  }

  @Override public void touch() {
  }

  @Override public void touchUp(final Touch touch) {
    if (isMoving) {
      updateOrientation();
    }
    isMoving = false;
    if (getNumTouches() == 0) {
      textArea.setChanged();
      textArea.notifyObservers(this);
    }
  }

  private void updatePosition() {
    final Point p = textArea.getInnerPointByTextPosition(textOffset, row);
    resetMatrix();
    translate(p.x, textArea.getLineBottom(row));
    scale(scaling);
    if (toLeft) {
      scale(-1.0, 1.0);
    }
  }
}

