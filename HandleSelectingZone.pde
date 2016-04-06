static class HandleSelectingZone extends TextAreaTouchZone implements TextSelectionListener {

  private HandleZone[] handles = new HandleZone[2];

  public HandleSelectingZone(final TextArea textArea) {
    super(textArea);
    for (int i = 0; i < handles.length; ++i) {
      handles[i] = new HandleZone(textArea);
    }
  }

  public void setHandleScaling(final float scaling) {
    for (final HandleZone h : handles) {
      h.setScaling(scaling);
    }
  }

  @Override public void onTextSelection(final int start, final int end, final boolean allTouchesUp, final Object src) {
    if (!
  }

  protected void onShowingSelection(final int start, final int startRow, final int end, final int endRow) {
    handles[0].setPosition(start, startRow);
    handles[1].setPosition(end, endRow);
    for (final HandleZone h : handles) {
      add(h);
    }
  }

  protected void onHidingSelection() {
    for (final HandleZone h : handles) {
      h.removeFromParent();
    }
  }
}

