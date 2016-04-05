private static PrintWriter output;
private int startMillis;

static int clampInt(int v, int min, int max) { // return a value between the range
  return v < min ? min : (v > max ? max : v);
}

static void swapPoint(final Point a, final Point b) {
  final Point tmp = new Point(a);
  a.setLocation(b);
  b.setLocation(tmp);
}

public void createTheWriter(String name){
  if(output==null){
    output = createWriter(name);
  } 
}

static void writeLine(String line){
   if(output!=null){
      output.println(line);
   } 
}

public void setStart(){
   startMillis = millis();
}
