-- Battleship! Void Shield
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.accon)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- Reset
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

s.listed_series={0x0227}

-- e1 functions

function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp 
end

function s.acfilter(c)
	return c:IsSetCard(0x0227)
end

function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local ei1=Effect.CreateEffect(c)
	ei1:SetType(EFFECT_TYPE_FIELD)
	ei1:SetCode(EFFECT_IMMUNE_EFFECT)
	ei1:SetTargetRange(LOCATION_ONFIELD,0)
	ei1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x0227))
	ei1:SetValue(s.efilter)
	ei1:SetLabelObject(re)
	ei1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(ei1,tp)
end

function s.efilter(e,re)
	return re==e:GetLabelObject()
end

-- e2 functions

function s.tdfilter(c)
	return c:IsSpell() and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToDeckAsCost()
end

function s.setcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, nil) end
	local g=Duel.GetMatchingGroup(s.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, nil)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
	Duel.SSet(tp, e:GetHandler())
end