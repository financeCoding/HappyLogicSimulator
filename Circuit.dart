//  (c) Copyright 2012 - Ryan C. Weaving    
//
//  This file is part of Happy Logic Simulator.
//  http://HappyLogicSimulator.com 
//
//  Happy Logic Simulator is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  Happy Logic Simulator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with Happy Logic Simulator.  If not, see <http://www.gnu.org/licenses/>.
      
/**
/ A circuit contains and controls the logic simulaton
*/
class Circuit {

  static final int BORDER_LINE_WIDTH = 1;
  static final String BORDER_LINE_COLOR = '#000000';
  
  static final int    NEW_WIRE_WIDTH = 3;
  static final String NEW_WIRE_COLOR = '#990000';
  static final String NEW_WIRE_VALID = '#009900';
  static final String NEW_WIRE_INVALID = '#999999';
  
  static final String WIRE_HIGH = '#ff4444';
  static final String WIRE_LOW = '#550091';
  static final String WIRE_INVALID = '#999999';
  static final int    WIRE_WIDTH = 3;
  
  static final int GRID_SIZE = 10;
  static final int GRID_POINT_SIZE = 1;
  static final String GRID_COLOR = '#999493';
  static final String GRID_BACKGROUND_COLOR = '#eeeeee';
  static final int PIN_INDICATOR_OFFSET = 5;
  static final TAU = Math.PI * 2;
  static final int TOOLBAR_WIDTH = 115;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  
  
  ImageElement validPinImage;
  ImageElement selectPin;
  ImageElement startWireImage;
  ImageElement connectablePinImage;
   
  int width;
  int height;
  int mouseX;
  int mouseY;

  LogicDeviceTypes deviceTypes; // Has all the various type of logic devices
  List<LogicDevice> logicDevices; // Holds all the devices in the simulation
  SelectedDevices selectedDevices; // Devices that are selected
  
  DeviceInput selectedInput;
  DeviceOutput selectedOutput;

  LogicDevice moveDevice;
  LogicDevice cloneDevice;
  
  
  Wire newWire; // Pointer to our new wire if adding one
  Wires circuitWires; // Holds all the wires for the simulation

  bool showGrid = false;
  bool gridSnap = false;
  
  Circuit(this.canvas) : 
    deviceTypes = new LogicDeviceTypes(), 
    logicDevices = new List<LogicDevice>(){

    context = canvas.getContext('2d');
    width = canvas.width;
    height = canvas.height;
    
    selectedDevices = new SelectedDevices(logicDevices);
    
    circuitWires = new Wires();
    
    validPinImage = new Element.tag('img'); 
    validPinImage.src = "images/SelectPinGreen.png";
    
    selectPin = new Element.tag('img');
    selectPin.src = "images/SelectPinBlack.png";  
    
    startWireImage = new Element.tag('img');
    startWireImage.src = "images/SelectPinBlack.png"; 
    
    connectablePinImage = new Element.tag('img');
    connectablePinImage.src = "images/SelectPinPurple.png";   
    
    window.setInterval(f() => tick(), 25); // Create a timer to update the simulation tick
    window.on.resize.add((event) => onResize(), true);
  
    canvas.on.mouseDown.add(onMouseDown);
    canvas.on.mouseUp.add(onMouseUp);
    canvas.on.doubleClick.add(onMouseDoubleClick);
    canvas.on.mouseMove.add(onMouseMove);
  }
  
  // Start the simulation
  void start() {
    createSelectorBar();
    onResize();
  }
  
  void onResize() {
    height = window.innerHeight - 25;
    width = window.innerWidth - 25;
    
    canvas.height = height;
    canvas.width = width;
    
    Paint();
  }
  
  
  void createSelectorBar() {
    addNewCloneableDevice('clock', 'CLOCK', 0, 0);
    addNewCloneableDevice('switch', 'SWITCH', 0, 60);
    addNewCloneableDevice('not', 'NOT', 0, 120);
    addNewCloneableDevice('and', 'AND', 0, 180);
    addNewCloneableDevice('nand', 'NAND', 0, 240);
    addNewCloneableDevice('or', 'OR', 0, 300);
    addNewCloneableDevice('nor', 'NOR', 0, 360);
    addNewCloneableDevice('xor', 'XOR', 0, 420);
    addNewCloneableDevice('xnor', 'XNOR', 0, 480);
    addNewCloneableDevice('led', 'LED', 50, 60);
    
    Paint();
  }
  
  LogicDevice addNewCloneableDevice(var id, var type, int x, int y) {
    LogicDeviceType deviceType = deviceTypes.getDeviceType(type);
    if(deviceType != null){
        LogicDevice newDevice = new LogicDevice(id, deviceType); 
        logicDevices.add(newDevice);
        newDevice.CloneMode = true;
        newDevice.selectable = false;
        newDevice.MoveDevice(x, y);
        return newDevice;
    }
  }
  
