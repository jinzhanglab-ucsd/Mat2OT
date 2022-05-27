
% Testing new class
%% Initiate OpenTrons
OT = OpenTrons;

%% Specify deck

tiprack200a = OT.loadContainer('tiprack200a','tiprack-200ul','C1');
tiprack200b = OT.loadContainer('tiprack200b','tiprack-200ul','C3');
% tiprack200sing = OT.loadContainer('tiprack200sing','tiprack-200ul','A3');
trash = OT.loadContainer('trash','point','B2');

% plate96drugstest = OT.loadContainer('plate96drugstest','96-supertall-well','B3');
plate96drugs = OT.loadContainer('plate96drugs','96-deep-well','B1');
plate96scp = OT.loadContainer('plate96scp','96-deep-well','D2');
% tubeRack = OT.loadContainer('tubeRack','tube-rack-2ml','A2');
% Specify plate 24 is the dynamic plate
% OT.set_dynamic_cont(plate96scp,Scp)
%% Specify pipettes

p300_multi = OT.loadPipette('p300_multi','a',300,'min_volume',50,'channels',8,'trash_container',OT.trash,'tip_racks',{OT.tiprack200a,OT.tiprack200b});
% p1000 = OT.loadPipette('p1000','b',1000,'min_volume',200,'trash_container',OT.trash,'tip_racks',{OT.tiprack1000});

%% Specify starting tip location

% p300_multi.start_at_tip(tiprack200,'A1');
p300_multi.pypette.start_at_tip(OT.helper.getRow(tiprack200a,'3'))
p300_multi.pypette.start_at_tip(OT.helper.getRow(tiprack200b,'2'))
% p1000.start_at_tip(tiprack1000,'G3');

%% Calibration stuff

p300_multi.pick_up_tip('presses',8)
% p300_multi.aspirate(50,py.None)
p300_multi.aspirate(50,plate96drugs.well('A1'))
% p300_multi.aspirate(50,py.None,'queuing','Now')
% p300_multi.dispense([],py.None)
% p300_multi.aspirate(50,calibTube.well('A1'),'queuing','Now')
p300_multi.dispense(50,plate96drugs.well('A3').bottom())
p300_multi.mix(3,100,'rate',1,'loc','here')
p300_multi.blow_out()
p300_multi.touch_tip()
p300_multi.return_tip()
p300_multi.drop_tip()
p300_multi.homeAll('queuing','Now')
% Test protocol by itself
p300_multi.pick_up_tip('queuing','Now')
p300_multi.aspirate(50,plate96drugs.well('A2'),'queuing','Now')
p300_multi.dispense(50,plate96drugs.well('A3').bottom(),'queuing','Now')
p300_multi.move_to(plate96scp.well('A1').top(),'queuing','Now')
p300_multi.dispense(50,plate96scp.well('A1').bottom(),'queuing','Now')
p300_multi.mix(3,100,'rate',1,'queuing','Now')
p300_multi.blow_out('queuing','Now')
p300_multi.move_to(plate96scp.well('A1').top(),'strategy','direct','queuing','Now')

%% Now set up protocol
% p1000.transfer_prep(200,tubes1_5mL.wells('A1'),tubes1_5mL.wells('B1'),'queuing','Now')
% p1000.transfer_disp(tubes1_5mL.wells('B1').bottom(),'vol',200,'mixreps',3,'blowout',1,'queuing','Now')
QueueList = OTexQueue;

IsoWell = {'A1','A2','A3','A4'};
FIWell = {'A7','A8','A9','A10'};
% FIwell = 'A8';
stageWell = {'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12'};

QueueNum = 0;
switchVar = [1,2,3,4,1,2,3,4,1,2,3,4];
for k = 1:12
    
    QueueNum = QueueNum +1;
QueueList(QueueNum).Name = 'PrepDrugDelivery';
QueueList(QueueNum).TimePoint = -1;
QueueList(QueueNum).TimeOrder = 1;
QueueList(QueueNum).QueueIndex = [k 1 0 1];
MDinfo.desc = 'Prep Deliver';
MDinfo.conc = 0;
MDinfo.units = 'N/A';
MDinfo.type = 'Drug Prep';
QueueList(QueueNum).MDdescr = MDinfo;
% QueueList(1).MDdescr = ' 50 uL Iso dose range to stage plate row 1 from row 1 of 96 well drugs';
QueueList(QueueNum).waitToCont = 0;



