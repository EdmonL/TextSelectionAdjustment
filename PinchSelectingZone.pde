static final class PinchSelectingZone extends TextAreaTouchZone implements Observer {

  private static final int MARK_WIDTH = 5;

  private int selStartRow, selEndRow;
  private final Point selStartTouchOffset = new Point(), selEndTouchOffset = new Point();
  private Color myColor = new Color(0x40, 0x96, 0xb2, 240);
  private final Map<Long, Boolean> touchRecords = new HashMap<Long, Boolean>();

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
    resetTouches();
    if (textArea.hasSelection()) {
      final Touch[] touches = getTouches();
      switch (touches.length) {
      case 1:
        bindTouch(touches[0]);
        break;
      case 2:
        bindTouches(touches[0], touches[1]);
        break;
      }
    }
  }

  @Override public void touchUp(final Touch touch) {
    super.touchUp(touch);
    resetTouches();
    if (textArea.hasSelection()) {
      final Touch[] touches = getTouches();
      switch (touches.length) {
      case 0:
        textArea.setChanged();
        textArea.notifyObservers(new TextSelectionEvent(textArea.getSelectionStart(), selStartRow, textArea.getSelectionEnd(), selEndRow, false, false));
        break;
      case 1:
        bindTouch(touches[0]);
        break;
      case 2:
        bindTouches(touches[0], touches[1]);
        break;
      }
    }
  }

  @Override public void touchMoved(final Touch touch) {
    super.touchMoved(touch);
    final Boolean isStartMark = touchRecords.get(touch.sessionID);
    if (isStartMark == null) {
      return;
    }
    final Touch[] touches = getTouches();
    if (touches.length <= 0 || touches.length > 2) {
      return;
    }

    final boolean isStart = isStartMark.booleanValue();
    int textOffset, otherTextOffset, row, otherRow;
    if (isStart) {
      textOffset = textArea.getSelectionStart();
      otherTextOffset = textArea.getSelectionEnd();
      row = selStartRow;
      otherRow = selEndRow;
    } else {
      textOffset = textArea.getSelectionEnd();
      otherTextOffset = textArea.getSelectionStart();
      row = selEndRow;
      otherRow = selStartRow;
    }
    final Point touchPoint = textArea.getInnerPointByPoint(touch.x, touch.y);
    Point ip = new Point(touchPoint);
    if (isStart) {
      ip.translate(selStartTouchOffset.x, selStartTouchOffset.y);
    } else {
      ip.translate(selEndTouchOffset.x, selEndTouchOffset.y);
    }
    TextPosition tp = textArea.getTextPositionByInnerPoint(ip);
    if (textOffset == tp.offset && row == tp.row) {
      return;
    }

    if (touches.length == 1) {
      ip = textArea.getInnerPointByTextPosition(tp.offset, tp.row);
      if (row != tp.row && otherTextOffset == tp.offset) {
        if (textArea.getLineOffset(tp.row) == tp.offset) {
          ++tp.offset;
        } else if (textArea.getLineEnd(tp.row) == tp.offset) {
          --tp.offset;
        } else {
          if (touchPoint.x <= ip.x) {
            --tp.offset;
          } else {
            ++tp.offset;
          }
        }
      }
      if (otherTextOffset == tp.offset) {
        return;
      }
      textArea.setSelection(tp.offset, otherTextOffset);
      if (isStart) {
        selStartRow = tp.row;
      } else {
        selEndRow = tp.row;
      }
      final boolean newIsStart = tp.offset == textArea.getSelectionStart();
      touchRecords.put(touch.sessionID, newIsStart);
      if (newIsStart != isStart) {
        final int tmpStart = selStartRow;
        selStartRow = selEndRow;
        selEndRow = tmpStart;
        if (newIsStart) {
          selStartTouchOffset.setLocation(selEndTouchOffset);
        } else {
          selEndTouchOffset.setLocation(selStartTouchOffset);
        }
      }
      if (row == tp.row) {
        if (newIsStart) {
          selStartTouchOffset.y = ip.y - touchPoint.y;
        } else {
          selEndTouchOffset.y = ip.y - touchPoint.y;
        }
      }
      return;
    }
    final Touch otherTouch = touches[0].sessionID == touch.sessionID ? touches[1] : touches[0];
    final Point otherTouchPoint = textArea.getInnerPointByPoint(otherTouch.x, otherTouch.y);
    final Point oip = new Point(otherTouchPoint);
    if (isStart) {
      oip.translate(selEndTouchOffset.x, selEndTouchOffset.y);
    } else {
      oip.translate(selStartTouchOffset.x, selStartTouchOffset.y);
    }
    boolean rebind = false;
    if (row <= otherRow && ip.y > oip.y && touchPoint.y <= otherTouchPoint.y || row >= otherRow && ip.y < oip.y && touchPoint.y >= otherTouchPoint.y) {
      ip.y = oip.y;
      tp = textArea.getTextPositionByInnerPoint(ip);
      rebind = true;
    }
    if (row == otherRow && tp.row == otherRow && (textOffset <= otherTextOffset && ip.x > oip.x && touchPoint.x <= otherTouchPoint.x || textOffset >= otherTextOffset && ip.x < oip.x && touchPoint.x >= otherTouchPoint.x)) {
      tp.offset = textOffset <= otherTextOffset ? otherTextOffset - 1 : otherTextOffset + 1;
      rebind = true;
    }
    if (textOffset == tp.offset && row == tp.row) {
      if (rebind) {
        bindTouches(touch, otherTouch);
      }
      return;
    }
    if (row != tp.row && otherTextOffset == tp.offset) {
      if (textArea.getLineOffset(tp.row) == tp.offset) {
        ++tp.offset;
      } else if (textArea.getLineEnd(tp.row) == tp.offset) {
        --tp.offset;
      } else if (touchPoint.x <= otherTouchPoint.x) {
        --tp.offset;
      } else {
        ++tp.offset;
      }
    }
    if (otherTextOffset == tp.offset) {
      if (rebind) {
        bindTouches(touch, otherTouch);
      }
      return;
    }
    textArea.setSelection(tp.offset, otherTextOffset);
    if (isStart) {
      selStartRow = tp.row;
    } else {
      selEndRow = tp.row;
    }
    final boolean newIsStart = tp.offset == textArea.getSelectionStart();
    touchRecords.put(touch.sessionID, newIsStart);
    touchRecords.put(otherTouch.sessionID, !newIsStart);
    if (newIsStart != isStart) {
      final int tmpStart = selStartRow;
      selStartRow = selEndRow;
      selEndRow = tmpStart;
      swapPoint(selStartTouchOffset, selEndTouchOffset);
    }
    rebind = rebind || row != tp.row && tp.row == otherRow;
    rebind = rebind || tp.row > otherRow && touchPoint.y < otherTouchPoint.y || tp.row < otherRow && touchPoint.y > otherTouchPoint.y;
    rebind = rebind || tp.row == otherRow && (tp.offset < otherTextOffset && touchPoint.x > otherTouchPoint.x || tp.offset > otherTextOffset && touchPoint.x < otherTouchPoint.x);
    if (rebind) {
      bindTouches(touch, otherTouch);
      return;
    }
    if (row == tp.row) {
      if (newIsStart) {
        selStartTouchOffset.y = ip.y - touchPoint.y;
      } else {
        selEndTouchOffset.y = ip.y - touchPoint.y;
      }
    }
  }

  @Override void draw() {
    super.draw();
    if (textArea.hasSelection()) {
      final Touch[] touches = getTouches();
      if (touches.length >= 1) {
        final int lineHeight = textArea.getFontHeight();
        pushStyle();
        if (touches.length == 1) {
          final Boolean isStart = touchRecords.get(touches[0].sessionID);
          if (isStart != null) {
            if (isStart.booleanValue()) {
              drawStartMark(lineHeight);
            } else {
              drawEndMark(lineHeight);
            }
          }
        } else {
          drawStartMark(lineHeight);
          drawEndMark(lineHeight);
        }
        popStyle();
      }
    }
  }

  private void bindTouch(final Touch touch) {
    final Point startOffset = textArea.getInnerPointByTextPosition(textArea.getSelectionStart(), selStartRow);
    final Point endOffset = textArea.getInnerPointByTextPosition(textArea.getSelectionEnd(), selEndRow);
    final Point innerPoint = textArea.getInnerPointByPoint(touch.x, touch.y);
    startOffset.translate(-innerPoint.x, -innerPoint.y);
    endOffset.translate(-innerPoint.x, -innerPoint.y);
    final boolean isStart = startOffset.x * startOffset.x + startOffset.y * startOffset.y <= endOffset.x * endOffset.x + endOffset.y * endOffset.y;
    touchRecords.put(touch.sessionID, isStart);
    if (isStart) {
      selStartTouchOffset.setLocation(startOffset);
    } else {
      selEndTouchOffset.setLocation(endOffset);
    }
  }

  private void bindTouches(final Touch t0, final Touch t1) {
    final boolean isT0Start = selStartRow == selEndRow ? t0.x <= t1.x : t0.y <= t1.y;
    final Point startPoint = textArea.getInnerPointByTextPosition(textArea.getSelectionStart(), selStartRow);
    final Point endPoint = textArea.getInnerPointByTextPosition(textArea.getSelectionEnd(), selEndRow);
    final Point t0p = textArea.getInnerPointByPoint(t0.x, t0.y);
    final Point t1p = textArea.getInnerPointByPoint(t1.x, t1.y);
    if (isT0Start) {
      touchRecords.put(t0.sessionID, true);
      selStartTouchOffset.setLocation(startPoint.x - t0p.x, startPoint.y - t0p.y);
      touchRecords.put(t1.sessionID, false);
      selEndTouchOffset.setLocation(endPoint.x - t1p.x, endPoint.y - t1p.y);
    } else {
      touchRecords.put(t0.sessionID, false);
      selEndTouchOffset.setLocation(endPoint.x - t0p.x, endPoint.y - t0p.y);
      touchRecords.put(t1.sessionID, true);
      selStartTouchOffset.setLocation(startPoint.x - t1p.x, startPoint.y - t1p.y);
    }
  }

  private void resetTouches() {
    selStartTouchOffset.setLocation(0, 0);
    selEndTouchOffset.setLocation(0, 0);
    touchRecords.clear();
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

