function vlcDevicestart (cfg, payload, vlcConfig, PIBDefaults)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                DEFAULTS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    primitiveDefaults = cfg;
    
    disp("The default values for the primitive paramters set");
    disp(" ");
    
    csvwrite("vlcHold", zeros(1,1));
    nextPrimitive = "MLMEResetRequest";
    previousPrimitive = "";
    loopVariable = true;
    csvwrite("vlcProcess", zeros(1,20));    %any random size of file as all we have to do is to check for all ones 
    macAckWaitDuration = 0;
    dataPayload = payload;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Main Loop Execution                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    while loopVariable

     timer = clock;
     timer = round(timer(6));
     flag = mod(timer ,2);
     if flag == 0
         fclose("all");
         continue
     else
        for i=1:300000000
            %Timer Loop
        end
 
        
        if strcmp(previousPrimitive, "MLMEDissociationConfirm")
            loopVariable = false;
            MLMEDissociationConfirm(primitiveDefaults);
            disp("Device dissociated. . .");
            disp("Communication terminated.")     
        
        else
            binFileH = fopen("vlcHold.csv");
            holdIndicator = fread(binFileH);
            
            if isempty(holdIndicator)
                continue
            end
            
            holdVariable = holdIndicator(1);
            fclose(binFileH); 
            
            if holdVariable == 1
                macAckWaitDuration = macAckWaitDuration + 1;
                disp("Wait time = ");
                disp(macAckWaitDuration);
                
                if macAckWaitDuration == 20
                    binFileH = fopen("vlcHold.csv", 'w');
                    fwrite(binFileH, ones(1,1));
                    fclose(binFileH);
                    nextPrimitive = previousPrimitive;
                    disp("Wait time exceeded macAckWaitDuration.");
                    disp(" ");
                    disp("RETRANSMITTING THE PREVIOUS FRAME. . .");
                    disp("Retransmitted after " + num2str(macAckWaitDuration) + " compiler clocks");
                    disp(" ");
                    macAckWaitDuration = 0;
                else
                    continue
                end
            
            else
                macAckWaitDuration = 0;
                binFileF = fopen("vlcProcess.csv");
                Frame = fread(binFileF);
                fclose(binFileF);
                
                if isempty(Frame)
                    frameType = "";
                    frameCommand = "";
                    [nextPrimitive, previousPrimitive] = vlcMessageDeviceSequencer(primitiveDefaults, nextPrimitive, frameType, frameCommand, dataPayload, vlcConfig, PIBDefaults);
                
                else
                    if all(Frame)
                        frameType = "";
                        frameCommand = "";
                        [nextPrimitive, previousPrimitive] = vlcMessageDeviceSequencer(primitiveDefaults, nextPrimitive, frameType, frameCommand, dataPayload, vlcConfig, PIBDefaults);
                    
                    else
                        vlcFrame = vlcMACFrameDecoder(Frame);
                        disp("Recieved frame after decoding :");
                        disp(vlcFrame);
                        frameType = vlcFrame.FrameType;
                        frameCommand = vlcFrame.MACCommand;
                        [nextPrimitive, previousPrimitive] = vlcMessageDeviceSequencer(primitiveDefaults, nextPrimitive, frameType, frameCommand, dataPayload, vlcConfig, PIBDefaults);
                    end
                end
            end
        end    
     end
    end
end