p300_multi.pick_up_tip('presses',8,'queuing','ExtQueue','locqueue',QueueList(QueueNum))
% p1000.move_to(OT.helper.get_well(tubes1_5mL,'A1').bottom,'queuing','ExtQueue','locqueue',QueueList(1))
p300_multi.aspirate(50,plate96drugs.well(IsoWell{switchVar(k)}).bottom(),'queuing','ExtQueue','locqueue',QueueList(QueueNum))
p300_multi.move_to(plate96drugs.well(IsoWell{switchVar(k)}).top(),'queuing','ExtQueue','locqueue',QueueList(QueueNum))

QueueNum = QueueNum +1;
QueueList(QueueNum).Name = 'DeliverDrugScreen';
QueueList(QueueNum).TimePoint = -1;
QueueList(QueueNum).TimeOrder = 1;
QueueList(QueueNum).QueueIndex = [k 1 0 -1];
MDinfo.desc = 'Deliver Drugs';
MDinfo.conc = 50;
MDinfo.units = 'uL';
MDinfo.type = 'Drug Delivery';
QueueList(QueueNum).MDdescr = MDinfo;
QueueList(QueueNum).waitToCont = 1;
% QueueList(2).MDdescr = 'Deliver 50 uL different Iso doses to stage 96 well and then mix';


% p300_multi.dispense(50,plate96drugs.well('A8').bottom(),'queuing','ExtQueue','locqueue',QueueList(2))

% OT.sendToExtQueue(Scp.Sched,QueueList)

p300_multi.dispense(50,plate96drugs.well('A5').bottom(),'queuing','ExtQueue','locqueue',QueueList(QueueNum))
p300_multi.mix(3,50,'rate',.5,'loc','here','queuing','ExtQueue','locqueue',QueueList(QueueNum))
% p300_multi.blow_out('queuing','ExtQueue','locqueue',QueueList(QueueNum))
% p300_multi.touch_tip('queuing','ExtQueue','locqueue',QueueList(2))
p300_multi.move_to(plate96drugs.well('A5').top(),'strategy','direct','queuing','ExtQueue','locqueue',QueueList(QueueNum))


QueueNum = QueueNum +1;
QueueList(QueueNum).Name = 'PrepFskIbmxDelivery';
QueueList(QueueNum).TimePoint = -1;
QueueList(QueueNum).TimeOrder = 1;
QueueList(QueueNum).QueueIndex = [k 3 0 -1];
MDinfo.desc = 'Prep Deliver';
MDinfo.conc = 0;
MDinfo.units = 'N/A';
MDinfo.type = 'Drug Prep';
QueueList(QueueNum).MDdescr = MDinfo;
% QueueList(1).MDdescr = ' 50 uL Iso dose range to stage plate row 1 from row 1 of 96 well drugs';
QueueList(QueueNum).waitToCont = 0;


p300_multi.aspirate(50,plate96drugs.well(FIWell{switchVar(k)}).bottom(),'queuing','ExtQueue','locqueue',QueueList(QueueNum))
p300_multi.move_to(plate96drugs.well(FIWell{switchVar(k)}).top(),'queuing','ExtQueue','locqueue',QueueList(QueueNum))


QueueNum = QueueNum +1;
QueueList(QueueNum).Name = 'DeliverFskIbmx';
QueueList(QueueNum).TimePoint = -1;
QueueList(QueueNum).TimeOrder = 1;
QueueList(QueueNum).QueueIndex = [k 10 0 1];
MDinfo.desc = 'Deliver FSK + IBMX';
MDinfo.conc = 50;
MDinfo.units = 'uL';
MDinfo.type = 'Drug Delivery';
QueueList(QueueNum).MDdescr = MDinfo;
QueueList(QueueNum).waitToCont = 1;


