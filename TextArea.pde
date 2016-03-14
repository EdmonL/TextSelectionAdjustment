import java.util.Collections;
import java.util.Comparator;

static final class LineRecord implements Comparable<LineRecord> {
  final int number, offset, end;
  final int x, y;

  LineRecord(final int number, final int offset, final int end, final int x, final int y) {
    this.number = number;
    this.offset = offset;
    this.end = end;
    this.x = x;
    this.y = y;
  }

  @Override
  public int compareTo(final LineRecord o) {
    return number - o.number;
  }
}

static final class LineOffsetComparator implements Comparator<LineRecord> {
  @Override
  public int compare(final LineRecord l1, final LineRecord l2) {
    return l1.offset - l2.offset;
  }
}

static final class LineYComparator implements Comparator<LineRecord> {
  @Override
  public int compare(final LineRecord l1, final LineRecord l2) {
    return l1.y - l2.y;
  }
}

static class Position {
  final int x;
  final int y;
  Position(final int x, final int y) {
    this.x = x;
    this.y = y;
  }
}

class TextArea {

  private final PFont font;
  private final int x, y, width, height;

  String text = "";
  int textSize = 14;
  color textColor = 0, backgroundColor = 255;
  int marginTop = 0, marginLeft = 0, marginBottom = 0, marginRight = 0;
  float lineSpacing = 1.0;
  color selectionBackgroudColor = #3297FD, selectionFrontColor = 255;
  private int selectionStart, selectionEnd;

  private final ArrayList<LineRecord> lines = new ArrayList<LineRecord>();
  private int fontHeight, lineHeight, textWidth, textBottom;

  TextArea(final int x, final int y, final int width, final int height, final PFont font) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.font = font;
  }

  void redraw() {
    lines.clear();
  }

  Position getPosition(final int offset) {
    int row = Collections.binarySearch(lines, new LineRecord(0, offset, 0, 0, 0), new LineOffsetComparator());
    if (row < 0) {
      row = -row - 2;
    }
    final LineRecord line = lines.get(row);
    return new Position(line.x + Math.round(textWidth(text.substring(line.offset, offset))), line.y + Math.round(fontHeight / 2.0));
  }

  int getTextOffset(final int x, final int y) {
    return 0;
  }

  int getSelectionStart() {
    return selectionStart;
  }

  int getSelectionEnd() {
    return selectionEnd;
  }

  boolean hasSelection() {
    return selectionStart < selectionEnd;
  }

  void setSelection(int start, int end) {
    start = clampSelection(start);
    end = clampSelection(end);
    if (start == end) {
      selectionStart = selectionEnd = 0;
    } else if (start > end) {
      final int tmp = end;
      end = start;
      start = tmp;
    }
    selectionStart = start;
    selectionEnd = end;
  }

  void draw() {
    pushStyle();
    fill(backgroundColor);
    rectMode(CORNER);
    noStroke();
    rect(x, y, width, height);

    textAlign(LEFT, TOP);
    textFont(font);
    textSize(textSize);
    fill(textColor);

    prepareText();

    for (final LineRecord line : lines) {
      final String lineText = text.substring(line.offset, line.end);
      text(lineText, line.x, line.y);
      if (selectionStart < selectionEnd && selectionStart < line.end && selectionEnd > line.offset) {
        String selectedText = null;
        int selectionX;
        if (line.offset <= selectionStart) {
          selectionX = line.x + Math.round(textWidth(text.substring(line.offset, selectionStart)));
          if (line.end > selectionEnd) {
            selectedText = text.substring(selectionStart, selectionEnd);
          } else {
            selectedText = text.substring(selectionStart, line.end);
          }
        } else {
          selectionX = line.x;
          if (line.end > selectionEnd) {
            selectedText = text.substring(line.offset, selectionEnd);
          } else {
            selectedText = text.substring(line.offset, line.end);
          }
        }
        if (selectedText != null) {
          fill(selectionBackgroudColor);
          rect(selectionX, line.y, textWidth(selectedText), fontHeight);
          fill(selectionFrontColor);
          text(selectedText, selectionX, line.y);
          fill(textColor);
        }
      }
    }

    fill(backgroundColor);
    rect(x, textBottom, width, height - textBottom);

    popStyle();
  }

  private void prepareText() {
    if (lines.size() != 0 || text.isEmpty()) {
      return;
    }
    fontHeight = Math.round(textAscent() + textDescent());
    lineHeight = Math.round(fontHeight * lineSpacing);
    textWidth = width - marginLeft - marginRight;
    textBottom = height - marginBottom;
    final int textLength = text.length();
    int posY = marginTop;
    int lineStart = 0;
    float lineWidth = 0.0;
    for (int i = 0; i < textLength; ++i) {
      final char c = text.charAt(i);
      final float cWidth = textWidth(c);
      int nextY = posY;
      if (lineStart < i && lineWidth + cWidth >= textWidth) {
        lines.add(new LineRecord(lines.size(), lineStart, i, marginLeft, posY));
        lineStart = i;
        lineWidth = cWidth;
        nextY += lineHeight;
      } else {
        lineWidth += cWidth;
        if (c == '\n') {
          final int lineEnd = i + 1;
          lines.add(new LineRecord(lines.size(), lineStart, lineEnd, marginLeft, posY));
          lineStart = lineEnd;
          lineWidth = 0;
          nextY += lineHeight;
        }
      }
      if (nextY >= textBottom) {
        if (lineStart < i) {
          lines.add(new LineRecord(lines.size(), lineStart, i, marginLeft, posY));
        }
        break;
      }
      posY = nextY;
    }
  }

  private int clampSelection(int pos) {
    if (pos < 0) {
      return 0;
    }
    return pos > text.length() ? text.length() : pos;
  }
}

