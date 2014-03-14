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

int webpageMaxWidth = 854;
int webpageMaxHeight = 480;
int screen_width = 854;
int screen_height = 480;


//this is the weight value for all the hot spot in the map.
int[][] map = new int[1000][5000];
HashMap hm = new HashMap();


void extractData(){
  String[] lines = loadStrings("102201_1_37.tsv");
  long last_time = -1;
  int[] lastLoc = new int[2];
  for(int i = 0; i< lines.length; i++){
    String[] datas = split(lines[i], '\t');
    if(datas.length == 4){
      if(datas[0].equals("Scroll")){
        if(last_time == -1)
        {
          last_time = Long.parseLong(datas[1]);
          lastLoc[1] = int(datas[2]);
          lastLoc[0] = int(datas[3]);
          continue;
        }
        else{
          long  curTime=  Long.parseLong(datas[1]);
          long duration = curTime - last_time;
          last_time = curTime;
          String key = lastLoc[0] + "_" + lastLoc[1];
          println(key);
          if(hm.containsKey(key))
            hm.put(key, int(hm.get(key).toString()) + duration);
          else
            hm.put(key, duration);
          /*
          for(int x =0; x < screen_width; x++){
            for(int y=0; y< screen_height; y++){
              map[x + lastLoc[0]][y+lastLoc[1]] += duration;
            }
          }
          */
          lastLoc[1] = int(datas[2]);
          lastLoc[0] = int(datas[3]);
          if((screen_width + lastLoc[0]) > webpageMaxWidth){
              webpageMaxWidth = screen_width + lastLoc[0];
          }
          if((screen_height + lastLoc[0]) > webpageMaxHeight){
              webpageMaxHeight = screen_height + lastLoc[0];
          }
        }
      }
    }
  }
  println("done"); 
}

//for data input
void renderingData(){
  Iterator iter = hm.entrySet().iterator();  // Get an iterator
while (iter.hasNext()) {
      Map.Entry me = (Map.Entry)iter.next();
      int[] xy =int(split( me.getKey().toString(), '_'));
      int i = xy[0] + webpageMaxWidth/2;
      int j = xy[1] + webpageMaxHeight/2;
      println(i + "\t" + j + "\t" + me.getValue().toString()); 
    // blit the clickmapBrush onto the (offscreen) clickmap:
    if(i>0 && i < backgroundImage.width && j >0 && j <backgroundImage.height){
      clickmap.blend(clickmapBrush, 0,0,clickmapBrush.width,clickmapBrush.height,i-clickmapBrush.width/2,j-clickmapBrush.height/2,clickmapBrush.width,clickmapBrush.height,BLEND);
      // blit the clickmapBrush onto the background image in the upper left corner:
      image(clickmapBrush, i-clickmapBrush.width/2, j-clickmapBrush.height/2);
      
      // render the heatmapBrush into the gradientMap:
      drawToGradient(i, j, int(me.getValue().toString()));
      // update the heatmap from the updated gradientMap:
      updateHeatmap();
          
    // draw the gradientMap in the lower left corner:
    image(gradientMap, 0, backgroundImage.height);
    
    // draw the background image in the upper right corner and transparently blend the heatmap on top of it:
    image(backgroundImage, backgroundImage.width,0);
    tint(255,255,255,192);
    image(heatmap, backgroundImage.width, 0);
    noTint();
    
    // draw the raw heatmap into the bottom right corner and draw the clickmap on top of it:
    image(heatmap, backgroundImage.width, backgroundImage.height);
    image(clickmap, backgroundImage.width, backgroundImage.height);
    }
    
}

}

//for test
void randomerenderingData(){
    for(int i =0; i<500; i= i+50){
    for(int j =0; j<500; j= j+50){
      //map[i][j] = int(random(500));
      //println(map[i][j]); 
    // blit the clickmapBrush onto the (offscreen) clickmap:
    if(i>0 && i < backgroundImage.width && j >0 && j <backgroundImage.height){
      clickmap.blend(clickmapBrush, 0,0,clickmapBrush.width,clickmapBrush.height,i-clickmapBrush.width/2,j-clickmapBrush.height/2,clickmapBrush.width,clickmapBrush.height,BLEND);
      // blit the clickmapBrush onto the background image in the upper left corner:
      image(clickmapBrush, i-clickmapBrush.width/2, j-clickmapBrush.height/2);
      
      // render the heatmapBrush into the gradientMap:
      drawToGradient(i, j, map[i][j]);
      // update the heatmap from the updated gradientMap:
      updateHeatmap();
      
      
          
    // draw the gradientMap in the lower left corner:
    image(gradientMap, 0, backgroundImage.height);
    
    // draw the background image in the upper right corner and transparently blend the heatmap on top of it:
    image(backgroundImage, backgroundImage.width,0);
    tint(255,255,255,192);
    image(heatmap, backgroundImage.width, 0);
    noTint();
    
    // draw the raw heatmap into the bottom right corner and draw the clickmap on top of it:
    image(heatmap, backgroundImage.width, backgroundImage.height);
    image(clickmap, backgroundImage.width, backgroundImage.height);
    }

    }
  }
}

