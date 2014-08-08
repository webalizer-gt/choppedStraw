-- Chopped Straw
-- Spec for chopped straw left on field
-- V1.1.03
-- 06.08.14

ChoppedStraw = {};

function ChoppedStraw.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(ChoppedStraw, specializations);
end;

function ChoppedStraw:load(xmlFile)
	self.getAreas = SpecializationUtil.callSpecializationsFunction("self.getAreas");
	self.wwMinMaxAreas = SpecializationUtil.callSpecializationsFunction("self.wwMinMaxAreas");
	self.createCStrawArea = SpecializationUtil.callSpecializationsFunction("self.createCStrawArea");
	self.setCStrawArea = SpecializationUtil.callSpecializationsFunction("self.setCStrawArea");
	
	self.getAreas = ChoppedStraw.getAreas;
	self.wwMinMaxAreas = ChoppedStraw.wwMinMaxAreas;
	self.createCStrawArea = ChoppedStraw.createCStrawArea;
	self.setCStrawArea = ChoppedStraw.setCStrawArea;
	
	-- Area creation
	self.strawZOffset = -1;
	self.strawNodeId = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.strawAreas.strawArea1#startIndex"));
	
	if self.strawNodeId ~= nil then
		self.cStrawAreas = {}
		self.cStrawAreas = self:createCStrawArea();
	end;
end;

function ChoppedStraw:delete()
end;

function ChoppedStraw:readStream(streamId, connection)

end;

function ChoppedStraw:writeStream(streamId, connection)

end;

function ChoppedStraw:mouseEvent(posX, posY, isDown, isUp, button)

end;

function ChoppedStraw:keyEvent(unicode, sym, modifier, isDown)
end;

function ChoppedStraw:onLeave()

end

function ChoppedStraw:update(dt)

end;

function ChoppedStraw:updateTick(dt)
	if self.strawNodeId ~= nil then
		if not self.isStrawActive then --or not fruitDesc.hasWindrow then
			if self.combineIsFilling then
				local preparingOutputId = nil;
				
				if g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDSTRAW] and g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDRAPE] and g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDMAIZE] then
					local fruitDesc = FruitUtil.fruitIndexToDesc[self.lastValidInputFruitType];
					--print(tostring(fruitDesc.name));

					if fruitDesc.name == "maize" then
						preparingOutputId = g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDMAIZE].preparingOutputId;
						for nIndex,oImplement in pairs(self.attachedImplements) do --parse all implements
							if oImplement ~= nil and oImplement.object ~= nil then
								for i = 1, table.getn(oImplement.object.cuttingAreas) do
									x, y, z = getWorldTranslation(oImplement.object.cuttingAreas[i].start)
									x1, y1, z1 = getWorldTranslation(oImplement.object.cuttingAreas[i].width)
									x2, y2, z2 = getWorldTranslation(oImplement.object.cuttingAreas[i].height)
									Utils.updateStrawHaulmArea(preparingOutputId, x, z, x1, z1, x2, z2)
								end;
							end;
						end;
					elseif fruitDesc.name == "rape" then
						if self.chopperPSenabled then
							preparingOutputId = g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDRAPE].preparingOutputId;
							for i = 1, table.getn(self.cStrawAreas) do
								local x, y, z = getWorldTranslation(self.cStrawAreas[i].start)
								local x1, y1, z1 = getWorldTranslation(self.cStrawAreas[i].width)
								local x2, y2, z2 = getWorldTranslation(self.cStrawAreas[i].height)
								Utils.updateStrawHaulmArea(preparingOutputId, x, z, x1, z1, x2, z2)
							end;
						end;
					else
						if self.chopperPSenabled then
							preparingOutputId = g_currentMission.fruits[FruitUtil.FRUITTYPE_CHOPPEDSTRAW].preparingOutputId;
							for i = 1, table.getn(self.cStrawAreas) do
								local x, y, z = getWorldTranslation(self.cStrawAreas[i].start)
								local x1, y1, z1 = getWorldTranslation(self.cStrawAreas[i].width)
								local x2, y2, z2 = getWorldTranslation(self.cStrawAreas[i].height)
								Utils.updateStrawHaulmArea(preparingOutputId, x, z, x1, z1, x2, z2)
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;


function ChoppedStraw:draw()

end;

function ChoppedStraw:attachImplement(implement)
	if self.strawNodeId ~= nil then
		self.caxMin, self.caxMax, self.cay, self.caz, self.caWW, self.caCenter = self:getAreas();
		self:setCStrawArea(self.caxMin, self.caxMax);
	end;
