-- Chopped Straw
-- Spec for chopped straw left on field
-- V1.1.03
-- 06.08.14

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

local old_UpdateDestroyCommonArea = Utils.updateDestroyCommonArea;
Utils.updateDestroyCommonArea = function(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ)
	old_UpdateDestroyCommonArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
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

local old_updateSowingArea = Utils.updateSowingArea;
Utils.updateSowingArea = function(fruitId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, angle, useDirectPlanting)
	local numPixels, numDetailPixels = old_updateSowingArea(fruitId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, angle, useDirectPlanting);
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