import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.lang.Long;

PImage backgroundImage; // background image
PImage heatmapBrush; // radial gradient used as a brush. Only the blue channel is used.
PImage heatmapColors; // single line bmp containing the color gradient for the finished heatmap, from cold to hot
PImage clickmapBrush; // bmp of the little marks used in the clickmap

PImage gradientMap; // canvas for the intermediate map
PImage heatmap; // canvas for the heatmap
PImage clickmap; // canvas for the clickmap

float maxValue = 0; // variable storing the current maximum value in the gradientMap
float minValue = 9999;
float coordinationscale = 2;
int coloroffset = 20;

int screen_width = (int)(854/coordinationscale);
int screen_height = int(480/coordinationscale);
int webpageMaxWidth = screen_width;
int webpageMaxHeight = screen_height;
float accumulateScaleWeight = 1;
float scaleUpdate = 1;


//String datalogpath = "102201_1_37.tsv";
String imgURL = "heatmap34.jpg";
String datalogpath = "102201_1_34.tsv";
//String imgURL = "heatmap1.png";

//this is the weight value for all the hot spot in the map.
int[][] map = new int[1000][5000];
HashMap hm = new HashMap();

void extractData(){
  String[] lines = loadStrings(datalogpath);
  long last_time = -1;
  int[] lastLoc = new int[2];
  for(int i = 0; i< lines.length; i++){
    String[] datas = split(lines[i], '\t');
    if(datas.length == 2){
      if(datas[0].equals("START")){
        last_time = Long.parseLong(datas[1]);
        lastLoc[1] = 0;
        lastLoc[0] = 0;
      }
      if(datas[0].equals("END")){
        long curTime=  Long.parseLong(datas[1]);
        long duration = curTime - last_time;
        if(duration > 1000)
          println(lines[i]); 
        last_time = curTime;
          
        for(int x =0; x < screen_width; x++){
          for(int y=0; y< screen_height; y++){
            map[x + lastLoc[0]][y+lastLoc[1]] += duration*accumulateScaleWeight;
            if(map[x + lastLoc[0]][y+lastLoc[1]] > maxValue){
              maxValue= map[x + lastLoc[0]][y+lastLoc[1]];
            }
            if(map[x + lastLoc[0]][y+lastLoc[1]] < minValue){
               minValue= map[x + lastLoc[0]][y+lastLoc[1]];
            }
          }
        }
      }
    }
    if(datas.length == 4){
      if(datas[0].equals("Scroll")){
        if(last_time == -1)
        {
          println("no start part");
          break;
        }
        else{
          long curTime=  Long.parseLong(datas[1]);
          long duration = curTime - last_time;
          if(duration > 1000)
            println(lines[i]); 
          last_time = curTime;
          
          for(int x =0; x < screen_width; x++){
            for(int y=0; y< screen_height; y++){
              map[x + lastLoc[0]][y+lastLoc[1]] += duration*accumulateScaleWeight;
              if(map[x + lastLoc[0]][y+lastLoc[1]] > maxValue){
                maxValue= map[x + lastLoc[0]][y+lastLoc[1]];
              }
              if(map[x + lastLoc[0]][y+lastLoc[1]] < minValue){
                minValue= map[x + lastLoc[0]][y+lastLoc[1]];
              }
            }
          }
          
          lastLoc[1] = int(int(datas[2])/coordinationscale);
          lastLoc[0] = int(int(datas[3])/coordinationscale);
        }
      }
      else if(datas[0].equals("ZOOM")){
        scaleUpdate = Float.parseFloat(datas[2])/Float.parseFloat(datas[3]);
        accumulateScaleWeight *= scaleUpdate;
        
        screen_width/=scaleUpdate;
        screen_height/=scaleUpdate;
        println(scaleUpdate);
      }
    }
  }
  println("extraction done"); 
}

void setup(){

  extractData();
  backgroundImage = loadImage(imgURL);
  webpageMaxWidth = int(backgroundImage.width/coordinationscale);
  webpageMaxHeight = int(backgroundImage.height/coordinationscale);
  backgroundImage.resize(webpageMaxWidth, webpageMaxHeight);
  size(webpageMaxWidth, webpageMaxHeight);
  background(0,0,0);
  image(backgroundImage, 0,0);
  tint(255,255,255,192);

  println("width: " + webpageMaxWidth + "\t" + "height: " + webpageMaxHeight); 
  

  
  heatmapColors = loadImage("images/heatmapColors.png");
  heatmapColors.loadPixels();

  heatmap = new PImage(webpageMaxWidth, webpageMaxHeight);
  heatmap.loadPixels();
  renderingData();
  save(datalogpath + "_heatmap.png");
}

void draw() {}

void renderingData(){
   println("maxValue: " + maxValue + "\t minValue: " + minValue ); 
  for(int i=0; i< webpageMaxWidth;i++){
    for(int j=0; j< webpageMaxHeight; j++){
      float gmValue = map[i][j];

      //println("gmValue: " + gmValue); 
      int colIndex = (int) ((gmValue/maxValue)*(heatmapColors.pixels.length-1 - coloroffset));      
      int col = heatmapColors.pixels[colIndex + coloroffset];

      heatmap.pixels[i + j *webpageMaxWidth] = col;
    }
  }
  heatmap.updatePixels();

  image(heatmap, 0, 0);
  
}
