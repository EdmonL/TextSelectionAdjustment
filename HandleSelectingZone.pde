static final class HandleSelectingZone extends TextAreaTouchZone implements Observer {

  private HandleZone[] handles = new HandleZone[2];

  public HandleSelectingZone(final String name, final TextArea textArea) {
    super(name, textArea);
    for (int i = 0; i < handles.length; ++i) {
      handles[i] = new HandleZone(textArea);
    }
    textArea.addObserver(this);
  }

  public void setHandleScaling(final float scaling) {
    for (final HandleZone h : handles) {
      h.setScaling(scaling);
    }
  }

  @Override public void update(final Observable o, final Object arg) {
    if (arg == handles[0] || arg == handles[1]) {
      final HandleZone handle = (HandleZone) arg;
      final HandleZone otherHandle = handle == handles[0] ? handles[1] : handles[0];
      if (handle.getNumTouches() > 0) {
        otherHandle.updateOrientation();
      } else if (getNumTouches() == 0 && otherHandle.getNumTouches() == 0) {
        nofitySelection();
      }
    } else if (arg instanceof TextSelectionEvent) {
      final TextSelectionEvent event = (TextSelectionEvent) arg;
      if (event.isInitial) {
        handles[0].setPosition(event.start, event.startRow);
        handles[1].setPosition(event.end, event.endRow);
        for (final HandleZone h : handles) {
          add(h);
        }
      } else if (!event.hasSelection()) {
        for (final HandleZone h : handles) {
          h.removeFromParent();
        }
      }
    }
  }

  private void nofitySelection() {
    if (handles[0].textOffset != textArea.getSelectionStart()) {
      final HandleZone tmp0 = handles[0];
      handles[0] = handles[1];
      handles[1] = tmp0;
    }
    textArea.setChanged();
    textArea.notifyObservers(new TextSelectionEvent(handles[0].textOffset, handles[0].row, handles[1].textOffset, handles[1].row, false, false));
  }
}

