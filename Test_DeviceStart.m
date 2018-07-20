
FileID = fopen("vlcHold.csv", 'w');
fwrite(FileID, zeros(1,1));
fclose(FileID);

FileID = fopen("vlcProcess.csv", 'w');
fwrite(FileID, ones(1,20));
fclose(FileID);

DeviceConfiguration = vlcConfig;
DefaultPrimitiveConfiguration = vlcPrimitiveParameterConfig;
DefaultPIBattributes=vlcMACPIBattributes;
DataPayload = "1111";
vlcDevicestart(DefaultPrimitiveConfiguration, DataPayload, DeviceConfiguration, DefaultPIBattributes)