static final class PinchSelectingZone extends TextAreaTouchZone implements Observer {

  private static final int MARK_WIDTH = 5;

  private int selStartRow, selEndRow;
  private boolean isStart;
  private Color myColor = new Color(0x40, 0x96, 0xb2, 240);
  private final Map<Long, Point> touchRecords = new HashMap<Long, Point>();

  public PinchSelectingZone(final String name, final TextArea textArea) {
    super(name, textArea);
    textArea.addObserver(this);
  }

  @Override public void update(final Observable o, final Object arg) {
    if (arg instanceof TextSelectionEvent) {
      final TextSelectionEvent event = (TextSelectionEvent) arg;
      if (event.isInitial) {
        selStartRow = event.startRow;
        selEndRow = event.endRow;
      }
    }
  }

  @Override public void touchDown(final Touch touch) {
    super.touchDown(touch);
    touchRecords.clear();
    if (textArea.hasSelection()) {
      final Touch[] touches = getTouches();
      if (touches.length == 1) {
        bindTouch(touch);
      }
      if (touches.length <= 2) {
        for (final Touch t : touches) {
          touchRecords.put(t.sessionID, new Point(t.x, t.y));
        }
      }
    }
  }

  @Override public void touchUp(final Touch touch) {
    super.touchUp(touch);
    touchRecords.clear();
    if (textArea.hasSelection()) {
      final Touch[] touches = getTouches();
      if (touches.length == 0) {
        textArea.setChanged();
        textArea.notifyObservers(new TextSelectionEvent(textArea.getSelectionStart(), selStartRow, textArea.getSelectionEnd(), selEndRow, false, false));
      } else {
        if (touches.length == 1) {
          bindTouch(touches[0]);
        }
        if (touches.length <= 2) {
          for (final Touch t : touches) {
            touchRecords.put(t.sessionID, new Point(t.x, t.y));
          }
        }
      }
    }
  }

  @Override public void touchMoved(final Touch touch) {
    super.touchMoved(touch);
    final Touch[] touches = getTouches();
    if (touches.length > 2) {
      return;
    }
    final Point touchPoint = touchRecords.get(touch.sessionID);
    if (touchPoint == null) {
      return;
    }
    if (touches.length == 1) {
      int textOffset, anotherOffset, row;
      if (isStart) {
        textOffset = textArea.getSelectionStart();
        anotherOffset = textArea.getSelectionEnd();
        row = selStartRow;
      } else {
        textOffset = textArea.getSelectionEnd();
        anotherOffset = textArea.getSelectionStart();
        row = selEndRow;
      }
      final Point p = textArea.getInnerPointByTextPosition(textOffset, row);
      final Point newPoint = new Point(p.x + touch.x - touchPoint.x, p.y + touch.y - touchPoint.y);
      final TextPosition tp = textArea.getTextPositionByInnerPoint(newPoint);
      if (textOffset != tp.offset || row != tp.row) {
        if (anotherOffset != tp.offset) {
          textArea.setSelection(tp.offset, anotherOffset);
          if (isStart) {
            selStartRow = tp.row;
          } else {
            selEndRow = tp.row;
          }
          final boolean oldIsStart = isStart;
          isStart = tp.offset == textArea.getSelectionStart();
          if (isStart != oldIsStart) {
            final int tmpStart = selStartRow;
            selStartRow = selEndRow;
            selEndRow = tmpStart;
          }
          touchPoint.setLocation(touch.x, touch.y); // reset touch point so that trivial offsets are ignored intead of being accumulated.
        }
      }
    }
    //    if (touches.size() != 2) {
    //      return;
    //    }
    //    final Touch[] ts = getTouches();
    //    if (ts.length != 2) {
    //      return;
    //    }
    //    // goal: update touch record and set selection
    //    // c indicates the current, l indicates the last, and o indicates the other
    //    final Touch oTouch = (ts[0].sessionID == touch.sessionID ? ts[1] : ts[0]);
    //    final TouchRecord ltr = touches.get(touch.sessionID);
    //    final TouchRecord otr = touches.get(oTouch.sessionID);
    //    if (ltr == null || otr == null) {
    //      return;
    //    }
    //    final Point cp = new Point(touch.x, touch.y);
    //    final Point lp = ltr.point;
    //    if (lp.x == cp.x && lp.y == cp.y) {
    //      return;
    //    }
    //
    //    final Point lip = ltr.innerPoint; // last inner point
    //    Point cip = new Point(lip.x + cp.x - lp.x, lip.y + cp.y - lp.y);
    //    final TextPosition otp = textArea.getTextPositionByInnerPoint(otr.innerPoint);
    //
    //    // visual consistency
    //    // we need to stop fingers from coming across each other when the fingers are not doing so
    //    // thinking about a senario where user pinch close multiple lines into one
    //    // when the selection has reduced to one but user's fingers are still moving towards each other, we need to stop the selection expansion
    //    // another case is we need to change the binding when multiple lines becomes one to confirm with our binding rule when,
    //    // for example, the upper touch point (bound to the start of selection) becomes the right one on one line (ought to be bound to the end of selection).
    //    if (cp.y < oTouch.y && cip.y > otr.innerPoint.y && lip.y <= otr.innerPoint.y || cp.y > oTouch.y && cip.y < otr.innerPoint.y && lip.y >= otr.innerPoint.y) {
    //      cip.y = otr.innerPoint.y;
    //    }
    //    final TextPosition ctp = textArea.getTextPositionByInnerPoint(cip);
    //    if (ctp.row == otp.row) {
    //      if (cp.x < oTouch.x && cip.x > otr.innerPoint.x && lip.x <= otr.innerPoint.x || cp.x > oTouch.x && cip.x < otr.innerPoint.x && lip.x >= otr.innerPoint.x) {
    //        cip.x = otr.innerPoint.x;
    //      }
    //    }
    //
    //    // selection should not disappear; we need find as least a closest character to select
    //    if (ctp.offset == otp.offset) {
    //      final Point currentInnerPoint = textArea.getInnerPointByTextPosition(ctp);
    //      if (ctp.offset == textArea.getLineEnd(ctp.row)) {
    //        --ctp.offset;
    //        cip.x = (int)Math.ceil((currentInnerPoint.x + textArea.getInnerPointByTextPosition(ctp).x) / 2.0) - 1;
    //      } else if (ctp.offset == textArea.getLineOffset(ctp.row)) {
    //        ++ctp.offset;
    //        cip.x = (int)Math.ceil((currentInnerPoint.x + textArea.getInnerPointByTextPosition(ctp).x) / 2.0);
    //      } else if (lip.x < otr.innerPoint.x) {
    //        --ctp.offset;
    //        cip.x = (int)Math.ceil((currentInnerPoint.x + textArea.getInnerPointByTextPosition(ctp).x) / 2.0) - 1;
    //      } else {
    //        ++ctp.offset;
    //        cip.x = (int)Math.ceil((currentInnerPoint.x + textArea.getInnerPointByTextPosition(ctp).x) / 2.0);
    //      }
    //    }
    //
    //    textArea.setSelection(ctp.offset, otp.offset);
    //
    //    // visual consistency
    //    // this is when fingers come across with each other but inner points do not.
    //    // swap the inner points (bindings) if necessary
    //    if (ctp.row == otp.row && (cp.y < oTouch.y && cip.y > otr.innerPoint.y || cp.y > oTouch.y && cip.y < otr.innerPoint.y || cp.x < oTouch.x && cip.x > otr.innerPoint.x || cp.x > oTouch.x && cip.x < otr.innerPoint.x) 
    //      || ctp.row != otp.row && (cp.y < oTouch.y && cip.y > otr.innerPoint.y || cp.y > oTouch.y && cip.y < otr.innerPoint.y)) {
    //      cip = textArea.getInnerPointByTextPosition(ctp);
    //      otr.innerPoint = textArea.getInnerPointByTextPosition(otp);
    //      if (ctp.row == otp.row) {
    //        if (cip.x < otr.innerPoint.x && cp.x > oTouch.x || cip.x > otr.innerPoint.x && cp.x < oTouch.x) {
    //          swapPoint(cip, otr.innerPoint);
    //        }
    //      } else {
    //        if (cip.y < otr.innerPoint.y && cp.y > oTouch.y || cip.y > otr.innerPoint.y && cp.y < oTouch.y) {
    //          swapPoint(cip, otr.innerPoint);
    //        }
    //      }
    //    }
    //    // record the points as the history for next time move
    //    final TouchRecord ctr = ltr;
    //    ctr.point = cp;
    //    ctr.innerPoint = cip;
  }

