static final class PinchSelectingZone extends TextAreaTouchZone {

  int currentTrial = 0;
  boolean showTouches = false;

  private static final class TouchRecord { // these are the points delimiting the selection in text and accociated with the touch points
    long id; // the touch point id that this inner point is associated with
    Point point; // the touch point; used as the last history to calculate touch point movement
    Point innerPoint; // I call as "inner pointers" the small points in demo which delimits the selection
    Color myColor; // just for demo

    TouchRecord(long id, final Point point, final Point innerPoint) {
      this.id = id;
      this.point = point;
      this.innerPoint = innerPoint;
    }
  }

  private final HashMap<Long, TouchRecord> touches = new HashMap<Long, TouchRecord>(); // touch point id -> inner point record; bindings between the inner points and touch points

  public PinchSelectingZone(final TextArea textArea) {
    super(textArea);
  }

  @Override public void touchDown(final Touch touch) {
    super.touchDown(touch);
    bindTouches();
  }

  @Override public void touchUp(final Touch touch) {
    bindTouches();
    super.touchUp(touch);
    if (getNumTouches() == 0) {
      textArea.setChanged();
      textArea.notifyObservers(Boolean.valueOf(true));
    }
  }

  @Override public void touchMoved(final Touch touch) {
    super.touchMoved(touch);
    if (touches.isEmpty()) {
      return;
    }
    final Touch[] ts = getTouches();
    if (ts.length != 2) {
      touches.clear();
      return;
    }
    // goal: update touch record and set selection
    // c indicates the current, l indicates the last, and o indicates the other
    final Touch oTouch = (ts[0].sessionID == touch.sessionID ? ts[1] : ts[0]);
    final TouchRecord ltr = touches.get(touch.sessionID);
    final TouchRecord otr = touches.get(oTouch.sessionID);
    if (ltr == null || otr == null) {
      touches.clear();
      return;
    }
    final Point cp = new Point(touch.x, touch.y);
    final Point lp = ltr.point;
    if (lp.x == cp.x && lp.y == cp.y) {
      return;
    }

    final Point lip = ltr.innerPoint; // last inner point
    Point cip = new Point(lip.x + cp.x - lp.x, lip.y + cp.y - lp.y);
    final TextPosition otp = textArea.getTextPositionByInnerPoint(otr.innerPoint);

    // visual consistency
    // we need to stop fingers from coming across each other when the fingers are not doing so
    // thinking about a senario where user pinch close multiple lines into one
    // when the selection has reduced to one but user's fingers are still moving towards each other, we need to stop the selection expansion
    // another case is we need to change the binding when multiple lines becomes one to confirm with our binding rule when,
    // for example, the upper touch point (bound to the start of selection) becomes the right one on one line (ought to be bound to the end of selection).
    if (cp.y < oTouch.y && cip.y > otr.innerPoint.y && lip.y <= otr.innerPoint.y || cp.y > oTouch.y && cip.y < otr.innerPoint.y && lip.y >= otr.innerPoint.y) {
      cip.y = otr.innerPoint.y;
    }
    final TextPosition ctp = textArea.getTextPositionByInnerPoint(cip);
    if (ctp.row == otp.row) {
      if (cp.x < oTouch.x && cip.x > otr.innerPoint.x && lip.x <= otr.innerPoint.x || cp.x > oTouch.x && cip.x < otr.innerPoint.x && lip.x >= otr.innerPoint.x) {
        cip.x = otr.innerPoint.x;
      }
    }

    // selection should not disappear; we need find as least a closest character to select
    if (ctp.offset == otp.offset) {
      final Point currentInnerPoint = textArea.getInnerPointByTextPosition(ctp);
      if (ctp.offset == textArea.getLineEnd(ctp.row)) {
        --ctp.offset;
        cip.x = (int)Math.ceil((currentInnerPoint.x + textArea.getInnerPointByTextPosition(ctp).x) / 2.0) - 1;
      } else if (ctp.offset == textArea.getLineOffset(ctp.row)) {
        ++ctp.offset;
        cip.x = (int)Math.ceil((currentInnerPoint.x + textArea.getInnerPointByTextPosition(ctp).x) / 2.0);
      } else if (lip.x < otr.innerPoint.x) {
        --ctp.offset;
        cip.x = (int)Math.ceil((currentInnerPoint.x + textArea.getInnerPointByTextPosition(ctp).x) / 2.0) - 1;
      } else {
        ++ctp.offset;
        cip.x = (int)Math.ceil((currentInnerPoint.x + textArea.getInnerPointByTextPosition(ctp).x) / 2.0);
      }
    }

    textArea.setSelection(ctp.offset, otp.offset);

    // visual consistency
    // this is when fingers come across with each other but inner points do not.
    // swap the inner points (bindings) if necessary
    if (ctp.row == otp.row && (cp.y < oTouch.y && cip.y > otr.innerPoint.y || cp.y > oTouch.y && cip.y < otr.innerPoint.y || cp.x < oTouch.x && cip.x > otr.innerPoint.x || cp.x > oTouch.x && cip.x < otr.innerPoint.x) 
      || ctp.row != otp.row && (cp.y < oTouch.y && cip.y > otr.innerPoint.y || cp.y > oTouch.y && cip.y < otr.innerPoint.y)) {
      cip = textArea.getInnerPointByTextPosition(ctp);
      otr.innerPoint = textArea.getInnerPointByTextPosition(otp);
      if (ctp.row == otp.row) {
        if (cip.x < otr.innerPoint.x && cp.x > oTouch.x || cip.x > otr.innerPoint.x && cp.x < oTouch.x) {
          swapPoint(cip, otr.innerPoint);
        }
      } else {
        if (cip.y < otr.innerPoint.y && cp.y > oTouch.y || cip.y > otr.innerPoint.y && cp.y < oTouch.y) {
          swapPoint(cip, otr.innerPoint);
        }
      }
    }
    // record the points as the history for next time move
    final TouchRecord ctr = ltr;
    ctr.point = cp;
    ctr.innerPoint = cip;
  }

