-- Oathbound Innkeeper
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	-- Excavate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end


-- e1 functions

function s.ctfilter(c)
	return c:IsSetCard(554) and not c:IsCode(id) and c:IsMonster()
end

function s.obfilter(c)
	return c:IsSetCard(554)
end

function s.ssfilter(c)
	return c:IsSetCard(555)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
end

function s.tdfilter(c)
	return c:IsSetCard(555) and c:IsAbleToDeck()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)+2
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return false end
		local g=Duel.GetDecktopGroup(tp,ct)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)+2
	Duel.ConfirmDecktop(tp,ct)
	local g=Duel.GetDecktopGroup(tp,ct)
	if #g>0 then
		local obg = g:Filter(s.obfilter, nil)
		if #obg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local obsg=obg:Select(tp, 1, 1, nil)
			Duel.DisableShuffleCheck()
			if obsg:GetFirst():IsAbleToHand() then
				Duel.SendtoHand(obsg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,obsg)
				Duel.ShuffleHand(tp)
			else
				Duel.SendtoGrave(obsg,REASON_RULE)
			end
		end

		local ssg = g:Filter(s.ssfilter, nil)
		if #ssg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sssg=ssg:Select(tp, 1, 1, nil)
			Duel.DisableShuffleCheck()
			if sssg:GetFirst():IsAbleToHand() then
				Duel.SendtoHand(sssg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sssg)
				Duel.ShuffleHand(tp)
			else
				Duel.SendtoGrave(sssg,REASON_RULE)
			end
		end
		
		if ct>1 then Duel.ShuffleDeck(tp) end
	end
end

-- e2 functions 

function s.filter(c)
	return true
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE+CATEGORY_TODECK, nil, 3, tp, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 3, nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end