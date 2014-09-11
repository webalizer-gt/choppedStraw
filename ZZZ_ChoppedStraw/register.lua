-- Chopped Straw
-- Spec for chopped straw left on field
-- by webalizer, www.planet-ls.de

SpecializationUtil.registerSpecialization('ChoppedStraw', 'ChoppedStraw', g_currentModDirectory .. 'ChoppedStraw.lua');
local choppedStrawSpec = SpecializationUtil.getSpecialization('ChoppedStraw');

ChoppedStraw_Register = {};
local modItem = ModsUtil.findModItemByModName(g_currentModName);
ChoppedStraw_Register.version = (modItem and modItem.version) and modItem.version or "?.?.?";

-- Register ChoppedStraw for callback from SoilMod's plugin facility
getfenv(0)["modSoilModPlugins"] = getfenv(0)["modSoilModPlugins"] or {}
table.insert(getfenv(0)["modSoilModPlugins"], ChoppedStraw_Register)
--
ChoppedStraw_Register.initialized = false
ChoppedStraw_Register.soilModPresent = false
-- Define implements
ChoppedStraw_Register.csTYPE_UNKNOWN    = 0
ChoppedStraw_Register.csTYPE_PLOUGH     = 2^0
ChoppedStraw_Register.csTYPE_CULTIVATOR = 2^1
ChoppedStraw_Register.csTYPE_SEEDER     = 2^2


function ChoppedStraw_Register.updateFoliage(sx,sz,wx,wz,hx,hz, isForced, implementType)
    -- Increase fertilizer(organic)...
    setDensityMaskParams(g_currentMission.fmcFoliageFertilizerOrganic, "greater", 0);
    -- ..where there's choppedStraw / choppedMaize / choppedRape, by 1.
    addDensityMaskedParallelogram(g_currentMission.fmcFoliageFertilizerOrganic, sx,sz,wx,wz,hx,hz, 0, 2, ChoppedStraw_Register.foliageChoppedStrawId, 0, 1, 1);
    addDensityMaskedParallelogram(g_currentMission.fmcFoliageFertilizerOrganic, sx,sz,wx,wz,hx,hz, 0, 2, ChoppedStraw_Register.foliageChoppedMaizeId, 0, 1, 1);
		addDensityMaskedParallelogram(g_currentMission.fmcFoliageFertilizerOrganic, sx,sz,wx,wz,hx,hz, 0, 2, ChoppedStraw_Register.foliageChoppedRapeId, 0, 1, 1);

    -- Decrease soil pH where there's choppedStraw / choppedMaize / choppedRape, by 1 - we're cultivating/plouging/seeding it into ground.
    setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "greater", 0)
    addDensityMaskedParallelogram(g_currentMission.fmcFoliageSoil_pH, sx,sz,wx,wz,hx,hz, 0, 3, ChoppedStraw_Register.foliageChoppedStrawId, 0, 1, -- mask
                        -1  -- decrease
                    );
		addDensityMaskedParallelogram(g_currentMission.fmcFoliageSoil_pH, sx,sz,wx,wz,hx,hz, 0, 3, ChoppedStraw_Register.foliageChoppedMaizeId, 0, 1, -- mask
												-1  -- decrease
										);
		addDensityMaskedParallelogram(g_currentMission.fmcFoliageSoil_pH, sx,sz,wx,wz,hx,hz, 0, 3, ChoppedStraw_Register.foliageChoppedRapeId, 0, 1, -- mask
												-1  -- decrease
										);
    setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "greater", -1)

		-- Remove the choppedStraw / choppedMaize / choppedRape we've just cultivated/ploughed/seeded into ground.
    setDensityParallelogram(ChoppedStraw_Register.foliageChoppedStrawId, sx,sz,wx,wz,hx,hz, 0, 1, 0)
    setDensityParallelogram(ChoppedStraw_Register.foliageChoppedMaizeId, sx,sz,wx,wz,hx,hz, 0, 1, 0)
    setDensityParallelogram(ChoppedStraw_Register.foliageChoppedRapeId,   sx,sz,wx,wz,hx,hz, 0, 1, 0)
end;

