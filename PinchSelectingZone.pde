import java.awt.Color;

static class PinchSelectingZone extends Zone {

  boolean showTouches = false;

  private static final class TouchRecord {
    long id;
    Point point;
    Point innerPoint;
    Color myColor;

    TouchRecord(long id, final Point point, final Point innerPoint) {
      this.id = id;
      this.point = point;
      this.innerPoint = innerPoint;
    }
  }

  private final TextArea textArea;
  private final HashMap<Long, TouchRecord> touches = new HashMap<Long, TouchRecord>();

  PinchSelectingZone(final int x, final int y, final int width, final int height, TextArea textArea) {
    super(x, y, width, height);
    this.textArea = textArea;
  }

  @Override public void touchDown(final Touch touch) {
    bindTouches();
  }

  @Override public void touchUp(final Touch touch) {
    bindTouches();
  }

  @Override public void touchMoved(final Touch touch) {
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
    final Point cip = new Point(lip.x + cp.x - lp.x, lip.y + cp.y - lp.y);
    final TextPosition ltp = textArea.getTextPositionByInnerPoint(lip);
    final TextPosition otp = textArea.getTextPositionByInnerPoint(otr.innerPoint);

    boolean switchRecords = false;

    // visual consistency
    if (cp.y < oTouch.y && cip.y > otr.innerPoint.y) {
      if (lip.y <= otr.innerPoint.y) {
        cip.y = otr.innerPoint.y;
      } else {
        switchRecords = true;
      }
    } else if (cp.y > oTouch.y && cip.y < otr.innerPoint.y) {
      if (lip.y >= otr.innerPoint.y) {
        cip.y = otr.innerPoint.y;
      } else {
        switchRecords = true;
      }
    }

    final TextPosition ctp = textArea.getTextPositionByInnerPoint(cip);

    // selection should not disappear
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

    final TouchRecord ctr = ltr;
    ctr.point = cp;
    ctr.innerPoint = cip;
    textArea.setSelection(ctp.offset, otp.offset);
    if (switchRecords) {
      ctr.innerPoint = otr.innerPoint;
      otr.innerPoint = cip;
    }
  }

  @Override public void touch() {
  }

  @Override public void draw() {
    if (showTouches) {
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

  private void bindTouches() {
    final Touch[] ts = getTouches();
    if (ts.length != 2 || !textArea.hasSelection()) {
      touches.clear();
      return;
    }
    if (touches.size() == 2) {
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
    tr[0].myColor = new Color(190, 50, 50, 200);
    tr[1].myColor = new Color(50, 50, 190, 200);
    for (int i = 0; i < 2; ++i) {
      final Color c = tr[i].myColor;
      ts[i].setTint(c.getRed(), c.getGreen(), c.getBlue(), c.getAlpha());
    }
  }
}

