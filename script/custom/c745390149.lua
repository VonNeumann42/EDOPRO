-- The Eyeless' Blinding Cloth
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,556))
	--Special on Search
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

-- e1 functions

function s.filter(c)
	return c:IsFaceup()
end

function s.atkcon(e)
	local tp = e:GetHandlerPlayer()
	local g = Duel.GetMatchingGroup(s.filter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	return #g == 1
end

-- e2 functions

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec and ec:IsLocation(LOCATION_MZONE) and ec:IsFacedown()
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then return c:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp) end
	Duel.SetOperationInfo(0, CATEGORY_DRAW, tp, 1, tp, 0)
end

function s.drop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		if Duel.SendtoDeck(c, tp, 2, REASON_EFFECT) then
			Duel.Draw(tp, 1, REASON_EFFECT)
		end
	end
end