/*
Rendering code that blits the heatmapBrush onto the gradientMap, centered at the specified pixel and drawn with additive blending
*/
void drawToGradient(int x, int y, int value)
{
  // find the top left corner coordinates on the target image
  int startX = x-heatmapBrush.width/2;
  int startY = y-heatmapBrush.height/2;

  for (int py = 0; py < heatmapBrush.height; py++)
  {
    for (int px = 0; px < heatmapBrush.width; px++) 
    {
      // for every pixel in the heatmapBrush:
      
      // find the corresponding coordinates on the gradient map:
      int hmX = startX+px;
      int hmY = startY+py;
      /*
      The next if-clause checks if we're out of bounds and skips to the next pixel if so.
      
      Note that you'd typically optimize by performing clipping outside of the for loops!
      */
      if (hmX < 0 || hmY < 0 || hmX >= gradientMap.width || hmY >= gradientMap.height)
      {
        continue;
      }
      
      // get the color of the heatmapBrush image at the current pixel.
      int col = heatmapBrush.pixels[py*heatmapBrush.width+px]; // The py*heatmapBrush.width+px part would normally also be optimized by just incrementing the index.
      col = col & 0xff; // This eliminates any part of the heatmapBrush outside of the blue color channel (0xff is the same as 0x0000ff)
      col = col * value;
      // find the corresponding pixel image on the gradient map:
      int gmIndex = hmY*gradientMap.width+hmX;
      
      if (gradientMap.pixels[gmIndex] < 0xffffff-col) // sanity check to make sure the gradient map isn't "saturated" at this pixel. This would take some 65535 clicks on the same pixel to happen. :)
      {
        gradientMap.pixels[gmIndex] += col; // additive blending in our 24-bit world: just add one value to the other.
        if (gradientMap.pixels[gmIndex] > maxValue) // We're keeping track of the maximum pixel value on the gradient map, so that the heatmap image can display relative click densities (scroll down to updateHeatmap() for more)
        {
          maxValue = gradientMap.pixels[gmIndex];
        }
      }
    }
  }
  gradientMap.updatePixels();
}


/*
Updates the heatmap from the gradient map.
*/
void updateHeatmap()
{
  // for all pixels in the gradient:
  for (int i=0; i<gradientMap.pixels.length; i++)
  {
    // get the pixel's value. Note that we're not extracting any channels, we're just treating the pixel value as one big integer.
    // cast to float is done to avoid integer division when dividing by the maximum value.
    float gmValue = gradientMap.pixels[i];
    
    // color map the value. gmValue/maxValue normalizes the pixel from 0...1, the rest is just mapping to an index in the heatmapColors data.
    int colIndex = (int) ((gmValue/maxValue)*(heatmapColors.pixels.length-1));
    int col = heatmapColors.pixels[colIndex];

    // update the heatmap at the corresponding position
    heatmap.pixels[i] = col;
  }
  // load the updated pixel data into the PImage.
  heatmap.updatePixels();
}

void setup(){
  extractData();
  size(1000, 740);
  background(0,0,0);
  
    // load image data:
  backgroundImage = loadImage("images/townsquare.jpg");
  heatmapColors = loadImage("images/heatmapColors.png");
  heatmapBrush = loadImage("images/heatmapBrush.png");
  clickmapBrush = loadImage("images/clickmapBrush.png");
  
  // draw the background image in the upper left corner.
  image(backgroundImage, 0,0);
  
  // create empty canvases:
  clickmap = createImage(backgroundImage.width, backgroundImage.height, ARGB);
  gradientMap = new PImage(backgroundImage.width, backgroundImage.height);
  heatmap = new PImage(backgroundImage.width, backgroundImage.height);
  // load pixel arrays for all relevant images
  gradientMap.loadPixels();
  heatmap.loadPixels();
  heatmapBrush.loadPixels();
  heatmapColors.loadPixels();
  
  renderingData();
}

void draw() {} // empty but needed for Processing to call the mouseReleased function