  newDeviceFrom(LogicDevice device) {
    LogicDevice newDevice = new LogicDevice(getNewId(), device.deviceType); 
    logicDevices.add(newDevice);
    newDevice.MoveDevice(device.X, device.Y);

    moveDevice = newDevice;
  }
  
  LogicDevice GetDeviceByID(var id) {
    for (LogicDevice device in logicDevices) {
      if(device.ID == id) return device; 
    }
    return null;
  }
  
  void ClearCircuit()
  {
    logicDevices.clear();
    Paint();
  }
  
  
  void drawBorder() {
    context.beginPath();
    context.rect(TOOLBAR_WIDTH, 0, width, height);
    context.fillStyle = GRID_BACKGROUND_COLOR;
    context.lineWidth = BORDER_LINE_WIDTH;
    context.strokeStyle = GRID_BACKGROUND_COLOR;
    context.fillRect(TOOLBAR_WIDTH, 0, width, height);
    context.stroke();
    context.closePath();
  }
  
  void drawGrid(){
    context.beginPath();
    context.lineWidth = 1;
    context.strokeStyle = GRID_COLOR;
    
    for(int x=TOOLBAR_WIDTH; x < width; x+=GRID_SIZE){
      for(int y=GRID_SIZE; y < height; y+=GRID_SIZE){
        context.rect(x, y, GRID_POINT_SIZE, GRID_POINT_SIZE);
      }
    }
    context.stroke();
    context.closePath(); 
  }
 
  void tick() {
    if(logicDevices.length <= 0) return;
    
    for (LogicDevice device in logicDevices) {
      device.calculated = false;
    }
    for (LogicDevice device in logicDevices) {
      device.Calculate();
    }
    
    Paint();   
  }
  
  // add new id number
  getNewId(){    
    return logicDevices.length;
  }

  /**
  / Try to select a logic device
  */
  LogicDevice tryDeviceSelect(int x, int y) {
    for (LogicDevice device in logicDevices) {  
      if(device.contains(x, y)) {
        return device;
      }
    }            
    return null;
  }
  
  /**
  / Try to select a logic device input
  */
  DeviceInput tryInputSelect(int x, int y) {
    for (LogicDevice device in logicDevices) { 
      if(device.InputPinHit(x, y) != null) {
        return device.InputPinHit(x, y);
      }
    }
    return null;
  }
  
  /**
  / Try to select a logic device output
  */
  DeviceOutput tryOutputSelect(int x, int y) {
    for (LogicDevice device in logicDevices) { 
      if(device.OutputPinHit(x, y) != null) {
        return device.OutputPinHit(x, y);
      }
    }   
    return null;
  }
  
  /**
  / Try to select a wire at a given point
  */
  Wire tryWireSelect(int x, int y) {
    for (LogicDevice device in logicDevices) { 
      if(device.WireHit(x, y) != null) {
        return device.WireSelect(x, y);
      }
    }        
    return null;
  }  

 // Mouse events 
 void onMouseDown(MouseEvent e) {
   e.preventDefault();
   
   // If we are moving a device stop moving it and stick it
   if(moveDevice != null) { 
     moveDevice = null;
     return;
   }
   
   // If we are adding a new wire try to add a new point to it
   if(newWire != null) {
     addWirePoint(mouseX, mouseY); 
     return;
   }
   
   if(StartWire(mouseX, mouseY) == true) {
     return;
   }
   
   LogicDevice selectedDevice = tryDeviceSelect(mouseX, mouseY);
   
   if(selectedDevice != null) {
     if(selectedDevice.CloneMode == true){
       newDeviceFrom(selectedDevice);
       return;
     }
     selectedDevices.selectTopAt(mouseX, mouseY);
     selectedDevice.clicked();
     print(selectedDevice.deviceType.type);
     return;
   }
  }
 
  // User releases mouse button
  void onMouseUp(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
   
    if(selectedDevices.count > 0){ // If we are moving devices stop it
      selectedDevices.clear();
    }
  }

  void onMouseDoubleClick(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
  }
 
