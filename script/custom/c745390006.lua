-- Arcane Corruptor
-- Scripted by VonNeumann42

local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Summon Rules:
	c:EnableReviveLimit()
    --Summon on summon:
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.scon)
    e1:SetTarget(s.star)
	e1:SetOperation(s.sop)
	c:RegisterEffect(e1)
	--Place in scale:
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.pencon)
    e2:SetTarget(s.pentar)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	--Negate Faceup Card
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destar)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Change Scales:
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetTarget(s.sctar)
	e4:SetOperation(s.scop)
	c:RegisterEffect(e4)
end

-- e1 functions:

function s.sfilter(c,e,tp)
	return c:IsRitualMonster() and c:IsFaceup() and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end

function s.scon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.star(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if #g>0 then
		Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
	end
end

--e2 functions:

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.pentar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

-- e3 functions:

function s.desfilter(c)
	return c:IsRitualMonster()
end

function s.negfilter(c)
	return not c:IsDisabled() and c:IsFaceup()
end

function s.descon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(s.negfilter, tp, 0, LOCATION_ONFIELD, 1, nil)
end

function s.destar(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsRitualMonster() end
	if chk == 0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local dg=Duel.GetMatchingGroup(s.negfilter,tp,0,LOCATION_MZONE,nil)
		if #dg > 0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
			local sg=dg:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			Duel.HintSelection(sc)
			local ei1=Effect.CreateEffect(c)
			ei1:SetType(EFFECT_TYPE_SINGLE)
			ei1:SetCode(EFFECT_DISABLE)
			ei1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(ei1)
			local ei2=Effect.CreateEffect(c)
			ei2:SetType(EFFECT_TYPE_SINGLE)
			ei2:SetCode(EFFECT_DISABLE_EFFECT)
			ei2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(ei2)
		end
	end
end

-- e4 functions

function s.scfilter(c,scl)
	if (not c:HasLevel()) or c:IsPublic() then return false end
	return c:GetLevel() ~= scl
end

function s.sctar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_HAND,0,1,nil,e:GetHandler():GetLeftScale()) end
end

function s.scop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_HAND,0,1,1,nil,c:GetLeftScale())
	Duel.ConfirmCards(1-tp,g)
	local ei3=Effect.CreateEffect(c)
	ei3:SetType(EFFECT_TYPE_SINGLE)
	ei3:SetReset(RESET_EVENT+RESETS_STANDARD)
	ei3:SetRange(LOCATION_PZONE)
	ei3:SetCode(EFFECT_CHANGE_LSCALE)
	ei3:SetValue(g:GetFirst():GetLevel())
	ei3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(ei3)
	local ei4=ei3:Clone()
	ei4:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(ei4)
	Duel.ShuffleHand(tp)
end
