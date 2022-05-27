
% Testing new class
%% Initiate OpenTrons
OT = OpenTrons;

%% Specify deck and pipettese
tiprack200 = OT.loadContainer('tiprack200','tiprack-200ul','C1');
trash = OT.loadContainer('trash','point','C2');
p200 = OT.loadPipette('p200','b',200,'min_volume',20,'trash_container',OT.trash,'tip_racks',{OT.tiprack200});

p1000 = OT.loadPipette('p1000','a',1000,'min_volume',200);
tiprack1000 = OT.loadContainer('tiprack1000','tiprack-1000ul','C3');
% tiprack1000b = OT.loadContainer('tiprack1000b','tiprack-1000ul','C3');

p1000.trash_container = trash;
% p1000.tip_racks = tiprack1000b;
p1000.add_tip_rack(tiprack1000,1);

plate24 = OT.loadContainer('plate24','24-plate','D2');

%% Calibrating positions


p200.calibrate_position(tiprack200,'A1')

% currTip = OT.helper.get_well(tiprack200,'A1');
p200.pick_up_tip([],'Now')

p200.calibrate_position(trash,'A1')
p200.drop_tip([],'Now')

p200.return_tip('Now')

p200.calibrate_position(plate24,'A1')

p200.pypette.move_to(OT.helper.get_well(plate24,'A1').bottom(),'arc',false)


p1000.calibrate_position(tiprack1000,'A1');
p1000.calibrate_position(trash,'A1');

p1000.pypette.start_at_tip(OT.helper.get_well(tiprack1000,'A3'))
p1000.pick_up_tip([],'Now')
p1000.drop_tip([],'Now')

%% Testing protocol
% p200.pick_up_tip([],'Now')
% p200.aspirate(100,OT.helper.get_well(plate24,'A1'),[],'Now')
% p200.dispense(50,OT.helper.get_well(plate24,'A2'),[],'Now')
% p200.mix(2,[],OT.helper.get_well(plate24,'A2'),[],'Now')
% p200.dispense(50,OT.helper.get_well(plate24,'B1'),[],'Now')
% p200.blow_out([],'Now')
% p200.touch_tip([],'Now')
% p200.drop_tip([],'Now')
% 
% p200.pick_up_tip()
% p200.aspirate(100,OT.helper.get_well(plate24,'A1'))
% p200.dispense(50,OT.helper.get_well(plate24,'A2'),1.5)
% p200.dispense(50,OT.helper.get_well(plate24,'B1'),0.5)
% p200.drop_tip()

%% Testing getting calibrated position
currCalib = p200.pypette.calibrator.convert(OT.helper.get_well(plate24,'A1'))
p200.move_to(OT.helper.get_well(plate24,'A1'),'queuing','Now')
currCalib = p200.pypette.calibrator.convert(plate24,OT.rel_pos(plate24,'A1'))
% deltaPos = OT.helper.xyzToVect(5,-5,0);

dX = 5;
dY = -5;
dZ = 0;
currCalibVV = currCalib.to_tuple
newCalibCell = {currCalibVV.x+dX,currCalibVV.y+dY,currCalibVV.z+dZ}
p200.calibrate_position(plate24,'A1','specified_pos',newCalibCell)
currCalib = p200.pypette.calibrator.convert(OT.helper.get_well(plate24,'A1'))

%% Testing dynamic container

OT.set_dynamic_cont(plate24,Scp)
p200.calibrate_position(plate24,'A1')
p200.move_to(OT.helper.get_well(plate24,'A1').bottom,'queuing','Now')

% move the stage and recalibrate
p200.calibrate_position(plate24,'A1','update_dyn_stage',1)
p200.move_to(OT.helper.get_well(plate24,'A1').bottom,'queuing','Now')

%% Sending to queue

testCommands = struct;
testCommands.name = 'test OT in';
testCommands.comd(1,:) = {OT.p200,'pick_up_tip',{py.None,'OTqueue'}};
testCommands.comd(2,:) = {OT.p200,'aspirate',{100,OT.helper.get_well(plate24,'A1'),py.None,'OTqueue'}};
testCommands.comd(3,:) = {OT.p200,'dispense',{50,OT.helper.get_well(plate24,'A2'),py.None,'OTqueue'}};


OT.sendToExtQueue(Scp.Sched,testCommands,20,'absolute',2)

testCommands = struct;
testCommands.name = 'test OT in 2';
testCommands.comd(1,:) = {OT.p200,'dispense',{50,OT.helper.get_well(plate24,'B1'),py.None,'OTqueue'}};
testCommands.comd(2,:) = {OT.p200,'drop_tip',{py.None,'OTqueue'}};

OT.sendToExtQueue(Scp.Sched,testCommands,40,'absolute',2)

%% Testing updated methods

p200.pick_up_tip('queuing','Now')
p200.move_to(OT.helper.get_well(plate24,'A1').bottom,'queuing','Now')
p200.aspirate(100,OT.helper.get_well(plate24,'A1').bottom,'queuing','Now')
p200.move_to(OT.helper.get_well(plate24,'B2').top,'queuing','Now')
p200.dispense(100,OT.helper.get_well(plate24,'B2').bottom,'queuing','Now')
p200.mix(3,50,'queuing','Now')
p200.blow_out('queuing','Now')
p200.touch_tip('queuing','Now')
p200.move_to(OT.helper.get_well(plate24,'B2').top,'queuing','Now')
p200.drop_tip('queuing','Now')
p200.home('queuing','Now')

%% Think about how to best populate queue

QueueList = OTexQueue;

QueueList(1).Name = 'firstThing';
QueueList(1).TimePoint = 15;
QueueList(1).MDdescr = 'This is the first thing to run';

p200.pick_up_tip('queuing','ExtQueue','locqueue',QueueList(1))
p200.move_to(OT.helper.get_well(plate24,'A1').bottom,'queuing','ExtQueue','locqueue',QueueList(1))
p200.aspirate(100,OT.helper.get_well(plate24,'A1').bottom,'queuing','ExtQueue','locqueue',QueueList(1))
p200.move_to(OT.helper.get_well(plate24,'B2').top,'queuing','ExtQueue','locqueue',QueueList(1))

QueueList(2).Name = 'secondThing';
QueueList(2).TimePoint = 60;
QueueList(2).TimeOrder = 1;
QueueList(2).MDdescr = 'This is the second thing to run';


p200.dispense(100,OT.helper.get_well(plate24,'B2').bottom,'queuing','ExtQueue','locqueue',QueueList(2))
p200.mix(3,50,'queuing','ExtQueue','locqueue',QueueList(2))
p200.blow_out('queuing','ExtQueue','locqueue',QueueList(2))
p200.touch_tip('queuing','ExtQueue','locqueue',QueueList(2))
p200.move_to(OT.helper.get_well(plate24,'B2').top,'queuing','ExtQueue','locqueue',QueueList(2))

QueueList(3).Name = 'thirdThing';
QueueList(3).TimePoint = 60;
QueueList(3).TimeOrder = -1; % add to end of the same time point
QueueList(3).MDdescr = 'This is the third thing to run';

p200.drop_tip('queuing','ExtQueue','locqueue',QueueList(3))


OT.sendToExtQueue(Scp.Sched,QueueList)

