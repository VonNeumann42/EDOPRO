-- BattleShip Escort Frigate
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	-- Quick Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCountLimit(1)
	e1:SetCondition(function (_,tp) return Duel.IsMainPhase() and Duel.IsTurnPlayer(1-tp) end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

end

s.listed_series={0x0227}

-- e1 functions

function s.tgfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0x0227)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_HAND+LOCATION_ONFIELD, 0, 1, c) end
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		local ei1=Effect.CreateEffect(c)
		ei1:SetType(EFFECT_TYPE_SINGLE)
		ei1:SetCode(EFFECT_DISABLE)
		ei1:SetCondition(s.rcon)
		ei1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ei1)
		local ei2=Effect.CreateEffect(c)
		ei2:SetType(EFFECT_TYPE_SINGLE)
		ei2:SetCode(EFFECT_CANNOT_ATTACK)
		ei2:SetCondition(s.rcon)
		ei2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ei2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local ei3=Effect.CreateEffect(c)
			ei3:SetType(EFFECT_TYPE_SINGLE)
			ei3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			ei3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			ei3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(ei3)
		end
	end
end

function s.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
