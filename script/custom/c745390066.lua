-- BattleShip Escort Cruiser
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	-- Quick Banish
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
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
	-- Return
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.leave)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
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
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		if Duel.Remove(tc, POS_FACEUP, REASON_TEMPORARY) then 
			if c:IsRelateToEffect(e) then
				c:SetCardTarget(tc)
				e:GetLabelObject():SetLabelObject(tc)
				c:CreateRelation(tc,RESET_EVENT|RESET_OVERLAY|RESET_TOFIELD|RESET_TURN_SET)
				tc:CreateRelation(c,RESET_EVENT|RESETS_STANDARD|RESET_OVERLAY)
			end
		end
	end
end

function s.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and c:IsRelateToCard(tc) and tc:IsRelateToCard(c) then
		Duel.ReturnToField(tc)
	end
end
