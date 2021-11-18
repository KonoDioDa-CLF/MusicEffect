import processing.sound.*;
import controlP5.*;

int mode = 1;

int buttonWidth = 50;
int buttonHeight = 50;
int sliderHeight = 16;

int waveDataSize = 500;
int waveWeight = 5;
int waveColor = 0xffffffff;

int colorRangeMin = 0;
int colorRangeMax = 60;

int circleSize = 300;

ControlP5 p5;
int musicIndex = 0;
ArrayList<SoundFile> musicList = new ArrayList();
String[] musicNames = new String[]{"The proof of Hero.mp3","Devil Trigger.mp3","yehangxin.mp3"};
PImage playIcon;
PImage pauseIcon;
PImage nextIcon;
PImage lastIcon;
PImage stopIcon;

Button playButton;
Button lastButton;
Button nextButton;
Button stopButton;
Slider volumeBar;
Slider progressBar;
Slider reverbRoom;
Slider reverbDamp;
Slider reverbWet;
Slider circleSizeBar;
Button mode1;
Button mode2;
Button mode3;

boolean showUI = true;

float room = 0f;
float damp = 0f;
float wet = 0f;

float volume = 0.5f;
boolean onRefresh = true;

int index = 0;

boolean direction = true;

AudioIn audioIn;
Waveform waveform;
Reverb reverb;
BeatDetector beatDetector;

void setup(){
  fullScreen();
  p5 = new ControlP5(this);
  audioIn = new AudioIn(this);
  waveform = new Waveform(this, waveDataSize);
  reverb = new Reverb(this);
  
  loadIcon();
  loadMusic();
  setUI();
}

void draw(){
  background(0x000000);
  index++;
  reverb.set(room, damp, wet);
  musicList.get(musicIndex).amp(volume);
  refreshButtonStatue();
  refreshProgress();
  drawWave();
  setVisible();
  if (index % 6 == 0){
    if (direction){
      colorRangeMin++;
      colorRangeMax++;
    }else{
      colorRangeMin--;
      colorRangeMax--;
    }
    if (colorRangeMin == 0 || colorRangeMax == 360){
      direction = !direction;
    }
  }
}

void setVisible(){
  playButton.setVisible(showUI);
  lastButton.setVisible(showUI);
  nextButton.setVisible(showUI);
  stopButton.setVisible(showUI);
  volumeBar.setVisible(showUI);
  progressBar.setVisible(showUI);
  reverbRoom.setVisible(showUI);
  reverbDamp.setVisible(showUI);
  reverbWet.setVisible(showUI);
  circleSizeBar.setVisible(showUI);
  mode1.setVisible(showUI);
  mode2.setVisible(showUI);
  mode3.setVisible(showUI);
}

void drawWave(){
  waveform.analyze();
  switch(mode){
    case 1:
    drawCircle();
    break;
    case 2:
    drawLine();
    break;
    case 3:
    drawBar();
    break;
    default:
    drawCircle();
    break;
  }
}

void drawCircle(){
  stroke(waveColor);
  strokeWeight(waveWeight);
  fill(waveColor);
  pushMatrix();
  beginShape();
  translate(width/2, height/2);
  for(int i = 0; i < waveDataSize; i++){
    float angle = map(i,0,waveDataSize,0,TWO_PI);
    vertex(map(waveform.data[i], -1, 1, 0, circleSize)*cos(angle),map(waveform.data[i], -1, 1, 0, circleSize)*sin(angle));
  }
  endShape(CLOSE);
  popMatrix();
}

void drawLine(){
  colorMode(HSB, 400);
  stroke(waveColor);
  strokeWeight(5);
  fill(waveColor);
  float angle = 2*PI/waveDataSize;
  pushMatrix();
  beginShape();
  translate(width/2, height/2);
  for(int i = 0; i < waveDataSize; i++){
    rotate(angle);
    stroke(map(i,0,waveDataSize, 0, 360), 400, 400);
    line(0,map(waveform.data[i], -1, 1, 0, circleSize)-waveWeight,0, map(waveform.data[i], -1, 1, 0, circleSize));
  }
  endShape();
  popMatrix();
}

