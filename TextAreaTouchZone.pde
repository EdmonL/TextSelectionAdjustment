import java.util.LinkedList;
import java.util.List;

static class TextAreaTouchZone extends Zone {

  protected final TextArea textArea;
  protected boolean isTap;
  private final List<TextSelectionListener> tsListeners = new LinkedList<TextSelectionListener>();

  public TextAreaTouchZone(final TextArea textArea) {
    super(textArea.x, textArea.y, textArea.width, textArea.height);
    this.textArea = textArea;
  }

  public void addTextSelectionListener(final TextSelectionListener newListener) {
    if (newListener == null) {
      return;
    }
    for (final TextSelectionListener l : tsListeners) {
      if  (newListener.equals(l)) {
        break;
      }
    }
    tsListeners.add(newListener);
  }

  public boolean removeTextSelectionListener(final TextSelectionListener newListener) {
    tsListeners.remove(newListener);
  }

  @Override public void touchDown(final Touch touch) {
    isTap = getNumTouches() == 1;
  }

  @Override public void touchUp(final Touch touch) {
    if (getNumTouches() == 0) {
      if (isTap) {
        if (textArea.hasSelection()) {
          textArea.setSelection(0, 0);
          onHidingSelection();
        } else {
          final TextPosition tp = textArea.getTextPositionByInnerPoint(textArea.getInnerPointByPoint(touch.x, touch.y));
          textArea.setSelection(tp.offset, tp.offset + tp.toward);
          onShowingSelection(textArea.getSelectionStart(), tp.row, textArea.getSelectionEnd(), tp.row);
        }
      }
    }
    isTap = false;
  }

  @Override public void touchMoved(final Touch touch) {
    final Point lp = touch.getLastPoint();
    isTap = isTap && (lp == null || lp.x == touch.x && lp.y == touch.y);
  }

  @Override public void touch() {
  }

  @Override public void draw() {
    textArea.draw();
  }

  protected void onShowingSelection(final int start, final int startRow, final int end, final int endRow) {
  }

  protected void onHidingSelection() {
  }

  protected void nofitySelection(final boolean allTouchesUp) {
    if (textArea.hasSelection()) {
      final int selStart = textArea.getSelectionStart();
      final int selEnd = textArea.getSelectionEnd();
      for (final TextSelectionListener l : tsListeners) {
        l.onTextSelection(selStart, selEnd, allTouchesUp);
      }
    }
  }
}

