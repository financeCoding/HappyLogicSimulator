/** Simple Logic Simulator for Google Dart Hackathon 4-27-2012   
/   By: Ryan C. Weaving  &  Athhur Liu                           */
class LogicDeviceType{
  var type;
  
  List<ImageElement> images;
  
  LogicDeviceType(this.type){
    images = new List<ImageElement>();
  }
  
}

class LogicDeviceTypes{
  List<LogicDeviceType> devicetypes;
  
  LogicDeviceTypes(){
    devicetypes = new List<LogicDeviceType>();
  }
  
  AddNewType(var type){
    devicetypes.add(new LogicDeviceType(type));
  }
  
}


Function Configure(LogicDevice device){
  switch(device.Type){
    case 'AND': ConfigureAnd2(device); break;
    case 'NAND': ConfigureNand2(device); break;
    case 'OR': ConfigureOr2(device); break;
    case 'NOR': ConfigureNor2(device); break;
    case 'XOR': ConfigureXor2(device); break;
    case 'XNOR': ConfigureXnor2(device); break;
    case 'NOT': ConfigureNot(device); break;
    case 'SWITCH': ConfigureSwitch(device); break;
    case 'LED': ConfigureLed(device); break;
    case 'DLOGO': ConfigureDartLogo(device); break;
    case 'CLOCK': ConfigureClock(device); break;
  }
}

Function ConfigureSwitch(LogicDevice device)
{
  device.addImage("images/01Switch_Low.png");
  device.addImage("images/01Switch_High.png");
  
  device.InputCount = 1;
  device.OutputCount = 1;
  device.SetInputPinLocation(0, -1, -1);
  device.SetOutputPinLocation(0, 21, 0);
}

Function ConfigureDartLogo(LogicDevice device)
{
  device.addImage("images/dartLogo.png");
  device.addImage("images/dartLogo2.png");
  
  device.InputCount = 1;
  device.OutputCount = 1;
  device.updateable = true;
  device.SetOutputPinLocation(0, -1, -1);
  device.SetInputPinLocation(0, 28, 0);
}

Function ConfigureLed(LogicDevice device)
{
  device.addImage("images/01Disp_Low.png");
  device.addImage("images/01Disp_High.png");
  
  device.InputCount = 1;
  device.OutputCount = 1;
  device.SetInputPinLocation(0, 16, 0);
  device.SetOutputPinLocation(0, -1, -1);
  device.updateable = true; 
}

Function ConfigureAnd2(LogicDevice device){
    device.addImage("images/and2.png");
    
    device.InputCount = 2;
    device.SetInputPinLocation(0, 5, 15);
    device.SetInputPinLocation(1, 5, 35);
  
    device.OutputCount = 1;
    device.SetOutputPinLocation(0, 95, 25);
}

Function ConfigureNand2(LogicDevice device){
  device.addImage("images/nand2.png");
  
  device.InputCount = 2;
  device.SetInputPinLocation(0, 5, 15);
  device.SetInputPinLocation(1, 5, 35);

  device.OutputCount = 1;
  device.SetOutputPinLocation(0, 95, 25);
}

Function ConfigureOr2(LogicDevice device){
  device.addImage("images/or.png");
  
  device.InputCount = 2;
  device.SetInputPinLocation(0, 5, 15);
  device.SetInputPinLocation(1, 5, 35);

  device.OutputCount = 1;
  device.SetOutputPinLocation(0, 95, 25);
}

Function ConfigureNor2(LogicDevice device){
  device.addImage("images/nor.png");
  
  device.InputCount = 2;
  device.SetInputPinLocation(0, 5, 15);
  device.SetInputPinLocation(1, 5, 35);

  device.OutputCount = 1;
  device.SetOutputPinLocation(0, 95, 25);
}

Function ConfigureXor2(LogicDevice device){
  device.addImage("images/xor.png");
  
  device.InputCount = 2;
  device.SetInputPinLocation(0, 5, 15);
  device.SetInputPinLocation(1, 5, 35);

  device.OutputCount = 1;
  device.SetOutputPinLocation(0, 95, 25);
}

Function ConfigureXnor2(LogicDevice device){
  device.addImage("images/xnor.png");
  
  device.InputCount = 2;
  device.SetInputPinLocation(0, 5, 15);
  device.SetInputPinLocation(1, 5, 35);

  device.OutputCount = 1;
  device.SetOutputPinLocation(0, 95, 25);
}


Function ConfigureNot(LogicDevice device){
    device.addImage("images/not.png");
    
    device.InputCount = 1;
    device.SetInputPinLocation(0, 5, 25);
  
    device.OutputCount = 1;
    device.SetOutputPinLocation(0, 94, 25);
}

Function ConfigureClock(LogicDevice device)
{
  device.addImage("images/Clock.png");
  
  device.InputCount = 1;
  device.SetInputPinLocation(0, 0, 0);
  device.SetInputConnectable(0, false);
  
  device.OutputCount = 2;
  device.SetOutputPinLocation(0, 64, 14);
  device.SetOutputPinLocation(1, 64, 39);
}