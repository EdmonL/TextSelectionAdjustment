static class PinchSelectingZone extends Zone {

  boolean showInnerPoints = false;

  private static final class TouchRecord {
    int offset;
    Point point, innerPoint;
    color myColor;

    TouchRecord(final int offset, final Point point, final Point innerPoint) {
      this.offset = offset;
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
    final int lo = ltr.offset, oo = otr.offset;
    final int co = textArea.getTextOffsetByInnerPoint(cip);
    final int lr = textArea.getRowByTextOffset(lo);
    final int cr = textArea.getRowByTextOffset(co);
    final int or = textArea.getRowByTextOffset(oo);

    final TouchRecord ctr = ltr;
    ctr.offset = co;
    ctr.point = cp;
    ctr.innerPoint = cip;
    textArea.setSelection(ctr.offset, otr.offset);
  }

  @Override public void touch() {
  }

  @Override public void draw() {
    if (showInnerPoints) {
      pushStyle();
      ellipseMode(RADIUS);
      noStroke();
      for (final TouchRecord r : touches.values ()) {
        final Point center = textArea.getPointByInnerPoint(r.innerPoint);
        fill(r.myColor);
        ellipse(center.x, center.y, 5, 5);
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
      tr[i] = new TouchRecord(s[i], new Point(ts[i].x, ts[i].y), textArea.getInnerPointByTextOffset(s[i]));
      touches.put(ts[i].sessionID, tr[i]);
    }
    ts[0].setTint(190, 50, 50, 200);
    tr[0].myColor = 0xC8BE3232;
    ts[1].setTint(50, 50, 190, 200);
    tr[1].myColor = 0xC83232BE;
  }
}