end;

function ChoppedStraw:getAreas()
	local wwMin = 0;
	local wwMax = 0;
	local wwY = 0;
	local wwZ = 0;
	for nIndex,oImplement in pairs(self.attachedImplements) do --parse all implements
		if oImplement ~= nil and oImplement.object ~= nil then
			wwMin,wwMax,wwY,wwZ = self:wwMinMaxAreas(self,oImplement.object.cuttingAreas);
		end;
	end;
	
	local workWidth = math.abs(wwMax-wwMin);
	local wwCenter = 0;
	if workWidth > .1 then
		wwCenter = (wwMin+wwMax)/2;
		if math.abs(wwCenter) < 0.1 then
			wwCenter = 0;
		end;
	end;
	return wwMin,wwMax,wwY,wwZ,workWidth,wwCenter;
end;

function ChoppedStraw:wwMinMaxAreas(self,areas)
	local minA = 0;
	local maxA = 0;
	if areas ~= nil then
		for _,cuttingArea in pairs(areas) do

				local x1,y1,z1 = getWorldTranslation(cuttingArea.start)
				local x2,y2,z2 = getWorldTranslation(cuttingArea.width)
				local x3,y3,z3 = getWorldTranslation(cuttingArea.height)
				local lx1,ly1,lz1 = worldToLocal(self.rootNode,x1,y1,z1)
				local lx2,ly2,lz2 = worldToLocal(self.rootNode,x2,y2,z2)
				local lx3,ly3,lz3 = worldToLocal(self.rootNode,x3,y3,z3)

				if lx1 < minA then
					minA = lx1;
				end;
				if lx1 > maxA then
					maxA = lx1;
				end;
				if lx2 < minA then
					minA = lx2;
				end;
				if lx2 > maxA then
					maxA = lx2;
				end;
				if lx3 < minA then
					minA = lx3;
				end;
				if lx3 > maxA then
					maxA = lx3;
				end;
		end;
	end;
	return minA, maxA, ly1, lz1;
end;

function ChoppedStraw:createCStrawArea()
	for _,strawArea in pairs(self.strawAreas) do
		local x1,y1,z1 = getWorldTranslation(strawArea.start);
		local lx1,ly1,lz1 = worldToLocal(self.rootNode,x1,y1,z1);
		local x2,y2,z2 = getWorldTranslation(strawArea.width);
		local lx2,ly2,lz2 = worldToLocal(self.rootNode,x2,y2,z2);
		self.strawXOffset = math.abs(lx2 + lx1)/2;
	end;
	
	local cStrawAreas = {};

	local startId1 = createTransformGroup("start1");
	link(self.strawNodeId, startId1);
	local heightId1 = createTransformGroup("height1");
	link(self.strawNodeId, heightId1);
	local widthId1 = createTransformGroup("width1");
	link(self.strawNodeId, widthId1);
	table.insert(cStrawAreas, {foldMinLimit=0,start=startId1,height=heightId1,foldMaxLimit=0.2,width=widthId1});

	local startId2 = createTransformGroup("start2");
	link(self.strawNodeId, startId2);
	local heightId2 = createTransformGroup("height2");
	link(self.strawNodeId, heightId2);
	local widthId2 = createTransformGroup("width2");
	link(self.strawNodeId, widthId2);
	table.insert(cStrawAreas, {foldMinLimit=0,start=startId2,height=heightId2,foldMaxLimit=0.2,width=widthId2});
	return cStrawAreas;
	
end;

function ChoppedStraw:setCStrawArea(caxMin, caxMax)
	local xMin = caxMin + self.strawXOffset;
	local xMax = caxMax + self.strawXOffset;
	local center = self.caCenter + self.strawXOffset;
	local y = self.cay;
	
	setTranslation(self.cStrawAreas[1].start,xMax,y,self.strawZOffset-2);
	setTranslation(self.cStrawAreas[1].height,xMax,y,self.strawZOffset-2.5);
	setTranslation(self.cStrawAreas[1].width,center,y,self.strawZOffset);

	setTranslation(self.cStrawAreas[2].start,center,y,self.strawZOffset);
	setTranslation(self.cStrawAreas[2].height,center,y,self.strawZOffset-0.5);
	setTranslation(self.cStrawAreas[2].width,xMin,y,self.strawZOffset-2);
end;