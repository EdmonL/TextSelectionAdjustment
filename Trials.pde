static class Trials {
  
  public static final int LINE_LENGTH = 34;
  public static final int TOTAL_LINES = 23;
  public static final int TOTAL_CHARS = LINE_LENGTH * TOTAL_LINES;
  public static final int MAX_TARGET_LENGTH = LINE_LENGTH * 10;
  public static final int MIN_TARGET_LENGTH = 3;
  public static final int CENTER = LINE_LENGTH * TOTAL_LINES / 2;
  public static final char FILLING_CHAR = '*';
  public static final char TARGET_CHAR = '@';
  
  private static final char[] FILLINGS = new char[TOTAL_CHARS];
  private static final char[] TARGETS = new char[MAX_TARGET_LENGTH];
  
  static {
    Arrays.fill(FILLINGS, FILLING_CHAR);
    Arrays.fill(TARGETS, TARGET_CHAR);
  }
  
  private String text;
  private int targetStart, targetEnd;
  private int no = 0, maxNo;
  
  public Trials(final int n) {
    maxNo = n;
  }
  
  public int getTrialNo() {
    return no;
  }
  
  public String getText() {
    return text;
  }
  
  public boolean checkTarget(final int start, final int end) {
    return start == targetStart && end == targetEnd;
  }
  
  public boolean next() {
    if (no >= maxNo) {
      return false;
    }
    ++no;
    final int targetLength = (int) Math.round(Math.random() * (MAX_TARGET_LENGTH - MIN_TARGET_LENGTH) + MIN_TARGET_LENGTH);
    final int targetLengthBeforeCenter = (int) Math.round(Math.random() * targetLength);
    targetStart = CENTER - targetLengthBeforeCenter;
    targetEnd = targetStart + targetLength;
    text = new String(FILLINGS, 0, targetStart) + new String(TARGETS, 0, targetLength) + new String(FILLINGS, 0, TOTAL_CHARS - targetEnd);
    return true;
  }
}

