% Get current folder

curDir = pwd;
cd('LiquidHandler/OTfiles')
%% Start up script for connecting to the robot

%import the robot directly
% import py.opentrons.robot;
robot = py.opentrons.robot;
% Add well location function
mod = py.importlib.import_module('getLoc');
py.importlib.reload(mod);

robot.reset();

pause(3);
%return to main folder
cd(curDir);

%Open up OT gui

OTgui(robot);
% %% Connect to the robot
% 
% conn = robot.connect('COM3');
% 
% if conn == 1
%     robot.home()
% else
%     error('Could not connect to robot')    
% end

%% Set up deck
tiprack200= py.opentrons.containers.load('tiprack-200ul','A1');
trash= py.opentrons.containers.load('point','B2');
p200 = py.opentrons.instruments.Pipette(pyargs('axis','b','max_volume',200,'min_volume',20,'channels',1,'name','p200','tip_racks',py.list({tiprack200}),'trash_container',trash));
p1000 = py.opentrons.instruments.Pipette(pyargs('axis','a','max_volume',1000,'min_volume',200,'channels',1,'name','p1000','trash_container',trash));
% p200 = py.opentrons.instruments.Pipette(pyargs('axis','b','max_volume',200,'min_volume',20,'channels',1,'name','p200','tip_racks',[tiprack200]));

% Get previous calibrations maybe p200.load_persisted_data()
%% Calibrating tiprack200 Position if not already calibrated
% Move pipette to position. 
firstHole = py.getLoc.get_well(tiprack200,'A1');
rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',tiprack200));
tipCoord = py.tuple({tiprack200,rel_pos});
%calibrate this position based on the current pipette position
p200.calibrate_position(tipCoord);

%% Calibrating trash Position if not already calibrated
firstHole = py.getLoc.get_well(trash,'A1');
rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',trash));
tipCoord = py.tuple({trash,rel_pos});

p200.calibrate_position(tipCoord);


%% adding p1000 tip rack now
tiprack1000= py.opentrons.containers.load('tiprack-1000ul','B3');
p1000.tip_racks = py.list({tiprack1000});
% Calibrate
firstHole = py.getLoc.get_well(tiprack1000,'A1');
rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',tiprack1000));
tipCoord = py.tuple({tiprack1000,rel_pos});

p1000.calibrate_position(tipCoord);

% Pick up first tip to test
currTip = mod.get_well(tiprack1000,int8(0));
p1000.pick_up_tip(currTip,false)

% Calibrate trash
firstHole = py.getLoc.get_well(trash,'A1');
rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',trash));
tipCoord = py.tuple({trash,rel_pos});

p1000.calibrate_position(tipCoord);


%% Add tube rack to deck and calibrate
tuberack2ml = py.opentrons.containers.load('tube-rack-2ml','B1');
firstHole = py.getLoc.get_well(tuberack2ml,'A1');
rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',tuberack2ml));
tipCoord = py.tuple({tuberack2ml,rel_pos});

p1000.calibrate_position(tipCoord);


plate24 = py.opentrons.containers.load('24-plate','D2');
firstHole = py.getLoc.get_well(plate24,'A1');
rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',plate24));
tipCoord = py.tuple({plate24,rel_pos});

p1000.calibrate_position(tipCoord);

%% After calibrating those lets try something
currTip = mod.get_well(tiprack1000,int8(8));
p1000.pick_up_tip(currTip,false)
p1000.aspirate(500,mod.get_well(tuberack2ml,'A1'),1,false)
p1000.dispense(500,mod.get_well(plate24,'C1'),1,false)
p1000.drop_tip([],false)

%% try running as a protocol

currTip = mod.get_well(tiprack1000,int8(7));
p1000.pick_up_tip(currTip);
p1000.aspirate(500,mod.get_well(tuberack2ml,'B1'));
p1000.dispense(500,mod.get_well(plate24,'D1'));
p1000.drop_tip();


robot.run()

%% Look into moving the plate.

% get the current calibrated position
rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',plate24));
coords = p1000.calibrator.convert(plate24,rel_pos);
% convert coords to VectorValues
coordVals = coords.to_tuple();

delta_x = 18*0;
delta_y = 18*1;

newCoord = py.tuple({coordVals.x+delta_x,coordVals.y+delta_y,coordVals.z})

tipCoord = py.tuple({plate24,rel_pos});

p1000.calibrate_position(tipCoord,newCoord);

p1000.move_to(mod.get_well(plate24,'A1').top(),'arc',false)

%% pretend to be a microscope manually
globalTipNum = 14;
currTip = mod.get_well(tiprack1000,int8(globalTipNum));
globalTipNum = globalTipNum+1;
p1000.pick_up_tip(currTip);
source = mod.get_well(tuberack2ml,'C1');
dest = mod.get_well(plate24,'B2');
vol = 200;
p1000.aspirate(vol,source);
p1000.move_to(dest.top());

robot.run()

robot.clear_commands();



rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',plate24));
coords = p1000.calibrator.convert(plate24,rel_pos);
% convert coords to VectorValues
coordVals = coords.to_tuple();

delta_x = 18*0;
delta_y = 18*0;

newCoord = py.tuple({coordVals.x+delta_x,coordVals.y+delta_y,coordVals.z});

tipCoord = py.tuple({plate24,rel_pos});

p1000.calibrate_position(tipCoord,newCoord);

robot.clear_commands()

p1000.dispense(vol,dest);
p1000.mix(int8(2),200);
p1000.drop_tip();

robot.run()

robot.clear_commands();

currTip = mod.get_well(tiprack1000,int8(globalTipNum));
globalTipNum = globalTipNum+1;
p1000.pick_up_tip(currTip);
source = mod.get_well(tuberack2ml,'C1');
dest = mod.get_well(plate24,'C2');
vol = 200;
p1000.aspirate(vol,source);
p1000.move_to(dest.top());

robot.run()

robot.clear_commands();

rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',plate24));
coords = p1000.calibrator.convert(plate24,rel_pos);
% convert coords to VectorValues
coordVals = coords.to_tuple();

delta_x = 18*0;
delta_y = 18*1;

newCoord = py.tuple({coordVals.x+delta_x,coordVals.y+delta_y,coordVals.z});

tipCoord = py.tuple({plate24,rel_pos});

p1000.calibrate_position(tipCoord,newCoord);

robot.clear_commands()

p1000.dispense(vol,dest);
p1000.mix(int8(2),200);
p1000.drop_tip();

robot.run()