p300_multi.dispense(50,plate96scp.well(stageWell{k}).bottom(),'queuing','ExtQueue','locqueue',QueueList(QueueNum))
p300_multi.mix(3,50,'rate',.5,'queuing','ExtQueue','locqueue',QueueList(QueueNum))
% p300_multi.blow_out('queuing','ExtQueue','locqueue',QueueList(QueueNum))
% p300_multi.touch_tip('queuing','ExtQueue','locqueue',QueueList(2))
p300_multi.move_to(plate96scp.well(stageWell{k}).top(),'strategy','direct','queuing','ExtQueue','locqueue',QueueList(QueueNum))


QueueNum = QueueNum +1;
QueueList(QueueNum).Name = 'trashTip';
QueueList(QueueNum).TimePoint = -1;
QueueList(QueueNum).TimeOrder = -1; % add to end of the same time point
QueueList(QueueNum).QueueIndex = [k 10 0 -1];
MDinfo.desc = 'Trash Tip';
MDinfo.conc = 0;
MDinfo.units = 'N/A';
MDinfo.type = 'Trash Tip';
QueueList(QueueNum).MDdescr = MDinfo;
% QueueList(5).MDdescr = 'get rid of tip and home';
QueueList(QueueNum).waitToCont = 0;

p300_multi.drop_tip('queuing','ExtQueue','locqueue',QueueList(QueueNum))
% p300_multi.home('queuing','ExtQueue','locqueue',QueueList(QueueNum))

end

OT.sendToExtQueue(Scp.Sched,QueueList)
% QueueList(3).Name = 'trashTip';
% QueueList(3).TimePoint = 60;
% QueueList(3).TimeOrder = -1; % add to end of the same time point
% QueueList(3).MDdescr = 'get rid of tip and home';
% QueueList(3).waitToCont = 0;
% 
% p300_multi.drop_tip('queuing','ExtQueue','locqueue',QueueList(3))
% p300_multi.home('queuing','ExtQueue','locqueue',QueueList(3))

QueueList(3).Name = 'PrepFSKibmx';
QueueList(3).TimePoint = 120;
QueueList(3).TimeOrder = 2;
MDinfo.desc = 'Prep FSK IBMX';
MDinfo.conc = 0;
MDinfo.units = 'N/A';
MDinfo.type = 'Drug Prep';
QueueList(3).MDdescr = MDinfo;
% QueueList(3).MDdescr = 'Prep Deliver 50 uL of 25 uM FSK + 50 uM IBMX to stage';
QueueList(3).waitToCont = 0;

% p300_multi.pick_up_tip('queuing','ExtQueue','locqueue',QueueList(3))
% p300_multi.move_to(OT.helper.get_well(tubes1_5mL,'A1').bottom,'queuing','ExtQueue','locqueue',QueueList(4))
p300_multi.aspirate(50,plate96drugs.well(FIwell).bottom(),'queuing','ExtQueue','locqueue',QueueList(3))
p300_multi.move_to(plate96scp.well(stageWell).top(),'queuing','ExtQueue','locqueue',QueueList(3))

QueueList(4).Name = 'DeliverFI';
QueueList(4).TimePoint = 240;
QueueList(4).TimeOrder = 1;
MDinfo.desc = 'Deliver FSK IBMX';
MDinfo.conc = 50;
MDinfo.units = 'uL';
MDinfo.type = 'Drug Delivery';
QueueList(4).MDdescr = MDinfo;
% QueueList(4).MDdescr = 'Deliver 50 uL of 25 uM FSK + 50 uM IBMX to stage';


p300_multi.dispense(50,plate96scp.well(stageWell).bottom(),'queuing','ExtQueue','locqueue',QueueList(4))
p300_multi.mix(3,100,'rate',.5,'queuing','ExtQueue','locqueue',QueueList(4))
p300_multi.blow_out('queuing','ExtQueue','locqueue',QueueList(4))
% p300_multi.touch_tip('queuing','ExtQueue','locqueue',QueueList(2))
p300_multi.move_to(plate96scp.well(stageWell).top(),'strategy','direct','queuing','ExtQueue','locqueue',QueueList(4))

