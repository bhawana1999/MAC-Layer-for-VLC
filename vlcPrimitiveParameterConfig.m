classdef vlcPrimitiveParameterConfig
    
    properties
        
        setDefaultPIB = true;
        status = 'SUCCESS';
        BSN = zeros(0,8);
        CoordAddrMode = '02';
        CoordVPANID = '0000';
        CoordAddress = '0000';
        DeviceAddress = '0000000000000000';
        DeviceAddrMode = '02';
        DeviceVPANID = '0000';
        DissociateReason = '02';
        AssocShortAddr = '0000';
        DSN = zeros(0,8);
        ScanType = '00';
        ScanDuration = 15;
        SouceAddrMode = '00';
        SourceAddr = 'f0f0f0f0f0f0f0f0';
        DestinationAddrMode = '00';
        DestinationAddr = 'f0f0f0f0f0f0f0f1';
        VPANID = '0000';
        SuperFrameOrder = 7;
        BeaconOrder = 7;
        VPANCoordinator = true;
        CoordinatorRealignment = false;
        StartTime = '000000';
        DissociationReason = '00';
        
        
        %         VPANDescriptor = CoordAddrMode+CoordVPANID+CoordAddress;
        %         VPANDescriptorList = ;
        
    end

    methods
        
     function obj = vlcPrimitiveParameterConfig(varargin)
      for i = 1:2:nargin
          obj.(varargin{i}) = varargin{i+1};
      end
     end
    
     function obj = set.setDefaultPIB(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'AllocateAddress');
      obj.setDefaultPIB = value;
     end
     
     function obj = set.VPANCoordinator(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'VPANCoordinator');
      obj.VPANCoordinator = value;
     end
     
     function obj = set.CoordinatorRealignment(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'CoordinatorRealignment');
      obj.CoordinatorRealignment = value;
     end
     
     function obj = set.status(obj, value)
      obj.status = validatestring(value, 'SUCCESS', '', 'status');
     end
     
     function obj = set.CoordAddrMode(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'CoordAddrMode');
     end
     
     function obj = set.CoordVPANID(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'CoordVPANID');
     end
     
     function obj = set.CoordAddress(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'CoordAddress');
     end
     
     function obj = set.DeviceAddress(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 16}, '', 'DeviceAddress');
     end
     
     function obj = set.DeviceAddrMode(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'DeviceAddrMode');
     end
     
     function obj = set.DeviceVPANID(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'DeviceVPANID');
     end
     
     function obj = set.DissociateReason(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'DissociateReason');
     end
     
     function obj = set.AssocShortAddr(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'AssocShortAddr');
     end
     
     function obj = set.ScanType(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'ScanType');
     end
     
     function obj = set.SouceAddrMode(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'SouceAddrMode');
     end
     
     function obj = set.SourceAddr(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 16}, '', 'SourceAddr');
     end
     
     function obj = set.DestinationAddrMode(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'DestinationAddrMode');
     end
     
     function obj = set.DestinationAddr(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 16}, '', 'DestinationAddr');
     end
     
     function obj = set.VPANID(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'VPANID');
     end
     
     function obj = set.StartTime(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 6}, '', 'StartTime');
     end
     
     function obj = set.ScanDuration(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'real'}, '', 'ScanDuration');
     end
     
     function obj = set.SuperFrameOrder(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'real'}, '', 'SuperFrameOrder');
     end
     
     function obj = set.BeaconOrder(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'real'}, '', 'BeaconOrder');
     end

%      function obj = set.VPANDescriptor(obj, value)
%       obj.VPANDescriptor = validatestring(value, '', '', 'VPANDescriptor');
%      end
%      
%      function obj = set.primitiveName(obj, value)
%       obj.primitiveName = validatestring(value, obj.primitiveNameValues, '', 'primitiveName');
%      end
         
    end
end