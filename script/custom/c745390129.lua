-- Soul Spirit Manifestation
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
    e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- e1 functions

function s.rsummonfilter(c,tp,pmg,e)
	return c:IsSetCard(555) and c:IsRitualMonster() and 
	pmg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99) and 
	c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, true)
end

function s.matfilter(c)
	return c:IsSetCard(554) and c:IsAbleToHand()
end

function s.dsummonfilter(c,e,tp)
	return c:IsSetCard(554) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dsummonfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not se:GetHandler():IsRitualSpell()
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.dsummonfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	Duel.BreakEffect()

	local pmg = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_MZONE+LOCATION_GRAVE, 0, nil)
	if not Duel.IsExistingMatchingCard(s.rsummonfilter, tp, LOCATION_HAND, 0, 1, nil, tp, pmg, e) then return end
	if not Duel.SelectYesNo(tp, aux.Stringid(id,1)) then return end

	local trmg = Duel.SelectMatchingCard(tp, s.rsummonfilter, tp, LOCATION_HAND, 0, 1, 1, nil, tp, pmg, e)
	local trmc = trmg:GetFirst()

	local mg = pmg:SelectWithSumEqual(tp, Card.Level, trmc:GetLevel(), 1, 99)
	
	Duel.SendtoHand(mg, tp, REASON_EFFECT)
	Duel.BreakEffect()
	Duel.SpecialSummon(trmc, SUMMON_TYPE_RITUAL, tp, tp, false, true, POS_FACEUP)
	trmc:CompleteProcedure()

	local c = e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end