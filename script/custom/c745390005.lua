-- Arcane Manifestation
-- Scripted by VonNeumann42

local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Summon Rules:
	c:EnableReviveLimit()
    -- Change Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.adcon)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRitualMonster))
	e1:SetValue(s.adval)
	c:RegisterEffect(e1)
	-- Protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetValue(s.value)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- Place in scale
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sctg)
	e3:SetOperation(s.scop)
	c:RegisterEffect(e3)
end

-- e1 functions

function s.adcon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.adfilter(c)
	return c:IsFaceup()
end

function s.adval(e,c)
	local g=Duel.GetMatchingGroup(s.adfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	tg,val=g:GetMaxGroup(Card.GetBaseAttack)
	return val
end

-- e2 functions

function s.value(e,c)
	return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD)
		and c:IsControler(e:GetHandlerPlayer())
end

function s.desfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) and 
		not c:IsReason(REASON_REPLACE) and c:IsControler(tp)
end

function s.shfilter(c)
	return c:IsRitualSpell() and c:IsAbleToDeck()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(s.desfilter,nil,tp)
		e:SetLabel(count)
		local tg=Duel.GetMatchingGroup(s.shfilter, tp, LOCATION_GRAVE, 0, nil)
		return count>0 and #tg >= count
	end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.shfilter,tp,LOCATION_GRAVE,0,count,count,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

-- e3 functions

function s.tscfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end

function s.fscfilter(c)
	return c:IsAbleToHand()
end

function s.sctg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetMatchingGroupCount(s.tscfilter,tp,LOCATION_EXTRA,0,nil) > 0 or Duel.GetMatchingGroupCount(s.fscfilter,tp,LOCATION_PZONE,0,nil) > 0
	end
end

function s.scop(e, tp, eg, ep, ev, re, r, rp)
	local g1=Duel.GetMatchingGroup(s.tscfilter,tp,LOCATION_EXTRA,0,nil)
	if #g1>0 and Duel.CheckPendulumZones(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg1=g1:Select(tp,1,1,nil)
		local sc1=sg1:GetFirst()
		Duel.MoveToField(sc1,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end

	local g2=Duel.GetMatchingGroup(s.fscfilter,tp,LOCATION_PZONE,0,nil)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg2=g2:Select(tp,1,1,nil)
		local sc2=sg2:GetFirst()
		Duel.SendtoHand(sc2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc2)
	end

end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end