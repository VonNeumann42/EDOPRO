-- Dimming Light
-- Scripted by VonNeumann42

local s,id=GetID()
function s.initial_effect(c)
    --Ritual summon:
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Recycle on destruction:
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.reccon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end

s.listed_names={id-1}

-- e1 functions

function s.filter(c,e,tp)
	if c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) and c:GetLevel() <= 6 then
		return true
	end
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and 
		Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,nil)
	local tc=tg:GetFirst()
	tc:SetMaterial(nil)


	Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
	tc:CompleteProcedure()
	local dg=Duel.GetMatchingGroup(nil,1-tp,0,LOCATION_ONFIELD,tc)
	if #dg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=dg:Select(1-tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
	

	local ei1=Effect.CreateEffect(c)
	ei1:SetType(EFFECT_TYPE_FIELD)
	ei1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ei1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	ei1:SetTargetRange(1,0)
	ei1:SetTarget(s.splimit)
	ei1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ei1,tp)
	local ei2=Effect.CreateEffect(c)
	ei2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ei2:SetDescription(aux.Stringid(id,1))
	ei2:SetReset(RESET_PHASE+PHASE_END)
	ei2:SetTargetRange(1,0)
	Duel.RegisterEffect(ei2,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRitualMonster()
end

-- e2 functions

function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id-1),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.recfilter(c)
	return c:IsFaceup() and c:IsAbleToHand() and c:IsType(TYPE_PENDULUM)
end

function s.rectg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_EXTRA,0,1,nil) end
end

function s.recop(e, tp, eg, ep, ev, re, r, rp)
	local dg=Duel.GetMatchingGroup(s.recfilter, tp, LOCATION_EXTRA, 0, nil)
	if #dg>0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local sg=dg:Select(tp,1,2,nil)
		Duel.HintSelection(sg)
		Duel.SendtoHand(sg,tp,REASON_EFFECT)
	end
end