  // User is moving the mouse
  void onMouseMove(MouseEvent e) {
    mouseX = e.offsetX;
    mouseY = e.offsetY; 
   
    if(gridSnap) {  // Snap mouse cursor to grid
      double x1 = mouseX.toDouble() / GRID_SIZE.toDouble();
      double y1 = mouseY.toDouble() / GRID_SIZE.toDouble();
   
      mouseX = x1.toInt() * GRID_SIZE;
      mouseY = y1.toInt() * GRID_SIZE;
    }
    
    if(selectedDevices.count > 0) {
      selectedDevices.moveTo(mouseX, mouseY);
      print("selectedDevices.moveTo(${mouseX}, ${mouseY})");
      return;
    }
   
    if(moveDevice != null) {
      moveDevice.MoveDevice(mouseX, mouseY);
      Paint();
      return;
    }
   
    // If we are adding a wire update its last point
    if(newWire != null){
      newWire.UpdateLast(mouseX, mouseY);
      if(checkConnection(mouseX, mouseY)){ // Check to see if we have valid connection
      
      }
      Paint();
      return;
  }
   
    // Check to see if mouse cursor is over a vaild point and select it
    if(checkValid(mouseX, mouseY)){
      return;
    }
 }
 
 
 /**
 / Check to see if this point is a vaild connection
 */
 bool checkConnection(int x, int y) {
   if(newWire == null) return false;
   
   // Looking for a vaild input
   if(newWire.input == null) {
     DeviceInput input = tryInputSelect(x, y); 
     selectedInput = input;
     if(selectedInput != null){
       newWire.UpdateLast(input.offsetX, input.offsetY); // snap to point
       return true;
     }
   }
   
   // Looking for a vaild output
   if(newWire.output == null) {
     DeviceOutput output = tryOutputSelect(x, y);
     selectedOutput = output;
     if(selectedOutput != null){
       newWire.UpdateLast(output.offsetX, output.offsetY); // snap to point 
       return true;
     }
   }
   return false;
 }
 
 /**
 / Check to see if this point is vaild
 */
 bool checkValid(int x, int y) {
     
   if(newWire != null) { // We are adding a wire
     return checkConnection(x, y);  
   }
   
   selectedInput = tryInputSelect(x, y); 
  
   if(selectedInput != null){
     drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, "VALID");  
     return true;
   }
   
   selectedOutput = tryOutputSelect(x, y);
   
   if(selectedOutput != null){
     drawHighlightPin(selectedOutput.offsetX, selectedOutput.offsetY, "VALID");  
     return true;
   }
   
