-- Soul Spirit Judicator
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--Summon Rules:
	c:EnableReviveLimit()
	-- Return to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.remcost)
	e1:SetTarget(s.remtg)
	e1:SetOperation(s.remop)
	c:RegisterEffect(e1)
	-- Gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end


-- e1 functions

function s.remfilter(c,e)
	return c:IsAbleToHandAsCost() and not c == e:GetHandler()
end

function s.filter(c)
	return c:IsMonster()
end

function s.remcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.remfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	local th=Duel.SelectMatchingCard(tp, s.remfilter, tp, LOCATION_MZONE, 0, 1, 1, nil,e)
	Duel.SendtoHand(th, tp, REASON_COST)
end

function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,st)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- banish it if it leaves the field
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT+RESET_PHASE+PHASE_END)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)

		if Duel.IsBattlePhase() then
			Duel.Destroy(tc, REASON_EFFECT)
		end
	end
	
end

-- e2 functions

function s.atkfilter(c)
	return c:IsSetCard(554) and c:IsFaceup()
end

function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)
	return g:GetSum(Card.GetAttack)
end