function ChoppedStraw_Register.soilModPluginCallback(soilMod)

	-- Mark that SoilMod has "called us"
	ChoppedStraw_Register.soilModPresent = true;

	-- Helper function, to extract the foliage-layer-id if available
	local function getFruitFoliageLayerId(fruitId)
		if g_currentMission.fruits[fruitId] ~= nil then
			if g_currentMission.fruits[fruitId].preparingOutputId ~= nil and g_currentMission.fruits[fruitId].preparingOutputId ~= 0 then
				return g_currentMission.fruits[fruitId].preparingOutputId;
			end;
		end;
		return nil;
	end;
	-- Helper function, to determine if foliageId is valid
	local function hasFoliageLayer(foliageId)
		return (foliageId ~= nil and foliageId ~= 0);
	end;

	-- Get the foliage-id values for choppedStraw, choppedMaize, choppedRape.
	if getFruitFoliageLayerId(FruitUtil.FRUITTYPE_CHOPPEDSTRAW) ~= nil then
		ChoppedStraw_Register.foliageChoppedStrawId = getFruitFoliageLayerId(FruitUtil.FRUITTYPE_CHOPPEDSTRAW);
	end;
	if getFruitFoliageLayerId(FruitUtil.FRUITTYPE_CHOPPEDMAIZE) ~= nil then
		ChoppedStraw_Register.foliageChoppedMaizeId = getFruitFoliageLayerId(FruitUtil.FRUITTYPE_CHOPPEDMAIZE);
	end;
	if getFruitFoliageLayerId(FruitUtil.FRUITTYPE_CHOPPEDRAPE) ~= nil then
		ChoppedStraw_Register.foliageChoppedRapeId = getFruitFoliageLayerId(FruitUtil.FRUITTYPE_CHOPPEDRAPE);
	end;

	-- Only add plugin for fruit-type, if fruit-type exists and has foliage-layer
  if hasFoliageLayer(ChoppedStraw_Register.foliageChoppedStrawId) and hasFoliageLayer(ChoppedStraw_Register.foliageChoppedMaizeId) and  hasFoliageLayer(ChoppedStraw_Register.foliageChoppedRapeId) then

		soilMod.addPlugin_UpdateSowingArea_before(
		"Process chopped straw",
		31,
    function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
      if dataStore.useDirectPlanting then
    	   ChoppedStraw_Register.updateFoliage(sx,sz,wx,wz,hx,hz, dataStore.forced, ChoppedStraw_Register.csTYPE_SEEDER)
      end
    end
		)

		soilMod.addPlugin_UpdateCultivatorArea_before(
		"Process chopped straw",
		31,
		function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
			ChoppedStraw_Register.updateFoliage(sx,sz,wx,wz,hx,hz, dataStore.forced, ChoppedStraw_Register.csTYPE_CULTIVATOR)
		end
		)

		soilMod.addPlugin_UpdatePloughArea_before(
		"Process chopped straw",
		31,
		function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
			ChoppedStraw_Register.updateFoliage(sx,sz,wx,wz,hx,hz, dataStore.forced, ChoppedStraw_Register.csTYPE_PLOUGH)
		end
		)

	end;
  return true;
end;

function ChoppedStraw_Register:loadMap(name)
	if self.specAdded then return; end;

	print('*** ChoppedStraw v'..ChoppedStraw_Register.version..' specialization loading ***');

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

function ChoppedStraw_Register:update(dt)
  if not ChoppedStraw_Register.initialized then
    ChoppedStraw_Register.initialized = true -- Only initialize ONCE.

    -- If SoilMod did not "call us", then do it "the old way"...
    if not ChoppedStraw_Register.soilModPresent then
		ChoppedStraw_Register.old_UpdateDestroyCommonArea = Utils.updateDestroyCommonArea;
		Utils.updateDestroyCommonArea = ChoppedStraw_Register.updateDestroyCommonArea;

		ChoppedStraw_Register.old_updateSowingArea = Utils.updateSowingArea;
		Utils.updateSowingArea = ChoppedStraw_Register.updateSowingArea;
    end;
  end;
end;

function ChoppedStraw_Register.updateDestroyCommonArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ)
	ChoppedStraw_Register.old_UpdateDestroyCommonArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
	if g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDSTRAW] then
		Utils.updateDensity(g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDSTRAW].preparingOutputId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, 0, 0);
	end;
	if g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDMAIZE] then
		Utils.updateDensity(g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDMAIZE].preparingOutputId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, 0, 0);
	end;
	if g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDRAPE] then
	Utils.updateDensity(g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDRAPE].preparingOutputId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, 0, 0);
	end;
end;

function ChoppedStraw_Register.updateSowingArea(fruitId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, angle, useDirectPlanting)
	local numPixels, numDetailPixels = ChoppedStraw_Register.old_updateSowingArea(fruitId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, angle, useDirectPlanting);
	if g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDSTRAW] then
		Utils.updateDensity(g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDSTRAW].preparingOutputId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, 0, 0);
	end;
	if g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDMAIZE] then
		Utils.updateDensity(g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDMAIZE].preparingOutputId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, 0, 0);
	end;
	if g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDRAPE] then
		Utils.updateDensity(g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDRAPE].preparingOutputId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, 0, 0);
	end;

	return numPixels, numDetailPixels;
end;

Utils.updateStrawHaulmArea = function(preparingOutputId, x, z, x1, z1, x2, z2)
	local IDs,detailId = {},g_currentMission.terrainDetailId;
	table.insert(IDs,g_currentMission.cultivatorChannel);
	table.insert(IDs,g_currentMission.sowingChannel);
	table.insert(IDs,g_currentMission.ploughChannel);
	local dx, dz, dwidthX, dwidthZ, dheightX, dheightZ = Utils.getXZWidthAndHeight(detailId, x, z, x1, z1, x2, z2)
	for i = 1, table.getn(IDs) do
		setDensityMaskedParallelogram(preparingOutputId, dx, dz, dwidthX, dwidthZ, dheightX, dheightZ, 0, 1, detailId, IDs[i], 1, 1)
	end
end;

function ChoppedStraw_Register:deleteMap() end;
function ChoppedStraw_Register:keyEvent(unicode, sym, modifier, isDown) end;
function ChoppedStraw_Register:mouseEvent(posX, posY, isDown, isUp, button) end;
function ChoppedStraw_Register:draw() end;

addModEventListener(ChoppedStraw_Register);
