-- Chopped Straw
-- Spec for chopped straw left on field
-- V1.1.03
-- 06.08.14

SpecializationUtil.registerSpecialization('ChoppedStraw', 'ChoppedStraw', g_currentModDirectory .. 'ChoppedStraw.lua');
local choppedStrawSpec = SpecializationUtil.getSpecialization('ChoppedStraw');
 
 
ChoppedStraw_Register = {};
 
function ChoppedStraw_Register:loadMap(name)
	if self.specAdded then return; end;
 
	print('*** ChoppedStraw v1.1.03 specialization loading ***');
 
	local titaniumChopperSwitcherSpec;
	if pdlc_titaniumAddon and pdlc_titaniumAddon.ChopperSwitcher then
		titaniumChopperSwitcherSpec = pdlc_titaniumAddon.ChopperSwitcher;
	end;
	-- print(('titaniumChopperSwitcherSpec=%s'):format(tostring(titaniumChopperSwitcherSpec)));
 
	local addedTo = {};
 
	for k, v in pairs(VehicleTypeUtil.vehicleTypes) do
		if v ~= nil then
			-- has Combine spec -> continue
			local allowInsertion = SpecializationUtil.hasSpecialization(Combine, v.specializations);
 
			local customEnvironment;
			if allowInsertion then
				-- print(('\tvehicleType %q has Combine spec'):format(v.name));
				if v.name:find('.') then
					customEnvironment = Utils.splitString('.', v.name)[1];
					-- print(('\t\tcustomEnvironment=%q'):format(customEnvironment));
				end;
 
				if customEnvironment then
					-- has ChoppedStraw spec -> abort
					if rawget(SpecializationUtil.specializations, customEnvironment .. '.ChoppedStraw') ~= nil or rawget(SpecializationUtil.specializations, customEnvironment .. '.choppedStraw') ~= nil then
						-- print(('\t\talready has spec "ChoppedStraw" -> allowInsertion = false'));
						allowInsertion = false;
					end;
				end;
			end;
 
			if allowInsertion then
				local hasChopperSwitcherSpec = false;
 
				-- has ChopperSwitcher or strawSpec or strawChopper spec [mod] -> continue
				if customEnvironment then
					hasChopperSwitcherSpec = rawget(SpecializationUtil.specializations, customEnvironment .. '.ChopperSwitcher') ~= nil or rawget(SpecializationUtil.specializations, customEnvironment .. '.chopperSwitcher') ~= nil or rawget(SpecializationUtil.specializations, customEnvironment .. '.strawSpec') ~= nil or rawget(SpecializationUtil.specializations, customEnvironment .. '.strawChopper') ~= nil;
					-- print(('\t\thasChopperSwitcherSpec [mod]=%s'):format(tostring(hasChopperSwitcherSpec)));
				end;
 
				-- has ChopperSwitcher spec [Titanium] -> continue
				if not hasChopperSwitcherSpec and titaniumChopperSwitcherSpec ~= nil then
					hasChopperSwitcherSpec = SpecializationUtil.hasSpecialization(titaniumChopperSwitcherSpec, v.specializations);
					-- print(('\t\thasChopperSwitcherSpec [Titanium]=%s'):format(tostring(hasChopperSwitcherSpec)));
				end;
 
				if not hasChopperSwitcherSpec then
					allowInsertion = false;
				end;
				-- print(('\t\thasChopperSwitcherSpec=%s -> allowInsertion=%s'):format(tostring(hasChopperSwitcherSpec), tostring(allowInsertion)));
			end;
 
			if allowInsertion then
				-- print(('\tChoppedStraw spec added to %q'):format(v.name));
				table.insert(v.specializations, choppedStrawSpec);
				addedTo[#addedTo + 1] = v.name;
			end;
		end;
	end;
 
	if #addedTo > 0 then
		print('*** ChoppedStraw added to:\n\t\t' .. table.concat(addedTo, '\n\t\t'));
	end;
 
	self.specAdded = true;
end;
 
function ChoppedStraw_Register:deleteMap() end;
function ChoppedStraw_Register:keyEvent(unicode, sym, modifier, isDown) end;
function ChoppedStraw_Register:mouseEvent(posX, posY, isDown, isUp, button) end;
function ChoppedStraw_Register:update(dt) end;
function ChoppedStraw_Register:draw() end;
 
addModEventListener(ChoppedStraw_Register);