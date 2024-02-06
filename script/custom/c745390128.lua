-- Soul Spirit Summoning
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

function s.summonfilter(c,tp,pmg,e)
	local fs = Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsSetCard(555) and c:IsRitualMonster() and pmg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,fs-1) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, true)
end

function s.matfilter(c,e,tp)
	return c:IsSetCard(554) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.extragroup(e,tp)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not se:GetHandler():IsRitualSpell()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	local pmg = s.extragroup(e,tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.summonfilter, tp, LOCATION_HAND, 0, 1, nil, tp, pmg, e) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_GRAVE)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
	local pmg = s.extragroup(e,tp)
	local fs = Duel.GetLocationCount(tp,LOCATION_MZONE)
	local psg = Duel.GetMatchingGroup(s.summonfilter, tp, LOCATION_HAND, 0, nil, tp, pmg, e)
	if #psg == 0 then return end
	local sg = psg:Select(tp, 1, 1, nil)
	local sc = sg:GetFirst()
	local mg = pmg:SelectWithSumEqual(tp, Card.Level, sc:GetLevel(), 1, fs-1)
	
	Duel.SpecialSummon(mg, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
	Duel.BreakEffect()
	Duel.SpecialSummon(sc, SUMMON_TYPE_RITUAL, tp, tp, false, true, POS_FACEUP)
	sc:CompleteProcedure()

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