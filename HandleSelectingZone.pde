static class HandleSelectingZone extends TextAreaTouchZone {

  private HandleZone[] handles = new HandleZone[2];

  public HandleSelectingZone(final TextArea textArea) {
    super(textArea);
  }

  @Override public void touchDown(final Touch touch) {
    if(this.getNumTouches()>1){
       return; 
    }
    super.touchDown(touch);
    bindTouches();
  }

  @Override public void touchUp(final Touch touch) {
    if(this.getNumTouches()>0){
       return; 
    }
    super.touchUp(touch);
    bindTouches();
  }

  @Override public void touchMoved(final Touch touch) {
    if (touches.isEmpty()) {
      return;
    }
    final Touch[] ts = getTouches();
    if (ts.length != 1) {
      touches.clear();
      return;
    }
    // goal: update touch record and set selection
    final TouchRecord ltr = touches.get(touch.sessionID);
    

    if (ltr == null) {
      touches.clear();
      return;
    }
  }

  public void setHandleScaling(final float scaling) {
    for (final HandleZone h : handles) {
      h.setScaling(scaling);
    }
  }

  // this method decides which touch point is bound to the start of the selection or the end of it
  private void bindTouches() {
    //Set the initial selection when the screen is first tapped.
    final Touch[] ts = getTouches();
    //When all touches are removed, check the selection against the goal
    if(ts.length == 0){
      touches.clear();
      if(testGoals()) return;
    }
    if (ts.length != 1 || !textArea.hasSelection()) {
      touches.clear();
      return;
    }
    if (touches.size() == 1) { // only bind when there are exactly two touch points
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
    Point startPoint, endPoint;
    float distToStart, distToEnd;
    startPoint = textArea.getInnerPointByTextOffset(s[0]);
    endPoint = textArea.getInnerPointByTextOffset(s[1]);
    distToStart = dist(ts[0].getLocalX(this), ts[0].getLocalY(this), (float)startPoint.getX(), (float)startPoint.getY()); 
    distToEnd = dist(ts[0].getLocalX(this), ts[0].getLocalY(this), (float)endPoint.getX(), (float)endPoint.getY()); 

    /*if (r[0] == r[1]) {
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
    }*/
    final TouchRecord[] tr = new TouchRecord[1];
    if(min(distToStart, distToEnd)>20){
      touches.clear();
      return;

    }
  }
  
  //Check the current selection against the goal of the trial, as set in the Trials class. Currently crashes when the goal is met. Called from the bindTouches() method.
  private boolean testGoals(){
    System.out.println(textArea.getSelectionStart() + " " + textArea.getSelectionEnd());
    if(textArea.getSelectionStart() == Trials.trialGoals[currentTrial][0] && textArea.getSelectionEnd() == Trials.trialGoals[currentTrial][1]){
      //TODO: end timer
      currentTrial++;
      
      textArea.text = Trials.trialText[currentTrial];
      textArea.setSelection(0,0);
      this.setFirstTap(true);
      return true;
    }
  }
}

