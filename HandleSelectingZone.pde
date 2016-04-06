static class HandleSelectingZone extends TextAreaTouchZone implements Observer {

  private HandleZone[] handles = new HandleZone[2];

  public HandleSelectingZone(final TextArea textArea) {
    super(textArea);
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
    }
  }

  @Override public void touchUp(final Touch touch) {
    super.touchUp(touch);
    if (getNumTouches() == 0 && handles[0].getNumTouches() == 0 && handles[1].getNumTouches() == 0) {
      nofitySelection();
    }
  }

  @Override protected void onShowingSelection(final int start, final int startRow, final int end, final int endRow) {
    handles[0].setPosition(start, startRow);
    handles[1].setPosition(end, endRow);
    for (final HandleZone h : handles) {
      add(h);
    }
  }

  @Override protected void onHidingSelection() {
    for (final HandleZone h : handles) {
      h.removeFromParent();
    }
  }

  private void nofitySelection() {
    textArea.setChanged();
    textArea.notifyObservers(Boolean.valueOf(true));
  }
}

