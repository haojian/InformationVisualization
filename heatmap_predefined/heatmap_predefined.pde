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
int coordinationscale = 5;
int coloroffset = 20;

int screen_width = 854/coordinationscale;
int screen_height = 480/coordinationscale;
int webpageMaxWidth = screen_width;
int webpageMaxHeight = screen_height;

String datalogpath = "102201_1_37.tsv";
String imgURL = "heatmap2.png";

//this is the weight value for all the hot spot in the map.
int[][] map = new int[1000][5000];
HashMap hm = new HashMap();

void extractData(){
  String[] lines = loadStrings(datalogpath);
  long last_time = -1;
  int[] lastLoc = new int[2];
  for(int i = 0; i< lines.length; i++){
    String[] datas = split(lines[i], '\t');
    if(datas.length == 4){
      if(datas[0].equals("Scroll")){
        if(last_time == -1)
        {
          last_time = Long.parseLong(datas[1]);
          lastLoc[1] = int(datas[2])/coordinationscale;
          lastLoc[0] = int(datas[3])/coordinationscale;
          continue;
        }
        else{
          long curTime=  Long.parseLong(datas[1]);
          long duration = curTime - last_time;
          if(duration > 1000)
            println(lines[i]); 
          last_time = curTime;
          
          for(int x =0; x < screen_width; x++){
            for(int y=0; y< screen_height; y++){
              map[x + lastLoc[0]][y+lastLoc[1]] += duration;
              if(map[x + lastLoc[0]][y+lastLoc[1]] > maxValue){
                maxValue= map[x + lastLoc[0]][y+lastLoc[1]];
              }
              if(map[x + lastLoc[0]][y+lastLoc[1]] < minValue){
                minValue= map[x + lastLoc[0]][y+lastLoc[1]];
              }
              
            }
          }
          
          lastLoc[1] = int(datas[2])/coordinationscale;
          lastLoc[0] = int(datas[3])/coordinationscale;
          
          /*
          if((screen_width + lastLoc[0]) > webpageMaxWidth){
              webpageMaxWidth = screen_width + lastLoc[0];
          }
          if((screen_height + lastLoc[1]) > webpageMaxHeight){
              webpageMaxHeight = screen_height + lastLoc[1];
          }
          */
        }
      }
    }
  }
  println("extraction done"); 
}

void setup(){

  extractData();
  backgroundImage = loadImage(imgURL);
  webpageMaxWidth = backgroundImage.width/coordinationscale;
  webpageMaxHeight = backgroundImage.height/coordinationscale;
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
  save("diagonal1.png");
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
