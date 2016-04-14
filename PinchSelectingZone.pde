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
      int textOffset, otherTextOffset, row;
      if (isStart) {
        textOffset = textArea.getSelectionStart();
        otherTextOffset = textArea.getSelectionEnd();
        row = selStartRow;
      } else {
        textOffset = textArea.getSelectionEnd();
        otherTextOffset = textArea.getSelectionStart();
        row = selEndRow;
      }
      final Point p = textArea.getInnerPointByTextPosition(textOffset, row);
      p.translate(touch.x - touchPoint.x, touch.y - touchPoint.y);
      final TextPosition tp = textArea.getTextPositionByInnerPoint(p);
      if (textOffset != tp.offset || row != tp.row) {
        if (row != tp.row && otherTextOffset == tp.offset) {
          if (textArea.getLineOffset(tp.row) == tp.offset) {
            ++tp.offset;
          } else if (textArea.getLineEnd(tp.row) == tp.offset) {
            --tp.offset;
          } else {
            final Point ip = textArea.getPointByInnerPoint(textArea.getInnerPointByTextPosition(tp.offset, tp.row));
            if (touch.x <= ip.x) {
              --tp.offset;
            } else {
              ++tp.offset;
            }
          }
        }
        if (otherTextOffset != tp.offset) {
          textArea.setSelection(tp.offset, otherTextOffset);
          if (isStart) {
            selStartRow = tp.row;
          } else {
            selEndRow = tp.row;
          }
          isStart = tp.offset == textArea.getSelectionStart();
          if (selStartRow > selEndRow) {
            final int tmpStart = selStartRow;
            selStartRow = selEndRow;
            selEndRow = tmpStart;
          }
          touchPoint.setLocation(touch.x, touch.y); // reset touch point so that trivial offsets are ignored intead of being accumulated.
        }
      }
      return;
    }
    final Touch otherTouch = touches[0].sessionID == touch.sessionID ? touches[1] : touches[0];
    final Point otherTouchPoint = touchRecords.get(otherTouch.sessionID);
    if (otherTouchPoint == null) {
      return;
    }
    int textOffset, otherTextOffset, row, otherRow;
    if (selStartRow == selEndRow) {
      if (touchPoint.x <= otherTouchPoint.x) {
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
    } else {
      if (touchPoint.y <= otherTouchPoint.y) {
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
    }
    final Point p = textArea.getInnerPointByTextPosition(textOffset, row);
    p.translate(touch.x - touchPoint.x, touch.y - touchPoint.y);
    final TextPosition tp = textArea.getTextPositionByInnerPoint(p);
    if (textOffset != tp.offset || row != tp.row) {
      if (row != tp.row && otherTextOffset == tp.offset) {
        if (textArea.getLineOffset(tp.row) == tp.offset) {
          ++tp.offset;
        } else if (textArea.getLineEnd(tp.row) == tp.offset) {
          --tp.offset;
        } else if (touch.x <= otherTouchPoint.x) {
          --tp.offset;
        } else {
          ++tp.offset;
        }
      }
      if (otherTextOffset != tp.offset) {
        if (tp.row == otherRow && (row != otherRow || tp.offset <= otherTextOffset && touch.x <= otherTouchPoint.x || tp.offset >= otherTextOffset && touch.x >= otherTouchPoint.x)
          || tp.row < otherRow && touch.y <= otherTouchPoint.y || tp.row > otherRow && touch.y >= otherTouchPoint.y) {
          textArea.setSelection(tp.offset, otherTextOffset);
          if (row == selStartRow) {
            selStartRow = tp.row;
          } else {
            selEndRow = tp.row;
          }
          if (selStartRow > selEndRow) {
            final int tmpStart = selStartRow;
            selStartRow = selEndRow;
            selEndRow = tmpStart;
          }
        }
        touchPoint.setLocation(touch.x, touch.y); // reset touch point so that trivial offsets are ignored intead of being accumulated.
      }
    }
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

