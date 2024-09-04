-- Eyeless Fusion
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff({
		handler=c, 
		matfilter=s.matfilter, 
		extrafil=s.extrafil, 
		extraop=s.extraop, 
		extratg=s.extratg, 
		stage2=s.stage2,
		sumpos=POS_FACEDOWN_DEFENSE
	})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end

-- e1 functions

function s.matfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsCanTurnSet()
end

function s.checkmat(tp,sg,fc)
	return fc:IsSetCard(556) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE|LOCATION_HAND)
end

function s.extrafil(e,tp,mg)
	local g1 = Duel.GetMatchingGroup(s.sffilter, tp, 0, LOCATION_MZONE, nil)
	local g2 = Duel.GetMatchingGroup(s.shgfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, nil, e, tp)
	return g1:Merge(g2),s.checkmat
end

function s.sffilter(c)
	return c:IsCanTurnSet()
end

function s.shgfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end

function s.extraop(e,tc,tp,sg)
	local tfg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE|LOCATION_HAND)
	if #tfg>0 then
		Duel.SpecialSummon(tfg, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,tfg)
		sg:Sub(tfg)
	end
	Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
	sg:Clear()
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		Duel.ConfirmCards(1-tp,tc)
	end
end
     