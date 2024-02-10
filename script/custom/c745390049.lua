-- Perpetual Core
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c, nil, 4, 2, nil, nil, 99)
	c:EnableReviveLimit()
	-- Search on End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetValue(aux.imval2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end

s.listed_series={0x0226}

function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsSetCard(0x0226,xyz,sumtype,tp)
end

-- e1 functions

function s.matchfilter(c,cc)
	return c:IsCode(cc)
end

function s.searchfilter(c,tp)
	return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.matchfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, c:GetCode())
end

function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.searchfilter, tp, LOCATION_DECK, 0, 1, nil, tp) end
	Duel.SetOperationInfo(0, CATEGORY_SEARCH, nil, 1, tp, 0)
	
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local sg = Duel.SelectMatchingCard(tp, s.searchfilter, tp, LOCATION_DECK, 0, 1, 1, nil, tp)
	Duel.SendtoHand(sg, tp, REASON_EFFECT)
end

-- e2 functions

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x0226) and not c:IsCode(id)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end