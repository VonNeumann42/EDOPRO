-- Soul Spirit Guardian
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--Summon Rules:
	c:EnableReviveLimit()
	-- Return to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.protcon)
	e1:SetCost(s.protcost)
	e1:SetOperation(s.protop)
	c:RegisterEffect(e1)
	-- Protect from attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
end


-- e1 functions

function s.protcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp 
end

function s.protfilter(c,e)
	return c:IsAbleToHandAsCost() and not c == e:GetHandler()
end

function s.protcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.protfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	local th=Duel.SelectMatchingCard(tp, s.protfilter, tp, LOCATION_MZONE, 0, 1, 1,nil,e)
	Duel.SendtoHand(th, tp, REASON_COST)
end

function s.immunity()
	return true 
end

function s.protop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ei1=Effect.CreateEffect(c)
	ei1:SetType(EFFECT_TYPE_FIELD)
	ei1:SetCode(EFFECT_IMMUNE_EFFECT)
	ei1:SetTargetRange(LOCATION_ONFIELD,0)
	ei1:SetTarget(s.immunity)
	ei1:SetValue(s.efilter)
	ei1:SetLabelObject(re)
	ei1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(ei1,tp)
end

function s.efilter(e,re)
	return re==e:GetLabelObject()
end

-- e2 functions

function s.atlimit(e,c)
	return c:GetCode() ~= id
end