  @Override void draw() {
    super.draw();
    if (textArea.hasSelection() && touchRecords.size() >= 1) {
      final int lineHeight = textArea.getFontHeight();
      pushStyle();
      if (touchRecords.size() == 1) {
        if (isStart) {
          drawStartMark(lineHeight);
        } else {
          drawEndMark(lineHeight);
        }
      } else {
        drawStartMark(lineHeight);
        drawEndMark(lineHeight);
      }
      popStyle();
    }
  }

  private void bindTouch(final Touch touch) {
    final Point startPoint = textArea.getInnerPointByTextPosition(textArea.getSelectionStart(), selStartRow);
    final Point endPoint = textArea.getInnerPointByTextPosition(textArea.getSelectionEnd(), selEndRow);
    final Point innerPoint = textArea.getInnerPointByPoint(touch.x, touch.y);
    startPoint.translate(-innerPoint.x, -innerPoint.y);
    endPoint.translate(-innerPoint.x, -innerPoint.y);
    isStart = (startPoint.x * startPoint.x + startPoint.y * startPoint.y <= endPoint.x * endPoint.x + endPoint.y * endPoint.y);
  }

  private void drawStartMark(final int lineHeight) {
    final Point point = textArea.getInnerPointByTextPosition(textArea.getSelectionStart(), selStartRow);
    point.setLocation(point.x - 2, textArea.getLineTop(selStartRow));
    noStroke();
    fill(myColor.getRed(), myColor.getGreen(), myColor.getBlue(), myColor.getAlpha());
    triangle(point.x, point.y, point.x, point.y + lineHeight, point.x - MARK_WIDTH, point.y + Math.round(lineHeight / 2.0));
  }

  private void drawEndMark(final int lineHeight) {
    final Point point = textArea.getInnerPointByTextPosition(textArea.getSelectionEnd(), selEndRow);
    point.setLocation(point.x + 2, textArea.getLineTop(selEndRow));
    noStroke();
    fill(myColor.getRed(), myColor.getGreen(), myColor.getBlue(), myColor.getAlpha());
    triangle(point.x, point.y, point.x, point.y + lineHeight, point.x + MARK_WIDTH, point.y + Math.round(lineHeight / 2.0));
  }
}