void drawBar(){
  colorMode(HSB, 400);
  stroke(waveColor);
  strokeWeight(5);
  fill(waveColor);
  float angle = 2*PI/waveDataSize;
  pushMatrix();
  beginShape();
  translate(width/2, height/2);
  for(int i = 0; i < waveDataSize; i++){
    rotate(angle);
    if (i < waveDataSize/2){
      stroke(map(i,0,waveDataSize, colorRangeMin, colorRangeMax), 400, 400);
    }else{
      stroke(map(i,0,waveDataSize, colorRangeMax, colorRangeMin), 400, 400);
    }
    line(0,0,0, map(waveform.data[i], -1, 1, 0, circleSize));
  }
  endShape();
  popMatrix();
}

void setUI(){
  playButton = p5.addButton("playMusic");
  playButton.setPosition(width/2-buttonWidth*0.5,height-buttonHeight-10);
  playButton.setSize(buttonWidth, buttonHeight);
  playButton.setImage(playIcon);
  
  lastButton = p5.addButton("lastMusic");
  lastButton.setPosition(width/2-buttonWidth*1.5-10,height-buttonHeight-10);
  lastButton.setSize(buttonWidth, buttonHeight);
  lastButton.setImage(lastIcon);
  
  nextButton = p5.addButton("nextMusic");
  nextButton.setPosition(width/2+buttonWidth*0.5+10,height-buttonHeight-10);
  nextButton.setSize(buttonWidth, buttonHeight);
  nextButton.setImage(nextIcon);
  
  stopButton = p5.addButton("stopMusic");
  stopButton.setPosition(width/2-buttonWidth*2.5-20,height-buttonHeight-10);
  stopButton.setSize(buttonWidth, buttonHeight);
  stopButton.setImage(stopIcon);
  
  volumeBar = p5.addSlider("onVolumeChange");
  volumeBar.setSize(width-(int)(width/2+buttonWidth*1.5+50)+10, sliderHeight);
  volumeBar.setValue(50);
  volumeBar.setPosition(width/2+buttonWidth*1.5+20,height-buttonHeight/2-10-sliderHeight/2);
  volumeBar.setLabelVisible(false);
  volumeBar.setColorBackground(0xffffffff);
 
  progressBar = p5.addSlider("onProgress");
  progressBar.setSize(width-40,sliderHeight);
  progressBar.setValue(0);
  progressBar.setRange(0,100);
  progressBar.setPosition(20,height-buttonHeight-20-sliderHeight);
  progressBar.setLabelVisible(false);
  progressBar.setColorBackground(0xffffffff);
  
  reverbRoom = p5.addSlider("onRoomChange");
  reverbRoom.setSize(width/3, sliderHeight);
  reverbRoom.setPosition(20,10);
  reverbRoom.setValue(0);
  reverbRoom.setRange(0,100);
  reverbRoom.setLabel("Room");
  reverbRoom.setColorBackground(0xffffffff);
  
  reverbDamp = p5.addSlider("onDampChange");
  reverbDamp.setSize(width/3, sliderHeight);
  reverbDamp.setPosition(20,20+sliderHeight);
  reverbDamp.setValue(0);
  reverbDamp.setRange(0,100);
  reverbDamp.setLabel("Damp");
  reverbDamp.setColorBackground(0xffffffff);
  
  reverbWet = p5.addSlider("onWetChange");
  reverbWet.setSize(width/3, sliderHeight);
  reverbWet.setPosition(20,30+sliderHeight*2);
  reverbWet.setValue(0);
  reverbWet.setRange(0,100);
  reverbWet.setLabel("Wet");
  reverbWet.setColorBackground(0xffffffff);
  
  mode1 = p5.addButton("onMode1");
  mode1.setSize(buttonWidth, buttonHeight);
  mode1.setPosition(20, 40+sliderHeight*3);
  mode1.setLabel("mode 1");
  
  mode2 = p5.addButton("onMode2");
  mode2.setSize(buttonWidth, buttonHeight);
  mode2.setPosition(30+buttonWidth, 40+sliderHeight*3);
  mode2.setLabel("mode 2");
  
  mode3 = p5.addButton("onMode3");
  mode3.setSize(buttonWidth, buttonHeight);
  mode3.setPosition(40+buttonWidth*2, 40+sliderHeight*3);
  mode3.setLabel("mode 3");
  
  circleSizeBar = p5.addSlider("onCircleSizeChange");
  circleSizeBar.setSize(width/3, sliderHeight);
  circleSizeBar.setPosition(20,50+sliderHeight*3+buttonHeight);
  circleSizeBar.setValue(0);
  circleSizeBar.setRange(300,Math.min(width,height));
  circleSizeBar.setLabel("Size");
  circleSizeBar.setColorBackground(0xffffffff);
}

