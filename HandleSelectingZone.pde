import java.awt.Color;

static class HandleSelectingZone extends Zone {
  int currentTrial = 0;
  boolean firstTap = true;
  boolean showTouches = false;

  private static final class TouchRecord { // these are the points delimiting the selection in text and accociated with the touch points
    long id; // the touch point id that this inner point is associated with
    Point point; // the touch point; used as the last history to calculate touch point movement
    Point innerPoint; // I call as "inner pointers" the small points in demo which delimits the selection
    Color myColor; // just for demo
    boolean isStart;

    TouchRecord(long id, final Point point, final Point innerPoint, boolean start) {
      this.id = id;
      this.point = point;
      this.innerPoint = innerPoint;
      this.isStart = start;
    }
  }
  
  private final TextArea textArea;
  private final HashMap<Long, TouchRecord> touches = new HashMap<Long, TouchRecord>(); // touch point id -> inner point record; bindings between the inner points and touch points

  HandleSelectingZone(final int x, final int y, final int width, final int height, TextArea textArea) {
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
    final Point cp = new Point(touch.x, touch.y);
    final Point lp = ltr.point;
    if (lp.x == cp.x && lp.y == cp.y) {
      return;
    }

    final Point lip = ltr.innerPoint; // last inner point
    Point cip = new Point(lip.x + cp.x - lp.x, lip.y + cp.y - lp.y);
    final TextPosition ltp = textArea.getTextPositionByInnerPoint(lip);
    
    
    final TextPosition ctp = textArea.getTextPositionByInnerPoint(cip);
    
    //Check where the new handle position is in relation to the current textArea selection, and change the selection accordingly.
    if(ltr.isStart && ctp.offset < textArea.getSelectionEnd()){
      textArea.setSelection(ctp.offset, textArea.getSelectionEnd());
    }else if(ltr.isStart && ctp.offset > textArea.getSelectionEnd()){
      textArea.setSelection(textArea.getSelectionEnd(), ctp.offset);
      ltr.isStart = false;
    }else if (!ltr.isStart && ctp.offset > textArea.getSelectionStart()){
      textArea.setSelection(textArea.getSelectionStart(), ctp.offset);
    }else if(!ltr.isStart && ctp.offset < textArea.getSelectionStart()){
      textArea.setSelection(ctp.offset, textArea.getSelectionStart()); 
      ltr.isStart = true;
    }

    
    final TouchRecord ctr = ltr;
    ctr.point = cp;
    ctr.innerPoint = cip;
  }

  @Override public void touch() {
  }

  @Override public void draw() {
    if (showTouches) { // for demo only
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

  // this method decides which touch point is bound to the start of the selection or the end of it
  private void bindTouches() {
    //Set the initial selection when the screen is first tapped.
    if(firstTap){
       firstTap = false;
       final Touch[] firstTouch = getTouches();
       TextPosition tp = textArea.getTextPositionByInnerPoint(new Point(firstTouch[0].x, firstTouch[0].y));
       int startSel = tp.offset - 3;
       int endSel = tp.offset+3;
       textArea.setSelection(startSel, endSel);
       //TODO: Start Timer
       return;
    }
    final Touch[] ts = getTouches();
    //When all touches are removed, check the selection against the goal
    if(ts.length == 0){
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
    distToStart = dist(ts[0].getLocalX(this), ts[0].getLocalY(this), (float)startPoint.getX()+textArea.marginLeft, (float)startPoint.getY()+textArea.marginTop); 
    distToEnd = dist(ts[0].getLocalX(this), ts[0].getLocalY(this), (float)endPoint.getX()+textArea.marginLeft, (float)endPoint.getY()+textArea.marginTop); 

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
    if(distToStart<distToEnd){
      tr[0] = new TouchRecord(ts[0].sessionID, new Point(ts[0].x, ts[0].y), textArea.getInnerPointByTextOffset(s[0]), true);
    } else{
      tr[0] = new TouchRecord(ts[0].sessionID, new Point(ts[0].x, ts[0].y), textArea.getInnerPointByTextOffset(s[1]), false);
    }
    
    touches.put(ts[0].sessionID, tr[0]);
    
    // for demo only
    tr[0].myColor = new Color(190, 50, 50, 200);
    final Color c = tr[0].myColor;
    ts[0].setTint(c.getRed(), c.getGreen(), c.getBlue(), c.getAlpha());
    
  }
  
  //Check the current selection against the goal of the trial, as set in the Trials class. Currently crashes when the goal is met. Called from the bindTouches() method.
  private boolean testGoals(){
    System.out.println(textArea.getSelectionStart() + " " + textArea.getSelectionEnd());
    if(textArea.getSelectionStart() == Trials.trialGoals[currentTrial][0] && textArea.getSelectionEnd() == Trials.trialGoals[currentTrial][1]){
      //TODO: end timer
      currentTrial++;
      
      textArea.text = Trials.trialText[currentTrial];
      textArea.setSelection(0,0);
      firstTap = true;
      System.out.println(currentTrial);
      return true;
    }
    return false;
  }
}
