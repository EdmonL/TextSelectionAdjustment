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

  @Override public int compareTo(final LineRecord o) {
    return number - o.number;
  }
}

static final class LineOffsetComparator implements Comparator<LineRecord> {
  @Override public int compare(final LineRecord l1, final LineRecord l2) {
    return l1.offset - l2.offset;
  }
}

static final class LineYComparator implements Comparator<LineRecord> {
  @Override public int compare(final LineRecord l1, final LineRecord l2) {
    return l1.y - l2.y;
  }
}

static class TextPosition {
  int offset;
  final int row;
  TextPosition(final int offset, final int row) {
    this.offset = offset;
    this.row = row;
  }
}

class TextArea {

  private final PFont font;
  private final int x, y, width, height;

  String text = "";
  color textColor = 0, backgroundColor = 255;
  int marginTop = 0, marginLeft = 0, marginBottom = 0, marginRight = 0;
  float lineSpacing = 1.0;
  color selectionBackgroudColor = #3297FD, selectionFrontColor = 255;
  private int selectionStart, selectionEnd;

  private final ArrayList<LineRecord> lines = new ArrayList<LineRecord>();
  private int fontHeight, lineHeight, textWidth, textRight, textBottom;

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

  Point getPointByInnerPoint(final Point p) {
    return new Point(x + p.x, y + p.y);
  }

  int getLineOffset(final int row) {
    return lines.get(row).offset;
  }

  int getLineEnd(final int row) {
    return lines.get(row).end;
  }

  // inner means relative to the text area rather than the window, display or screen
  Point getInnerPointByTextOffset(final int offset) {
    LineRecord line;
    int row = Collections.binarySearch(lines, new LineRecord(0, offset, 0, 0, 0), new LineOffsetComparator());
    if (row < 0) {
      line = lines.get(-row - 2);
    } else if (row > 0) {
      line = lines.get(row - 1);
      if (line.end != offset) {
        line = lines.get(row);
      }
    } else {
      line = lines.get(row);
    }
    return new Point(line.x + Math.round(textWidth(text.substring(line.offset, offset))), line.y + Math.round(fontHeight / 2.0));
  }

  Point getInnerPointByTextPosition(final TextPosition tp) {
    final LineRecord line = lines.get(tp.row);
    return new Point(line.x + Math.round(textWidth(text.substring(line.offset, tp.offset))), line.y + Math.round(fontHeight / 2.0));
  }

  TextPosition getTextPositionByInnerPoint(final Point p) {
    clampIntoTextArea(p);
    int row = Collections.binarySearch(lines, new LineRecord(0, 0, 0, 0, p.y), new LineYComparator());
    if (row < 0) {
      row = -row - 2;
    }
    LineRecord line = lines.get(row);
    if (row != lines.size() - 1) {
      final LineRecord nextLine = lines.get(row + 1);
      if (p.y >= Math.round((nextLine.y + line.y + fontHeight) / 2.0)) {
        line = nextLine;
        ++row;
      }
    }
    final int lineWidth = Math.round(textWidth(text.substring(line.offset, line.end)));
    int offset = line.offset + Math.round((float)(p.x - line.x) / lineWidth * (line.end - line.offset));
    offset = clampInt(offset, line.offset, line.end);
    int x0 = line.x + Math.round(textWidth(text.substring(line.offset, offset)));
    int x1 = x0;
    if (p.x < x0) {
      if (offset <= line.offset) {
        return new TextPosition(offset, row);
      }
      do {
        --offset;
        x1 = x0;
        x0 = line.x + Math.round(textWidth(text.substring(line.offset, offset)));
      } 
      while (p.x < x0 && offset > line.offset);
      return new TextPosition(abs(p.x - x0) < abs(x1 - p.x) ? offset : offset + 1, row);
    }
    if (offset >= line.end) {
      return new TextPosition(offset, row);
    }
    do {
      ++offset;
      x1 = x0;
      x0 = line.x + Math.round(textWidth(text.substring(line.offset, offset)));
    } 
    while (p.x >= x0 && offset < line.end);
    return new TextPosition(abs(x0 - p.x) <= abs(p.x - x1) ? offset : offset - 1, row);
  }

  int getSelectionStart() {
    return selectionStart;
  }

  int getSelectionEnd() {
    return selectionEnd;
  }

  int getRowByTextOffset(final int offset) {
    final int row = Collections.binarySearch(lines, new LineRecord(0, offset, 0, 0, 0), new LineOffsetComparator());
    return row < 0 ? -row - 2 : row;
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
    background(backgroundColor);
    noStroke();
    rectMode(CORNER);

    textAlign(LEFT, TOP);
    textFont(font);
    fill(textColor);

    prepareText();

    for (final LineRecord line : lines) {
      final String lineText = text.substring(line.offset, line.end);
      text(lineText, x + line.x, y + line.y);
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
          selectionX += x;
          final int selectionY = y + line.y;
          fill(selectionBackgroudColor);
          rect(selectionX, selectionY, textWidth(selectedText), fontHeight);
          fill(selectionFrontColor);
          text(selectedText, selectionX, selectionY);
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
    textRight = width - marginRight;
    textWidth = textRight - marginLeft;
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

  private void clampIntoTextArea(final Point p) {
    p.x = clampInt(p.x, marginLeft, textRight);
    p.y = clampInt(p.y, marginTop, textBottom);
  }

  private int clampSelection(final int pos) {
    if (pos < 0) {
      return 0;
    }
    return pos > text.length() ? text.length() : pos;
  }
}

