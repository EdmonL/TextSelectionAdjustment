static class TextSegment {
  final StringBuilder textBuilder = new StringBuilder();
  String text;
  int x, y;
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
  int selectionStart, selectionEnd;

  private final StringList lines = new StringList();
  private final ArrayList<TextSegment> selectedText = new ArrayList<TextSegment>();
  private int fontHeight, lineHeight, textWidth, textBottom;

  TextArea(final int x, final int y, final int width, final int height, final PFont font) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.font = font;
  }

  void format() {
    lines.clear();
    selectedText.clear();
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

    final int posX = marginLeft;
    int posY = marginTop;
    for (final String line : lines) {
      text(line, posX, posY);
      posY += lineHeight;
    }
    
    fill(selectionBackgroudColor);
    for (final TextSegment ts : selectedText) {
      rect(ts.x, ts.y, textWidth(ts.text), fontHeight);
    }
    fill(selectionFrontColor);
    for (final TextSegment ts : selectedText) {
      text(ts.text, ts.x, ts.y);
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
    TextSegment selected = null;
    int i = 0;
    for (; i < textLength; ++i) {
      if (posY >= textBottom) {
        break;
      }
      final char c = text.charAt(i);
      final float cWidth = textWidth(c);
      if (lineStart < i && lineWidth + cWidth >= textWidth) {
        lines.append(text.substring(lineStart, i));
        lineStart = i;
        lineWidth = cWidth;
        posY += lineHeight;
        if (selected != null) {
          selectedText.add(selected);
          selected = null;
        }
        if (i >= selectionStart && i < selectionEnd) {
          selected = new TextSegment();
          selected.textBuilder.append(c);
          selected.x = marginLeft;
          selected.y = posY;
        }
      } else {
        if (i >= selectionStart && i < selectionEnd) {
          if (selected == null) {
            selected = new TextSegment();
            selected.textBuilder.append(c);
            selected.x = marginLeft + Math.round(lineWidth);
            selected.y = posY;
          } else {
            selected.textBuilder.append(c);
          }
        } else if (selected != null) {
          selectedText.add(selected);
          selected = null;
        }
        lineWidth += cWidth;
        if (c == '\n') {
          lineStart = i + 1;
          lineWidth = 0;
          posY += lineHeight;
          if (selected != null) {
            selectedText.add(selected);
            selected = null;
          }
        }
      }
    }
    if (lineStart < i) {
      lines.append(text.substring(lineStart, i));
    }
    for (final TextSegment ts : selectedText) {
      ts.text = ts.textBuilder.toString();
    }
  }
}