QueueList(5).Name = 'trashTip';
QueueList(5).TimePoint = 240;
QueueList(5).TimeOrder = -1; % add to end of the same time point
MDinfo.desc = 'Trash Tip';
MDinfo.conc = 0;
MDinfo.units = 'N/A';
MDinfo.type = 'Trash Tip';
QueueList(5).MDdescr = MDinfo;
% QueueList(5).MDdescr = 'get rid of tip and home';
QueueList(5).waitToCont = 0;

p300_multi.drop_tip('queuing','ExtQueue','locqueue',QueueList(5))
p300_multi.home('queuing','ExtQueue','locqueue',QueueList(5))

% queueInd = 7;
% QueueList(queueInd).Name = 'PrepDeliverToC1';
% QueueList(queueInd).TimePoint = 360.2;
% QueueList(queueInd).MDdescr = 'Prep Deliver 200 uL to stage plate C1 from 2 mL tube rack A3';
% QueueList(queueInd).waitToCont = 0;
% 
% p1000.pick_up_tip('queuing','ExtQueue','locqueue',QueueList(queueInd))
% % p1000.move_to(OT.helper.get_well(tubes1_5mL,'A1').bottom,'queuing','ExtQueue','locqueue',QueueList(4))
% p1000.aspirate(200,OT.helper.get_well(tubes1_5mL,'A3').bottom,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.move_to(OT.helper.get_well(plate24drugs,'C1').top,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 8;
% QueueList(queueInd).Name = 'DeliverToC1';
% QueueList(queueInd).TimePoint = 420.2;
% QueueList(queueInd).TimeOrder = 1;
% QueueList(queueInd).MDdescr = 'Deliver 200 uL to stage plate C1 from 2 mL tube rack A3';
% 
% 
% p1000.dispense(200,OT.helper.get_well(plate24drugs,'C1').bottom,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.mix(3,200,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.blow_out('queuing','ExtQueue','locqueue',QueueList(queueInd))
% % p1000.touch_tip('queuing','ExtQueue','locqueue',QueueList(2))
% p1000.move_to(OT.helper.get_well(plate24drugs,'C1').top,'strategy','direct','queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 9;
% QueueList(queueInd).Name = 'trashTip';
% QueueList(queueInd).TimePoint = 420.2;
% QueueList(queueInd).TimeOrder = -1; % add to end of the same time point
% QueueList(queueInd).MDdescr = 'get rid of tip and home';
% QueueList(queueInd).waitToCont = 0;
% 
% p1000.drop_tip('queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 10;
% QueueList(queueInd).Name = 'PrepDeliverToC1second';
% QueueList(queueInd).TimePoint = 430.2;
% QueueList(queueInd).MDdescr = 'Prep Deliver 200 uL rhodamine to stage plate C1 from 2 mL tube rack B3';
% QueueList(queueInd).waitToCont = 0;
% 
% p1000.pick_up_tip('queuing','ExtQueue','locqueue',QueueList(queueInd))
% % p1000.move_to(OT.helper.get_well(tubes1_5mL,'A1').bottom,'queuing','ExtQueue','locqueue',QueueList(4))
% p1000.aspirate(200,OT.helper.get_well(tubes1_5mL,'B3').bottom,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.move_to(OT.helper.get_well(plate24drugs,'C1').top,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 11;
% QueueList(queueInd).Name = 'DeliverToC1second';
% QueueList(queueInd).TimePoint = 480.2;
% QueueList(queueInd).TimeOrder = 1;
% QueueList(queueInd).MDdescr = 'Deliver 200 uL rhodamine to stage plate C1 from 2 mL tube rack B3';
% 
% 
% p1000.dispense(200,OT.helper.get_well(plate24drugs,'C1').bottom,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.mix(3,200,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.blow_out('queuing','ExtQueue','locqueue',QueueList(queueInd))
% % p1000.touch_tip('queuing','ExtQueue','locqueue',QueueList(2))
% p1000.move_to(OT.helper.get_well(plate24drugs,'C1').top,'strategy','direct','queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 12;
% QueueList(queueInd).Name = 'trashTip';
% QueueList(queueInd).TimePoint = 480.2;
% QueueList(queueInd).TimeOrder = -1; % add to end of the same time point
% QueueList(queueInd).MDdescr = 'get rid of tip and home';
% QueueList(queueInd).waitToCont = 0;
% 
% p1000.drop_tip('queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.home('queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 13;
% QueueList(queueInd).Name = 'PrepDeliverToD1rhod';
% QueueList(queueInd).TimePoint = 540.3;
% QueueList(queueInd).MDdescr = 'Prep Deliver 200 uL rhodamine to stage plate D1 from 2 mL tube rack B3';
% QueueList(queueInd).waitToCont = 0;
% 
% p1000.pick_up_tip('queuing','ExtQueue','locqueue',QueueList(queueInd))
% % p1000.move_to(OT.helper.get_well(tubes1_5mL,'A1').bottom,'queuing','ExtQueue','locqueue',QueueList(4))
% p1000.aspirate(200,OT.helper.get_well(tubes1_5mL,'B3').bottom,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.move_to(OT.helper.get_well(plate24drugs,'D1').top,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 14;
% QueueList(queueInd).Name = 'DeliverToD1rhod';
% QueueList(queueInd).TimePoint = 600.3;
% QueueList(queueInd).TimeOrder = 1;
% QueueList(queueInd).MDdescr = 'Deliver 200 uL rhodamine to stage plate D1 from 2 mL tube rack B3';
% 
% 
% p1000.dispense(200,OT.helper.get_well(plate24drugs,'D1').bottom,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.mix(3,200,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.blow_out('queuing','ExtQueue','locqueue',QueueList(queueInd))
% % p1000.touch_tip('queuing','ExtQueue','locqueue',QueueList(2))
% p1000.move_to(OT.helper.get_well(plate24drugs,'D1').top,'strategy','direct','queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 15;
% QueueList(queueInd).Name = 'trashTip';
% QueueList(queueInd).TimePoint = 600.3;
% QueueList(queueInd).TimeOrder = -1; % add to end of the same time point
% QueueList(queueInd).MDdescr = 'get rid of tip and home';
% QueueList(queueInd).waitToCont = 0;
% 
% p1000.drop_tip('queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.home('queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 16;
% QueueList(queueInd).Name = 'PrepDeliverToD1fluore';
% QueueList(queueInd).TimePoint = 610.3;
% QueueList(queueInd).MDdescr = 'Prep Deliver 200 uL to stage plate D1 from 2 mL tube rack A3';
% QueueList(queueInd).waitToCont = 0;
% 
% p1000.pick_up_tip('queuing','ExtQueue','locqueue',QueueList(queueInd))
% % p1000.move_to(OT.helper.get_well(tubes1_5mL,'A1').bottom,'queuing','ExtQueue','locqueue',QueueList(4))
% p1000.aspirate(200,OT.helper.get_well(tubes1_5mL,'A3').bottom,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.move_to(OT.helper.get_well(plate24drugs,'D1').top,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 17;
% QueueList(queueInd).Name = 'DeliverToD1fluore';
% QueueList(queueInd).TimePoint = 660.3;
% QueueList(queueInd).TimeOrder = 1;
% QueueList(queueInd).MDdescr = 'Deliver 200 uL to stage plate C1 from 2 mL tube rack A3';
% 
% 
% p1000.dispense(200,OT.helper.get_well(plate24drugs,'D1').bottom,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.mix(3,200,'queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.blow_out('queuing','ExtQueue','locqueue',QueueList(queueInd))
% % p1000.touch_tip('queuing','ExtQueue','locqueue',QueueList(2))
% p1000.move_to(OT.helper.get_well(plate24drugs,'D1').top,'strategy','direct','queuing','ExtQueue','locqueue',QueueList(queueInd))
% 
% queueInd = 18;
% QueueList(queueInd).Name = 'trashTip';
% QueueList(queueInd).TimePoint = 4660.3;
% QueueList(queueInd).TimeOrder = -1; % add to end of the same time point
% QueueList(queueInd).MDdescr = 'get rid of tip and home';
% QueueList(queueInd).waitToCont = 0;
% 
% p1000.drop_tip('queuing','ExtQueue','locqueue',QueueList(queueInd))
% p1000.home('queuing','ExtQueue','locqueue',QueueList(queueInd))

OT.sendToExtQueue(Scp.Sched,QueueList)
