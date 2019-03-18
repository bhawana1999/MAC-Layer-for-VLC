function IPPacket = MACunwrap(macFrame)
    HeaderPlusPayload = macFrame(1:end-16);
    CRC_Tx = macFrame(end-15:end);
    CRC_Object = comm.CRCGenerator('z^16 + z^15 + z^2 + 1');
    macFrame_Rx = CRC_Object(HeaderPlusPayload');
    macFrame_Rx = macFrame_Rx'; 
    CRC_Rx = macFrame_Rx(end-15:end);
    if CRC_Rx==CRC_Tx
        disp('Frame Valid');
        IPPacket=HeaderPlusPayload(97:end);
    else
        disp('ERROR!! Invalid Frame !!!')
        return;
    end
    