   return false;
 }

 LogicDevice checkCloneableDevices(int x, int y) {
  // Check to see if we 
   for (LogicDevice device in logicDevices)
     if(device.CloneMode)
       if(device.contains(x, y))
         return device;
 }
 
 /**
 /Try to start adding a wire, returns true if a wire is started
 */
 bool StartWire(int x, int y) {
    
    DeviceInput input = tryInputSelect(x, y);
    // If we have a vaild point then continue adding a wire
    if(input != null){ 
      newWire = circuitWires.createWire();
      newWire.input = input;
      WirePoint wp = newWire.AddPoint(input.offsetX, input.offsetY);
      input.wirePoint = wp;
      newWire.AddPoint(input.offsetX, input.offsetY); // extra point to track to mouse
      print("StartWire:${input.device.ID} ${input.id}");
      return true;
    }
    
    DeviceOutput output = tryOutputSelect(x, y);    
    if(output != null){
      newWire = circuitWires.createWire(); 
      newWire.output = output;
      WirePoint wp = newWire.AddPoint(output.offsetX, output.offsetY);
      output.wirePoint = wp;
      newWire.AddPoint(output.offsetX, output.offsetY); // extra point to track to mouse
      print("StartWire:${output.device.ID} ${output.id}");
      return true;
    }
    
    // If we are adding a new wire and we get here we should abort
    if(newWire != null)
      circuitWires.deleteWire(newWire);
 }
 
 /**
 / Add a new point to the wire and end it if vaild connection
 / returns true if wire point is added and false if wire connection ends
 */
 bool addWirePoint(int x, int y) {
   
   if(newWire == null) return false;

   newWire.UpdateLast(x, y);
      
   // Looking for a vaild input
   if(newWire.input == null) {
     DeviceInput input = tryInputSelect(x, y);
     if(input != null) {
       newWire.input = input;  
       newWire.UpdateLast(input.offsetX, input.offsetY);
       input.wirePoint = newWire.wirePoints.last();
     }
     else{// if user tries to place connection on top of start device then abort
       LogicDevice device = tryDeviceSelect(x, y);
       if(newWire.output.device != null){  
         if(device === newWire.output.device){
           abortWire();
           return false;
         }
       }
     }
   }
   
   // Looking for a valid output
   if(newWire.output == null) {
     DeviceOutput output = tryOutputSelect(x, y); 
     if(output != null) {
       newWire.output = output;
       newWire.UpdateLast(output.offsetX, output.offsetY);
       output.wirePoint = newWire.wirePoints.last();
     }
     else{// if user tries to place connection on top of start device then abort 
       LogicDevice device = tryDeviceSelect(x, y);
       if(newWire.input.device != null){  
         if(device === newWire.input.device){
           abortWire();
           return false;
         }
       }
     }
   }
   
   // Check vaid connection
   if(newWire.input != null && newWire.output != null) {
     newWire = null;
     return false;
   }

   // Add the new point
   newWire.AddPoint(x, y);
   return true;
 }
  
  // Abort the connection of two devices
  void abortWire() {
    selectedInput = null;
    selectedOutput = null;
    
    // Remove the new wire if we abort adding the wire
    if(newWire != null){
      circuitWires.deleteWire(newWire);
      newWire = null;
    }
    
    print("abortWire()");
    Paint();
  }

  void Paint() {
    clearCanvas();  
    drawBorder();
    //drawGrid();
    drawDevices();
    drawWires();
    drawPinSelectors();
  }
  
  void clearCanvas() {
    context.clearRect(0, 0, width, height);
  }
  
  // Redraw all of the devices
  void drawDevices(){
    for (LogicDevice device in logicDevices) {
      context.drawImage(device.deviceType.getImage(device.outputs[0].value), device.X, device.Y);  
    }
  }
    
  void drawWire(Wire wire) {
    if(wire == null) return;  

    context.fillStyle = context.strokeStyle;
    context.beginPath();
    context.lineWidth = WIRE_WIDTH;

    if(wire.input == null || wire.output == null){
      context.strokeStyle = WIRE_INVALID;
    }
    else{
      if(wire.output.value == true){ // High
        context.strokeStyle = WIRE_HIGH;  
      }
      else{
        context.strokeStyle = WIRE_LOW;
      }
    }

    context.fillStyle = context.strokeStyle;
    
    //need at least 2 points
    if(wire.wirePoints.length >= 2) {
      context.moveTo(wire.wirePoints[0].x, wire.wirePoints[0].y); 
      for (WirePoint point in wire.wirePoints) {
        context.lineTo(point.x, point.y);
      }
    }
    context.stroke();
    context.closePath(); 
    
    /*
    // Check to see if we need to draw a knot
    if(input.connectedOutput != null) {
      if(input.connectedOutput.offsetX != input.wire.wirePoints.last().x &&
          input.connectedOutput.offsetY != input.wire.wirePoints.last().y) {
          context.beginPath();
          context.lineWidth = 2;
          context.arc(input.wire.wirePoints[input.wire.wirePoints.length-1].x, input.wire.wirePoints[input.wire.wirePoints.length-1].y, 5, 0, TAU, false);
          context.fill();
          context.stroke();
          context.closePath(); 
      }
    }*/
  }    
  
  //Draw all the wires
  void drawWires() {
    for (Wire wire in circuitWires.wires) { 
      drawWire(wire);
    }
  }

  // Draw the device visual pin indicators
  void drawPinSelectors() {
    if(selectedOutput != null){
      drawHighlightPin(selectedOutput.offsetX, selectedOutput.offsetY, 'VALID'); 
    }
    
    if(selectedInput != null){
      drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, 'VALID'); 
    }
    
    // If we are adding a wire draw acceptable connection points
    if(newWire != null){
      if(newWire.input == null) { // Looking for a vaild input
        drawConnectableInputPins();
      }
      if(newWire.output == null){ // Looking for a vaild output
        drawConnectableOutputPins();
      }
    }
  }
  
  // Draw the output pins that we can connect to
  void drawConnectableOutputPins() {
    for (LogicDevice device in logicDevices) {
      if(device.CloneMode) continue;
      for (DeviceOutput output in device.outputs) {
        if(output.connectable == true)
          drawHighlightPin(output.offsetX, output.offsetY, 'CONNECTABLE'); 
      }
    }      
  }
  
  // Draw the input pins that we can connect to
  void drawConnectableInputPins() {
    for (LogicDevice device in logicDevices) {
      if(device.CloneMode) continue;     
      for (DeviceInput input in device.inputs) {
        if(input.connected == false && input.connectable == true)    
          drawHighlightPin(input.offsetX, input.offsetY, 'CONNECTABLE'); 
      }
    }      
  }
  
  void drawHighlightPin(int x, int y, var highlightMode) {
    x = x - PIN_INDICATOR_OFFSET;
    y = y - PIN_INDICATOR_OFFSET;
    
    switch(highlightMode){
      case 'VALID':       context.drawImage(validPinImage, x, y); break;
      case 'INVALID':     context.drawImage(validPinImage, x, y); break;
      case 'WIRECONNECT': context.drawImage(startWireImage, x, y); break;
      case 'CONNECTED':   context.drawImage(startWireImage, x, y); break;
      case 'CONNECTABLE': context.drawImage(connectablePinImage, x, y); break; 
      default:            context.drawImage(validPinImage, x, y);
    }
  }
}
  