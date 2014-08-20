-- Chopped Straw
-- Spec for chopped straw left on field
-- by webalizer, www.planet-ls.de

	FruitUtil.registerFruitType("choppedStraw", g_i18n:getText("choppedStraw"), false, false, true, 1, 100, 2, 1, 1, nil);
	FruitUtil.registerFruitTypePreparing(FruitUtil.FRUITTYPE_CHOPPEDSTRAW,"choppedStraw_haulm", 8, 8, 9);

	FruitUtil.registerFruitType("choppedMaize", g_i18n:getText("choppedMaize"), false, false, true, 1, 100, 2, 1, 1, nil);
	FruitUtil.registerFruitTypePreparing(FruitUtil.FRUITTYPE_CHOPPEDMAIZE,"choppedMaize_haulm", 8, 8, 9);

	FruitUtil.registerFruitType("choppedRape", g_i18n:getText("choppedRape"), false, false, true, 1, 100, 2, 1, 1, nil);
	FruitUtil.registerFruitTypePreparing(FruitUtil.FRUITTYPE_CHOPPEDRAPE,"choppedRape_haulm", 8, 8, 9);

	if g_i18n.globalI18N.texts.choppedStraw == nil then
		g_i18n.globalI18N.texts.choppedStraw = g_i18n:getText("choppedStraw");
	end;

	if g_i18n.globalI18N.texts.choppedMaize == nil then
		g_i18n.globalI18N.texts.choppedMaize = g_i18n:getText("choppedMaize");
	end;

	if g_i18n.globalI18N.texts.choppedRape == nil then
		g_i18n.globalI18N.texts.choppedRape = g_i18n:getText("choppedRape");
	end;
	print("*** ChoppedStraw fruittypes registered!");