void keyPressed(){
  switch(keyCode){
    case 32://space
    showUI = !showUI;
    break;
    case 37://left
    if (mode > 1){
      mode--;
    }else{
      mode = 3;
    }
    break;
    case 39://right
    if (mode < 3){
      mode++;
    }else{
      mode = 1;
    }
    break;
  }
}

void loadMusic(){
  for (int i = 0; i < musicNames.length; i++){
    musicList.add(new SoundFile(this, musicNames[i]));
  }
  
  waveform.input(musicList.get(musicIndex));
  reverb.process(musicList.get(musicIndex));
}

void loadIcon(){
  playIcon = loadImage("icon_play.png");
  pauseIcon = loadImage("icon_pause.png");
  stopIcon = loadImage("icon_stop.png");
  nextIcon = loadImage("icon_next.png");
  lastIcon = loadImage("icon_last.png");
  
  playIcon.resize(buttonWidth, buttonHeight);
  pauseIcon.resize(buttonWidth, buttonHeight);
  stopIcon.resize(buttonWidth, buttonHeight);
  nextIcon.resize(buttonWidth, buttonHeight);
  lastIcon.resize(buttonWidth, buttonHeight);
}

void playMusic(){
  if (getIsPlaying()){
    musicList.get(musicIndex).pause();
  }else{
    musicList.get(musicIndex).play();
  }
}

void stopMusic(){
  musicList.get(musicIndex).stop();
}

void nextMusic(){
  musicList.get(musicIndex).stop();
  musicIndex++;
  if (musicIndex == musicList.size()){
    musicIndex = 0;
  }
  musicList.get(musicIndex).play();
  waveform.input(musicList.get(musicIndex));
  reverb.process(musicList.get(musicIndex));
}

void lastMusic(){
  musicList.get(musicIndex).stop();
  musicIndex--;
  if (musicIndex < 0){
    musicIndex = musicList.size()-1;
  }
  musicList.get(musicIndex).play();
  waveform.input(musicList.get(musicIndex));
  reverb.process(musicList.get(musicIndex));
}

void onVolumeChange(float value){
  this.volume = value / 100;
}

void onProgress(float value){
  if (!onRefresh){
    musicList.get(musicIndex).jump(musicList.get(musicIndex).duration() * value / 100);
    musicList.get(musicIndex).pause();
  }
}

void onRoomChange(float value){
  this.room = value / 100;
}

void onDampChange(float value){
  this.damp = value / 100;
}

void onWetChange(float value){
  this.wet = value / 100;
}

void onMode1(){
  this.mode = 1;
}

void onMode2(){
  this.mode = 2;
}

void onMode3(){
  this.mode = 3;
}

void onCircleSizeChange(int value){
  this.circleSize = value;
}

void refreshButtonStatue(){
  if (getIsPlaying()){
    playButton.setImage(pauseIcon);
  }else{
    playButton.setImage(playIcon);
  }
}

void refreshProgress(){
  onRefresh = true;
  progressBar.setValue(musicList.get(musicIndex).percent());
  onRefresh = false;
  if (musicList.get(musicIndex).percent() > 99.9){
    nextMusic();
  }
}

boolean getIsPlaying(){
  return musicList.get(musicIndex).isPlaying();
}
