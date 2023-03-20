-- BattleShip Missile Battery
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Target and Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

s.listed_series={0x0227}

-- e2 functions

function s.filter(c)
	return c:IsDiscardable(REASON_EFFECT)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return true end

	if Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.IsExistingMatchingCard(s.filter, tp, 0, LOCATION_HAND, 1, nil) then
			if Duel.SelectYesNo(1-tp, aux.Stringid(id,0)) then
				Duel.DiscardHand(1-tp, s.filter, 1, 1, REASON_EFFECT, nil)
				Duel.Damage(1-tp, 600, REASON_EFFECT)
			else
				Duel.Destroy(tc,REASON_EFFECT)
			end
		else 
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else 
		Duel.Damage(1-tp, 600, REASON_EFFECT)
	end
end