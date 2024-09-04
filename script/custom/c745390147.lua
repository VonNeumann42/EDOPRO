-- Eyeless Revalation
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Recycle
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.retg)
	e2:SetOperation(s.reop)
	c:RegisterEffect(e2)
end

-- e1 functions

function s.filter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	local b1=s.sptg1(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.sptg2(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	if op==1 then
		e:SetProperty(0)
		e:SetOperation(s.spop1)
		s.sptg1(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.spop2)
		s.sptg2(e,tp,eg,ep,ev,re,r,rp,1)
	end
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.GetMatchingGroup(s.filter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	Duel.ChangePosition(g, POS_FACEUP_DEFENSE)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- Lock battle position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3313)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
	-- banish when leaving
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3300)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
	tc:RegisterEffect(e2,true)
end

-- e2 functions

function s.ssetfilter(c,rem_chk,set_chk, e, tp)
	if not c:IsSetCard(556) then return false end
	if c:IsMonster() then
		return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and rem_chk) or
			(Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsAbleToRemove() and set_chk)
	elseif c:IsSpellTrap() then
		return ((c:IsFieldSpell() or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and c:IsSSetable() and rem_chk) or
			(Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsAbleToRemove() and set_chk)
	end
end

function s.remfilter(c)
	return c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE)
end

function s.retg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return false end
	local c = e:GetHandler()
	local rem_chk = c:IsAbleToRemove()
	local set_chk = c:IsSSetable()
	if chk == 0 then return
		Duel.IsExistingMatchingCard(s.ssetfilter, tp, LOCATION_GRAVE, 0, 1, c, rem_chk, set_chk, e, tp)
	end
	local g=Duel.SelectMatchingCard(tp,s.ssetfilter,tp,LOCATION_GRAVE,0,1,1,c, rem_chk, set_chk,e,tp)
	Duel.SetTargetCard(g+c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_GRAVE)
end

function s.reop(e, tp, eg, ep, ev, re, r, rp)
	local tg = Duel.GetTargetCards(e)
	local rg = tg:Filter(s.remfilter, nil)
	if #rg <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id,2))
	local rc = rg:Select(tp, 1, 1, nil)
	if Duel.Remove(rc, POS_FACEDOWN, REASON_EFFECT) then 
		tg:RemoveCard(rc:GetFirst())
		if #tg <= 0 then return end
		local sc = tg:GetFirst()
		if sc:IsMonster() and sc:IsCanBeSpecialSummoned(e,0, tp, false, false, POS_FACEDOWN_DEFENSE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(sc, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
		end
		if sc:IsSpellTrap() and sc:IsSSetable() and (sc:IsFieldSpell() or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then
			Duel.SSet(tp, sc)
		end
	end
end