  @Override public void draw() {
    super.draw();
    if (showTouches) { // for demo only
      pushStyle();
      ellipseMode(RADIUS);
      textAlign(LEFT, TOP);
      noStroke();
      for (final TouchRecord r : touches.values ()) {
        final Point center = textArea.getPointByInnerPoint(r.innerPoint);
        final Color c = r.myColor;
        fill(c.getRed(), c.getGreen(), c.getBlue(), c.getAlpha());
        ellipse(center.x, center.y, 5, 5);
        fill(c.getRed(), c.getGreen(), c.getBlue(), 255);
        textSize(16);
        text(center.x + "," + center.y, center.x + 1, center.y + 1);
        textSize(20);
        text(r.point.x + "," + r.point.y, r.point.x + 3, r.point.y + 3);
      }
      popStyle();
    }
  }

  // this method decides which touch point is bound to the start of the selection or the end of it
  private void bindTouches() {
    final Touch[] ts = getTouches();
    // some criteria to decide it's the time for binding
    if (ts.length != 2 || !textArea.hasSelection()) {
      touches.clear();
      return;
    }
    if (touches.size() == 2) { // only bind when there are exactly two touch points
      for (final Touch t : ts) {
        if (!touches.containsKey(t.sessionID)) {
          touches.clear();
          break;
        }
      }
    } else {
      touches.clear();
    }
    if (!touches.isEmpty()) {
      return;
    }
    // binding; 
    // the general rule is if there are multiple lines, upper touch point is bound to the start of selection
    // if there is only one line selected, left touch point is bound to the start of selection
    final int[] s = new int[2];
    final int[] r = new int[2];
    s[0] = textArea.getSelectionStart();
    s[1] = textArea.getSelectionEnd();
    r[0] = textArea.getRowByTextOffset(s[0]);
    r[1] = textArea.getRowByTextOffset(s[1]);
    if (r[0] == r[1]) {
      if (ts[0].x > ts[1].x) {
        final int tmp0 = s[0];
        s[0] = s[1];
        s[1] = tmp0;
      }
    } else if (ts[0].y > ts[1].y) {
      int tmp0 = s[0];
      s[0] = s[1];
      s[1] = tmp0;
      tmp0 = r[0];
      r[0] = r[1];
      r[1] = tmp0;
    }
    final TouchRecord[] tr = new TouchRecord[2];
    for (int i = 0; i < 2; ++i) {
      tr[i] = new TouchRecord(ts[i].sessionID, new Point(ts[i].x, ts[i].y), textArea.getInnerPointByTextOffset(s[i]));
      touches.put(ts[i].sessionID, tr[i]);
    }
    // for demo only
    tr[0].myColor = new Color(190, 50, 50, 200);
    tr[1].myColor = new Color(50, 50, 190, 200);
    for (int i = 0; i < 2; ++i) {
      final Color c = tr[i].myColor;
      ts[i].setTint(c.getRed(), c.getGreen(), c.getBlue(), c.getAlpha());
    }
  }
}