function [nextPrimitive, previousPrimitive] = vlcMessageDeviceSequencer(primitiveDefauts, nextPrimitive, frameType, frameCommand, dataPayload, vlcConfig, PIBDefaults)
    
    previousPrimitive = nextPrimitive;

    if strcmp(nextPrimitive, "MLMEResetRequest") &&  strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEResetRequest(primitiveDefauts, PIBDefaults);
        nextPrimitive = "MLMEResetConfirm";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, zeros(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
                
    elseif strcmp(nextPrimitive, "MLMEResetConfirm") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEResetConfirm(primitiveDefauts);
        nextPrimitive = "MLMEScanRequest";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, zeros(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
               
    elseif strcmp(nextPrimitive, "MLMEScanRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEScanRequest(primitiveDefauts);
        nextPrimitive = "MLMEBeaconNotify";
        disp("Sending MAC Command frame with command Beacon Request from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        commandConfig = vlcConfig;
        commandConfig.FrameType = 'MAC command';
        commandConfig.MACCommand = 'Beacon request';
        disp(commandConfig);
        writeFrame = vlcMACFrameGenerator(commandConfig);
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, writeFrame);
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEBeaconNotify") && strcmp(frameType, "Beacon") && strcmp(frameCommand, "")
        disp("Recieved Beacon frame from Coordinator MAC Layer.");
        disp(" ");
        MLMEBeaconNotify(primitiveDefauts);
        nextPrimitive = "MLMEScanConfirm";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, zeros(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEScanConfirm") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEScanConfirm(primitiveDefauts);
        nextPrimitive = "MLMEAssociateRequest";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, zeros(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEAssociateRequest(primitiveDefauts);
        disp("Sending MAC Command frame with command Association request from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        commandConfig = vlcConfig;
        commandConfig.FrameType = 'MAC command';
        commandConfig.MACCommand = 'Association request';
        disp(commandConfig);
        writeFrame = vlcMACFrameGenerator(commandConfig);
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, writeFrame);
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateRequest") && strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Coordinator MAC Layer");
        disp(" ");
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateRequest") && strcmp(frameType, "MAC command") && strcmp(frameCommand, "Association response")
        disp("Recieved MAC Command frame with command Association response from Coordinator MAC Layer.");
        disp(" ");
        nextPrimitive = "MLMEAssociateConfirm";
        disp("Sending Acknowledgment frame from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        ackConfig = vlcConfig;
        ackConfig.FrameType='Acknowledgment';
        disp(ackConfig);
        writeFrame = vlcMACFrameGenerator(ackConfig);
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, writeFrame);
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateConfirm") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEAssociateConfirm(primitiveDefauts);
        nextPrimitive = "MLMEPollRequest";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEPollRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEPollRequest(primitiveDefauts);
        disp("Sending MAC Command frame with command Data request from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        commandConfig = vlcConfig;
        commandConfig.FrameType = 'MAC command';
        commandConfig.MACCommand = 'Data request';
        disp(commandConfig);
        writeFrame = vlcMACFrameGenerator(commandConfig);
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, writeFrame);
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEPollRequest") && strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Coordinator MAC Layer.");
        disp(" ");
        nextPrimitive = "MLMEPollConfirm";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, zeros(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEPollConfirm") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEPollConfirm(primitiveDefauts);
        nextPrimitive = "MCPSDataRequest";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, zeros(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);

    elseif strcmp(nextPrimitive, "MCPSDataRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")  && ~strcmp(dataPayload, "")
        MCPSDataRequest(primitiveDefauts, dataPayload);
        disp("Sending Data frame from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        dataConfig = vlcConfig;
        dataConfig.FrameType='Data';
        disp(dataConfig);
        writeFrame = vlcMACFrameGenerator(dataConfig, dataPayload);
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, writeFrame);
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MCPSDataRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")  && strcmp(dataPayload, "")
        disp("Data Payload not found.");
        disp("DIssociating device. . .");
        disp(" ");
        nextPrimitive = "DissociationRequest";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, zeros(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MCPSDataRequest") && strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Coordinator MAC Layer.");
        disp(" ");
        nextPrimitive = "MCPSDataConfirm";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MCPSDataConfirm") && strcmp(frameType, "") && strcmp(frameType, "")
        MCPSDataConfirm(primitiveDefauts);
        nextPrimitive = "MLMEDissociationRequest";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, zeros(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEDissociationRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEDissociationRequest(primitiveDefauts);
        disp("Sending MAC Command frame with command Dissociation notification from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        commandConfig = vlcConfig;
        commandConfig.FrameType = 'MAC command';
        commandConfig.MACCommand = 'Disassociation notification';
        disp(commandConfig);
        writeFrame = vlcMACFrameGenerator(commandConfig);
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, writeFrame);
        fclose(binFileF);
        
    elseif strcmp(nextPrimitive, "MLMEDissociationRequest") && strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Coordinator MAC Layer.");
        disp(" ");
        nextPrimitive = "MLMEDissociationConfirm";
        binFileH = fopen("vlcHold.csv", 'w');
        fwrite(binFileH, ones(1,1));
        fclose(binFileH);
        binFileF = fopen("vlcProcess.csv", 'w');
        fwrite(binFileF, ones(1,20));
        fclose(binFileF);
        
    end
end

function MLMEResetRequest (primitiveDefaults, PIBDefaults)
    disp("Sending MLMEResetRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("setDefaultPIB : " + primitiveDefaults.setDefaultPIB);
    disp(" ");
    vlcPIBattributesDefault = PIBDefaults;
    disp("The default values for PIB attributes are :");
    disp(" ");
    disp(vlcPIBattributesDefault);
end

function MLMEResetConfirm (primitiveDefaults)
    disp("Sending MLMEResetConfirm primitive from device MAC Layer to device Higher Layer. . .");
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end

function MLMEScanRequest (primitiveDefaults)
    disp("Sending MLMEScanRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("ScanType : " + primitiveDefaults.ScanType);
    disp("By default ACTIVE scanning is performed. . .");
    disp(" ");
end

function MLMEBeaconNotify (primitiveDefaults)
    disp("Sending MLMEBeaconNotify primitive from device MAC Layer to device Higher Layer. . .");
%     disp("VPANDescriptor : " + primitiveDefaults.VPANDescriptor)%(1) + primitiveDefaults.VPANDescriptor(2) + primitiveDefaults.VPANDescriptor(3));
    disp("BSN :");
    disp(primitiveDefaults.BSN);
    disp(" ");
end

function MLMEScanConfirm (primitiveDefaults)
    disp("Sending MLMEScanConfirm primitive from device MAC Layer to device Higher Layer. . .");
    disp("status : " + primitiveDefaults.status);
    disp("ScanType : " + primitiveDefaults.ScanType);
    disp(" ");
end

function MLMEAssociateRequest (primitiveDefaults)
    disp("Sending MLMEAssociateRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("CoordAddrMode : " + primitiveDefaults.CoordAddrMode);
    disp("By default Short address used.");
    disp("CoordVPANID : " + primitiveDefaults.CoordVPANID);
    disp("CoordAddress : " + primitiveDefaults.CoordAddress);
    disp(" ");
end

function MLMEAssociateConfirm (primitiveDefaults)
    disp("Sending MLMEAssociateConfirm primitive from device MAC Layer to device Higher Layer. . .");
    disp("AssocShortAddr : " + primitiveDefaults.AssocShortAddr);
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end

function MLMEPollRequest (primitiveDefaults)
    disp("Sending MLMEPollRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("CoordAddrMode : " + primitiveDefaults.CoordAddrMode);
    disp("By default Short address used.");
    disp("CoordVPANID : " + primitiveDefaults.CoordVPANID);
    disp("CoordAddress : " + primitiveDefaults.CoordAddress);
    disp(" ");
end

function MLMEPollConfirm (primitiveDefaults)
    disp("Sending MLMEPollConfirm primitive from device MAC to device Higher Layer. . .");
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end

function MCPSDataRequest (primitiveDefaults, dataPayload)
    disp("Sending MCPSDataRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("SouceAddrMode : " + primitiveDefaults.SouceAddrMode);
    disp("MSDU : " + dataPayload);
    disp("DestinationAddrMode : " + primitiveDefaults.DestinationAddrMode);
    disp("By default Extended address used.");
    disp("DestVPANID : " + primitiveDefaults.VPANID);
    disp("DestinationAddr : " + primitiveDefaults.DestinationAddr);
    disp("MSDU Length : " + strlength(dataPayload));
    disp(" ");
end

function MCPSDataConfirm (primitiveDefaults)
    disp("Sending MCPSDataConfirm primitive from device MAC Layer to device Higher Layer. . .");
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end

function MLMEDissociationRequest (primitiveDefaults)
    disp("Sending MLMEDissociationRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("DeviceAddrMode : " + primitiveDefaults.DeviceAddrMode);
    disp("DeviceVPANID : " + primitiveDefaults.DeviceVPANID);
    disp("DeviceAddress : " + primitiveDefaults.DeviceAddress);
    disp("Dissociation Reason : " + primitiveDefaults.DissociationReason);
    disp(" ");
end

function MLMEDissociationConfirm (primitiveDefaults)
    disp("Sending MLMEDissociationConfirm primitive from MAC Layer to device Higher Layer. . .");
    disp("DeviceAddrMode : " + primitiveDefaults.DeviceAddrMode);
    disp("DeviceVPANID : " + primitiveDefaults.DeviceVPANID);
    disp("DeviceAddress : " + primitiveDefaults.DeviceAddress);
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end